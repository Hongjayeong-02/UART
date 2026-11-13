// V3 PAD top RO 5 ns : Genus netlist (golden) vs Innovus ECO netlist (revised)
set log file ./log/lec_ro5_syn2eco.log -replace
set dofile abort exit
read library -liberty -both <PDK>/std/stdlib/timing/std_ss.lib <PDK>/io/timing/io_ss.lib
set undefined cell black_box -noascend -both
read design -verilog -golden  ./netlist/uart_chip_top_allpad_netlist.v
set root module uart_chip_top_allpad -golden
read design -verilog -revised ./netlist/uart_chip_top_allpad_eco.v
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
