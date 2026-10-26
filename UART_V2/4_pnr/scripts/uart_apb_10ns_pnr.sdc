# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.17-s071_1 on Tue Oct 27 05:54:36 KST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design uart_apb

create_clock -name "MAIN_CLOCK" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_transition 0.05 [get_clocks MAIN_CLOCK]
set_load -pin_load 0.01 [get_ports {o_prdata[31]}]
set_load -pin_load 0.01 [get_ports {o_prdata[30]}]
set_load -pin_load 0.01 [get_ports {o_prdata[29]}]
set_load -pin_load 0.01 [get_ports {o_prdata[28]}]
set_load -pin_load 0.01 [get_ports {o_prdata[27]}]
set_load -pin_load 0.01 [get_ports {o_prdata[26]}]
set_load -pin_load 0.01 [get_ports {o_prdata[25]}]
set_load -pin_load 0.01 [get_ports {o_prdata[24]}]
set_load -pin_load 0.01 [get_ports {o_prdata[23]}]
set_load -pin_load 0.01 [get_ports {o_prdata[22]}]
set_load -pin_load 0.01 [get_ports {o_prdata[21]}]
set_load -pin_load 0.01 [get_ports {o_prdata[20]}]
set_load -pin_load 0.01 [get_ports {o_prdata[19]}]
set_load -pin_load 0.01 [get_ports {o_prdata[18]}]
set_load -pin_load 0.01 [get_ports {o_prdata[17]}]
set_load -pin_load 0.01 [get_ports {o_prdata[16]}]
set_load -pin_load 0.01 [get_ports {o_prdata[15]}]
set_load -pin_load 0.01 [get_ports {o_prdata[14]}]
set_load -pin_load 0.01 [get_ports {o_prdata[13]}]
set_load -pin_load 0.01 [get_ports {o_prdata[12]}]
set_load -pin_load 0.01 [get_ports {o_prdata[11]}]
set_load -pin_load 0.01 [get_ports {o_prdata[10]}]
set_load -pin_load 0.01 [get_ports {o_prdata[9]}]
set_load -pin_load 0.01 [get_ports {o_prdata[8]}]
set_load -pin_load 0.01 [get_ports {o_prdata[7]}]
set_load -pin_load 0.01 [get_ports {o_prdata[6]}]
set_load -pin_load 0.01 [get_ports {o_prdata[5]}]
set_load -pin_load 0.01 [get_ports {o_prdata[4]}]
set_load -pin_load 0.01 [get_ports {o_prdata[3]}]
set_load -pin_load 0.01 [get_ports {o_prdata[2]}]
set_load -pin_load 0.01 [get_ports {o_prdata[1]}]
set_load -pin_load 0.01 [get_ports {o_prdata[0]}]
set_load -pin_load 0.01 [get_ports o_pready]
set_load -pin_load 0.01 [get_ports o_pslverr]
set_load -pin_load 0.01 [get_ports o_uartTx]
set_load -pin_load 0.01 [get_ports o_irq]
set_false_path -from [get_ports i_uartRx]
set_false_path -to [get_ports o_uartTx]
group_path -name R2R -from [list \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_uartTx_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[2]}]  \
  [get_cells uut_uart_irq_r_falseStartPending_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_parityErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_frameErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[3]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxBusy_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_falseStart_reg]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[15]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[13]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[14]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_parityBit_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells r_rxReadPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells uut_uart_irq_r_framePending_reg]  \
  [get_cells uut_uart_irq_r_parityPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txBusy_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells {r_baudDiv_reg[4]}]  \
  [get_cells {r_baudDiv_reg[5]}]  \
  [get_cells {r_baudDiv_reg[8]}]  \
  [get_cells {r_baudDiv_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells {r_irqEn_reg[1]}]  \
  [get_cells {r_irqEn_reg[4]}]  \
  [get_cells {r_irqEn_reg[3]}]  \
  [get_cells {r_baudDiv_reg[7]}]  \
  [get_cells {r_baudDiv_reg[9]}]  \
  [get_cells {r_irqEn_reg[2]}]  \
  [get_cells {r_irqEn_reg[0]}]  \
  [get_cells {r_baudDiv_reg[2]}]  \
  [get_cells {r_baudDiv_reg[1]}]  \
  [get_cells {r_baudDiv_reg[6]}]  \
  [get_cells {r_baudDiv_reg[12]}]  \
  [get_cells {r_baudDiv_reg[10]}]  \
  [get_cells {r_baudDiv_reg[14]}]  \
  [get_cells {r_baudDiv_reg[13]}]  \
  [get_cells {r_baudDiv_reg[0]}]  \
  [get_cells {r_baudDiv_reg[15]}]  \
  [get_cells {r_baudDiv_reg[11]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_fifoRdEn_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[3]}]  \
  [get_cells {r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[0]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stop2_reg]  \
  [get_cells r_stop2_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_data7_reg]  \
  [get_cells r_enable_reg]  \
  [get_cells r_data7_reg]  \
  [get_cells {r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stop2_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_data7_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[2]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_frameErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_parityErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[7]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxValid_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txDone_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_txValid_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxSync_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxMeta_reg]  \
  [get_cells uut_uart_core_uut_baud_gen_o_tick16_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[2]}] ] -to [list \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_uartTx_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[2]}]  \
  [get_cells uut_uart_irq_r_falseStartPending_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_parityErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_frameErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[3]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxBusy_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_falseStart_reg]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[15]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[13]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[14]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_parityBit_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells r_rxReadPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells uut_uart_irq_r_framePending_reg]  \
  [get_cells uut_uart_irq_r_parityPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txBusy_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells {r_baudDiv_reg[4]}]  \
  [get_cells {r_baudDiv_reg[5]}]  \
  [get_cells {r_baudDiv_reg[8]}]  \
  [get_cells {r_baudDiv_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells {r_irqEn_reg[1]}]  \
  [get_cells {r_irqEn_reg[4]}]  \
  [get_cells {r_irqEn_reg[3]}]  \
  [get_cells {r_baudDiv_reg[7]}]  \
  [get_cells {r_baudDiv_reg[9]}]  \
  [get_cells {r_irqEn_reg[2]}]  \
  [get_cells {r_irqEn_reg[0]}]  \
  [get_cells {r_baudDiv_reg[2]}]  \
  [get_cells {r_baudDiv_reg[1]}]  \
  [get_cells {r_baudDiv_reg[6]}]  \
  [get_cells {r_baudDiv_reg[12]}]  \
  [get_cells {r_baudDiv_reg[10]}]  \
  [get_cells {r_baudDiv_reg[14]}]  \
  [get_cells {r_baudDiv_reg[13]}]  \
  [get_cells {r_baudDiv_reg[0]}]  \
  [get_cells {r_baudDiv_reg[15]}]  \
  [get_cells {r_baudDiv_reg[11]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_fifoRdEn_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[3]}]  \
  [get_cells {r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[0]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stop2_reg]  \
  [get_cells r_stop2_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_data7_reg]  \
  [get_cells r_enable_reg]  \
  [get_cells r_data7_reg]  \
  [get_cells {r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stop2_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_data7_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[2]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_frameErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_parityErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[7]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxValid_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txDone_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_txValid_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxSync_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxMeta_reg]  \
  [get_cells uut_uart_core_uut_baud_gen_o_tick16_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[2]}] ]
group_path -name I2R -from [list \
  [get_ports clk]  \
  [get_ports rst_n]  \
  [get_ports i_psel]  \
  [get_ports i_penable]  \
  [get_ports i_pwrite]  \
  [get_ports {i_paddr[7]}]  \
  [get_ports {i_paddr[6]}]  \
  [get_ports {i_paddr[5]}]  \
  [get_ports {i_paddr[4]}]  \
  [get_ports {i_paddr[3]}]  \
  [get_ports {i_paddr[2]}]  \
  [get_ports {i_paddr[1]}]  \
  [get_ports {i_paddr[0]}]  \
  [get_ports {i_pwdata[31]}]  \
  [get_ports {i_pwdata[30]}]  \
  [get_ports {i_pwdata[29]}]  \
  [get_ports {i_pwdata[28]}]  \
  [get_ports {i_pwdata[27]}]  \
  [get_ports {i_pwdata[26]}]  \
  [get_ports {i_pwdata[25]}]  \
  [get_ports {i_pwdata[24]}]  \
  [get_ports {i_pwdata[23]}]  \
  [get_ports {i_pwdata[22]}]  \
  [get_ports {i_pwdata[21]}]  \
  [get_ports {i_pwdata[20]}]  \
  [get_ports {i_pwdata[19]}]  \
  [get_ports {i_pwdata[18]}]  \
  [get_ports {i_pwdata[17]}]  \
  [get_ports {i_pwdata[16]}]  \
  [get_ports {i_pwdata[15]}]  \
  [get_ports {i_pwdata[14]}]  \
  [get_ports {i_pwdata[13]}]  \
  [get_ports {i_pwdata[12]}]  \
  [get_ports {i_pwdata[11]}]  \
  [get_ports {i_pwdata[10]}]  \
  [get_ports {i_pwdata[9]}]  \
  [get_ports {i_pwdata[8]}]  \
  [get_ports {i_pwdata[7]}]  \
  [get_ports {i_pwdata[6]}]  \
  [get_ports {i_pwdata[5]}]  \
  [get_ports {i_pwdata[4]}]  \
  [get_ports {i_pwdata[3]}]  \
  [get_ports {i_pwdata[2]}]  \
  [get_ports {i_pwdata[1]}]  \
  [get_ports {i_pwdata[0]}]  \
  [get_ports i_uartRx] ] -to [list \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_uartTx_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[2]}]  \
  [get_cells uut_uart_irq_r_falseStartPending_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_parityErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_frameErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[3]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxBusy_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_falseStart_reg]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[15]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[13]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[14]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_parityBit_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells r_rxReadPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells uut_uart_irq_r_framePending_reg]  \
  [get_cells uut_uart_irq_r_parityPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txBusy_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells {r_baudDiv_reg[4]}]  \
  [get_cells {r_baudDiv_reg[5]}]  \
  [get_cells {r_baudDiv_reg[8]}]  \
  [get_cells {r_baudDiv_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells {r_irqEn_reg[1]}]  \
  [get_cells {r_irqEn_reg[4]}]  \
  [get_cells {r_irqEn_reg[3]}]  \
  [get_cells {r_baudDiv_reg[7]}]  \
  [get_cells {r_baudDiv_reg[9]}]  \
  [get_cells {r_irqEn_reg[2]}]  \
  [get_cells {r_irqEn_reg[0]}]  \
  [get_cells {r_baudDiv_reg[2]}]  \
  [get_cells {r_baudDiv_reg[1]}]  \
  [get_cells {r_baudDiv_reg[6]}]  \
  [get_cells {r_baudDiv_reg[12]}]  \
  [get_cells {r_baudDiv_reg[10]}]  \
  [get_cells {r_baudDiv_reg[14]}]  \
  [get_cells {r_baudDiv_reg[13]}]  \
  [get_cells {r_baudDiv_reg[0]}]  \
  [get_cells {r_baudDiv_reg[15]}]  \
  [get_cells {r_baudDiv_reg[11]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_fifoRdEn_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[3]}]  \
  [get_cells {r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[0]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stop2_reg]  \
  [get_cells r_stop2_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_data7_reg]  \
  [get_cells r_enable_reg]  \
  [get_cells r_data7_reg]  \
  [get_cells {r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stop2_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_data7_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[2]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_frameErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_parityErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[7]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxValid_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txDone_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_txValid_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxSync_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxMeta_reg]  \
  [get_cells uut_uart_core_uut_baud_gen_o_tick16_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[2]}] ]
group_path -name R2O -from [list \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_state_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_uartTx_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stopCnt_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[2]}]  \
  [get_cells uut_uart_irq_r_falseStartPending_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_state_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_parityErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_frameErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[3]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxBusy_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_falseStart_reg]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[15]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[13]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[14]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_parityBit_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[1][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[2][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[5][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_count_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[14][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[10][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[6][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[13][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[9][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[0][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[4][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[12][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[8][4]}]  \
  [get_cells r_rxReadPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[7][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[15][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[11][1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_o_rdData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_mem_reg[3][7]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_o_rdData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells uut_uart_irq_r_framePending_reg]  \
  [get_cells uut_uart_irq_r_parityPending_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txBusy_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[0]}]  \
  [get_cells {r_baudDiv_reg[4]}]  \
  [get_cells {r_baudDiv_reg[5]}]  \
  [get_cells {r_baudDiv_reg[8]}]  \
  [get_cells {r_baudDiv_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_fifo_r_rdPtr_reg[2]}]  \
  [get_cells {r_irqEn_reg[1]}]  \
  [get_cells {r_irqEn_reg[4]}]  \
  [get_cells {r_irqEn_reg[3]}]  \
  [get_cells {r_baudDiv_reg[7]}]  \
  [get_cells {r_baudDiv_reg[9]}]  \
  [get_cells {r_irqEn_reg[2]}]  \
  [get_cells {r_irqEn_reg[0]}]  \
  [get_cells {r_baudDiv_reg[2]}]  \
  [get_cells {r_baudDiv_reg[1]}]  \
  [get_cells {r_baudDiv_reg[6]}]  \
  [get_cells {r_baudDiv_reg[12]}]  \
  [get_cells {r_baudDiv_reg[10]}]  \
  [get_cells {r_baudDiv_reg[14]}]  \
  [get_cells {r_baudDiv_reg[13]}]  \
  [get_cells {r_baudDiv_reg[0]}]  \
  [get_cells {r_baudDiv_reg[15]}]  \
  [get_cells {r_baudDiv_reg[11]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[3]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_fifoRdEn_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[3]}]  \
  [get_cells {r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_parityMode_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_txData_reg[0]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_stop2_reg]  \
  [get_cells r_stop2_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_r_data7_reg]  \
  [get_cells r_enable_reg]  \
  [get_cells r_data7_reg]  \
  [get_cells {r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_stop2_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[0]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_data7_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_parityMode_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[2]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_frameErr_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_parityErr_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_o_rxData_reg[7]}]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_o_rxValid_reg]  \
  [get_cells uut_uart_core_uut_tx_fifo_uut_tx_o_txDone_reg]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[7]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_txData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_r_ctrlState_reg[1]}]  \
  [get_cells uut_uart_core_uut_tx_fifo_r_txValid_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxSync_reg]  \
  [get_cells uut_uart_core_uut_rx_fifo_uut_rx_r_rxMeta_reg]  \
  [get_cells uut_uart_core_uut_baud_gen_o_tick16_reg]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_fifo_r_wrPtr_reg[1]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[5]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_tickCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[2]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[4]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[6]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_tickCnt_reg[1]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_rxData_reg[0]}]  \
  [get_cells {uut_uart_core_uut_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {uut_uart_core_uut_tx_fifo_uut_tx_r_bitCnt_reg[0]}]  \
  [get_cells {uut_uart_core_uut_rx_fifo_uut_rx_r_bitCnt_reg[2]}] ] -to [list \
  [get_ports {o_prdata[31]}]  \
  [get_ports {o_prdata[30]}]  \
  [get_ports {o_prdata[29]}]  \
  [get_ports {o_prdata[28]}]  \
  [get_ports {o_prdata[27]}]  \
  [get_ports {o_prdata[26]}]  \
  [get_ports {o_prdata[25]}]  \
  [get_ports {o_prdata[24]}]  \
  [get_ports {o_prdata[23]}]  \
  [get_ports {o_prdata[22]}]  \
  [get_ports {o_prdata[21]}]  \
  [get_ports {o_prdata[20]}]  \
  [get_ports {o_prdata[19]}]  \
  [get_ports {o_prdata[18]}]  \
  [get_ports {o_prdata[17]}]  \
  [get_ports {o_prdata[16]}]  \
  [get_ports {o_prdata[15]}]  \
  [get_ports {o_prdata[14]}]  \
  [get_ports {o_prdata[13]}]  \
  [get_ports {o_prdata[12]}]  \
  [get_ports {o_prdata[11]}]  \
  [get_ports {o_prdata[10]}]  \
  [get_ports {o_prdata[9]}]  \
  [get_ports {o_prdata[8]}]  \
  [get_ports {o_prdata[7]}]  \
  [get_ports {o_prdata[6]}]  \
  [get_ports {o_prdata[5]}]  \
  [get_ports {o_prdata[4]}]  \
  [get_ports {o_prdata[3]}]  \
  [get_ports {o_prdata[2]}]  \
  [get_ports {o_prdata[1]}]  \
  [get_ports {o_prdata[0]}]  \
  [get_ports o_pready]  \
  [get_ports o_pslverr]  \
  [get_ports o_uartTx]  \
  [get_ports o_irq] ]
group_path -name I2O -from [list \
  [get_ports clk]  \
  [get_ports rst_n]  \
  [get_ports i_psel]  \
  [get_ports i_penable]  \
  [get_ports i_pwrite]  \
  [get_ports {i_paddr[7]}]  \
  [get_ports {i_paddr[6]}]  \
  [get_ports {i_paddr[5]}]  \
  [get_ports {i_paddr[4]}]  \
  [get_ports {i_paddr[3]}]  \
  [get_ports {i_paddr[2]}]  \
  [get_ports {i_paddr[1]}]  \
  [get_ports {i_paddr[0]}]  \
  [get_ports {i_pwdata[31]}]  \
  [get_ports {i_pwdata[30]}]  \
  [get_ports {i_pwdata[29]}]  \
  [get_ports {i_pwdata[28]}]  \
  [get_ports {i_pwdata[27]}]  \
  [get_ports {i_pwdata[26]}]  \
  [get_ports {i_pwdata[25]}]  \
  [get_ports {i_pwdata[24]}]  \
  [get_ports {i_pwdata[23]}]  \
  [get_ports {i_pwdata[22]}]  \
  [get_ports {i_pwdata[21]}]  \
  [get_ports {i_pwdata[20]}]  \
  [get_ports {i_pwdata[19]}]  \
  [get_ports {i_pwdata[18]}]  \
  [get_ports {i_pwdata[17]}]  \
  [get_ports {i_pwdata[16]}]  \
  [get_ports {i_pwdata[15]}]  \
  [get_ports {i_pwdata[14]}]  \
  [get_ports {i_pwdata[13]}]  \
  [get_ports {i_pwdata[12]}]  \
  [get_ports {i_pwdata[11]}]  \
  [get_ports {i_pwdata[10]}]  \
  [get_ports {i_pwdata[9]}]  \
  [get_ports {i_pwdata[8]}]  \
  [get_ports {i_pwdata[7]}]  \
  [get_ports {i_pwdata[6]}]  \
  [get_ports {i_pwdata[5]}]  \
  [get_ports {i_pwdata[4]}]  \
  [get_ports {i_pwdata[3]}]  \
  [get_ports {i_pwdata[2]}]  \
  [get_ports {i_pwdata[1]}]  \
  [get_ports {i_pwdata[0]}]  \
  [get_ports i_uartRx] ] -to [list \
  [get_ports {o_prdata[31]}]  \
  [get_ports {o_prdata[30]}]  \
  [get_ports {o_prdata[29]}]  \
  [get_ports {o_prdata[28]}]  \
  [get_ports {o_prdata[27]}]  \
  [get_ports {o_prdata[26]}]  \
  [get_ports {o_prdata[25]}]  \
  [get_ports {o_prdata[24]}]  \
  [get_ports {o_prdata[23]}]  \
  [get_ports {o_prdata[22]}]  \
  [get_ports {o_prdata[21]}]  \
  [get_ports {o_prdata[20]}]  \
  [get_ports {o_prdata[19]}]  \
  [get_ports {o_prdata[18]}]  \
  [get_ports {o_prdata[17]}]  \
  [get_ports {o_prdata[16]}]  \
  [get_ports {o_prdata[15]}]  \
  [get_ports {o_prdata[14]}]  \
  [get_ports {o_prdata[13]}]  \
  [get_ports {o_prdata[12]}]  \
  [get_ports {o_prdata[11]}]  \
  [get_ports {o_prdata[10]}]  \
  [get_ports {o_prdata[9]}]  \
  [get_ports {o_prdata[8]}]  \
  [get_ports {o_prdata[7]}]  \
  [get_ports {o_prdata[6]}]  \
  [get_ports {o_prdata[5]}]  \
  [get_ports {o_prdata[4]}]  \
  [get_ports {o_prdata[3]}]  \
  [get_ports {o_prdata[2]}]  \
  [get_ports {o_prdata[1]}]  \
  [get_ports {o_prdata[0]}]  \
  [get_ports o_pready]  \
  [get_ports o_pslverr]  \
  [get_ports o_uartTx]  \
  [get_ports o_irq] ]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports i_psel]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports i_penable]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports i_pwrite]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[7]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[6]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[5]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[4]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[3]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[2]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[1]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_paddr[0]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[31]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[30]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[29]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[28]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[27]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[26]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[25]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[24]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[23]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[22]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[21]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[20]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[19]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[18]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[17]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[16]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[15]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[14]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[13]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[12]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[11]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[10]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[9]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[8]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[7]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[6]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[5]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[4]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[3]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[2]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[1]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {i_pwdata[0]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports i_psel]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports i_penable]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports i_pwrite]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[7]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[6]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[5]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[4]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[3]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[2]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[1]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_paddr[0]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[31]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[30]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[29]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[28]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[27]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[26]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[25]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[24]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[23]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[22]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[21]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[20]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[19]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[18]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[17]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[16]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[15]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[14]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[13]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[12]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[11]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[10]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[9]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[8]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[7]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[6]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[5]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[4]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[3]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[2]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[1]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_pwdata[0]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports rst_n]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports rst_n]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[31]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[30]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[29]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[28]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[27]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[26]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[25]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[24]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[23]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[22]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[21]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[20]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[19]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[18]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[17]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[16]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[15]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[14]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[13]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[12]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[11]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[10]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[9]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[8]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[7]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[6]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[5]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[4]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[3]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[2]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[1]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports {o_prdata[0]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports o_pready]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports o_pslverr]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 4.0 [get_ports o_irq]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[31]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[30]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[29]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[28]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[27]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[26]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[25]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[24]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[23]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[22]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[21]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[20]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[19]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[18]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[17]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[16]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[15]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[14]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[13]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[12]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[11]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[10]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[9]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[8]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[7]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[6]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[5]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[4]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[3]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[2]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[1]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_prdata[0]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_pready]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_pslverr]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_irq]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports rst_n]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports i_psel]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports i_penable]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports i_pwrite]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[7]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[6]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[5]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[4]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[3]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[2]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[1]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_paddr[0]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[31]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[30]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[29]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[28]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[27]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[26]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[25]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[24]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[23]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[22]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[21]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[20]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[19]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[18]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[17]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[16]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[15]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[14]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[13]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[12]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[11]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[10]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[9]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[8]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[7]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[6]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[5]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[4]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[3]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[2]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[1]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_pwdata[0]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports i_uartRx]
set_ideal_network [get_ports rst_n]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.1 [get_clocks MAIN_CLOCK]
set_clock_uncertainty -hold 0.05 [get_clocks MAIN_CLOCK]
