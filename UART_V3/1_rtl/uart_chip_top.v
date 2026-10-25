
`timescale 1ns/1ps

module uart_chip_top #(
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

wire w_uart_rx;
wire w_uart_tx;

// ======================================================
// I/O PAD
// ======================================================

`ifdef NO_PAD

    assign w_uart_rx = i_uartRx;
    assign o_uartTx  = w_uart_tx;

`else

    // UART RX : Input PAD
    PADDI u_pad_uart_rx (
        .PAD (i_uartRx),
        .Y   (w_uart_rx)
    );

    // UART TX : Output PAD
    PADDO u_pad_uart_tx (
        .A   (w_uart_tx),
        .PAD (o_uartTx)
    );

`endif

// ======================================================
// UART V3 Core
// ======================================================

uart_apb #(
    .STRICT_APB_ERR (STRICT_APB_ERR),
    .TX_FIFO_DEPTH  (TX_FIFO_DEPTH),
    .RX_FIFO_DEPTH  (RX_FIFO_DEPTH)
) u_uart_apb (
    .clk        (clk),
    .rst_n      (rst_n),

    .i_psel     (i_psel),
    .i_penable  (i_penable),
    .i_pwrite   (i_pwrite),
    .i_paddr    (i_paddr),
    .i_pwdata   (i_pwdata),

    .o_prdata   (o_prdata),
    .o_pready   (o_pready),
    .o_pslverr  (o_pslverr),

    .i_uartRx   (w_uart_rx),
    .o_uartTx   (w_uart_tx),

    .o_irq      (o_irq)
);

endmodule

