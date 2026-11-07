`timescale 1ns/1ps
// Self-checking TB for uart_v4_baud_gen.
//   B1 period == div+1 for several dividers
//   B2 commit with a LOWER div while the counter is high -> first tick exactly div+1 after commit
//   B3 commit with a HIGHER div -> first tick exactly div+1 after commit
//   B4 V3 erratum scenario: lower div WITHOUT commit -> tick within 2 cycles (no 2^16 wrap)
//   B5 enable=0 -> no tick, counter restarts on enable
//   B6 div=0 -> no tick
module tb_uart_v4_baud_gen;

reg             r_clk, r_rst_n, r_en, r_commit;
reg  [15:0]     r_div;
wire            w_tick;
integer         r_errCnt, r_n;

uart_v4_baud_gen dut (.i_clk(r_clk), .i_rst_n(r_rst_n), .i_enable(r_en),
                      .i_cfgCommit(r_commit), .i_baudDiv(r_div), .o_tick16(w_tick));

initial begin r_clk = 1'b0; forever #5 r_clk = ~r_clk; end

task check;
        input cond;
        input [8*60-1:0] msg;
        begin
                if (cond) $display("PASS: %0s", msg);
                else begin $display("FAIL: %0s", msg); r_errCnt = r_errCnt + 1; end
        end
endtask

// cycles from now until the next tick (gives up after lim)
task cycles_to_tick;
        input  integer lim;
        output integer n;
        begin
                n = 0;
                @(posedge r_clk); #1; n = 1;
                while (!w_tick && n < lim) begin @(posedge r_clk); #1; n = n + 1; end
                if (!w_tick) n = -1;
        end
endtask

// commit a new divider: div and commit change together, commit is one cycle
task commit_div;
        input [15:0] d;
        begin
                @(negedge r_clk); r_div = d; r_commit = 1'b1;
                @(negedge r_clk); r_commit = 1'b0;
        end
endtask

integer r_p1, r_p2;
initial begin
        r_errCnt = 0; r_rst_n = 0; r_en = 0; r_commit = 0; r_div = 16'd8;
        #22 r_rst_n = 1;

        // B1
        @(negedge r_clk); r_en = 1;
        cycles_to_tick(100, r_p1); cycles_to_tick(100, r_p1); cycles_to_tick(100, r_p2);
        check(r_p1 == 9 && r_p2 == 9, "B1 div=8  -> period 9");
        commit_div(16'd1);
        cycles_to_tick(100, r_p1); cycles_to_tick(100, r_p2);
        check(r_p2 == 2, "B1 div=1  -> period 2");
        commit_div(16'd25);
        cycles_to_tick(100, r_p1); cycles_to_tick(100, r_p2);
        check(r_p2 == 26, "B1 div=25 -> period 26");

        // B2: counter near 300, then commit div=8
        commit_div(16'd325);
        repeat (300) @(posedge r_clk);
        commit_div(16'd8);
        // commit_div returns between the commit edge and the next edge: tick after 9 more edges
        cycles_to_tick(70000, r_p1);
        check(r_p1 == 9, "B2 lower div + commit: first tick = div+1 after commit");

        // B3: higher div
        commit_div(16'd40);
        cycles_to_tick(70000, r_p1);
        check(r_p1 == 41, "B3 higher div + commit: first tick = div+1 after commit");

        // B4: V3 erratum scenario, NO commit
        commit_div(16'd325);
        repeat (300) @(posedge r_clk);
        @(negedge r_clk); r_div = 16'd8;
        cycles_to_tick(70000, r_p1);
        check(r_p1 >= 1 && r_p1 <= 2, "B4 lower div without commit: tick within 2 cycles");

        // B5
        @(negedge r_clk); r_en = 0;
        cycles_to_tick(50, r_p1);
        check(r_p1 == -1, "B5 enable=0 -> no tick");
        @(negedge r_clk); r_en = 1;
        cycles_to_tick(100, r_p1);
        check(r_p1 == 9, "B5 re-enable -> first tick after div+1");

        // B6
        commit_div(16'd0);
        cycles_to_tick(50, r_p1);
        check(r_p1 == -1, "B6 div=0 -> no tick");

        if (r_errCnt == 0) $display("BAUD_GEN ALL PASS");
        else               $display("BAUD_GEN FAIL  errors=%0d", r_errCnt);
        $finish;
end

endmodule
