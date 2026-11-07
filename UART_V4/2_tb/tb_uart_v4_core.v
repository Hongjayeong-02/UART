`timescale 1ns/1ps
// Self-checking TB for uart_v4_core + uart_v4_cfg_cdc (PCLK != UART_CLK).
//   C1 loopback 8N1, 40 random bytes, TX FIFO back-pressure
//   C2 7E2 on an external wire (TX pin -> RX pin), 30 bytes
//   C3 8O1, slower baud, 20 bytes
//   C4 RX overflow: 16 + 5 bytes, no read -> 5 overflow pulses, first 16 kept
//   C5 injected frames: bad parity -> entry bit8, bad stop -> entry bit9,
//      stop low for 1.5 bits (short break) -> one entry, next frame intact
//   C6 txEn = 0: bytes stay in the TX FIFO, line stays high, sent after txEn = 1
//   C7 config written while a frame is on the line: old frame keeps old format,
//      next frames use the new one
//   C8 config written while only RX is busy (TX idle): applied after the frame
//   C9 txEn cleared while bytes are queued: frame in flight finishes, the rest
//      stay in the TX FIFO (none lost), sent after txEn = 1
//   Always-on checkers: config commit only when idle (TX/RX not busy),
//   received entry == expected (data, parity flag, frame flag), no extra entry.
// Options: +PHALF=<ns> +UHALF=<ns> +SEED=<n>
module tb_uart_v4_core;

localparam AW = 4;
localparam D  = 1 << AW;

reg             r_pclk, r_uclk, r_prst_n, r_urst_n;
real            r_pHalf, r_uHalf;
integer         r_seed, r_seed0, r_errCnt, r_commits, r_c0;

// cfg_cdc
reg             r_cfgWr;
reg     [23:0]  r_cfgWrData;
wire            w_cfgBusy, w_cfgWrErr, w_cfgCommit, w_applyPulse;
wire    [23:0]  w_swCfg, w_act;

// core
reg             r_txWr;
reg     [7:0]   r_txData;
wire            w_txFull;
reg             r_rxRd;
wire    [9:0]   w_rxRdData;
wire            w_rxEmpty;
wire            w_uIdle, w_uartTx, w_txBusy, w_rxBusy, w_txDone, w_rxValid;
wire            w_parityErr, w_frameErr, w_falseStart, w_rxOverflow;

// line: TX pin -> RX pin, TB can take over for injection
reg             r_inj, r_injLvl;
wire            w_line = r_inj ? r_injLvl : w_uartTx;

// cfg layout: {loopback, stop2, parity[1:0], data7, rxEn, txEn, enable, baudDiv[15:0]}
function [23:0] cfg;
        input lb, s2; input [1:0] par; input d7, rxe, txe, en; input [15:0] div;
        cfg = {lb, s2, par, d7, rxe, txe, en, div};
endfunction

uart_v4_cfg_cdc #(.CW(24)) u_cfg (
        .i_pclk(r_pclk), .i_prst_n(r_prst_n),
        .i_cfgWr(r_cfgWr), .i_cfgWrData(r_cfgWrData),
        .o_cfgBusy(w_cfgBusy), .o_cfgWrErr(w_cfgWrErr), .o_swCfg(w_swCfg),
        .i_uclk(r_uclk), .i_urst_n(r_urst_n), .i_uIdle(w_uIdle),
        .o_activeCfg(w_act), .o_cfgCommit(w_cfgCommit), .o_applyPulse(w_applyPulse));

uart_v4_core #(.AW(AW)) u_dut (
        .i_pclk(r_pclk), .i_prst_n(r_prst_n),
        .i_txWr(r_txWr), .i_txData(r_txData), .o_txFull(w_txFull),
        .i_rxRd(r_rxRd), .o_rxRdData(w_rxRdData), .o_rxEmpty(w_rxEmpty),
        .i_uclk(r_uclk), .i_urst_n(r_urst_n),
        .i_enable(w_act[16]), .i_txEn(w_act[17]), .i_rxEn(w_act[18]), .i_baudDiv(w_act[15:0]),
        .i_data7(w_act[19]), .i_parityMode(w_act[21:20]), .i_stop2(w_act[22]), .i_loopbackEn(w_act[23]),
        .i_cfgCommit(w_cfgCommit), .o_uIdle(w_uIdle),
        .i_uartRx(w_line), .o_uartTx(w_uartTx),
        .o_txBusy(w_txBusy), .o_rxBusy(w_rxBusy), .o_txDone(w_txDone), .o_rxValid(w_rxValid),
        .o_parityErr(w_parityErr), .o_frameErr(w_frameErr), .o_falseStart(w_falseStart),
        .o_rxOverflow(w_rxOverflow));

initial begin
        r_pHalf = 5.0; r_uHalf = 7.3; r_seed = 1;
        if ($value$plusargs("PHALF=%f", r_pHalf)) ;
        if ($value$plusargs("UHALF=%f", r_uHalf)) ;
        if ($value$plusargs("SEED=%d",  r_seed))  ;
        r_seed0 = r_seed;
end
initial begin r_pclk = 0; #0.2;  forever #(r_pHalf) r_pclk = ~r_pclk; end
initial begin r_uclk = 0; #0.57; forever #(r_uHalf) r_uclk = ~r_uclk; end

task check;
        input cond; input [8*64-1:0] msg;
        begin
                if (cond) $display("PASS: %0s", msg);
                else begin $display("FAIL: %0s", msg); r_errCnt = r_errCnt + 1; end
        end
endtask

// ---------------- scoreboard (expected RX entries) ----------------
reg     [9:0]   r_exp [0:1023];
integer         r_expWr, r_expRd, r_got, r_ovf;
reg             r_autoRd;

task expect_entry;
        input [9:0] e;
        begin r_exp[r_expWr % 1024] = e; r_expWr = r_expWr + 1; end
endtask

// PCLK reader: show-ahead data is valid while !empty, pop with rxRd
always @(posedge r_pclk) begin
        r_rxRd <= 1'b0;
        if (r_prst_n && r_autoRd && !w_rxEmpty && !r_rxRd) begin
                r_rxRd <= 1'b1;
                if (r_expRd >= r_expWr) begin
                        $display("FAIL: extra RX entry %h @%0t", w_rxRdData, $time); r_errCnt = r_errCnt + 1;
                end else if (w_rxRdData !== r_exp[r_expRd % 1024]) begin
                        $display("FAIL: RX entry #%0d got %h exp %h @%0t", r_expRd, w_rxRdData,
                                 r_exp[r_expRd % 1024], $time); r_errCnt = r_errCnt + 1;
                        r_expRd = r_expRd + 1;
                end else r_expRd = r_expRd + 1;
                r_got = r_got + 1;
        end
end

// ---------------- always-on UCLK checkers ----------------
always @(posedge r_uclk) if (r_urst_n) begin
        if (w_cfgCommit && (w_txBusy || w_rxBusy || !w_uIdle)) begin
                $display("FAIL: config commit while busy @%0t", $time); r_errCnt = r_errCnt + 1;
        end
        if (w_rxOverflow) r_ovf = r_ovf + 1;
        if (w_cfgCommit)  r_commits = r_commits + 1;
end

// ---------------- drivers ----------------
task cfg_write;                         // PCLK write, wait until applied in UCLK
        input [23:0] c; input wait_apply;
        begin
                @(negedge r_pclk); while (w_cfgBusy) @(negedge r_pclk);
                r_cfgWr = 1; r_cfgWrData = c;
                @(negedge r_pclk); r_cfgWr = 0;
                if (wait_apply) begin
                        @(posedge r_pclk); while (w_cfgBusy) @(posedge r_pclk);
                        repeat (2) @(posedge r_uclk);
                end
        end
endtask

task tx_byte;                           // PCLK write with back-pressure
        input [7:0] b;
        begin
                @(negedge r_pclk); while (w_txFull) @(negedge r_pclk);
                r_txWr = 1; r_txData = b;
                @(negedge r_pclk); r_txWr = 0;
        end
endtask

task drain;                             // wait until everything sent and read
        integer t;
        begin
                t = 0;
                while ((r_expRd < r_expWr || !w_uIdle || !u_dut.w_txFifoEmpty) && t < 2000000) begin
                        @(posedge r_uclk); t = t + 1;
                end
                repeat (40) @(posedge r_uclk);
        end
endtask

// TB-driven frame on the line (bit time = 16 * (div + 1) UART_CLK cycles)
task inj_frame;
        input [7:0] d; input d7; input [1:0] par; input badPar; input [1:0] badStop; input [15:0] div;
        // badStop: 0 = good stop, 1 = stop bit low for 1 bit, 2 = low for 1.5 bits (short break)
        integer i, n; reg p;
        begin
                n = d7 ? 7 : 8;
                p = (par == 2'b10);                     // odd seed 1, even seed 0
                for (i = 0; i < n; i = i + 1) p = p ^ d[i];
                @(negedge r_uclk); r_inj = 1; r_injLvl = 0;    // drive on negedge: no race with RX sampling
                repeat (16 * (div + 1)) @(negedge r_uclk);
                for (i = 0; i < n; i = i + 1) begin
                        r_injLvl = d[i]; repeat (16 * (div + 1)) @(negedge r_uclk);
                end
                if (par != 2'b00) begin
                        r_injLvl = p ^ badPar; repeat (16 * (div + 1)) @(negedge r_uclk);
                end
                r_injLvl = (badStop == 0);
                repeat ((badStop == 2) ? 24 * (div + 1) : 16 * (div + 1)) @(negedge r_uclk);
                r_injLvl = 1; repeat (3 * 16 * (div + 1)) @(negedge r_uclk);
                r_inj = 0;
        end
endtask

integer i, k, t, r_e0, r_o0, r_lowCnt;
reg [7:0] b;

initial begin
        r_errCnt = 0; r_commits = 0; r_expWr = 0; r_expRd = 0; r_got = 0; r_ovf = 0; r_autoRd = 1;
        r_cfgWr = 0; r_cfgWrData = 0; r_txWr = 0; r_txData = 0; r_rxRd = 0;
        r_inj = 0; r_injLvl = 1;
        r_prst_n = 0; r_urst_n = 0;
        #53 r_prst_n = 1; #17 r_urst_n = 1;
        repeat (4) @(posedge r_pclk);

        // ---------------- C1 ----------------
        cfg_write(cfg(1, 0, 2'b00, 0, 1, 1, 1, 16'd1), 1);
        r_e0 = r_expRd;
        for (i = 0; i < 40; i = i + 1) begin
                b = $random(r_seed); expect_entry({2'b00, b}); tx_byte(b);
        end
        drain;
        check(r_expRd - r_e0 == 40 && r_expRd == r_expWr, "C1 loopback 8N1: 40/40 bytes in order");

        // ---------------- C2 ----------------
        cfg_write(cfg(0, 1, 2'b01, 1, 1, 1, 1, 16'd2), 1);
        check(w_act[19] && w_act[22] && w_act[21:20] == 2'b01, "C2 config 7E2 applied");
        r_e0 = r_expRd;
        for (i = 0; i < 30; i = i + 1) begin
                b = $random(r_seed); expect_entry({3'b000, b[6:0]}); tx_byte(b);
        end
        drain;
        check(r_expRd - r_e0 == 30 && r_expRd == r_expWr, "C2 external wire 7E2: 30/30, bit7 = 0");

        // ---------------- C3 ----------------
        cfg_write(cfg(0, 0, 2'b10, 0, 1, 1, 1, 16'd5), 1);
        r_e0 = r_expRd;
        for (i = 0; i < 20; i = i + 1) begin
                b = $random(r_seed); expect_entry({2'b00, b}); tx_byte(b);
        end
        drain;
        check(r_expRd - r_e0 == 20 && r_expRd == r_expWr, "C3 8O1 div=5: 20/20");

        // ---------------- C4 ----------------
        cfg_write(cfg(1, 0, 2'b00, 0, 1, 1, 1, 16'd1), 1);
        r_autoRd = 0; r_o0 = r_ovf; r_e0 = r_expRd;
        for (i = 0; i < D + 5; i = i + 1) begin
                b = 8'hA0 + i;
                if (i < D) expect_entry({2'b00, b});
                tx_byte(b);
        end
        t = 0;
        while ((!w_uIdle || !u_dut.w_txFifoEmpty) && t < 2000000) begin @(posedge r_uclk); t = t + 1; end
        repeat (40) @(posedge r_uclk);
        check(r_ovf - r_o0 == 5, "C4 RX overflow: 5 pulses for 5 extra bytes");
        r_autoRd = 1; drain;
        check(r_expRd - r_e0 == D && r_expRd == r_expWr, "C4 first 16 bytes kept, extra dropped");

        // ---------------- C5 ----------------
        cfg_write(cfg(0, 0, 2'b01, 0, 1, 1, 1, 16'd2), 1);
        r_e0 = r_expRd;
        expect_entry({2'b00, 8'h3C}); inj_frame(8'h3C, 0, 2'b01, 0, 0, 16'd2);
        expect_entry({2'b01, 8'h5A}); inj_frame(8'h5A, 0, 2'b01, 1, 0, 16'd2);
        expect_entry({2'b10, 8'hC3}); inj_frame(8'hC3, 0, 2'b01, 0, 1, 16'd2);
        expect_entry({2'b00, 8'h81}); inj_frame(8'h81, 0, 2'b01, 0, 0, 16'd2);
        expect_entry({2'b10, 8'h96}); inj_frame(8'h96, 0, 2'b01, 0, 2, 16'd2);   // short break
        expect_entry({2'b00, 8'h42}); inj_frame(8'h42, 0, 2'b01, 0, 0, 16'd2);
        drain;
        check(r_expRd - r_e0 == 6 && r_expRd == r_expWr, "C5 good / bad parity / bad stop / good / short break / good");

        // ---------------- C6 ----------------
        cfg_write(cfg(0, 0, 2'b00, 0, 1, 0, 1, 16'd1), 1);
        r_e0 = r_expRd;
        for (i = 0; i < 6; i = i + 1) begin b = 8'h10 + i; expect_entry({2'b00, b}); tx_byte(b); end
        r_lowCnt = 0;
        for (t = 0; t < 2000; t = t + 1) begin @(posedge r_uclk); if (!w_uartTx || w_txBusy) r_lowCnt = r_lowCnt + 1; end
        check(r_lowCnt == 0 && r_expRd == r_e0, "C6 txEn=0: line high, nothing sent");
        cfg_write(cfg(0, 0, 2'b00, 0, 1, 1, 1, 16'd1), 1);
        drain;
        check(r_expRd - r_e0 == 6 && r_expRd == r_expWr, "C6 txEn=1: 6 held bytes sent");

        // ---------------- C7 ----------------
        r_e0 = r_expRd;
        expect_entry({2'b00, 8'hE7}); tx_byte(8'hE7);           // old: 8N1
        @(posedge r_uclk); while (!w_txBusy) @(posedge r_uclk);
        cfg_write(cfg(0, 1, 2'b10, 1, 1, 1, 1, 16'd1), 0);       // new: 7O2, during the frame
        check(w_txBusy && w_cfgBusy, "C7 config write accepted while frame on the line (pending)");
        for (i = 0; i < 8; i = i + 1) begin
                b = $random(r_seed); expect_entry({3'b000, b[6:0]}); tx_byte(b);
        end
        drain;
        check(r_expRd - r_e0 == 9 && r_expRd == r_expWr, "C7 frame in flight old format, next 8 new format");

        // ---------------- C8 ----------------
        cfg_write(cfg(0, 0, 2'b00, 0, 1, 1, 1, 16'd2), 1);
        r_e0 = r_expRd; r_c0 = r_commits;
        expect_entry({2'b00, 8'h6B});
        fork
                inj_frame(8'h6B, 0, 2'b00, 0, 0, 16'd2);
                begin
                        @(posedge r_uclk); while (!w_rxBusy) @(posedge r_uclk);
                        repeat (40) @(posedge r_uclk);
                        cfg_write(cfg(0, 0, 2'b01, 0, 1, 1, 1, 16'd2), 0);
                        repeat (8) @(posedge r_uclk);
                        check(w_rxBusy && r_commits == r_c0, "C8 config pending while RX busy (not applied)");
                end
        join
        drain;
        check(r_commits == r_c0 + 1 && w_act[21:20] == 2'b01, "C8 applied after RX frame");
        check(r_expRd - r_e0 == 1 && r_expRd == r_expWr, "C8 frame received with old format");

        // ---------------- C9 ----------------
        cfg_write(cfg(1, 0, 2'b00, 0, 1, 1, 1, 16'd1), 1);
        r_e0 = r_expRd;
        for (i = 0; i < 6; i = i + 1) begin b = 8'h50 + i; expect_entry({2'b00, b}); tx_byte(b); end
        @(posedge r_uclk); while (!w_txBusy) @(posedge r_uclk);
        cfg_write(cfg(1, 0, 2'b00, 0, 1, 0, 1, 16'd1), 1);      // txEn = 0 while busy
        repeat (2000) @(posedge r_uclk);
        check(r_expRd - r_e0 == 1, "C9 txEn=0 while busy: only the frame in flight sent");
        cfg_write(cfg(1, 0, 2'b00, 0, 1, 1, 1, 16'd1), 1);
        drain;
        check(r_expRd - r_e0 == 6 && r_expRd == r_expWr, "C9 txEn=1: remaining 5 sent, none lost");

        if (r_errCnt == 0)
                $display("CORE ALL PASS  rxEntries=%0d overflow=%0d pHalf=%0.2f uHalf=%0.2f seed=%0d",
                         r_got, r_ovf, r_pHalf, r_uHalf, r_seed0);
        else
                $display("CORE FAIL  errors=%0d", r_errCnt);
        $finish;
end

initial begin #200_000_000; $display("CORE FAIL  timeout"); $finish; end

endmodule
