`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// uart_v4_sync_level
//   2-FF synchronizer for a single-bit LEVEL (e.g. TX busy -> PCLK STATUS).
//   The source must be a flop output (no logic before the first stage).
//   A level that stays stable for >= 2 destination cycles is seen 2-3
//   destination cycles later. Shorter glitches may be missed (allowed for
//   status levels).
// -----------------------------------------------------------------------------
module uart_v4_sync_level #(
        parameter RST_VAL = 1'b0
)(
        input   wire    i_clk,          // destination clock
        input   wire    i_rst_n,
        input   wire    i_level,        // from the other clock domain
        output  wire    o_level
);

reg     r_sync1;
reg     r_sync2;

assign o_level = r_sync2;

always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
                r_sync1 <= RST_VAL;
                r_sync2 <= RST_VAL;
        end else begin
                r_sync1 <= i_level;
                r_sync2 <= r_sync1;
        end
end

endmodule
