`timescale 1ns/1ps
// Self-checking TB for uart_v4_cfg_cdc.
//   T1 single write            : busy=1 -> applied in UART_CLK -> busy=0
//   T2 write while busy        : o_cfgWrErr=1, SW register and final config unchanged
//   T3 engine not idle         : config held (not applied) until idle
//   T4 UART_CLK stopped        : write still accepted, busy held, 2nd write refused, applied after restart
//   T5 50 writes, random idle  : every accepted value applied exactly once, in order
//   T6 reset while pending     : busy=0, both registers back to reset value, nothing applied later
//   Checker (always)           : apply only when idle, active changes only with apply pulse,
//                                applied value == next accepted value, refused writes never applied
// Options: +PHALF=<ns> +UHALF=<ns> +SEED=<n>
module tb_uart_v4_cfg_cdc;

localparam CW = 24;
localparam [CW-1:0] RSTV = {16'd325, 8'h00};

reg             r_pclk, r_uclk, r_prst_n, r_urst_n, r_uStop;
reg             r_cfgWr, r_uIdle, r_idleAtEdge;
reg  [CW-1:0]   r_cfgWrData;
wire            w_busy, w_wrErr, w_apply, w_commit;
reg             r_commitAtEdge;
wire [CW-1:0]   w_swCfg, w_active;

reg  [CW-1:0]   r_q [0:255];
reg  [CW-1:0]   r_prevActive;
integer         r_qW, r_qR, r_errCnt, r_i, r_seed, r_seed0, r_refused;
real            r_pHalf, r_uHalf;

uart_v4_cfg_cdc #(.CW(CW), .CFG_RST(RSTV)) dut (
        .i_pclk(r_pclk), .i_prst_n(r_prst_n), .i_cfgWr(r_cfgWr), .i_cfgWrData(r_cfgWrData),
        .o_cfgBusy(w_busy), .o_cfgWrErr(w_wrErr), .o_swCfg(w_swCfg),
        .i_uclk(r_uclk), .i_urst_n(r_urst_n), .i_uIdle(r_uIdle),
        .o_activeCfg(w_active), .o_cfgCommit(w_commit), .o_applyPulse(w_apply));

// ---------------- clocks ----------------
initial begin
        r_pHalf = 5.0; r_uHalf = 13.1; r_seed = 1;
        if ($value$plusargs("PHALF=%f", r_pHalf)) ;
        if ($value$plusargs("UHALF=%f", r_uHalf)) ;
        if ($value$plusargs("SEED=%d",  r_seed))  ;
        r_seed0 = r_seed;
end
initial begin
        r_pclk = 1'b0;
        #0.1;
        forever #(r_pHalf) r_pclk = ~r_pclk;
end
initial begin
        r_uclk = 1'b0; r_uStop = 1'b0;
        #0.53;
        forever begin
                #(r_uHalf);
                if (!r_uStop) r_uclk = ~r_uclk;
        end
end

// ---------------- checkers ----------------
// PCLK: record accepted writes, check the error flag
always @(posedge r_pclk) if (r_prst_n) begin
        if (w_wrErr !== (r_cfgWr && w_busy)) begin
                $display("FAIL: wrErr=%b with wr=%b busy=%b at %0t", w_wrErr, r_cfgWr, w_busy, $time); r_errCnt = r_errCnt + 1;
        end
        if (r_cfgWr && !w_busy) begin
                r_q[r_qW] = r_cfgWrData; r_qW = r_qW + 1;
        end
        if (r_cfgWr && w_busy) r_refused = r_refused + 1;
end

// UART_CLK: apply only when idle, applied value == next accepted value
always @(posedge r_uclk) begin r_idleAtEdge <= r_uIdle; r_commitAtEdge <= w_commit; end
always @(negedge r_uclk) if (r_urst_n) begin
        if (w_apply) begin
                if (!r_commitAtEdge) begin
                        $display("FAIL: config loaded without commit strobe on that edge at %0t", $time); r_errCnt = r_errCnt + 1;
                end
                if (!r_idleAtEdge) begin
                        $display("FAIL: applied while engine busy at %0t", $time); r_errCnt = r_errCnt + 1;
                end
                if (r_qR >= r_qW) begin
                        $display("FAIL: apply without an accepted write at %0t", $time); r_errCnt = r_errCnt + 1;
                end else if (w_active !== r_q[r_qR]) begin
                        $display("FAIL: applied %h exp %h at %0t", w_active, r_q[r_qR], $time); r_errCnt = r_errCnt + 1;
                end
                r_qR = r_qR + 1;
        end else if (w_active !== r_prevActive) begin
                $display("FAIL: active config changed without apply at %0t", $time); r_errCnt = r_errCnt + 1;
        end
        r_prevActive = w_active;
end

// ---------------- helpers ----------------
task check;
        input   cond;
        input [8*56-1:0] msg;
        begin
                if (cond) $display("PASS: %0s", msg);
                else begin $display("FAIL: %0s", msg); r_errCnt = r_errCnt + 1; end
        end
endtask

task cfg_write;                         // one-cycle write request
        input [CW-1:0] d;
        begin
                @(negedge r_pclk); r_cfgWr = 1'b1; r_cfgWrData = d;
                @(negedge r_pclk); r_cfgWr = 1'b0;
                #0.01;                  // let combinational outputs settle before checks
        end
endtask

task wait_not_busy;
        begin
                while (w_busy) @(negedge r_pclk);
        end
endtask

task settle;                            // busy cleared AND the UART_CLK checker has run
        begin
                wait_not_busy;
                @(negedge r_uclk);
                #0.01;
        end
endtask

// ---------------- sequence ----------------
initial begin
        r_errCnt = 0; r_qW = 0; r_qR = 0; r_refused = 0;
        r_cfgWr = 0; r_cfgWrData = 0; r_uIdle = 1; r_idleAtEdge = 1; r_commitAtEdge = 0;
        r_prevActive = RSTV;
        r_prst_n = 0; r_urst_n = 0;
        #60 r_prst_n = 1; #17 r_urst_n = 1;
        repeat (4) @(posedge r_uclk);
        check(w_busy === 1'b0 && w_active === RSTV && w_swCfg === RSTV, "T0 reset values, not busy");

        // T1
        cfg_write(24'h0008_87);
        check(w_busy === 1'b1 && w_swCfg === 24'h0008_87,           "T1 busy=1 right after accepted write");
        settle;
        check(w_active === 24'h0008_87 && r_qR == 1,                "T1 applied once, busy cleared");

        // T2
        cfg_write(24'h0010_07);
        @(negedge r_pclk); r_cfgWr = 1'b1; r_cfgWrData = 24'hDEAD_00;
        #0.01;
        check(w_wrErr === 1'b1,                                     "T2 write while busy -> wrErr (PSLVERR)");
        @(negedge r_pclk); r_cfgWr = 1'b0;
        check(w_swCfg === 24'h0010_07,                              "T2 SW register unchanged by refused write");
        settle;
        check(w_active === 24'h0010_07,                             "T2 refused value never applied");

        // T3
        @(negedge r_uclk); r_uIdle = 1'b0;
        cfg_write(24'h0020_47);
        repeat (40) @(posedge r_uclk);
        check(w_busy === 1'b1 && w_active === 24'h0010_07,          "T3 held while engine busy");
        @(negedge r_uclk); r_uIdle = 1'b1;
        settle;
        check(w_active === 24'h0020_47,                             "T3 applied after engine idle");

        // T4
        @(negedge r_uclk); r_uStop = 1'b1;
        cfg_write(24'h0030_87);
        check(w_wrErr === 1'b0 && w_swCfg === 24'h0030_87,          "T4 write accepted with UART_CLK stopped");
        repeat (100) @(posedge r_pclk);
        check(w_busy === 1'b1 && w_active === 24'h0020_47,          "T4 busy held while UART_CLK stopped");
        cfg_write(24'hBAD0_00);
        check(w_swCfg === 24'h0030_87,                              "T4 2nd write refused while stopped");
        r_uStop = 1'b0;
        settle;
        check(w_active === 24'h0030_87,                             "T4 applied after UART_CLK restarts");

        // T5
        fork
                begin : idle_rand
                        forever begin
                                @(negedge r_uclk);
                                r_uIdle = ($random(r_seed) % 4 != 0);
                        end
                end
                begin
                        for (r_i = 0; r_i < 50; r_i = r_i + 1) begin
                                wait_not_busy;
                                repeat ($random(r_seed) & 3) @(negedge r_pclk);
                                cfg_write($random(r_seed));
                                if ($random(r_seed) % 2) cfg_write($random(r_seed));   // often refused
                        end
                        wait_not_busy;
                        disable idle_rand;
                end
        join
        @(negedge r_uclk); r_uIdle = 1'b1;
        repeat (4) @(posedge r_uclk);
        check(r_qR == r_qW && w_busy === 1'b0,                      "T5 every accepted write applied once");

        // T6
        @(negedge r_uclk); r_uIdle = 1'b0;
        cfg_write(24'h0055_AA);
        repeat (6) @(posedge r_uclk);
        r_prst_n = 0; r_urst_n = 0;
        #40 r_prst_n = 1; #7 r_urst_n = 1;
        r_qR = r_qW; r_prevActive = RSTV;           // pending write discarded by reset
        @(negedge r_uclk); r_uIdle = 1'b1;
        repeat (20) @(posedge r_uclk);
        check(w_busy === 1'b0 && w_active === RSTV && w_swCfg === RSTV, "T6 reset clears pending config");

        if (r_errCnt == 0)
                $display("CFG_CDC ALL PASS  accepted=%0d refused=%0d pHalf=%0.2f uHalf=%0.2f seed=%0d",
                         r_qW, r_refused, r_pHalf, r_uHalf, r_seed0);
        else
                $display("CFG_CDC FAIL  errors=%0d", r_errCnt);
        $finish;
end

initial begin #50_000_000; $display("CFG_CDC FAIL  timeout"); $finish; end

endmodule
