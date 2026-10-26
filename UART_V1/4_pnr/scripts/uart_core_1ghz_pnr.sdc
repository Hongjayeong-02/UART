# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.17-s071_1 on Tue Oct 27 03:02:15 KST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design uart_core

create_clock -name "MAIN_CLOCK" -period 1.0 -waveform {0.0 0.5} [get_ports clk]
set_clock_transition 0.05 [get_clocks MAIN_CLOCK]
set_load -pin_load 0.01 [get_ports o_uartTx]
set_load -pin_load 0.01 [get_ports o_txReady]
set_load -pin_load 0.01 [get_ports o_txBusy]
set_load -pin_load 0.01 [get_ports {o_rxData[7]}]
set_load -pin_load 0.01 [get_ports {o_rxData[6]}]
set_load -pin_load 0.01 [get_ports {o_rxData[5]}]
set_load -pin_load 0.01 [get_ports {o_rxData[4]}]
set_load -pin_load 0.01 [get_ports {o_rxData[3]}]
set_load -pin_load 0.01 [get_ports {o_rxData[2]}]
set_load -pin_load 0.01 [get_ports {o_rxData[1]}]
set_load -pin_load 0.01 [get_ports {o_rxData[0]}]
set_load -pin_load 0.01 [get_ports o_rxValid]
set_load -pin_load 0.01 [get_ports o_frameErr]
set_false_path -from [get_ports i_uartRx]
set_false_path -to [get_ports o_uartTx]
group_path -name R2R -from [list \
  [get_cells {u_uart_tx_r_txShift_reg[3]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[7]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[4]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[0]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[5]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[2]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[6]}]  \
  [get_cells u_uart_tx_o_uartTx_reg]  \
  [get_cells {u_uart_tx_r_txShift_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_tx_r_state_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[10]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[2]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[6]}]  \
  [get_cells {u_uart_rx_r_state_reg[0]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[3]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[12]}]  \
  [get_cells {u_uart_rx_r_state_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[9]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[8]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[5]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[1]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[1]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[6]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[2]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[0]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[7]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[4]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[7]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells u_uart_rx_o_frameErr_reg]  \
  [get_cells u_uart_rx_o_rxValid_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells u_uart_baud_gen_o_baudTick_reg]  \
  [get_cells u_uart_tx_o_txReady_reg]  \
  [get_cells u_uart_tx_o_txBusy_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells u_uart_rx_r_rxSync_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells u_uart_rx_r_rxMeta_reg]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_tx_r_state_reg[0]}]  \
  [get_cells {u_uart_tx_r_state_reg[2]}] ] -to [list \
  [get_cells {u_uart_tx_r_txShift_reg[3]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[7]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[4]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[0]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[5]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[2]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[6]}]  \
  [get_cells u_uart_tx_o_uartTx_reg]  \
  [get_cells {u_uart_tx_r_txShift_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_tx_r_state_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[10]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[2]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[6]}]  \
  [get_cells {u_uart_rx_r_state_reg[0]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[3]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[12]}]  \
  [get_cells {u_uart_rx_r_state_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[9]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[8]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[5]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[1]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[1]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[6]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[2]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[0]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[7]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[4]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[7]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells u_uart_rx_o_frameErr_reg]  \
  [get_cells u_uart_rx_o_rxValid_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells u_uart_baud_gen_o_baudTick_reg]  \
  [get_cells u_uart_tx_o_txReady_reg]  \
  [get_cells u_uart_tx_o_txBusy_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells u_uart_rx_r_rxSync_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells u_uart_rx_r_rxMeta_reg]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_tx_r_state_reg[0]}]  \
  [get_cells {u_uart_tx_r_state_reg[2]}] ]
group_path -name I2R -from [list \
  [get_ports clk]  \
  [get_ports rst_n]  \
  [get_ports i_txValid]  \
  [get_ports {i_txData[7]}]  \
  [get_ports {i_txData[6]}]  \
  [get_ports {i_txData[5]}]  \
  [get_ports {i_txData[4]}]  \
  [get_ports {i_txData[3]}]  \
  [get_ports {i_txData[2]}]  \
  [get_ports {i_txData[1]}]  \
  [get_ports {i_txData[0]}]  \
  [get_ports i_uartRx] ] -to [list \
  [get_cells {u_uart_tx_r_txShift_reg[3]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[7]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[4]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[0]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[5]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[2]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[6]}]  \
  [get_cells u_uart_tx_o_uartTx_reg]  \
  [get_cells {u_uart_tx_r_txShift_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_tx_r_state_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[10]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[2]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[6]}]  \
  [get_cells {u_uart_rx_r_state_reg[0]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[3]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[12]}]  \
  [get_cells {u_uart_rx_r_state_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[9]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[8]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[5]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[1]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[1]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[6]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[2]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[0]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[7]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[4]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[7]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells u_uart_rx_o_frameErr_reg]  \
  [get_cells u_uart_rx_o_rxValid_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells u_uart_baud_gen_o_baudTick_reg]  \
  [get_cells u_uart_tx_o_txReady_reg]  \
  [get_cells u_uart_tx_o_txBusy_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells u_uart_rx_r_rxSync_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells u_uart_rx_r_rxMeta_reg]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_tx_r_state_reg[0]}]  \
  [get_cells {u_uart_tx_r_state_reg[2]}] ]
group_path -name R2O -from [list \
  [get_cells {u_uart_tx_r_txShift_reg[3]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[7]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[4]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[0]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[5]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[2]}]  \
  [get_cells {u_uart_tx_r_txShift_reg[6]}]  \
  [get_cells u_uart_tx_o_uartTx_reg]  \
  [get_cells {u_uart_tx_r_txShift_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_tx_r_state_reg[1]}]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[10]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[2]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[6]}]  \
  [get_cells {u_uart_rx_r_state_reg[0]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[0]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[3]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[12]}]  \
  [get_cells {u_uart_rx_r_state_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[9]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[8]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[1]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[0]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[4]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[2]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[5]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_sampleCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[7]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[1]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[1]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[6]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[2]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[3]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[0]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[7]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[4]}]  \
  [get_cells {u_uart_rx_o_rxData_reg[5]}]  \
  [get_cells {u_uart_rx_r_rxShift_reg[7]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[12]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[9]}]  \
  [get_cells u_uart_rx_o_frameErr_reg]  \
  [get_cells u_uart_rx_o_rxValid_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[8]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[6]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[3]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[5]}]  \
  [get_cells u_uart_baud_gen_o_baudTick_reg]  \
  [get_cells u_uart_tx_o_txReady_reg]  \
  [get_cells u_uart_tx_o_txBusy_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[4]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[2]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[1]}]  \
  [get_cells u_uart_rx_r_rxSync_reg]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[0]}]  \
  [get_cells u_uart_rx_r_rxMeta_reg]  \
  [get_cells {u_uart_tx_r_bitCnt_reg[0]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[10]}]  \
  [get_cells {u_uart_baud_gen_r_clkCnt_reg[11]}]  \
  [get_cells {u_uart_rx_r_bitCnt_reg[2]}]  \
  [get_cells {u_uart_tx_r_state_reg[0]}]  \
  [get_cells {u_uart_tx_r_state_reg[2]}] ] -to [list \
  [get_ports o_uartTx]  \
  [get_ports o_txReady]  \
  [get_ports o_txBusy]  \
  [get_ports {o_rxData[7]}]  \
  [get_ports {o_rxData[6]}]  \
  [get_ports {o_rxData[5]}]  \
  [get_ports {o_rxData[4]}]  \
  [get_ports {o_rxData[3]}]  \
  [get_ports {o_rxData[2]}]  \
  [get_ports {o_rxData[1]}]  \
  [get_ports {o_rxData[0]}]  \
  [get_ports o_rxValid]  \
  [get_ports o_frameErr] ]
group_path -name I2O -from [list \
  [get_ports clk]  \
  [get_ports rst_n]  \
  [get_ports i_txValid]  \
  [get_ports {i_txData[7]}]  \
  [get_ports {i_txData[6]}]  \
  [get_ports {i_txData[5]}]  \
  [get_ports {i_txData[4]}]  \
  [get_ports {i_txData[3]}]  \
  [get_ports {i_txData[2]}]  \
  [get_ports {i_txData[1]}]  \
  [get_ports {i_txData[0]}]  \
  [get_ports i_uartRx] ] -to [list \
  [get_ports o_uartTx]  \
  [get_ports o_txReady]  \
  [get_ports o_txBusy]  \
  [get_ports {o_rxData[7]}]  \
  [get_ports {o_rxData[6]}]  \
  [get_ports {o_rxData[5]}]  \
  [get_ports {o_rxData[4]}]  \
  [get_ports {o_rxData[3]}]  \
  [get_ports {o_rxData[2]}]  \
  [get_ports {o_rxData[1]}]  \
  [get_ports {o_rxData[0]}]  \
  [get_ports o_rxValid]  \
  [get_ports o_frameErr] ]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports i_txValid]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[7]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[6]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[5]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[4]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[3]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[2]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[1]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {i_txData[0]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports i_txValid]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[7]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[6]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[5]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[4]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[3]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[2]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[1]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {i_txData[0]}]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports rst_n]
set_input_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports rst_n]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports o_txReady]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports o_txBusy]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[7]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[6]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[5]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[4]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[3]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[2]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[1]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports {o_rxData[0]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports o_rxValid]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -max 0.6 [get_ports o_frameErr]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_txReady]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_txBusy]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[7]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[6]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[5]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[4]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[3]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[2]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[1]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports {o_rxData[0]}]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_rxValid]
set_output_delay -clock [get_clocks MAIN_CLOCK] -add_delay -min 0.0 [get_ports o_frameErr]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports rst_n]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports i_txValid]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[7]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[6]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[5]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[4]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[3]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[2]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[1]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports {i_txData[0]}]
set_driving_cell -lib_cell BUFX2 -library slow_vdd1v0 -pin "Y" [get_ports i_uartRx]
set_ideal_network [get_ports rst_n]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.1 [get_clocks MAIN_CLOCK]
set_clock_uncertainty -hold 0.05 [get_clocks MAIN_CLOCK]
