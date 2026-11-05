`timescale 1ns/1ps

module uart_apb #(
        // Per spec sec.10.2: the base/default behavior is a silent drop
        // (checked via STATUS/FIFO_LEVEL polling) - PSLVERR-on-illegal-
        // access is an opt-in "strict mode", not the default. Keep this
        // at 0 unless the system integrator explicitly wants strict APB
        // error reporting.
        parameter STRICT_APB_ERR = 1'b0,
        // Per spec sec.8.3 / sec.16: default FIFO depth is 8 for both
        // TX and RX, parameterizable if a design needs more headroom.
        parameter TX_FIFO_DEPTH  = 8,
        parameter RX_FIFO_DEPTH  = 8
)(
        input   wire            clk,
        input   wire            rst_n,

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


// ---------------------------------------------------------
// Reset synchronizer (asynchronous assert, synchronous deassert)
//
// The external rst_n only drives these two flops. All other flops
// use w_rst_n, which is released on a clk edge, so their
// recovery/removal checks are against an internally launched,
// clock-aligned signal instead of an assumed input delay.
// rst_n assertion still resets the whole IP immediately.
// Deassertion is delayed by 2 clk cycles.
// ---------------------------------------------------------
reg     [1:0]   r_rstSync;
wire            w_rst_n;

always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
                r_rstSync <= 2'b00;
        else
                r_rstSync <= {r_rstSync[0], 1'b1};
end

assign w_rst_n = r_rstSync[1];


// ---------------------------------------------------------
// Register Address
// ---------------------------------------------------------
localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_IRQ_EN      = 8'h14;
localparam ADDR_IRQ_STATUS  = 8'h18;
localparam ADDR_FIFO_LEVEL  = 8'h1C;


// ---------------------------------------------------------
// CONTROL Register
// ---------------------------------------------------------
reg             r_uartEn;
reg             r_txEn;
reg             r_rxEn;

reg     [1:0]   r_parityMode;

reg             r_stop2;
reg             r_data7;
reg             r_loopbackEn;


// ---------------------------------------------------------
// BAUD_DIV
// ---------------------------------------------------------
reg     [15:0]  r_baudDiv;


// ---------------------------------------------------------
// IRQ ENABLE
// ---------------------------------------------------------
reg     [4:0]   r_irqEn;


// ---------------------------------------------------------
// RX Read
// ---------------------------------------------------------
reg             r_rxReadPending;
reg             r_pready;       // padall_read_opt: registered PREADY


// ---------------------------------------------------------
// UART Core
// ---------------------------------------------------------
wire            w_txFifoFull;
wire            w_txFifoEmpty;
wire    [4:0]   w_txFifoCount;

wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;


wire    [7:0]   w_rxData;

wire            w_rxParityErrData;
wire            w_rxFrameErrData;

wire            w_rxFifoFull;
wire            w_rxFifoEmpty;
wire    [4:0]   w_rxFifoCount;

wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;
wire            w_rxOverflow;


// ---------------------------------------------------------
// IRQ
// ---------------------------------------------------------
wire    [4:0]   w_irqStatus;
wire    [4:0]   w_irqClear;


// ---------------------------------------------------------
// APB
// ---------------------------------------------------------
wire            w_apbAccess;

wire            w_txWrEn;
wire            w_rxRdEn;


assign w_apbAccess = i_psel &&
                     i_penable;


// TX_DATA Write
assign w_txWrEn = w_apbAccess &&
                  i_pwrite &&
                  (i_paddr == ADDR_TXDATA) &&
                  r_uartEn &&
                  r_txEn &&
                  !w_txFifoFull;


// ---------------------------------------------------------
// TX_DATA write pipeline (timing opt, 1 GHz)
//
// Original: APB access -> address decode -> r_txEn gating -> FIFO
//           !full -> wrPtr decode -> mem enable -> data MUX, all in
//           one cycle (worst R2R path, 9 logic levels).
// Now     : the accepted TX_DATA write is registered (r_txPush /
//           r_txPushData) and pushed into the FIFO on the NEXT cycle.
//
// Software-visible behavior is unchanged: an APB transfer needs at
// least 2 cycles (SETUP + ACCESS), so the push (cycle N+1) and the
// FIFO count/full update (visible from N+2) complete before the next
// ACCESS phase can sample STATUS / FIFO_LEVEL / TX_DATA again.
// CTRL (r_txEn/r_uartEn) also cannot change before the push for the
// same reason. TX line start is delayed by 1 clk (internal only).
// ---------------------------------------------------------
reg             r_txPush;
reg     [7:0]   r_txPushData;

wire            w_txDataWr;

// address-only decode for the data capture (r_txEn kept out of the
// 8-bit data enable path)
assign w_txDataWr = w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_TXDATA);

always @(posedge clk or negedge w_rst_n) begin
        if (!w_rst_n)
                r_txPush <= 1'b0;
        else
                r_txPush <= w_txWrEn;
end

// data register: no reset (only consumed when r_txPush == 1, which
// always follows a capture)
always @(posedge clk) begin
        if (w_txDataWr)
                r_txPushData <= i_pwdata[7:0];
end


// RX_DATA Read
assign w_rxRdEn = w_apbAccess &&
                  !i_pwrite &&
                  (i_paddr == ADDR_RXDATA) &&
                  !r_rxReadPending &&
                  !r_pready &&          // read_opt: pop only in ACCESS1
                  !w_rxFifoEmpty;


// IRQ_STATUS = RW1C
assign w_irqClear =
        (w_apbAccess &&
         i_pwrite &&
         (i_paddr == ADDR_IRQ_STATUS)) ?

        i_pwdata[4:0] :

        5'b00000;


// ---------------------------------------------------------
// UART Core
// ---------------------------------------------------------
uart_core #(
        .TX_FIFO_DEPTH      (TX_FIFO_DEPTH),
        .RX_FIFO_DEPTH      (RX_FIFO_DEPTH)
) uut_uart_core (
        .clk                (clk),
        .rst_n              (w_rst_n),

        .i_enable           (r_uartEn),
        .i_txEn             (r_txEn),
        .i_rxEn             (r_rxEn),

        .i_baudDiv          (r_baudDiv),

        .i_data7            (r_data7),
        .i_parityMode       (r_parityMode),
        .i_stop2            (r_stop2),
        .i_loopbackEn       (r_loopbackEn),

        .i_txWrEn           (r_txPush),
        .i_txData           (r_txPushData),

        .i_rxRdEn           (w_rxRdEn),

        .i_uartRx           (i_uartRx),
        .o_uartTx           (o_uartTx),

        .o_txFifoFull       (w_txFifoFull),
        .o_txFifoEmpty      (w_txFifoEmpty),
        .o_txFifoCount      (w_txFifoCount),

        .o_txReady          (w_txReady),
        .o_txBusy           (w_txBusy),
        .o_txDone           (w_txDone),

        .o_rxData           (w_rxData),
        .o_rxParityErrData  (w_rxParityErrData),
        .o_rxFrameErrData   (w_rxFrameErrData),

        .o_rxFifoFull       (w_rxFifoFull),
        .o_rxFifoEmpty      (w_rxFifoEmpty),
        .o_rxFifoCount      (w_rxFifoCount),

        .o_rxValid          (w_rxValid),
        .o_rxBusy           (w_rxBusy),

        .o_parityErr        (w_parityErr),
        .o_frameErr         (w_frameErr),
        .o_falseStart       (w_falseStart),

        .o_rxOverflow       (w_rxOverflow)
);


// ---------------------------------------------------------
// IRQ Controller
// ---------------------------------------------------------
uart_irq uut_uart_irq (
        .clk            (clk),
        .rst_n          (w_rst_n),

        .i_irqEn        (r_irqEn),
        .i_irqClear     (w_irqClear),

        .i_rxFifoEmpty  (w_rxFifoEmpty),

        // TX Empty IRQ는 TX Enable일 때만 발생
        .i_txFifoEmpty  (w_txFifoEmpty && r_txEn),

        .i_parityErr    (w_parityErr),
        .i_frameErr     (w_frameErr),
        .i_rxOverflow   (w_rxOverflow),

        .o_irqStatus    (w_irqStatus),
        .o_irq          (o_irq)
);


// ---------------------------------------------------------
// Register Write
// ---------------------------------------------------------
always @(posedge clk or negedge w_rst_n) begin
        if (!w_rst_n) begin

                r_uartEn       <= 1'b0;
                r_txEn         <= 1'b0;
                r_rxEn         <= 1'b0;

                r_parityMode   <= 2'b00;

                r_stop2        <= 1'b0;
                r_data7        <= 1'b0;
                r_loopbackEn   <= 1'b0;

                // Target board: CORE-5300 (Zynq-7000 SoC lab kit), PL fabric
                // clock = 50MHz (board pin U18, PL_clk). Default baud = 9600.
                // BAUD_DIV = round(PCLK/(16*BAUD)) - 1
                //          = round(50_000_000/(16*9600)) - 1 = 325
                // Actual baud = 50_000_000/(16*(325+1)) = 9585.9 bps
                // (~-0.15% error, well within the spec's 2% budget).
                // NOTE: simulation testbenches use their own fast-sim
                // BAUD_DIV values (8, 312, etc.) written explicitly over
                // APB and do not rely on this reset default.
                r_baudDiv      <= 16'd325;

                r_irqEn        <= 5'b00000;

        end else begin

                // CONTROL
                if (w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_CTRL)) begin

                        r_uartEn       <= i_pwdata[0];
                        r_txEn         <= i_pwdata[1];
                        r_rxEn         <= i_pwdata[2];

                        r_parityMode   <= i_pwdata[4:3];

                        r_stop2        <= i_pwdata[5];
                        r_data7        <= i_pwdata[6];
                        r_loopbackEn   <= i_pwdata[7];

                end


                // BAUD_DIV
                if (w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_BAUDDIV)) begin

                        r_baudDiv <= i_pwdata[15:0];

                end


                // IRQ_ENABLE
                if (w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_IRQ_EN)) begin

                        r_irqEn <= i_pwdata[4:0];

                end

        end
end


// ---------------------------------------------------------
// RX FIFO Synchronous Read
// ---------------------------------------------------------
always @(posedge clk or negedge w_rst_n) begin
        if (!w_rst_n) begin

                r_rxReadPending <= 1'b0;

        end else begin

                if (!w_apbAccess)
                        r_rxReadPending <= 1'b0;

                else if (w_rxRdEn)
                        r_rxReadPending <= 1'b1;

        end
end


// ---------------------------------------------------------
// APB Read / Response  (padall_read_opt)
//
// V3 baseline: PRDATA / PREADY / PSLVERR were combinational from
// PADDR / PWRITE. With PADs on every port this is a one-cycle
//   PAD_in -> decode / read mux -> PAD_out
// path, and 17 I/O paths missed setup (WNS -0.318 ns, 10 ns, full PAD).
//
// Now every READ takes one wait state, the same shape RX_DATA already
// had in V3:
//   SETUP   : r_pready <= 0
//   ACCESS1 : PREADY = 0. The read mux is sampled into r_prdata in the
//             same cycle V3 returned it, so the same register values are
//             seen (incl. TX push visibility, see TX_DATA note above).
//             RX_DATA: FIFO pop is issued here and ONLY here
//             (w_rxRdEn gated with !r_pready). Without that gate a
//             byte arriving during ACCESS2 of an empty-FIFO read was
//             popped and lost (found by 6_verify/read_opt diff TB).
//   ACCESS2 : PREADY = 1, PRDATA from flops only.
// WRITE stays zero-wait (r_pready <= 1 at SETUP).
//
// PRDATA / PREADY now come from flops only: no input -> output path.
// PSLVERR: read errors registered; write errors stay combinational,
// but only exist when STRICT_APB_ERR = 1 (default 0 -> constant 0).
// Cost: +1 clk on every read except RX_DATA (already had 1 wait).
// ---------------------------------------------------------
reg     [31:0]  w_rdData;       // combinational read mux
reg             w_rdErr;        // combinational, STRICT_APB_ERR only
reg             w_wrErr;        // combinational, STRICT_APB_ERR only

reg     [31:0]  r_prdata;
reg             r_rdIsRx;
reg             r_rdErr;

wire            w_apbSetup;
wire            w_rdCapture;

assign w_apbSetup  = i_psel &&
                     !i_penable;

assign w_rdCapture = w_apbAccess &&
                     !i_pwrite &&
                     !r_pready;


// read mux (same register map / bit positions as V3)
always @(*) begin

        w_rdData = 32'd0;
        w_rdErr  = 1'b0;

        case (i_paddr)

                ADDR_TXDATA: begin
                        w_rdErr = STRICT_APB_ERR;
                end

                // data itself comes from the FIFO in ACCESS2 (r_rdIsRx)
                ADDR_RXDATA: begin
                        if (w_rxFifoEmpty && !r_rxReadPending)
                                w_rdErr = STRICT_APB_ERR;
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
                end

                ADDR_CTRL: begin
                        w_rdData[0]   = r_uartEn;
                        w_rdData[1]   = r_txEn;
                        w_rdData[2]   = r_rxEn;
                        w_rdData[4:3] = r_parityMode;
                        w_rdData[5]   = r_stop2;
                        w_rdData[6]   = r_data7;
                        w_rdData[7]   = r_loopbackEn;
                end

                ADDR_BAUDDIV: begin
                        w_rdData[15:0] = r_baudDiv;
                end

                ADDR_IRQ_EN: begin
                        w_rdData[4:0] = r_irqEn;
                end

                ADDR_IRQ_STATUS: begin
                        w_rdData[4:0] = w_irqStatus;
                end

                ADDR_FIFO_LEVEL: begin
                        w_rdData[7:0]  = {3'b000, w_txFifoCount};
                        w_rdData[15:8] = {3'b000, w_rxFifoCount};
                end

                default: begin
                        w_rdErr = STRICT_APB_ERR;
                end

        endcase
end


// write error (STRICT_APB_ERR only, same rules as V3)
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
                ADDR_BAUDDIV,
                ADDR_IRQ_EN,
                ADDR_IRQ_STATUS: begin
                        w_wrErr = 1'b0;
                end

                default: begin
                        w_wrErr = STRICT_APB_ERR;
                end

        endcase
end


// response state + read data register
always @(posedge clk or negedge w_rst_n) begin
        if (!w_rst_n) begin

                r_pready <= 1'b0;
                r_prdata <= 32'd0;
                r_rdIsRx <= 1'b0;
                r_rdErr  <= 1'b0;

        end else begin

                if (w_apbSetup) begin

                        // write: ready in ACCESS1, read: wait one cycle
                        r_pready <= i_pwrite;
                        r_rdErr  <= 1'b0;

                end else if (w_rdCapture) begin

                        r_pready <= 1'b1;
                        r_prdata <= w_rdData;
                        r_rdErr  <= w_rdErr;
                        r_rdIsRx <= (i_paddr == ADDR_RXDATA) &&
                                    !w_rxFifoEmpty;

                end else begin

                        r_pready <= 1'b0;

                end

        end
end


// outputs: flops only (PSLVERR write term exists only if STRICT)
always @(*) begin

        o_pready = r_pready;

        if (r_rdIsRx)
                o_prdata = {22'd0,
                            w_rxFrameErrData,
                            w_rxParityErrData,
                            w_rxData};
        else
                o_prdata = r_prdata;

        if (w_apbAccess && i_pwrite)
                o_pslverr = w_wrErr;
        else
                o_pslverr = r_rdErr;

end


endmodule
