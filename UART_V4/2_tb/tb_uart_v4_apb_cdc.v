`timescale 1ns/1ps
// V4-only APB tests (things the V3 regression cannot see).
//   P1 BAUDDIV write keeps CTRL fields (24-bit config merge)
//   P2 CTRL then BAUDDIV with no poll: PSLVERR=1 exactly when the value was
//      not taken (refusal depends on the clock ratio; forced in P6)
//   P3 TX_BUSY = "TX not finished": 1 right after TXDATA write, 0 only after
//      the byte is back in the RX FIFO (loopback)
//   P4 TX empty IRQ only while txEn=1
//   P5 FIFO_LEVEL TX counts queued bytes, returns to 0
//   P6 UART_CLK stopped: config write still completes (PREADY), CFG_BUSY stays
//      1, next config write refused; after UART_CLK restarts CFG_BUSY clears
//      and the new config is used
//   P7 reset with data in both FIFOs and a config request pending: after reset
//      all levels 0, CTRL/BAUDDIV reset values, no stale RX entry, line idle
//   P8 reset asserted and released while UART_CLK is stopped: APB works, the
//      UART_CLK side stays in reset until its clock runs, then a config write
//      and a byte go through
//   P9 41 bytes one by one (TX_BUSY poll each): push / done counters wrap
//      (AW+1 = 5 bits) and TX_BUSY still ends at 0 every time
//   P10 SETUP/ACCESS boundary (D24): CFG_BUSY is 1 at the edge that ends SETUP
//      and 0 during ACCESS. The write is still refused (decided in SETUP),
//      PSLVERR=1, and the register keeps the value accepted before
// APB sampling: PREADY / PRDATA / PSLVERR read mid-cycle before the completing edge.
// Options: +PHALF=<ns> +UHALF=<ns>
module tb_uart_v4_apb_cdc;

localparam ADDR_TXDATA = 8'h00, ADDR_RXDATA = 8'h04, ADDR_STATUS = 8'h08, ADDR_CTRL = 8'h0C,
           ADDR_BAUDDIV = 8'h10, ADDR_IRQ_EN = 8'h14, ADDR_IRQ_STATUS = 8'h18, ADDR_FIFO_LEVEL = 8'h1C;

reg             r_pclk, r_uclkRun, r_uclkGate, r_rst_n;
reg             r_psel, r_penable, r_pwrite;
reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;
wire    [31:0]  w_prdata;
wire            w_pready, w_pslverr, w_uartTx, w_irq;
wire            w_uclk = r_uclkRun & r_uclkGate;

real            r_pHalf, r_uHalf;
integer         r_errCnt, r_i, r_t, r_bad;
reg     [31:0]  r_rd;
reg             r_err;
reg             r_sawBusy;

`ifdef GLS
uart_v4_apb uut (
`else
uart_v4_apb #(.FIFO_AW(4)) uut (
`endif
        .i_pclk(r_pclk), .i_uclk(w_uclk), .rst_n(r_rst_n),
        .i_psel(r_psel), .i_penable(r_penable), .i_pwrite(r_pwrite),
        .i_paddr(r_paddr), .i_pwdata(r_pwdata),
        .o_prdata(w_prdata), .o_pready(w_pready), .o_pslverr(w_pslverr),
        .i_uartRx(1'b1), .o_uartTx(w_uartTx), .o_irq(w_irq));

initial begin
        r_pHalf = 5.0; r_uHalf = 7.3;
        if ($value$plusargs("PHALF=%f", r_pHalf)) ;
        if ($value$plusargs("UHALF=%f", r_uHalf)) ;
end
initial begin r_pclk = 0; #0.2; forever #(r_pHalf) r_pclk = ~r_pclk; end
initial begin r_uclkRun = 0; #0.61; forever #(r_uHalf) r_uclkRun = ~r_uclkRun; end

task check;
        input cond; input [8*64-1:0] msg;
        begin
                if (cond) $display("PASS: %0s", msg);
                else begin $display("FAIL: %0s", msg); r_errCnt = r_errCnt + 1; end
        end
endtask

task apb;                               // one transfer, returns data and PSLVERR
        input wr; input [7:0] a; input [31:0] d; output [31:0] q; output e;
        begin
                @(negedge r_pclk);
                r_psel = 1; r_penable = 0; r_pwrite = wr; r_paddr = a; r_pwdata = d;
                @(negedge r_pclk);
                r_penable = 1;
                #0.01;
                while (!w_pready) begin @(negedge r_pclk); #0.01; end
                q = w_prdata; e = w_pslverr;    // values the completing edge samples
                @(posedge r_pclk);
                @(negedge r_pclk);
                r_psel = 0; r_penable = 0; r_pwrite = 0; r_paddr = 0; r_pwdata = 0;
        end
endtask

task wr; input [7:0] a; input [31:0] d; begin apb(1, a, d, r_rd, r_err); end endtask
task rd; input [7:0] a; begin apb(0, a, 0, r_rd, r_err); end endtask

task cfg_wait;                          // poll CFG_BUSY = 0
        begin
                rd(ADDR_STATUS);
                r_t = 0;
                while (r_rd[9] && r_t < 100000) begin rd(ADDR_STATUS); r_t = r_t + 1; end
        end
endtask

initial begin
        r_errCnt = 0; r_uclkGate = 1;
        r_psel = 0; r_penable = 0; r_pwrite = 0; r_paddr = 0; r_pwdata = 0;
        r_rst_n = 0; #100 r_rst_n = 1;
        repeat (10) @(posedge r_pclk);

        // ---------------- P1 ----------------
        wr(ADDR_CTRL, 32'h87); cfg_wait;                // loopback, 8N1, en/tx/rx
        wr(ADDR_BAUDDIV, 32'd1); cfg_wait;
        rd(ADDR_CTRL);
        check(r_rd[7:0] == 8'h87, "P1 CTRL kept after BAUDDIV write");
`ifndef GLS   // RTL-internal signal
        check(uut.w_actCfg[23:16] == 8'h87 && uut.w_actCfg[15:0] == 16'd1, "P1 UART_CLK side: loopback/en/tx/rx kept, div=1");
`endif

        // ---------------- P2 ----------------
        // Back-to-back config writes. Whether the 2nd one is refused depends on
        // the clock ratio (slow PCLK: the handshake is already done). Either
        // way PSLVERR must tell the truth. The refusal itself is checked
        // deterministically in P6 (UART_CLK stopped).
        wr(ADDR_CTRL, 32'h87);
        wr(ADDR_BAUDDIV, 32'd3);
        r_sawBusy = r_err;
        cfg_wait;
        rd(ADDR_BAUDDIV);
        check(( r_sawBusy && r_rd[15:0] == 16'd1) ||
              (!r_sawBusy && r_rd[15:0] == 16'd3), "P2 back-to-back: PSLVERR=1 <-> value unchanged");
        $display("INFO: P2 2nd write %0s at this ratio", r_sawBusy ? "refused" : "accepted");
        wr(ADDR_BAUDDIV, 32'd3);
        check(r_err == 1'b0, "P2 write accepted after CFG_BUSY=0");
        cfg_wait;

        // ---------------- P3 ----------------
        wr(ADDR_TXDATA, 32'h5A);
        rd(ADDR_STATUS);
        check(r_rd[4] == 1'b1, "P3 TX_BUSY=1 right after TXDATA write (TX_EMPTY may already be 1)");
        r_t = 0;
        rd(ADDR_STATUS);
        while (r_rd[4] && r_t < 100000) begin rd(ADDR_STATUS); r_t = r_t + 1; end
        repeat (8) @(posedge r_pclk);
        rd(ADDR_FIFO_LEVEL);
        check(r_rd[15:8] == 8'd1, "P3 TX_BUSY=0 only after the byte is in the RX FIFO");
        rd(ADDR_RXDATA);
        check(r_rd[9:0] == 10'h05A, "P3 loopback byte");

        // ---------------- P4 ----------------
        wr(ADDR_IRQ_EN, 32'h02);
        wr(ADDR_CTRL, 32'h85); cfg_wait;                // txEn = 0
        repeat (10) @(posedge r_pclk);
        check(w_irq == 1'b0, "P4 TX empty IRQ off while txEn=0");
        wr(ADDR_CTRL, 32'h87); cfg_wait;                // txEn = 1
        repeat (10) @(posedge r_pclk);
        check(w_irq == 1'b1, "P4 TX empty IRQ on while txEn=1 and FIFO empty");
        wr(ADDR_IRQ_EN, 32'h00);

        // ---------------- P5 ----------------
        wr(ADDR_BAUDDIV, 32'd20); cfg_wait;             // slow baud: bytes stay queued
        for (r_i = 0; r_i < 5; r_i = r_i + 1) wr(ADDR_TXDATA, 32'h30 + r_i);
        rd(ADDR_FIFO_LEVEL);
        check(r_rd[7:0] >= 8'd4 && r_rd[7:0] <= 8'd5, "P5 FIFO_LEVEL TX = 4..5 queued");
        rd(ADDR_STATUS);
        r_t = 0;
        while (r_rd[4] && r_t < 200000) begin rd(ADDR_STATUS); r_t = r_t + 1; end
        repeat (8) @(posedge r_pclk);
        rd(ADDR_FIFO_LEVEL);
        check(r_rd[7:0] == 8'd0 && r_rd[15:8] == 8'd5, "P5 TX level 0, RX level 5 after send");
        for (r_i = 0; r_i < 5; r_i = r_i + 1) rd(ADDR_RXDATA);

        // ---------------- P6 ----------------
        wr(ADDR_BAUDDIV, 32'd1); cfg_wait;
        @(negedge r_uclkRun); r_uclkGate = 0;           // stop UART_CLK
        r_t = $time;
        wr(ADDR_CTRL, 32'hF7);                          // 7O2 loopback
        check(r_err == 1'b0, "P6 config write completes with UART_CLK stopped");
        repeat (200) @(posedge r_pclk);
        rd(ADDR_STATUS);
        check(r_rd[9] == 1'b1, "P6 CFG_BUSY stays 1 while UART_CLK is stopped");
        wr(ADDR_BAUDDIV, 32'd2);
        check(r_err == 1'b1, "P6 next config write refused (PSLVERR=1)");
        rd(ADDR_STATUS);
        check(r_err == 1'b0, "P6 STATUS read still works (APB never waits for UART_CLK)");
        @(negedge r_uclkRun); r_uclkGate = 1;              // restart
        cfg_wait;
        check(r_rd[9] == 1'b0, "P6 CFG_BUSY clears after UART_CLK restarts");
        wr(ADDR_TXDATA, 32'hC5);
        rd(ADDR_STATUS);
        r_t = 0;
        while (r_rd[4] && r_t < 100000) begin rd(ADDR_STATUS); r_t = r_t + 1; end
        repeat (8) @(posedge r_pclk);
        rd(ADDR_RXDATA);
        check(r_rd[9:0] == 10'h045, "P6 new config (7-bit) used: 0xC5 -> 0x45");

        // ---------------- P7 ----------------
        wr(ADDR_CTRL, 32'h87); cfg_wait;
        wr(ADDR_BAUDDIV, 32'd20); cfg_wait;
        for (r_i = 0; r_i < 3; r_i = r_i + 1) wr(ADDR_TXDATA, 32'h60 + r_i);
        r_t = 0; rd(ADDR_FIFO_LEVEL);
        while (r_rd[15:8] == 0 && r_t < 100000) begin rd(ADDR_FIFO_LEVEL); r_t = r_t + 1; end
        wr(ADDR_CTRL, 32'hF7);                          // pending (TX busy) when reset hits
        @(negedge r_pclk); r_rst_n = 0;
        repeat (3) @(posedge r_pclk);
        @(negedge r_pclk); r_rst_n = 1;
        repeat (10) @(posedge r_pclk);
        rd(ADDR_FIFO_LEVEL);
        check(r_rd[15:0] == 16'h0000, "P7 FIFO_LEVEL 0/0 after reset with data inside");
        rd(ADDR_STATUS);
        check(r_rd[9:0] == 10'h005, "P7 STATUS = TX empty + RX empty only");
        rd(ADDR_CTRL);
        check(r_rd[7:0] == 8'h00, "P7 CTRL reset value (pending config dropped)");
        rd(ADDR_BAUDDIV);
        check(r_rd[15:0] == 16'd325, "P7 BAUDDIV reset value");
        repeat (3000) @(posedge r_pclk);
        rd(ADDR_FIFO_LEVEL);
        check(r_rd[15:8] == 8'd0 && w_uartTx == 1'b1, "P7 no stale byte appears later, TX line idle");
`ifndef GLS   // RTL-internal signal
        check(uut.w_actCfg == {8'h00, 16'd325}, "P7 UART_CLK side config = reset value");
`endif

        // ---------------- P8 ----------------
        @(negedge r_uclkRun); r_uclkGate = 0;
        @(negedge r_pclk); r_rst_n = 0;
        repeat (3) @(posedge r_pclk);
        @(negedge r_pclk); r_rst_n = 1;
        repeat (10) @(posedge r_pclk);
        rd(ADDR_STATUS);
        check(r_err == 1'b0 && r_rd[9:0] == 10'h005, "P8 APB works after reset with UART_CLK stopped");
`ifndef GLS   // RTL-internal signal
        check(uut.w_urst_n == 1'b0, "P8 UART_CLK domain still in reset (no clock)");
`endif
        wr(ADDR_BAUDDIV, 32'd1);
        check(r_err == 1'b0, "P8 config write accepted (crosses when UART_CLK runs)");
        repeat (50) @(posedge r_pclk);
        @(negedge r_uclkRun); r_uclkGate = 1;
        cfg_wait;
        wr(ADDR_CTRL, 32'h87); cfg_wait;
        wr(ADDR_TXDATA, 32'h9C);
        r_t = 0; rd(ADDR_STATUS);
        while (r_rd[4] && r_t < 100000) begin rd(ADDR_STATUS); r_t = r_t + 1; end
        repeat (8) @(posedge r_pclk);
        rd(ADDR_RXDATA);
        check(r_rd[9:0] == 10'h09C, "P8 after UART_CLK starts: config applied, byte looped back");

        // ---------------- P9 ----------------
        r_bad = 0;
        for (r_i = 0; r_i < 41; r_i = r_i + 1) begin
                wr(ADDR_TXDATA, r_i * 7);
                r_t = 0; rd(ADDR_STATUS);
                while (r_rd[4] && r_t < 100000) begin rd(ADDR_STATUS); r_t = r_t + 1; end
                repeat (8) @(posedge r_pclk);
                rd(ADDR_RXDATA);
                if (r_rd[9:0] != ((r_i * 7) & 8'hFF) || r_t >= 100000) r_bad = r_bad + 1;
        end
        rd(ADDR_STATUS);
        check(r_bad == 0 && r_rd[4] == 1'b0, "P9 41 bytes: counters wrapped, TX_BUSY 0 after each, data ok");

`ifndef GLS   // P10 needs u_cfg internal toggles (RTL only)
        // ---------------- P10 ----------------
        // Find the PCLK cycle in which ackSync1 already matches reqTog but
        // ackSync2 does not: CFG_BUSY clears at the next rising edge. Start
        // SETUP in exactly that cycle, so the SETUP-ending edge sees BUSY=1
        // and ACCESS sees BUSY=0.
        wr(ADDR_CTRL, 32'h87); cfg_wait;
        wr(ADDR_BAUDDIV, 32'd1); cfg_wait;
        wr(ADDR_BAUDDIV, 32'd2);                        // accepted, CFG_BUSY = 1
        check(r_err == 1'b0, "P10 first BAUDDIV write (2) accepted");
        r_t = 0;
        @(negedge r_pclk);
        while (!(uut.u_cfg.r_ackSync1 == uut.u_cfg.r_reqTog &&
                 uut.u_cfg.r_ackSync2 != uut.u_cfg.r_reqTog) && r_t < 100000) begin
                @(negedge r_pclk); r_t = r_t + 1;
        end
        check(r_t < 100000, "P10 found the cycle before CFG_BUSY clears");
        r_psel = 1; r_penable = 0; r_pwrite = 1; r_paddr = ADDR_BAUDDIV; r_pwdata = 32'd5;
        @(negedge r_pclk);                              // SETUP-ending edge saw BUSY=1
        r_penable = 1;
        #0.01;
        r_sawBusy = uut.w_cfgBusy;
        check(w_pready == 1'b1 && w_pslverr == 1'b1, "P10 boundary write refused (PREADY=1, PSLVERR=1)");
        check(r_sawBusy == 1'b0, "P10 boundary hit: CFG_BUSY already 0 during ACCESS");
        @(posedge r_pclk);
        @(negedge r_pclk);
        r_psel = 0; r_penable = 0; r_pwrite = 0; r_paddr = 0; r_pwdata = 0;
        repeat (5) @(posedge r_pclk);
        rd(ADDR_STATUS);
        check(r_rd[9] == 1'b0, "P10 no new config request (CFG_BUSY stays 0)");
        rd(ADDR_BAUDDIV);
        check(r_rd[15:0] == 16'd2, "P10 BAUDDIV keeps 2 (refused 5 not taken)");
        check(uut.w_actCfg[15:0] == 16'd2, "P10 UART_CLK side divider = 2");
        wr(ADDR_BAUDDIV, 32'd1); cfg_wait;              // restore
`endif

        if (r_errCnt == 0)
                $display("APB_CDC ALL PASS  pHalf=%0.2f uHalf=%0.2f", r_pHalf, r_uHalf);
        else
                $display("APB_CDC FAIL  errors=%0d", r_errCnt);
        $finish;
end

initial begin #100_000_000; $display("APB_CDC FAIL  timeout"); $finish; end

endmodule
