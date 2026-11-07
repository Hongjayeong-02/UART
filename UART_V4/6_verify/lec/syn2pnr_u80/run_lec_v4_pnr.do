// UART V4 : Genus 10 ns netlist vs Innovus P&R netlist (CTS, hold buffer, resize)
set log file ./log/lec_v4_syn2pnr.log -replace
set dofile abort exit
read library -liberty -both <PDK>/std/stdlib/timing/std_ss.lib
set undefined cell black_box -noascend -both
read design -verilog -golden  ./netlist/uart_v4_apb_netlist.v
set root module uart_v4_apb -golden
read design -verilog -revised ./netlist/uart_v4_apb_pnr.v
set root module uart_v4_apb -revised
report design data
report black box
set flatten model -seq_constant -seq_constant_x_to 0
set analyze option -auto
set system mode lec
report unmapped points -summary
report unmapped points -notmapped
add compare points -all
compare
report verification
report statistics
report compare data -class nonequivalent
report compare data -class abort
exit -force
