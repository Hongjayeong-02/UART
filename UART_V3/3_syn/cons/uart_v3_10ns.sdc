set PERIOD 10.0
set IO_DELAY_MAX [expr {$PERIOD * 0.4}]
set IO_DELAY_MIN 0.0
set RST_DELAY_MAX $IO_DELAY_MAX
create_clock -name MAIN_CLOCK -period $PERIOD -waveform {0.0 5.0} [get_ports clk]
set_clock_uncertainty -setup 0.10 [get_clocks MAIN_CLOCK]
set_clock_uncertainty -hold 0.05 [get_clocks MAIN_CLOCK]
set_clock_transition 0.05 [get_clocks MAIN_CLOCK]
set CLK_PORT [get_ports clk]
set RST_PORT [get_ports rst_n]
set UART_RX [get_ports i_uartRx]
set UART_TX [get_ports o_uartTx]
set ALL_DATA_INPUTS [remove_from_collection [all_inputs] $CLK_PORT]
set APB_INPUTS [remove_from_collection $ALL_DATA_INPUTS $RST_PORT]
set APB_INPUTS [remove_from_collection $APB_INPUTS $UART_RX]
set SYNC_OUTPUTS [remove_from_collection [all_outputs] $UART_TX]
set_input_delay -max $IO_DELAY_MAX -clock MAIN_CLOCK $APB_INPUTS
set_input_delay -min $IO_DELAY_MIN -clock MAIN_CLOCK $APB_INPUTS
set_input_delay -max $RST_DELAY_MAX -clock MAIN_CLOCK $RST_PORT
set_input_delay -min $IO_DELAY_MIN -clock MAIN_CLOCK $RST_PORT
set_ideal_network $RST_PORT
set_output_delay -max $IO_DELAY_MAX -clock MAIN_CLOCK $SYNC_OUTPUTS
set_output_delay -min $IO_DELAY_MIN -clock MAIN_CLOCK $SYNC_OUTPUTS
set_driving_cell -lib_cell BUFX2 -pin Y $ALL_DATA_INPUTS
set_load 0.01 [all_outputs]
set_false_path -from $UART_RX
set_false_path -to $UART_TX
