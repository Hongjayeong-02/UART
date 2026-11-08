`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// uart_baud_gen  (step 10-A: terminal-count lookahead)
//
// Behavior (same as step 9 when BAUDDIV is static):
//   - i_enable = 0 or BAUDDIV = 0 : counter held at 0, no tick
//   - otherwise o_tick16 pulses once every (BAUDDIV + 1) cycles
//
// Timing change:
//   step 9 : r_clkCnt -> (r_clkCnt == i_baudDiv) 16-bit compare -> 16-bit reset mux
//   step 10: r_cntLast is a flop that equals (r_clkCnt == BAUDDIV).
//            It is computed one cycle early as (r_clkCnt == BAUDDIV - 1)
//            when the counter increments, so the counter mux select
//            comes directly from a flop.
//   BAUDDIV - 1 and (BAUDDIV == 0) are registered (r_divM1, r_divZero).
//
// Live BAUDDIV change (spec change vs step 9):
//   step 9 compares against the live value, so if the new BAUDDIV is smaller
//   than the current count the counter wraps through 65536 before the next tick.
//   step 10 detects the change (r_divChg, registered compare) and restarts the
//   counter; the first tick comes (new BAUDDIV + 1) cycles after the restart,
//   i.e. <= new BAUDDIV + 4 cycles after the APB write. No 65536 stall.
// ---------------------------------------------------------------------------
module uart_baud_gen (
	input 	wire 		clk,
	input 	wire 		rst_n,
	input 	wire		i_enable,
	input	wire	[15:0]	i_baudDiv,

	output 	reg		o_tick16
);

reg [15:0] r_clkCnt;
reg        r_cntLast;	// == (r_clkCnt == BAUDDIV)
reg [15:0] r_divM1;	// BAUDDIV - 1
reg        r_divZero;	// BAUDDIV == 0
reg [15:0] r_divD;	// BAUDDIV delayed 1 cycle
reg        r_divChg;	// BAUDDIV changed -> restart counter

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_divM1   <= 16'd0;
		r_divZero <= 1'b1;
		r_divD    <= 16'd0;
		r_divChg  <= 1'b0;
	end else begin
		r_divM1   <= i_baudDiv - 1'b1;
		r_divZero <= (i_baudDiv == 16'd0);
		r_divD    <= i_baudDiv;
		r_divChg  <= (i_baudDiv != r_divD);
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_clkCnt  <= 16'd0;
		r_cntLast <= 1'b0;
		o_tick16  <= 1'b0;
	end else begin
		o_tick16 <= 1'b0;

		if (!i_enable || r_divZero || r_divChg) begin
			r_clkCnt  <= 16'd0;
			r_cntLast <= 1'b0;

		end else if (r_cntLast) begin
			r_clkCnt  <= 16'd0;
			r_cntLast <= 1'b0;	// 0 == BAUDDIV is false (BAUDDIV >= 1)
			o_tick16  <= 1'b1;

		end else begin
			r_clkCnt  <= r_clkCnt + 1'b1;
			r_cntLast <= (r_clkCnt == r_divM1);

		end
	end
end

endmodule
