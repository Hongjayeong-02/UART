#!/bin/bash
# ⑩ LEC 묶음 만들기 (P&R 서버에서 실행) -> ~/lec_<V>.tgz -> PC -> hitech001
#   bash ~/r10pkg/mk_lec_r10.sh r10e
# hitech001:
#   tar xzf lec_<V>.tgz ; cd lec_<V> ; bash run_lec.sh      -> ~/lec_<V>_result.tgz
TOP=~/PROJ1/proj1_make/TOP
V=${1:?variant (예: r10e)}
VU=$(echo $V | tr a-z A-Z)
RTL=$TOP/RTL/UART_V3_$V
NL=$TOP/SYN/netlist_1ghz_$V/uart_apb_netlist.v
PNR=$TOP/PNR/PNR_1GHZ_${VU}_QRC
W=~/lec_$V
stop() { echo "STOP: $*"; exit 1; }

[ -d $RTL ] || stop "$RTL 없음"
[ -s $NL ]  || stop "$NL 없음"
[ -d $PNR/outputs ] || stop "$PNR/outputs 없음"
echo "== P&R outputs 의 netlist 후보"; ls -l $PNR/outputs/*.v
PN=$(ls $PNR/outputs/*.v | grep -v -i "phys\|fill" | head -1)
[ -s "$PN" ] || stop "P&R netlist 없음"
echo "   사용: $PN"

# 라이브러리 경로는 합성 스크립트에서 그대로 가져온다 (dofile에 직접 적지 않음)
LIB=$(grep '^set LIB_PATH' $TOP/SYN/script/run_synthesis_1ghz_rsync.tcl | cut -d'"' -f2)
[ -s "$LIB" ] || stop "LIB_PATH 확인 ($LIB)"

rm -rf $W && mkdir -p $W/rtl $W/netlist $W/log
GOLD="uart_apb uart_baud_gen uart_core uart_fifo uart_irq uart_loopback uart_rx uart_rx_fifo uart_tx uart_tx_fifo"
for m in $GOLD; do cp $RTL/$m.v $W/rtl/ || stop "$m.v 없음"; done
cp $NL $W/netlist/uart_apb_netlist.v
cp $PN $W/netlist/uart_apb_pnr.v

RLIST=$(for m in $GOLD; do printf " ./rtl/%s.v" $m; done)

cat > $W/run_rtl2syn.do <<EOD
// UART V3 step 10 ($V) RTL vs Genus 1 GHz netlist
set log file ./log/lec_${V}_rtl2syn.log -replace
set dofile abort exit
read library -liberty -both $LIB
set undefined cell black_box -noascend -both
read design -verilog2k -golden $RLIST
set root module uart_apb -golden
read design -verilog -revised ./netlist/uart_apb_netlist.v
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
EOD

cat > $W/run_syn2pnr.do <<EOD
// UART V3 step 10 ($V) Genus 1 GHz netlist vs Innovus P&R netlist
set log file ./log/lec_${V}_syn2pnr.log -replace
set dofile abort exit
read library -liberty -both $LIB
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
EOD

cat > $W/run_lec.sh <<'EOS'
#!/bin/bash
# hitech001: bash run_lec.sh
cd "$(dirname "$0")"
V=$(basename $(pwd) | sed 's/^lec_//')
for d in rtl2syn syn2pnr; do
  lec -XL -nogui -dofile run_$d.do > $d.console 2>&1
  echo "== $d"
  grep -E "Compare Results|^ *Equivalent|Non-equivalent|Abort|Not-compared" $d.console | tail -8
  grep -A12 "Unmapped points" $d.console | grep -E "Not-mapped|Extra|Unreachable|Total" | head -6
done
cd .. && tar czf lec_${V}_result.tgz lec_${V}/*.console lec_${V}/log lec_${V}/*.do
echo "== 결과 묶음: $(pwd)/lec_${V}_result.tgz"
EOS

cd ~ && tar czf lec_$V.tgz lec_$V && ls -l ~/lec_$V.tgz
echo "== 다음: lec_$V.tgz 를 PC로 받아 hitech001 홈에 올린 뒤"
echo "   tar xzf lec_$V.tgz ; bash lec_$V/run_lec.sh"
