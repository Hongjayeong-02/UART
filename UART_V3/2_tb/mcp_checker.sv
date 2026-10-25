`timescale 1ns/1ps
// =========================================================
// MCP (setup 2 / hold 1) 근거 검사 - RTL 전용 (hierarchical ref)
//   A0 : tick16 pulse 간격 >= 2 clk
//   A1 : RX/TX r_tickCnt 는 tick edge 에서만 값이 바뀐다
//   B* : 아래 source 는 "읽히는 edge" 직전 edge 에서 바뀌지 않았다
//        (= launch 후 최소 2 clk 뒤에만 capture 에 쓰인다)
//        TX r_data7, r_bitCnt, r_parityBit, r_txData, r_parityMode
//           (읽는 곳: START/DATA tick edge, PARITY state 매 cycle)
//        RX r_rxData -> r_parityErr
// 사용: 시뮬레이션에 이 파일을 같이 넣고 두 번째 top 으로 지정 (xrun: -top tb_uart_v3_final -top mcp_checker)
// =========================================================
module mcp_checker;

`ifndef TB
 `define TB tb_uart_v3_final
`endif

wire        clk    = `TB.clk;
wire        tick   = `TB.uut.uut_uart_core.w_tick16;

// RX
wire [2:0]  rxSt   = `TB.uut.uut_uart_core.uut_rx_fifo.uut_rx.r_state;
wire [3:0]  rxTc   = `TB.uut.uut_uart_core.uut_rx_fifo.uut_rx.r_tickCnt;
wire [7:0]  rxDat  = `TB.uut.uut_uart_core.uut_rx_fifo.uut_rx.r_rxData;

// TX
wire [2:0]  txSt   = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_state;
wire [3:0]  txTc   = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_tickCnt;
wire        txD7   = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_data7;
wire [2:0]  txBc   = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_bitCnt;
wire        txPb   = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_parityBit;
wire [7:0]  txDat  = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_txData;
wire [1:0]  txPm   = `TB.uut.uut_uart_core.uut_tx_fifo.uut_tx.r_parityMode;

localparam RX_PARITY = 3'd3;
localparam TX_START  = 3'd2;
localparam TX_DATA   = 3'd3;
localparam TX_PARITY = 3'd4;

integer errCnt, nTick, nRxTc, nTxTc, nTxRead, nTxParRead, nRxParRead;
integer gap;

// 이전 edge 직후 값 (edge + 1ns 에서 샘플)
reg [3:0] pRxTc, pTxTc;
reg [7:0] pRxDat, pTxDat;
reg       pTxD7, pTxPb;
reg [2:0] pTxBc;
reg [1:0] pTxPm;
// "직전 edge 에서 값이 바뀌었는가"
reg       chRxDat, chTxD7, chTxBc, chTxPb, chTxDat, chTxPm;
// edge 에서 FSM 이 본 값 (edge 직전 = 이전 cycle 값)
reg       sTick;
reg [2:0] sRxSt, sTxSt;
reg       started;

initial begin
        errCnt = 0; nTick = 0; nRxTc = 0; nTxTc = 0;
        nTxRead = 0; nTxParRead = 0; nRxParRead = 0;
        gap = 100; started = 1'b0;
        {chRxDat, chTxD7, chTxBc, chTxPb, chTxDat, chTxPm} = 6'd0;
end

task err;
        input [8*40-1:0] msg;
        begin
                errCnt = errCnt + 1;
                if (errCnt <= 10)
                        $display("MCP_ASSERT FAIL @%0t : %0s", $time, msg);
        end
endtask

always @(posedge clk) begin
        // FSM 이 이 edge 에서 사용하는 값 (NBA 이전)
        sTick = tick;
        sRxSt = rxSt;
        sTxSt = txSt;

        // ---- B : 읽히는 edge 에서 source 가 직전 edge 에 바뀌지 않았어야 함
        if (started) begin
                // TX START/DATA state 의 tick edge : data7, bitCnt, parityBit, txData, parityMode 를 읽음
                if ((sTxSt == TX_START || sTxSt == TX_DATA) && sTick) begin
                        nTxRead = nTxRead + 1;
                        if (chTxD7)  err("B1 TX r_data7 changed 1 clk before read");
                        if (chTxBc)  err("B2 TX r_bitCnt changed 1 clk before read");
                        if (chTxPb)  err("B3 TX r_parityBit changed 1clk before read");
                        if (chTxDat) err("B4 TX r_txData changed 1 clk before read");
                        if (chTxPm)  err("B5 TX parityMode changed 1clk before read");
                end
                // TX PARITY state : 매 cycle o_uartTx <= w_parityOut (parityBit, parityMode)
                if (sTxSt == TX_PARITY) begin
                        nTxParRead = nTxParRead + 1;
                        if (chTxPb)  err("B6 TX r_parityBit chg 1clk before PARITY");
                        if (chTxPm)  err("B7 TX parityMode chg 1clk before PARITY");
                end
                // RX PARITY state 의 tick edge : r_rxData 로 parity 검사
                if (sRxSt == RX_PARITY && sTick) begin
                        nRxParRead = nRxParRead + 1;
                        if (chRxDat) err("B8 RX r_rxData changed 1 clk before read");
                end
        end

        // ---- A0 : tick 간격
        if (sTick) begin
                nTick = nTick + 1;
                if (gap < 2) err("A0 tick16 spacing < 2 clk");
                gap = 1;
        end else if (gap < 100)
                gap = gap + 1;

        #1;     // NBA 반영 후 샘플

        if (started) begin
                // ---- A1 : tickCnt 는 tick edge 에서만 변함
                if (rxTc !== pRxTc) begin
                        nRxTc = nRxTc + 1;
                        if (!sTick) err("A1 RX r_tickCnt changed w/o tick");
                end
                if (txTc !== pTxTc) begin
                        nTxTc = nTxTc + 1;
                        if (!sTick) err("A1 TX r_tickCnt changed w/o tick");
                end
        end

        chRxDat = (rxDat !== pRxDat);
        chTxD7  = (txD7  !== pTxD7);
        chTxBc  = (txBc  !== pTxBc);
        chTxPb  = (txPb  !== pTxPb);
        chTxDat = (txDat !== pTxDat);
        chTxPm  = (txPm  !== pTxPm);

        pRxTc = rxTc;  pTxTc = txTc;
        pRxDat = rxDat; pTxDat = txDat;
        pTxD7 = txD7;  pTxBc = txBc;  pTxPb = txPb;  pTxPm = txPm;
        started = (`TB.rst_n === 1'b1);
end

// reset 중에는 비교하지 않음
always @(negedge `TB.rst_n) started = 1'b0;

// 결과 요약 (SystemVerilog final block : xrun 은 -sv, iverilog 는 -g2012)
final begin
                $display("MCP_ASSERT SUMMARY: fail=%0d | ticks=%0d rxTcChg=%0d txTcChg=%0d | TX START/DATA reads=%0d TX PARITY cycles=%0d RX PARITY reads=%0d",
                         errCnt, nTick, nRxTc, nTxTc, nTxRead, nTxParRead, nRxParRead);
end

endmodule
