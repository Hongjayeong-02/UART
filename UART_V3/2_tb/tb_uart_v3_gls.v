
`timescale 1ns/1ps

// ============================================================
// UART V3 - PRE-LAYOUT GATE-LEVEL SIMULATION
// Technology : GPDK045
// DUT        : uart_chip_top
// Clock      : 1 MHz (1000 ns)
//
// Supports:
//   1. Zero-delay Gate-Level Simulation
//   2. SDF Back-Annotated Timing Simulation
//
// APB Rules:
//   SETUP  : PSEL=1, PENABLE=0
//   ACCESS : PSEL=1, PENABLE=1
//   SAMPLE : PREADY at rising clock edge
//   READ   : PRDATA at the completion rising edge
// ============================================================

module tb_uart_v3_gls;

// ------------------------------------------------------------
// Register Address
// ------------------------------------------------------------

localparam ADDR_TXDATA     = 8'h00;
localparam ADDR_RXDATA     = 8'h04;
localparam ADDR_STATUS     = 8'h08;
localparam ADDR_CTRL       = 8'h0C;
localparam ADDR_BAUDDIV    = 8'h10;
localparam ADDR_FIFO_LEVEL = 8'h1C;

localparam MAX_APB_WAIT = 16;

// ------------------------------------------------------------
// Clock / Reset
// ------------------------------------------------------------

reg clk;
reg rst_n;

// ------------------------------------------------------------
// APB Master
// ------------------------------------------------------------

reg         r_psel;
reg         r_penable;
reg         r_pwrite;
reg  [7:0]  r_paddr;
reg  [31:0] r_pwdata;

wire [31:0] w_prdata;
wire        w_pready;
wire        w_pslverr;

// ------------------------------------------------------------
// UART / IRQ
// ------------------------------------------------------------

wire w_uartLine;
wire w_irq;

// ------------------------------------------------------------
// Test Registers
// ------------------------------------------------------------

reg [31:0] r_readData;
reg [31:0] r_fifoLevel;
reg [31:0] r_status;
reg [31:0] r_statusAfter;
reg [31:0] r_rxData;

integer r_errorCnt;
integer r_txEdgeCnt;
integer r_rxReadWaitCnt;

// ============================================================
// DUT : SYNTHESIZED UART CHIP TOP
// ============================================================

uart_chip_top uut (
    .clk        (clk),
    .rst_n      (rst_n),

    .i_psel     (r_psel),
    .i_penable  (r_penable),
    .i_pwrite   (r_pwrite),
    .i_paddr    (r_paddr),
    .i_pwdata   (r_pwdata),

    .o_prdata   (w_prdata),
    .o_pready   (w_pready),
    .o_pslverr  (w_pslverr),

    .i_uartRx   (w_uartLine),
    .o_uartTx   (w_uartLine),
    .o_irq      (w_irq)
);

// ============================================================
// CLOCK : 1 MHz
// ============================================================

initial begin
    clk = 1'b0;
    forever #500 clk = ~clk;
end

// ============================================================
// UART TX FALLING EDGE MONITOR
// ============================================================

always @(negedge w_uartLine) begin
    if (rst_n === 1'b1) begin

        r_txEdgeCnt = r_txEdgeCnt + 1;

        $display(
            "[TIME=%0t] UART TX FALLING EDGE = %0d",
            $time,
            r_txEdgeCnt
        );

    end
end

// ============================================================
// APB WRITE TASK
//
// PREADY must be sampled at a rising clock edge.
// The ACCESS phase remains asserted during wait states.
// ============================================================

task apb_write;

    input [7:0]  addr;
    input [31:0] data;

    integer wait_cnt;

    begin

        // SETUP
        @(negedge clk);

        r_psel    = 1'b1;
        r_penable = 1'b0;
        r_pwrite  = 1'b1;
        r_paddr   = addr;
        r_pwdata  = data;

        // ACCESS
        @(negedge clk);

        r_penable = 1'b1;
        wait_cnt  = 0;

        // Sample only on rising clock edges
        begin : WRITE_WAIT_LOOP

            forever begin

                @(posedge clk);

                if (w_pready === 1'b1) begin

                    if (w_pslverr !== 1'b0) begin

                        $display(
                            "FAIL: APB WRITE PSLVERR ADDR=%02h",
                            addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                    end
                    else begin

                        $display(
                            "APB WRITE ADDR=%02h DATA=%08h WAIT=%0d",
                            addr,
                            data,
                            wait_cnt
                        );

                    end

                    disable WRITE_WAIT_LOOP;

                end
                else if (w_pready === 1'b0) begin

                    wait_cnt = wait_cnt + 1;

                    $display(
                        "APB WRITE WAIT ADDR=%02h COUNT=%0d",
                        addr,
                        wait_cnt
                    );

                    if (wait_cnt >= MAX_APB_WAIT) begin

                        $display(
                            "FAIL: APB WRITE TIMEOUT ADDR=%02h",
                            addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                        disable WRITE_WAIT_LOOP;

                    end

                end
                else begin

                    $display(
                        "FAIL: APB WRITE PREADY UNKNOWN ADDR=%02h",
                        addr
                    );

                    r_errorCnt = r_errorCnt + 1;

                    disable WRITE_WAIT_LOOP;

                end

            end

        end

        // End the transfer after the completion edge
        @(negedge clk);

        r_psel    = 1'b0;
        r_penable = 1'b0;
        r_pwrite  = 1'b0;
        r_paddr   = 8'd0;
        r_pwdata  = 32'd0;

    end

endtask

// ============================================================
// APB READ TASK
//
// Do not sample PREADY immediately after PENABLE changes.
//
// At each rising edge:
//   PREADY=0 -> Hold ACCESS and wait
//   PREADY=1 -> Capture PRDATA and complete
// ============================================================

task apb_read;

    input  [7:0]  addr;
    output [31:0] data;

    integer wait_cnt;

    begin

        data = 32'd0;

        // SETUP
        @(negedge clk);

        r_psel    = 1'b1;
        r_penable = 1'b0;
        r_pwrite  = 1'b0;
        r_paddr   = addr;
        r_pwdata  = 32'd0;

        // ACCESS
        @(negedge clk);

        r_penable = 1'b1;
        wait_cnt  = 0;

        // Sample on rising clock edges
        begin : READ_WAIT_LOOP

            forever begin

                @(posedge clk);

                $display(
                    "APB EDGE ADDR=%02h PREADY=%b PRDATA=%08h",
                    addr,
                    w_pready,
                    w_prdata
                );

                if (w_pready === 1'b1) begin

                    // Capture before DUT sequential updates
                    data = w_prdata;

                    if (w_pslverr !== 1'b0) begin

                        $display(
                            "FAIL: APB READ PSLVERR ADDR=%02h",
                            addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                    end

                    $display(
                        "APB READ ADDR=%02h DATA=%08h WAIT=%0d",
                        addr,
                        data,
                        wait_cnt
                    );

                    disable READ_WAIT_LOOP;

                end
                else if (w_pready === 1'b0) begin

                    wait_cnt = wait_cnt + 1;

                    $display(
                        "APB WAIT ADDR=%02h PREADY=0 COUNT=%0d",
                        addr,
                        wait_cnt
                    );

                    if (wait_cnt >= MAX_APB_WAIT) begin

                        $display(
                            "FAIL: APB READ TIMEOUT ADDR=%02h",
                            addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                        disable READ_WAIT_LOOP;

                    end

                end
                else begin

                    $display(
                        "FAIL: APB READ PREADY UNKNOWN ADDR=%02h",
                        addr
                    );

                    r_errorCnt = r_errorCnt + 1;

                    disable READ_WAIT_LOOP;

                end

            end

        end

        if (addr == ADDR_RXDATA)
            r_rxReadWaitCnt = wait_cnt;

        // End the transfer
        @(negedge clk);

        r_psel    = 1'b0;
        r_penable = 1'b0;
        r_pwrite  = 1'b0;
        r_paddr   = 8'd0;

    end

endtask

// ============================================================
// MAIN TEST
// ============================================================

initial begin

    // Initialization
    rst_n            = 1'b0;

    r_psel           = 1'b0;
    r_penable        = 1'b0;
    r_pwrite         = 1'b0;
    r_paddr          = 8'd0;
    r_pwdata         = 32'd0;

    r_readData       = 32'd0;
    r_fifoLevel      = 32'd0;
    r_status         = 32'd0;
    r_statusAfter    = 32'd0;
    r_rxData         = 32'd0;

    r_errorCnt       = 0;
    r_txEdgeCnt      = 0;
    r_rxReadWaitCnt  = 0;

    $dumpfile("uart_v3_gls.vcd");
    $dumpvars(0, tb_uart_v3_gls);

    $display("====================================");
    $display(" UART V3 GATE-LEVEL SIMULATION");
    $display(" CLOCK : 1 MHz");
    $display(" PAD   : RX / TX");
    $display(" APB   : CLOCK-EDGE PREADY HANDSHAKE");
    $display("====================================");

    // --------------------------------------------------------
    // TEST 0 : RESET
    // --------------------------------------------------------

    $display("------------------------------------");
    $display(" TEST 0 : RESET");
    $display("------------------------------------");

    repeat (6) @(negedge clk);

    rst_n = 1'b1;

    repeat (5) @(posedge clk);

    $display("RESET RELEASED");

    // --------------------------------------------------------
    // TEST 1 : APB CONFIGURATION
    // --------------------------------------------------------

    $display("------------------------------------");
    $display(" TEST 1 : APB CONFIGURATION");
    $display("------------------------------------");

    // BAUDDIV = 8
    apb_write(ADDR_BAUDDIV, 32'd8);

    // UART EN + TX EN + RX EN
    // Internal loopback disabled
    apb_write(ADDR_CTRL, 32'h0000_0007);

    apb_read(ADDR_CTRL, r_readData);

    if (r_readData[7:0] === 8'h07) begin
        $display("PASS: APB CONTROL REGISTER");
    end
    else begin

        $display(
            "FAIL: APB CONTROL REGISTER = %08h",
            r_readData
        );

        r_errorCnt = r_errorCnt + 1;

    end

    // --------------------------------------------------------
    // TEST 2 : UART TX / EXTERNAL LOOPBACK
    // --------------------------------------------------------

    $display("------------------------------------");
    $display(" TEST 2 : UART TX");
    $display("------------------------------------");

    apb_write(ADDR_TXDATA, 32'h0000_00A5);

    // Allow complete TX/RX frame
    repeat (2200) @(posedge clk);

    $display(
        "TX EDGE COUNT = %0d",
        r_txEdgeCnt
    );

    $display(
        "UART LINE = %b",
        w_uartLine
    );

    if (r_txEdgeCnt > 0) begin
        $display("PASS: UART TX PAD TRANSITIONS");
    end
    else begin

        $display("FAIL: NO UART TX TRANSITIONS");

        r_errorCnt = r_errorCnt + 1;

    end

    // --------------------------------------------------------
    // TEST 3 : RX FIFO STATUS
    // --------------------------------------------------------

    $display("------------------------------------");
    $display(" TEST 3 : RX FIFO STATUS");
    $display("------------------------------------");

    apb_read(ADDR_FIFO_LEVEL, r_fifoLevel);

    $display(
        "FIFO LEVEL = %08h",
        r_fifoLevel
    );

    apb_read(ADDR_STATUS, r_status);

    $display(
        "UART STATUS = %08h",
        r_status
    );

    if (r_status[5] === 1'b1) begin
        $display("PASS: RX DATA AVAILABLE");
    end
    else begin

        $display("FAIL: RX DATA NOT AVAILABLE");

        r_errorCnt = r_errorCnt + 1;

    end

    // --------------------------------------------------------
    // TEST 4 : RXDATA + APB WAIT STATE
    // --------------------------------------------------------

    $display("------------------------------------");
    $display(" TEST 4 : RX DATA READ");
    $display("------------------------------------");

    apb_read(ADDR_RXDATA, r_rxData);

    $display(
        "RX WAIT CYCLES = %0d",
        r_rxReadWaitCnt
    );

    $display(
        "RX DATA = %02h",
        r_rxData[7:0]
    );

    if (r_rxReadWaitCnt >= 1) begin
        $display("PASS: RX APB WAIT STATE");
    end
    else begin

        $display(
            "FAIL: RX APB WAIT STATE NOT OBSERVED"
        );

        r_errorCnt = r_errorCnt + 1;

    end

    if (r_rxData[7:0] === 8'hA5) begin

        $display(
            "PASS: RX DATA = %02h",
            r_rxData[7:0]
        );

    end
    else begin

        $display(
            "FAIL: RX DATA = %02h",
            r_rxData[7:0]
        );

        r_errorCnt = r_errorCnt + 1;

    end

    // --------------------------------------------------------
    // TEST 5 : FIFO AFTER READ
    // --------------------------------------------------------

    $display("------------------------------------");
    $display(" TEST 5 : FIFO AFTER READ");
    $display("------------------------------------");

    apb_read(ADDR_STATUS, r_statusAfter);

    $display(
        "STATUS AFTER READ = %08h",
        r_statusAfter
    );

    if (r_statusAfter[2] === 1'b1) begin
        $display("PASS: RX FIFO EMPTY AFTER READ");
    end
    else begin

        $display(
            "FAIL: RX FIFO NOT EMPTY AFTER READ"
        );

        r_errorCnt = r_errorCnt + 1;

    end

    // --------------------------------------------------------
    // FINAL RESULT
    // --------------------------------------------------------

    $display("====================================");
    $display(" UART V3 GLS FINAL RESULT");
    $display("====================================");

    $display(
        "TX EDGE COUNT  = %0d",
        r_txEdgeCnt
    );

    $display(
        "RX WAIT CYCLES = %0d",
        r_rxReadWaitCnt
    );

    $display(
        "RX DATA        = %02h",
        r_rxData[7:0]
    );

    if (r_errorCnt == 0) begin

        $display(
            "UART V3 PRE-LAYOUT GLS ALL PASS"
        );

    end
    else begin

        $display(
            "UART V3 PRE-LAYOUT GLS FAIL = %0d",
            r_errorCnt
        );

    end

    $display("====================================");

    $finish;

end

// ============================================================
// TIMEOUT
// ============================================================

initial begin

    #5000000;

    $display("====================================");
    $display("FAIL: UART V3 GLS TIMEOUT");
    $display("====================================");

    $finish;

end

endmodule

