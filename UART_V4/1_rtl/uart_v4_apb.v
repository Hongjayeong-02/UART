`timescale 1ns/1ps

// UART V4 APB3 peripheral: PCLK (APB) and UART_CLK (baud / shifting) are
// fully asynchronous. Register map and bit positions are the same as V3.
//
// Differences from V3 (see cdc_spec.md):
//   - STATUS[9]  CFG_BUSY: a CTRL / BAUDDIV write is crossing to UART_CLK.
//     A CTRL / BAUDDIV write while CFG_BUSY=1 is refused: PSLVERR=1 and the
//     register keeps its value (D4, D10). Driver: write, poll CFG_BUSY=0 (D13).
//   - STATUS[4]  TX_BUSY = "TX not finished": a byte is queued or on the
//     line (D20). V3 meant "shifting" only.
//   - FIFO levels / empty / full come from synchronized pointers and can lag
//     by 2-3 cycles in the conservative direction (D11).
//   - CTRL / BAUDDIV read back the software value (PCLK copy). The UART_CLK
//     side uses it after the handshake, at a frame boundary (D7, D15).
//   - Reads take one wait state, PRDATA / PREADY from flops (same as V3 RO).
//   - TXDATA write is dropped while !enable or !txEn (same as V3, D19).
//
// Internal names w_txBusy, w_rxFifoCount, w_irqStatus and the core instance
// name uut_uart_core (with w_tick16 inside) match V3 so the V3 testbench
// can observe the same points.

module uart_v4_apb #(
        parameter STRICT_APB_ERR = 1'b0,
        parameter FIFO_AW        = 4            // FIFO depth = 2**FIFO_AW
)(
        input   wire            i_pclk,
        input   wire            i_uclk,
        input   wire            rst_n,          // asserted for both domains (D12)

        input   wire            i_psel,
        input   wire            i_penable,
        input   wire            i_pwrite,
        input   wire    [7:0]   i_paddr,
        input   wire    [31:0]  i_pwdata,
        output  reg     [31:0]  o_prdata,
        output  reg             o_pready,
        output  reg             o_pslverr,

        input   wire            i_uartRx,
        output  wire            o_uartTx,
        output  wire            o_irq
);

localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_IRQ_EN      = 8'h14;
localparam ADDR_IRQ_STATUS  = 8'h18;
localparam ADDR_FIFO_LEVEL  = 8'h1C;

// config word: {loopback, stop2, parity[1:0], data7, rxEn, txEn, enable, baudDiv[15:0]}
localparam [23:0] CFG_RST = {8'h00, 16'd325};


// ---------------------------------------------------------
// Resets (one synchronizer per domain)
// ---------------------------------------------------------
wire            w_prst_n;
wire            w_urst_n;

uart_v4_rst_sync u_prst (.i_clk(i_pclk), .i_rst_n(rst_n), .o_rst_n(w_prst_n));
uart_v4_rst_sync u_urst (.i_clk(i_uclk), .i_rst_n(rst_n), .o_rst_n(w_urst_n));


// ---------------------------------------------------------
// Signals
// ---------------------------------------------------------
wire            w_apbAccess;
wire            w_apbSetup;

wire    [23:0]  w_swCfg;
wire    [23:0]  w_actCfg;
wire            w_cfgBusy;
wire            w_cfgWr;
wire            w_cfgWrErr;
reg             r_pslverr;      // registered PSLVERR (write: SETUP, read: capture)
wire    [23:0]  w_cfgWrData;
wire            w_cfgCommit;
wire            w_uIdle;

wire            w_swEnable  = w_swCfg[16];
wire            w_swTxEn    = w_swCfg[17];

wire            w_txWrEn;
wire            w_txFifoFull;
wire            w_txFifoEmpty;
wire            w_txAllDone;
wire            w_txBusy;
wire    [FIFO_AW:0] w_txLevel;

wire            w_rxRdEn;
wire    [9:0]   w_rxRdData;
wire            w_rxFifoEmpty;
wire            w_rxFifoFull;
wire    [FIFO_AW:0] w_rxLevel;
wire    [7:0]   w_rxFifoCount;          // FIFO_LEVEL field is 8 bits: FIFO_AW <= 7
wire    [7:0]   w_txFifoCount;

// UART_CLK events / status
wire            w_uTxBusy, w_uRxBusy, w_uTxDone, w_uRxValid;
wire            w_uParityErr, w_uFrameErr, w_uFalseStart, w_uRxOverflow;

// PCLK events
wire            w_parityErr, w_frameErr, w_rxOverflow;

reg     [4:0]   r_irqEn;
wire    [4:0]   w_irqStatus;
wire    [4:0]   w_irqClear;

reg             r_pready;


// ---------------------------------------------------------
// APB decode
// ---------------------------------------------------------
assign w_apbAccess = i_psel && i_penable;
assign w_apbSetup  = i_psel && !i_penable;

assign w_txWrEn = w_apbAccess && i_pwrite &&
                  (i_paddr == ADDR_TXDATA) &&
                  w_swEnable && w_swTxEn &&
                  !w_txFifoFull &&
                  !r_pslverr;     // refused at SETUP -> same decision as PSLVERR

// RX pop only in ACCESS1 of a read (same rule as V3 RO)
assign w_rxRdEn = w_apbAccess && !i_pwrite &&
                  (i_paddr == ADDR_RXDATA) &&
                  !r_pready &&
                  !w_rxFifoEmpty;

assign w_irqClear = (w_apbAccess && i_pwrite && (i_paddr == ADDR_IRQ_STATUS)) ?
                    i_pwdata[4:0] : 5'b00000;

// CTRL / BAUDDIV: merge the written field into the full config word
assign w_cfgWr = w_apbAccess && i_pwrite &&
                 ((i_paddr == ADDR_CTRL) || (i_paddr == ADDR_BAUDDIV)) &&
                 !r_pslverr;      // CFG_BUSY decided at SETUP

assign w_cfgWrData = (i_paddr == ADDR_CTRL) ?
                     {i_pwdata[7], i_pwdata[5], i_pwdata[4:3], i_pwdata[6],
                      i_pwdata[2], i_pwdata[1], i_pwdata[0], w_swCfg[15:0]} :
                     {w_swCfg[23:16], i_pwdata[15:0]};


// ---------------------------------------------------------
// Config CDC
// ---------------------------------------------------------
uart_v4_cfg_cdc #(.CW(24), .CFG_RST(CFG_RST)) u_cfg (
        .i_pclk         (i_pclk),
        .i_prst_n       (w_prst_n),
        .i_cfgWr        (w_cfgWr),
        .i_cfgWrData    (w_cfgWrData),
        .o_cfgBusy      (w_cfgBusy),
        .o_cfgWrErr     (w_cfgWrErr),
        .o_swCfg        (w_swCfg),

        .i_uclk         (i_uclk),
        .i_urst_n       (w_urst_n),
        .i_uIdle        (w_uIdle),
        .o_activeCfg    (w_actCfg),
        .o_cfgCommit    (w_cfgCommit),
        .o_applyPulse   ()
);


// ---------------------------------------------------------
// Core (UART_CLK logic + async FIFOs)
// ---------------------------------------------------------
uart_v4_core #(.AW(FIFO_AW)) uut_uart_core (
        .i_pclk         (i_pclk),
        .i_prst_n       (w_prst_n),
        .i_txWr         (w_txWrEn),
        .i_txData       (i_pwdata[7:0]),
        .o_txFull       (w_txFifoFull),
        .o_txLevel      (w_txLevel),
        .o_txEmpty      (w_txFifoEmpty),
        .o_txAllDone    (w_txAllDone),
        .i_rxRd         (w_rxRdEn),
        .o_rxRdData     (w_rxRdData),
        .o_rxEmpty      (w_rxFifoEmpty),
        .o_rxLevel      (w_rxLevel),
        .o_rxFull       (w_rxFifoFull),

        .i_uclk         (i_uclk),
        .i_urst_n       (w_urst_n),
        .i_enable       (w_actCfg[16]),
        .i_txEn         (w_actCfg[17]),
        .i_rxEn         (w_actCfg[18]),
        .i_baudDiv      (w_actCfg[15:0]),
        .i_data7        (w_actCfg[19]),
        .i_parityMode   (w_actCfg[21:20]),
        .i_stop2        (w_actCfg[22]),
        .i_loopbackEn   (w_actCfg[23]),
        .i_cfgCommit    (w_cfgCommit),
        .o_uIdle        (w_uIdle),
        .i_uartRx       (i_uartRx),
        .o_uartTx       (o_uartTx),
        .o_txBusy       (w_uTxBusy),
        .o_rxBusy       (w_uRxBusy),
        .o_txDone       (w_uTxDone),
        .o_rxValid      (w_uRxValid),
        .o_parityErr    (w_uParityErr),
        .o_frameErr     (w_uFrameErr),
        .o_falseStart   (w_uFalseStart),
        .o_rxOverflow   (w_uRxOverflow)
);

assign w_txBusy      = !w_txAllDone;
assign w_txFifoCount = w_txLevel;       // zero-extended
assign w_rxFifoCount = w_rxLevel;


// ---------------------------------------------------------
// Error events UART_CLK -> PCLK (at least once, merged while in flight)
// ---------------------------------------------------------
uart_v4_event_sync u_evParity (
        .i_sclk(i_uclk), .i_srst_n(w_urst_n), .i_event(w_uParityErr), .o_busy(),
        .i_dclk(i_pclk), .i_drst_n(w_prst_n), .o_pulse(w_parityErr));

uart_v4_event_sync u_evFrame (
        .i_sclk(i_uclk), .i_srst_n(w_urst_n), .i_event(w_uFrameErr), .o_busy(),
        .i_dclk(i_pclk), .i_drst_n(w_prst_n), .o_pulse(w_frameErr));

uart_v4_event_sync u_evOverflow (
        .i_sclk(i_uclk), .i_srst_n(w_urst_n), .i_event(w_uRxOverflow), .o_busy(),
        .i_dclk(i_pclk), .i_drst_n(w_prst_n), .o_pulse(w_rxOverflow));


// ---------------------------------------------------------
// IRQ (V3 module: sticky bits, event wins over a same-cycle W1C clear)
// ---------------------------------------------------------
uart_irq uut_uart_irq (
        .clk            (i_pclk),
        .rst_n          (w_prst_n),
        .i_irqEn        (r_irqEn),
        .i_irqClear     (w_irqClear),
        .i_rxFifoEmpty  (w_rxFifoEmpty),
        .i_txFifoEmpty  (w_txFifoEmpty && w_swTxEn),
        .i_parityErr    (w_parityErr),
        .i_frameErr     (w_frameErr),
        .i_rxOverflow   (w_rxOverflow),
        .o_irqStatus    (w_irqStatus),
        .o_irq          (o_irq)
);


// ---------------------------------------------------------
// IRQ_EN register
// ---------------------------------------------------------
always @(posedge i_pclk or negedge w_prst_n) begin
        if (!w_prst_n)
                r_irqEn <= 5'b00000;
        else if (w_apbAccess && i_pwrite && (i_paddr == ADDR_IRQ_EN))
                r_irqEn <= i_pwdata[4:0];
end


// ---------------------------------------------------------
// APB response : reads 1 wait, writes 0 wait, all outputs registered
// PSLVERR : write error decided at SETUP and used for both the response
//           and the write enables (w_txWrEn, w_cfgWr)
// ---------------------------------------------------------
reg     [31:0]  w_rdData;
reg             w_rdErr;
reg             w_wrErr;
reg     [31:0]  r_prdata;
wire            w_rdCapture;

assign w_rdCapture = w_apbAccess && !i_pwrite && !r_pready;

always @(*) begin
        w_rdData = 32'd0;
        w_rdErr  = 1'b0;
        case (i_paddr)
                ADDR_TXDATA: begin
                        w_rdErr = STRICT_APB_ERR;
                end
                // show-ahead FIFO: the entry is valid now, popped on this edge
                ADDR_RXDATA: begin
                        if (w_rxFifoEmpty)
                                w_rdErr = STRICT_APB_ERR;
                        else
                                w_rdData[9:0] = w_rxRdData;
                end
                ADDR_STATUS: begin
                        w_rdData[0] = w_txFifoEmpty;
                        w_rdData[1] = w_txFifoFull;
                        w_rdData[2] = w_rxFifoEmpty;
                        w_rdData[3] = w_rxFifoFull;
                        w_rdData[4] = w_txBusy;
                        w_rdData[5] = !w_rxFifoEmpty;
                        w_rdData[6] = w_irqStatus[2];
                        w_rdData[7] = w_irqStatus[3];
                        w_rdData[8] = w_irqStatus[4];
                        w_rdData[9] = w_cfgBusy;
                end
                ADDR_CTRL: begin
                        w_rdData[0]   = w_swCfg[16];
                        w_rdData[1]   = w_swCfg[17];
                        w_rdData[2]   = w_swCfg[18];
                        w_rdData[4:3] = w_swCfg[21:20];
                        w_rdData[5]   = w_swCfg[22];
                        w_rdData[6]   = w_swCfg[19];
                        w_rdData[7]   = w_swCfg[23];
                end
                ADDR_BAUDDIV: begin
                        w_rdData[15:0] = w_swCfg[15:0];
                end
                ADDR_IRQ_EN: begin
                        w_rdData[4:0] = r_irqEn;
                end
                ADDR_IRQ_STATUS: begin
                        w_rdData[4:0] = w_irqStatus;
                end
                ADDR_FIFO_LEVEL: begin
                        w_rdData[7:0]  = w_txFifoCount;
                        w_rdData[15:8] = w_rxFifoCount;
                end
                default: begin
                        w_rdErr = STRICT_APB_ERR;
                end
        endcase
end

// write error: V3 STRICT rules + refused config write (always, D10)
always @(*) begin
        w_wrErr = 1'b0;
        case (i_paddr)
                ADDR_TXDATA: begin
                        if (w_txFifoFull)
                                w_wrErr = STRICT_APB_ERR;
                end
                ADDR_RXDATA,
                ADDR_STATUS,
                ADDR_FIFO_LEVEL: begin
                        w_wrErr = STRICT_APB_ERR;
                end
                ADDR_CTRL,
                ADDR_BAUDDIV: begin
                        w_wrErr = w_cfgBusy;    // busy state, not gated by i_cfgWr (decided at SETUP)
                end
                ADDR_IRQ_EN,
                ADDR_IRQ_STATUS: begin
                        w_wrErr = 1'b0;
                end
                default: begin
                        w_wrErr = STRICT_APB_ERR;
                end
        endcase
end

always @(posedge i_pclk or negedge w_prst_n) begin
        if (!w_prst_n) begin
                r_pready <= 1'b0;
                r_prdata <= 32'd0;
                r_pslverr <= 1'b0;
        end else begin
                if (w_apbSetup) begin
                        r_pready  <= i_pwrite;
                        r_pslverr <= i_pwrite ? w_wrErr : 1'b0;
                end else if (w_rdCapture) begin
                        r_pready <= 1'b1;
                        r_prdata <= w_rdData;
                        r_pslverr <= w_rdErr;
                end else begin
                        r_pready <= 1'b0;
                        r_pslverr <= 1'b0;
                end
        end
end

always @(*) begin
        o_pready  = r_pready;
        o_prdata  = r_prdata;
        o_pslverr = r_pslverr;
end

endmodule
