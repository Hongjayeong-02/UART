`timescale 1ns/1ps
// Self-checking TB for uart_async_fifo (two unrelated clocks).
//   Phase 1 directed : D1 fill to exactly DEPTH -> full=1, writes while full are refused
//                      D2 read requests while empty -> nothing popped
//                      D3 reset both domains with data inside -> empty, no stale data
//   Phase 2 random   : exactly N accepted pushes / pops, many pointer wrap-arounds
//   Checker (always) : order + value, no pop from an empty model, occupancy <= DEPTH while full=0
//   Level checker    : wLevel >= true occupancy, wEmpty only when truly empty,
//                      rLevel <= true occupancy, rFull only when truly full (step 6)
// Options: +WHALF=<ns> +RHALF=<ns> +SEED=<n>
module tb_uart_async_fifo;

localparam DW = 8, AW = 4, DEPTH = 16, N = 4000, MAXQ = 8192;

reg             r_wclk, r_rclk, r_wrst_n, r_rrst_n;
reg             r_wrEn, r_rdEn, r_rnd;
reg  [DW-1:0]   r_wrData;
wire [DW-1:0]   w_rdData;
wire            w_full, w_empty, w_wEmpty, w_rFull;
wire [AW:0]     w_wLevel, w_rLevel;

reg  [DW-1:0]   r_model [0:MAXQ-1];
integer         r_wCnt, r_rCnt, r_errCnt, r_occMax, r_seed, r_seed0, r_target, r_i;
real            r_wHalf, r_rHalf;

uart_async_fifo #(.DW(DW), .AW(AW)) dut (
        .i_wclk(r_wclk), .i_wrst_n(r_wrst_n), .i_wrEn(r_wrEn), .i_wrData(r_wrData), .o_full(w_full),
        .o_wLevel(w_wLevel), .o_wEmpty(w_wEmpty),
        .i_rclk(r_rclk), .i_rrst_n(r_rrst_n), .i_rdEn(r_rdEn), .o_rdData(w_rdData), .o_empty(w_empty),
        .o_rLevel(w_rLevel), .o_rFull(w_rFull));

// ---------------- clocks ----------------
initial begin
        r_wHalf = 5.0; r_rHalf = 7.3; r_seed = 1;
        if ($value$plusargs("WHALF=%f", r_wHalf)) ;
        if ($value$plusargs("RHALF=%f", r_rHalf)) ;
        if ($value$plusargs("SEED=%d",  r_seed))  ;
        r_seed0 = r_seed;
end
initial begin
        r_wclk = 1'b0;
        #0.1;
        forever #(r_wHalf) r_wclk = ~r_wclk;
end
initial begin
        r_rclk = 1'b0;
        #0.47;
        forever #(r_rHalf) r_rclk = ~r_rclk;
end

// ---------------- checker (monitors accepted transfers) ----------------
always @(posedge r_wclk) begin
        if (r_wrst_n && r_wrEn && !w_full) begin
                r_model[r_wCnt % MAXQ] = r_wrData;
                r_wCnt = r_wCnt + 1;
        end
        if (r_wrst_n && !w_full && (r_wCnt - r_rCnt) > DEPTH) begin
                $display("FAIL: occupancy %0d > DEPTH while full=0 at %0t", r_wCnt - r_rCnt, $time);
                r_errCnt = r_errCnt + 1;
        end
        if ((r_wCnt - r_rCnt) > r_occMax) r_occMax = r_wCnt - r_rCnt;
end

always @(posedge r_rclk) begin
        if (r_rrst_n && r_rdEn && !w_empty) begin
                if (r_rCnt >= r_wCnt) begin
                        $display("FAIL: pop while model empty (rCnt=%0d) at %0t", r_rCnt, $time);
                        r_errCnt = r_errCnt + 1;
                end else if (w_rdData !== r_model[r_rCnt % MAXQ]) begin
                        $display("FAIL: pop #%0d data %h exp %h at %0t", r_rCnt, w_rdData, r_model[r_rCnt % MAXQ], $time);
                        r_errCnt = r_errCnt + 1;
                end
                r_rCnt = r_rCnt + 1;
        end
end

// ---------------- level checkers (mid-cycle) ----------------
always @(negedge r_wclk) if (r_wrst_n && r_rrst_n) begin
        if (w_wLevel < (r_wCnt - r_rCnt) || w_wLevel > DEPTH || (w_wEmpty && r_wCnt != r_rCnt)) begin
                $display("FAIL: wLevel %0d wEmpty %b vs occupancy %0d at %0t", w_wLevel, w_wEmpty, r_wCnt - r_rCnt, $time);
                r_errCnt = r_errCnt + 1;
        end
end
always @(negedge r_rclk) if (r_wrst_n && r_rrst_n) begin
        if (w_rLevel > (r_wCnt - r_rCnt) || (w_rFull && (r_wCnt - r_rCnt) != DEPTH)) begin
                $display("FAIL: rLevel %0d rFull %b vs occupancy %0d at %0t", w_rLevel, w_rFull, r_wCnt - r_rCnt, $time);
                r_errCnt = r_errCnt + 1;
        end
end

// ---------------- random drivers (phase 2) ----------------
always @(negedge r_wclk) if (r_rnd) begin
        r_wrEn   <= (r_wCnt < r_target) && ($random(r_seed) % 4 != 0);
        r_wrData <= $random(r_seed);
end
always @(negedge r_rclk) if (r_rnd) r_rdEn <= ($random(r_seed) % 3 != 0);

// ---------------- helpers ----------------
task check;
        input   cond;
        input [8*48-1:0] msg;
        begin
                if (cond) $display("PASS: %0s", msg);
                else begin $display("FAIL: %0s", msg); r_errCnt = r_errCnt + 1; end
        end
endtask

task push_one;                          // one write request on the next wclk edge
        input [DW-1:0] d;
        begin
                @(negedge r_wclk); r_wrEn = 1'b1; r_wrData = d;
                @(negedge r_wclk); r_wrEn = 1'b0;
        end
endtask

task drain;                             // read until the model is empty, then settle
        begin
                @(negedge r_rclk); r_rdEn = 1'b1;
                while (r_rCnt < r_wCnt) @(negedge r_rclk);
                r_rdEn = 1'b0;
                repeat (6) @(posedge r_rclk);
        end
endtask

// ---------------- sequence ----------------
initial begin
        r_errCnt = 0; r_occMax = 0; r_wCnt = 0; r_rCnt = 0;
        r_wrEn = 0; r_rdEn = 0; r_rnd = 0; r_wrData = 0; r_target = 0;
        r_wrst_n = 0; r_rrst_n = 0;
        #50 r_wrst_n = 1; #13 r_rrst_n = 1;
        repeat (4) @(posedge r_wclk);

        // D1: fill exactly DEPTH, then 4 more requests while full
        @(negedge r_wclk); r_wrEn = 1'b1;
        for (r_i = 0; r_i < DEPTH + 4; r_i = r_i + 1) begin
                r_wrData = 8'h40 + r_i;
                @(negedge r_wclk);
        end
        r_wrEn = 1'b0;
        check(w_full === 1'b1,          "D1 full=1 after 16 accepted writes");
        check(r_wCnt == DEPTH,          "D1 writes while full were refused (16 kept)");
        repeat (4) @(posedge r_rclk); repeat (4) @(posedge r_wclk); #0.01;
        check(w_wLevel == DEPTH && w_rLevel == DEPTH && w_rFull, "D1 levels 16/16, rFull=1 after settle");
        drain;
        repeat (4) @(posedge r_wclk); #0.01;      // full / wLevel need the read pointer in wclk
        check(w_empty === 1'b1 && w_full === 1'b0, "D1 empty=1 / full=0 after drain");
        check(w_wLevel == 0 && w_rLevel == 0 && w_wEmpty && !w_rFull, "D1 levels 0/0, wEmpty=1 after settle");

        // D2: read requests while empty
        @(negedge r_rclk); r_rdEn = 1'b1;
        repeat (10) @(negedge r_rclk);
        r_rdEn = 1'b0;
        check(r_rCnt == r_wCnt && w_empty === 1'b1, "D2 no pop while empty");

        // D3: reset both domains with 5 entries inside, then refill
        for (r_i = 0; r_i < 5; r_i = r_i + 1) push_one(8'hA0 + r_i);
        repeat (3) @(posedge r_rclk);
        r_wrst_n = 0; r_rrst_n = 0;
        #40 r_wrst_n = 1; #9 r_rrst_n = 1;
        r_rCnt = r_wCnt;                // old entries are discarded by the reset
        repeat (6) @(posedge r_rclk);
        check(w_empty === 1'b1 && w_full === 1'b0, "D3 empty=1 / full=0 after reset");
        for (r_i = 0; r_i < 3; r_i = r_i + 1) push_one(8'hC0 + r_i);
        drain;
        check(r_rCnt == r_wCnt,         "D3 only post-reset data read back");

        // Phase 2: random, exactly N more accepted pushes
        r_target = r_wCnt + N;
        r_rnd = 1;
        wait (r_wCnt == r_target);
        r_rnd = 0; @(negedge r_wclk); r_wrEn = 1'b0;
        drain;
        check(r_wCnt == r_target && r_rCnt == r_target, "R  exact count pushed == popped");
        check(w_empty === 1'b1,         "R  empty after final drain");

        if (r_errCnt == 0)
                $display("ASYNC_FIFO ALL PASS  accepted=%0d maxOcc=%0d wHalf=%0.2f rHalf=%0.2f seed=%0d",
                         r_wCnt, r_occMax, r_wHalf, r_rHalf, r_seed0);
        else
                $display("ASYNC_FIFO FAIL  errors=%0d", r_errCnt);
        $finish;
end

initial begin #20_000_000; $display("ASYNC_FIFO FAIL  timeout w=%0d r=%0d", r_wCnt, r_rCnt); $finish; end

endmodule
