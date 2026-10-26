`timescale 1ns/1ps

// ============================================================
// UART V3 chip top - ALL external ports through I/O PAD cells
//   input  : PADDI (PAD -> Y)   clk, rst_n, APB inputs, i_uartRx
//   output : PADDO (A -> PAD)   APB outputs, o_irq, o_uartTx
// Same ports / parameters as uart_chip_top (RX/TX-only PAD version).
// `define NO_PAD : bypass every PAD (RTL simulation without the PAD library)
// ============================================================
module uart_chip_top_allpad #(
    parameter STRICT_APB_ERR = 1'b0,
    parameter TX_FIFO_DEPTH  = 8,
    parameter RX_FIFO_DEPTH  = 8
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        i_psel,
    input  wire        i_penable,
    input  wire        i_pwrite,
    input  wire [7:0]  i_paddr,
    input  wire [31:0] i_pwdata,

    output wire [31:0] o_prdata,
    output wire        o_pready,
    output wire        o_pslverr,

    input  wire        i_uartRx,
    output wire        o_uartTx,

    output wire        o_irq
);

// core-side nets
wire        w_clk, w_rst_n, w_psel, w_penable, w_pwrite, w_uartRx;
wire [7:0]  w_paddr;
wire [31:0] w_pwdata;
wire [31:0] w_prdata;
wire        w_pready, w_pslverr, w_uartTx, w_irq;

`ifdef NO_PAD

assign w_clk     = clk;
assign w_rst_n   = rst_n;
assign w_psel    = i_psel;
assign w_penable = i_penable;
assign w_pwrite  = i_pwrite;
assign w_paddr   = i_paddr;
assign w_pwdata  = i_pwdata;
assign w_uartRx  = i_uartRx;
assign o_prdata  = w_prdata;
assign o_pready  = w_pready;
assign o_pslverr = w_pslverr;
assign o_uartTx  = w_uartTx;
assign o_irq     = w_irq;

`else

// ---------------- input PADs
PADDI u_pad_clk     (.PAD (clk),       .Y (w_clk));
PADDI u_pad_rst_n   (.PAD (rst_n),     .Y (w_rst_n));
PADDI u_pad_psel    (.PAD (i_psel),    .Y (w_psel));
PADDI u_pad_penable (.PAD (i_penable), .Y (w_penable));
PADDI u_pad_pwrite  (.PAD (i_pwrite),  .Y (w_pwrite));
PADDI u_pad_uart_rx (.PAD (i_uartRx),  .Y (w_uartRx));

genvar gi;
generate
    for (gi = 0; gi < 8; gi = gi + 1) begin : g_pad_paddr
        PADDI u_pad (.PAD (i_paddr[gi]), .Y (w_paddr[gi]));
    end
    for (gi = 0; gi < 32; gi = gi + 1) begin : g_pad_pwdata
        PADDI u_pad (.PAD (i_pwdata[gi]), .Y (w_pwdata[gi]));
    end
    // ---------------- output PADs
    for (gi = 0; gi < 32; gi = gi + 1) begin : g_pad_prdata
        PADDO u_pad (.A (w_prdata[gi]), .PAD (o_prdata[gi]));
    end
endgenerate

PADDO u_pad_pready  (.A (w_pready),  .PAD (o_pready));
PADDO u_pad_pslverr (.A (w_pslverr), .PAD (o_pslverr));
PADDO u_pad_uart_tx (.A (w_uartTx),  .PAD (o_uartTx));
PADDO u_pad_irq     (.A (w_irq),     .PAD (o_irq));

`endif

// ---------------- UART V3 core
uart_apb #(
    .STRICT_APB_ERR (STRICT_APB_ERR),
    .TX_FIFO_DEPTH  (TX_FIFO_DEPTH),
    .RX_FIFO_DEPTH  (RX_FIFO_DEPTH)
) u_uart_apb (
    .clk        (w_clk),
    .rst_n      (w_rst_n),
    .i_psel     (w_psel),
    .i_penable  (w_penable),
    .i_pwrite   (w_pwrite),
    .i_paddr    (w_paddr),
    .i_pwdata   (w_pwdata),
    .o_prdata   (w_prdata),
    .o_pready   (w_pready),
    .o_pslverr  (w_pslverr),
    .i_uartRx   (w_uartRx),
    .o_uartTx   (w_uartTx),
    .o_irq      (w_irq)
);

endmodule
