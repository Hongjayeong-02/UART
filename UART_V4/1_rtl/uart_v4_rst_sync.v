`timescale 1ns/1ps

// Reset synchronizer: asynchronous assert, synchronous deassert (2 flops).
// One instance per clock domain (D12).
module uart_v4_rst_sync (
        input   wire    i_clk,
        input   wire    i_rst_n,
        output  wire    o_rst_n
);

reg     [1:0]   r_sync;

always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
                r_sync <= 2'b00;
        else
                r_sync <= {r_sync[0], 1'b1};
end

assign o_rst_n = r_sync[1];

endmodule
