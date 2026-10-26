// UART V3 (rsync9) RTL vs Genus 10 ns netlist - Conformal LEC
// 실행 위치: EC_10ns/   (lec -XL -nogui -dofile run_lec.do)
set log file ./log/lec_rtl2syn_10ns.log -replace
set dofile abort exit

// 1) Library (golden / revised 동일)
read library -liberty -both /GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib

// 2) Golden = 합성에 쓴 RTL (uart_chip_top.v 는 PAD top 이라 제외, root = uart_apb)
read design -verilog2k -golden \
  ./rtl/uart_apb.v ./rtl/uart_baud_gen.v ./rtl/uart_core.v ./rtl/uart_fifo.v \
  ./rtl/uart_irq.v ./rtl/uart_loopback.v ./rtl/uart_rx.v ./rtl/uart_rx_fifo.v ./rtl/uart_tx.v ./rtl/uart_tx_fifo.v
set root module uart_apb -golden

// 3) Revised = Genus 10 ns netlist
read design -verilog -revised ./netlist/uart_apb_netlist.v
set root module uart_apb -revised

// 4) 읽기 점검
report design data
report black box
report rule check -summary

// 5) 합성에서 상수로 바뀌어 지워진 flop 처리 후 비교
set flatten model -seq_constant
set system mode lec
report unmapped points -summary
report unmapped points -notmapped
add compare points -all
compare

// 6) 결과
report verification
report statistics
report compare data -class nonequivalent
report compare data -class abort
exit -force
