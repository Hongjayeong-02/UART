`timescale 1ns/1ps

// UART V4 core: everything that runs on UART_CLK, plus the two async FIFOs
// that carry data between PCLK and UART_CLK.
//
//   PCLK side : TX FIFO write port, RX FIFO read port (show-ahead)
//   UCLK side : baud gen, TX controller + uart_tx, uart_rx + RX FIFO write,
//               config inputs (already in UCLK, from uart_v4_cfg_cdc),
//               event pulses / status levels (to be synchronized at top)
//
// Reused from V3: uart_tx.v (no change). uart_v4_rx.v = V3 uart_rx.v + BRK_WAIT
// state after a frame error (V3 erratum, see cdc_spec.md). The RX pin has a
// 2-FF synchronizer inside the receiver.
//
// Rules (see cdc_spec.md D15-D18):
//   - o_uIdle = TX controller idle, uart_tx ready, uart_rx not busy.
//     uart_v4_cfg_cdc applies a new config only when o_uIdle = 1.
//   - No TX pop on the config commit edge: the next byte always starts with
//     the new config and a cleared baud counter.
//   - TX pops only when enable && txEn (V3 popped while txEn = 0 and sent the
//     byte to a forced-high pin; V4 keeps it in the FIFO).
//   - RX FIFO entry = {frameErr, parityErr, data[7:0]} (same as V3).
//   - PCLK status (step 6): FIFO levels from the async FIFOs, and
//     o_txAllDone = every byte accepted on the PCLK side has finished on the
//     line. PCLK counts accepted pushes; UART_CLK counts txDone in a Gray
//     counter that crosses with a 2-FF synchronizer (D20).

module uart_v4_core #(
        parameter AW = 4                        // FIFO depth = 2**AW
)(
        // ---------------- PCLK domain ----------------
        input   wire            i_pclk,
        input   wire            i_prst_n,

        input   wire            i_txWr,
        input   wire    [7:0]   i_txData,
        output  wire            o_txFull,
        output  wire    [AW:0]  o_txLevel,
        output  wire            o_txEmpty,
        output  wire            o_txAllDone,

        input   wire            i_rxRd,
        output  wire    [9:0]   o_rxRdData,
        output  wire            o_rxEmpty,
        output  wire    [AW:0]  o_rxLevel,
        output  wire            o_rxFull,

        // ---------------- UART_CLK domain ----------------
        input   wire            i_uclk,
        input   wire            i_urst_n,

        input   wire            i_enable,
        input   wire            i_txEn,
        input   wire            i_rxEn,
        input   wire    [15:0]  i_baudDiv,
        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,
        input   wire            i_loopbackEn,
        input   wire            i_cfgCommit,

        output  wire            o_uIdle,

        input   wire            i_uartRx,
        output  wire            o_uartTx,

        output  wire            o_txBusy,
        output  wire            o_rxBusy,
        output  wire            o_txDone,
        output  wire            o_rxValid,
        output  wire            o_parityErr,
        output  wire            o_frameErr,
        output  wire            o_falseStart,
        output  reg             o_rxOverflow
);

localparam T_IDLE = 1'b0;
localparam T_WAIT = 1'b1;

wire            w_tick16;

wire    [7:0]   w_txFifoData;
wire            w_txFifoEmpty;
wire            w_txGo;
wire            w_txReady;
wire            w_uartTx;

reg             r_tState;
reg             r_txValid;
reg     [7:0]   r_txData;

wire            w_uartRx;
wire    [7:0]   w_rxData;
wire            w_rxFifoFull;
wire            w_rxFifoWr;
reg             r_paritySave;
reg             r_frameSave;


// ---------------------------------------------------------
// Baud generator (clear on config commit)
// ---------------------------------------------------------
uart_v4_baud_gen u_baud (
        .i_clk          (i_uclk),
        .i_rst_n        (i_urst_n),
        .i_enable       (i_enable),
        .i_cfgCommit    (i_cfgCommit),
        .i_baudDiv      (i_baudDiv),
        .o_tick16       (w_tick16)
);


// ---------------------------------------------------------
// TX FIFO: PCLK write -> UCLK read
// ---------------------------------------------------------
uart_async_fifo #(.DW(8), .AW(AW)) u_txFifo (
        .i_wclk         (i_pclk),
        .i_wrst_n       (i_prst_n),
        .i_wrEn         (i_txWr),
        .i_wrData       (i_txData),
        .o_full         (o_txFull),
        .o_wLevel       (o_txLevel),
        .o_wEmpty       (o_txEmpty),

        .i_rclk         (i_uclk),
        .i_rrst_n       (i_urst_n),
        .i_rdEn         (w_txGo),
        .o_rdData       (w_txFifoData),
        .o_empty        (w_txFifoEmpty),
        .o_rLevel       (),
        .o_rFull        ()
);


// ---------------------------------------------------------
// TX controller: show-ahead FIFO -> one-cycle txValid
// ---------------------------------------------------------
assign w_txGo = (r_tState == T_IDLE) &&
                !r_txValid &&
                w_txReady &&
                !w_txFifoEmpty &&
                i_enable && i_txEn &&
                !i_cfgCommit;

always @(posedge i_uclk or negedge i_urst_n) begin
        if (!i_urst_n) begin
                r_tState  <= T_IDLE;
                r_txValid <= 1'b0;
                r_txData  <= 8'd0;
        end else begin
                r_txValid <= 1'b0;
                case (r_tState)
                        T_IDLE: begin
                                if (w_txGo) begin
                                        r_txData  <= w_txFifoData;
                                        r_txValid <= 1'b1;
                                        r_tState  <= T_WAIT;
                                end
                        end
                        T_WAIT: begin
                                if (o_txDone)
                                        r_tState <= T_IDLE;
                        end
                        default: begin
                                r_tState <= T_IDLE;
                        end
                endcase
        end
end

uart_tx u_tx (
        .clk            (i_uclk),
        .rst_n          (i_urst_n),
        .i_tick16       (w_tick16),
        .i_txValid      (r_txValid),
        .i_txData       (r_txData),
        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),
        .o_txReady      (w_txReady),
        .o_txBusy       (o_txBusy),
        .o_txDone       (o_txDone),
        .o_uartTx       (w_uartTx)
);

assign o_uartTx = (i_enable && i_txEn) ? w_uartTx : 1'b1;


// ---------------------------------------------------------
// RX
// ---------------------------------------------------------
assign w_uartRx = (!i_enable || !i_rxEn) ? 1'b1 :
                  (i_loopbackEn ? w_uartTx : i_uartRx);

uart_v4_rx u_rx (
        .clk            (i_uclk),
        .rst_n          (i_urst_n),
        .i_tick16       (w_tick16),
        .i_uartRx       (w_uartRx),
        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),
        .o_rxData       (w_rxData),
        .o_rxValid      (o_rxValid),
        .o_rxBusy       (o_rxBusy),
        .o_parityErr    (o_parityErr),
        .o_frameErr     (o_frameErr),
        .o_falseStart   (o_falseStart)
);

// Error flags arrive before rxValid: keep them until the byte is written.
always @(posedge i_uclk or negedge i_urst_n) begin
        if (!i_urst_n) begin
                r_paritySave <= 1'b0;
                r_frameSave  <= 1'b0;
        end else begin
                if (o_parityErr) r_paritySave <= 1'b1;
                if (o_frameErr)  r_frameSave  <= 1'b1;
                if (o_rxValid) begin
                        r_paritySave <= 1'b0;
                        r_frameSave  <= 1'b0;
                end
        end
end

assign w_rxFifoWr = o_rxValid && !w_rxFifoFull;

always @(posedge i_uclk or negedge i_urst_n) begin
        if (!i_urst_n)
                o_rxOverflow <= 1'b0;
        else
                o_rxOverflow <= o_rxValid && w_rxFifoFull;
end


// ---------------------------------------------------------
// RX FIFO: UCLK write -> PCLK read
// ---------------------------------------------------------
uart_async_fifo #(.DW(10), .AW(AW)) u_rxFifo (
        .i_wclk         (i_uclk),
        .i_wrst_n       (i_urst_n),
        .i_wrEn         (w_rxFifoWr),
        .i_wrData       ({r_frameSave | o_frameErr,
                          r_paritySave | o_parityErr,
                          w_rxData}),
        .o_full         (w_rxFifoFull),
        .o_wLevel       (),
        .o_wEmpty       (),

        .i_rclk         (i_pclk),
        .i_rrst_n       (i_prst_n),
        .i_rdEn         (i_rxRd),
        .o_rdData       (o_rxRdData),
        .o_empty        (o_rxEmpty),
        .o_rLevel       (o_rxLevel),
        .o_rFull        (o_rxFull)
);


// ---------------------------------------------------------
// TX completion count (D20)
//   PCLK : r_pushCnt  = bytes accepted into the TX FIFO
//   UCLK : r_doneGray = frames finished (Gray, +1 per txDone)
//   o_txAllDone = (r_pushCnt == done count seen in PCLK)
//   Up to DEPTH + 1 bytes can be pending (FIFO + one in uart_tx), which
//   fits in AW+1 bits (max 2**(AW+1) - 1 >= DEPTH + 1 for AW >= 1).
// ---------------------------------------------------------
reg     [AW:0]  r_pushCnt;
reg     [AW:0]  r_doneBin;
reg     [AW:0]  r_doneGray;
reg     [AW:0]  r_doneSync1;
reg     [AW:0]  r_doneSync2;
wire    [AW:0]  w_doneBinNext;
reg     [AW:0]  w_doneSyncBin;
integer         k;

assign w_doneBinNext = r_doneBin + {{AW{1'b0}}, o_txDone};

always @(posedge i_uclk or negedge i_urst_n) begin
        if (!i_urst_n) begin
                r_doneBin  <= {(AW+1){1'b0}};
                r_doneGray <= {(AW+1){1'b0}};
        end else begin
                r_doneBin  <= w_doneBinNext;
                r_doneGray <= (w_doneBinNext >> 1) ^ w_doneBinNext;
        end
end

always @(posedge i_pclk or negedge i_prst_n) begin
        if (!i_prst_n) begin
                r_pushCnt   <= {(AW+1){1'b0}};
                r_doneSync1 <= {(AW+1){1'b0}};
                r_doneSync2 <= {(AW+1){1'b0}};
        end else begin
                if (i_txWr && !o_txFull)
                        r_pushCnt <= r_pushCnt + 1'b1;
                r_doneSync1 <= r_doneGray;
                r_doneSync2 <= r_doneSync1;
        end
end

always @(*) begin
        w_doneSyncBin[AW] = r_doneSync2[AW];
        for (k = AW - 1; k >= 0; k = k - 1)
                w_doneSyncBin[k] = w_doneSyncBin[k + 1] ^ r_doneSync2[k];
end

assign o_txAllDone = (r_pushCnt == w_doneSyncBin);


// ---------------------------------------------------------
// Idle for config apply
// ---------------------------------------------------------
assign o_uIdle = (r_tState == T_IDLE) &&
                 !r_txValid &&
                 w_txReady &&
                 !o_rxBusy;

endmodule
