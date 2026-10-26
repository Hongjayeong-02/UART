// UART V3 10 ns : Genus 합성 netlist (golden) vs Innovus P&R netlist (revised, hold 목표 +5 ps 최종)
// 실행 위치: EC_10ns_pnr/   (lec -XL -nogui -dofile run_lec_pnr.do)
set log file ./log/lec_syn2pnr_10ns.log -replace
set dofile abort exit

read library -liberty -both /GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib
set undefined cell black_box -noascend -both

read design -verilog -golden  ./netlist/uart_apb_netlist.v
set root module uart_apb -golden
read design -verilog -revised ./netlist/uart_apb_pnr.v
set root module uart_apb -revised

report design data
report black box
report rule check -summary

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
