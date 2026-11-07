`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// uart_async_fifo
//   Dual-clock FIFO for UART V4 (PCLK <-> UART_CLK, fully asynchronous).
//   - Binary pointers (AW+1 bits) for addressing, Gray pointers for crossing.
//   - Each Gray pointer crosses the domain through a 2-FF synchronizer.
//   - o_full  : registered in the write domain (conservative: may stay high
//               a few wclk cycles after a read; never low while full).
//   - o_empty : registered in the read domain (conservative: may stay high
//               a few rclk cycles after a write; never low while empty).
//   - Read data is show-ahead: o_rdData = mem[rdPtr] while o_empty == 0.
//   - Levels (V4 step 6, for FIFO_LEVEL / STATUS), from local binary pointer
//     and the synchronized Gray pointer of the other side:
//       o_wLevel = wBin - gray2bin(rGraySync2)   (write side, may be high:
//                  a read shows up 2-3 wclk later)
//       o_rLevel = gray2bin(wGraySync2) - rBin   (read side, may be low)
//       o_wEmpty = (o_wLevel == 0): asserts late after the last read,
//                  deasserts on the write edge. Never 1 while data is queued.
//       o_rFull  = (o_rLevel == DEPTH): status only.
//   - Parameter rule: AW >= 2 (the full compare inverts the two pointer MSBs).
//   - Reset: assert both domain resets together (one-side-only reset is not
//     supported in V4; see cdc_spec.md). Memory has no reset: data written
//     while in reset is never visible because both pointers are held at 0.
// -----------------------------------------------------------------------------
module uart_async_fifo #(
        parameter DW = 8,               // data width
        parameter AW = 3                // address width, depth = 2**AW
)(
        // write domain
        input   wire            i_wclk,
        input   wire            i_wrst_n,
        input   wire            i_wrEn,
        input   wire [DW-1:0]   i_wrData,
        output  reg             o_full,
        output  wire [AW:0]     o_wLevel,
        output  wire            o_wEmpty,

        // read domain
        input   wire            i_rclk,
        input   wire            i_rrst_n,
        input   wire            i_rdEn,
        output  wire [DW-1:0]   o_rdData,
        output  reg             o_empty,
        output  wire [AW:0]     o_rLevel,
        output  wire            o_rFull
);

localparam DEPTH = (1 << AW);

function [AW:0] gray2bin;
        input [AW:0] g;
        integer k;
        begin
                gray2bin[AW] = g[AW];
                for (k = AW - 1; k >= 0; k = k - 1)
                        gray2bin[k] = gray2bin[k + 1] ^ g[k];
        end
endfunction

reg     [DW-1:0]        r_mem [0:DEPTH-1];

// read-domain pointers (declared first: used by the write-domain sync)
reg     [AW:0]          r_rBin;
reg     [AW:0]          r_rGray;
reg     [AW:0]          r_wGraySync1;   // write pointer, 1st sync stage
reg     [AW:0]          r_wGraySync2;   // write pointer, 2nd sync stage

// ---------------- write domain ----------------
reg     [AW:0]          r_wBin;
reg     [AW:0]          r_wGray;
reg     [AW:0]          r_rGraySync1;   // read pointer, 1st sync stage
reg     [AW:0]          r_rGraySync2;   // read pointer, 2nd sync stage

wire                    w_wPush;
wire    [AW:0]          w_wBinNext;
wire    [AW:0]          w_wGrayNext;
wire                    w_fullNext;

assign w_wPush     = i_wrEn && !o_full;
assign w_wBinNext  = r_wBin + {{AW{1'b0}}, w_wPush};
assign w_wGrayNext = (w_wBinNext >> 1) ^ w_wBinNext;

// full: next write Gray == synced read Gray with the two MSBs inverted
assign w_fullNext  = (w_wGrayNext == {~r_rGraySync2[AW:AW-1], r_rGraySync2[AW-2:0]});

always @(posedge i_wclk) begin
        if (w_wPush)
                r_mem[r_wBin[AW-1:0]] <= i_wrData;
end

always @(posedge i_wclk or negedge i_wrst_n) begin
        if (!i_wrst_n) begin
                r_wBin       <= {(AW+1){1'b0}};
                r_wGray      <= {(AW+1){1'b0}};
                r_rGraySync1 <= {(AW+1){1'b0}};
                r_rGraySync2 <= {(AW+1){1'b0}};
                o_full       <= 1'b0;
        end else begin
                r_wBin       <= w_wBinNext;
                r_wGray      <= w_wGrayNext;
                r_rGraySync1 <= r_rGray;
                r_rGraySync2 <= r_rGraySync1;
                o_full       <= w_fullNext;
        end
end

assign o_wLevel = r_wBin - gray2bin(r_rGraySync2);
assign o_wEmpty = (o_wLevel == {(AW+1){1'b0}});

// ---------------- read domain ----------------

wire                    w_rPop;
wire    [AW:0]          w_rBinNext;
wire    [AW:0]          w_rGrayNext;
wire                    w_emptyNext;

assign w_rPop      = i_rdEn && !o_empty;
assign w_rBinNext  = r_rBin + {{AW{1'b0}}, w_rPop};
assign w_rGrayNext = (w_rBinNext >> 1) ^ w_rBinNext;
assign w_emptyNext = (w_rGrayNext == r_wGraySync2);

assign o_rdData    = r_mem[r_rBin[AW-1:0]];
assign o_rLevel    = gray2bin(r_wGraySync2) - r_rBin;
assign o_rFull     = (o_rLevel == DEPTH);

always @(posedge i_rclk or negedge i_rrst_n) begin
        if (!i_rrst_n) begin
                r_rBin       <= {(AW+1){1'b0}};
                r_rGray      <= {(AW+1){1'b0}};
                r_wGraySync1 <= {(AW+1){1'b0}};
                r_wGraySync2 <= {(AW+1){1'b0}};
                o_empty      <= 1'b1;
        end else begin
                r_rBin       <= w_rBinNext;
                r_rGray      <= w_rGrayNext;
                r_wGraySync1 <= r_wGray;
                r_wGraySync2 <= r_wGraySync1;
                o_empty      <= w_emptyNext;
        end
end

endmodule
