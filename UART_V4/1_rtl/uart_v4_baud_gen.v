`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// uart_v4_baud_gen  (UART_CLK domain)
//   o_tick16 pulses once every (i_baudDiv + 1) cycles while enabled.
//   V3 erratum fix (spec D6):
//     - compare with >= : a counter already above a newly lowered divider
//       ticks on the next cycle instead of wrapping through 2^16.
//     - i_cfgCommit (same edge that loads the new active config) clears the
//       counter, so the first period after a config change is exactly
//       (new BAUDDIV + 1) cycles.
//   i_baudDiv == 0 : no tick (same as V3).
// -----------------------------------------------------------------------------
module uart_v4_baud_gen (
        input   wire            i_clk,
        input   wire            i_rst_n,
        input   wire            i_enable,
        input   wire            i_cfgCommit,
        input   wire    [15:0]  i_baudDiv,

        output  reg             o_tick16
);

reg     [15:0]  r_clkCnt;

always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
                r_clkCnt <= 16'd0;
                o_tick16 <= 1'b0;
        end else begin
                o_tick16 <= 1'b0;

                if (!i_enable || i_cfgCommit) begin
                        r_clkCnt <= 16'd0;

                end else if (i_baudDiv == 16'd0) begin
                        r_clkCnt <= 16'd0;

                end else if (r_clkCnt >= i_baudDiv) begin
                        r_clkCnt <= 16'd0;
                        o_tick16 <= 1'b1;

                end else begin
                        r_clkCnt <= r_clkCnt + 16'd1;

                end
        end
end

endmodule
