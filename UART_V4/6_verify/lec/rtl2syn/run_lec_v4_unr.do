// UART V4 (dual-clock CDC, registered PSLVERR) : RTL vs Genus 10 ns netlist
set log file ./log/lec_v4_rtl2syn.log -replace
set dofile abort exit
read library -liberty -both <PDK>/std/stdlib/timing/std_ss.lib
set undefined cell black_box -noascend -both
read design -verilog2k -golden  ./rtl/uart_async_fifo.v ./rtl/uart_v4_cfg_cdc.v ./rtl/uart_v4_baud_gen.v ./rtl/uart_tx.v ./rtl/uart_v4_rx.v ./rtl/uart_v4_core.v ./rtl/uart_v4_sync_level.v ./rtl/uart_v4_event_sync.v ./rtl/uart_v4_rst_sync.v ./rtl/uart_irq.v ./rtl/uart_v4_apb.v
set root module uart_v4_apb -golden
read design -verilog -revised ./netlist/uart_v4_apb_netlist.v
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
report unmapped points -unreachable
exit -force
