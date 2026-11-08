// V3 PAD top RO + BAUDDIV fix : RTL vs Genus 5 ns netlist (chip-level)
set log file ./log/lec_ro5_rtl2syn.log -replace
set dofile abort exit
read library -liberty -both <PDK>/std/stdlib/timing/std_ss.lib <PDK>/io/timing/io_ss.lib
set undefined cell black_box -noascend -both
read design -verilog2k -golden ./rtl/uart_apb.v ./rtl/uart_baud_gen.v ./rtl/uart_chip_top_allpad.v ./rtl/uart_core.v ./rtl/uart_fifo.v ./rtl/uart_irq.v ./rtl/uart_loopback.v ./rtl/uart_rx.v ./rtl/uart_rx_fifo.v ./rtl/uart_tx.v ./rtl/uart_tx_fifo.v 
set root module uart_chip_top_allpad -golden
read design -verilog -revised ./netlist/uart_chip_top_allpad_netlist.v
set root module uart_chip_top_allpad -revised
report design data
report black box
set flatten model -seq_constant -seq_constant_x_to 0
set analyze option -auto
set system mode lec
report unmapped points -summary
report unmapped points -notmapped
report unmapped points -unreachable
add compare points -all
compare
report verification
report statistics
report compare data -class nonequivalent
report compare data -class abort
exit -force
