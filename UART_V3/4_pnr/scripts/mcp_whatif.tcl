# =========================================================
# MCP what-if (Innovus, post-route ChipFinish DB 위에서 STA만)
#   - 재최적화 없음: "같은 배치/배선에서 constraint만 바꾸면 slack이 어떻게 되나"
#   - setup 2 / hold 1 : hold 검사 edge는 원래 자리(0) 유지
#
# 근거 (RTL + mcp_checker.v assertion, BAUD_DIV 8/1 에서 fail 0)
#   A  RX/TX r_tickCnt : tick edge에서만 값이 바뀌고, 모든 읽기가 i_tick16으로 gate
#                        + tick 간격 >= 2 clk (uart_baud_gen 구조로 BAUD_DIV 무관)
#   B  TX r_data7 / r_bitCnt / r_parityBit / r_txData / r_parityMode :
#                        START/DATA tick edge, PARITY state에서만 읽히고
#                        읽기 직전 edge에서 바뀌지 않음
#   C  RX r_rxData -> r_parityErr : PARITY tick edge에서만 읽힘
#
# 제외 (반드시 1-cycle 유지)
#   RX/TX r_state (IDLE/PUSH/DONE 등에서 tick 없이 전이), RX r_rxSync,
#   baud gen r_clkCnt / o_tick16 (매 cycle), APB/CTRL/FIFO 레지스터
# =========================================================

set RX uut_uart_core_uut_rx_fifo_uut_rx_
set TX uut_uart_core_uut_tx_fifo_uut_tx_

set mcpA [get_cells [list ${RX}r_tickCnt_reg* ${TX}r_tickCnt_reg*]]
set mcpB [get_cells [list ${TX}r_data7_reg ${TX}r_bitCnt_reg* ${TX}r_parityBit_reg ${TX}r_txData_reg* ${TX}r_parityMode_reg*]]
set mcpCf [get_cells [list ${RX}r_rxData_reg*]]
set mcpCt [get_cells [list ${RX}r_parityErr_reg]]

# 이름이 합성/P&R에서 바뀌었으면 여기서 개수가 줄어든다 -> 먼저 확인
puts "MCP cells : A=[sizeof_collection $mcpA] (expect 8)  B=[sizeof_collection $mcpB] (expect 15)  C=[sizeof_collection $mcpCf]->[sizeof_collection $mcpCt] (expect 8->1)"

set_multicycle_path 2 -setup -from $mcpA
set_multicycle_path 1 -hold  -from $mcpA
set_multicycle_path 2 -setup -from $mcpB
set_multicycle_path 1 -hold  -from $mcpB
set_multicycle_path 2 -setup -from $mcpCf -to $mcpCt
set_multicycle_path 1 -hold  -from $mcpCf -to $mcpCt
