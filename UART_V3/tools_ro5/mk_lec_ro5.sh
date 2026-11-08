#!/bin/bash
# 발표용 5 ns PAD top RO + BAUDDIV 수정 : chip-level LEC 묶음 (P&R 서버에서 실행)
#   bash ~/ro5pkg/mk_lec_ro5.sh   -> ~/lec_ro5.tgz -> PC -> hitech001
# hitech001:
#   tar xzf lec_ro5.tgz ; bash lec_ro5/run_lec.sh   -> ~/lec_ro5_result.tgz
TOP=~/PROJ1/proj1_make/TOP
RTL=$TOP/RTL/UART_V3_padall_ro_bf
NL=$TOP/SYN/netlist_5ns_padall_ro_bf/uart_chip_top_allpad_netlist.v
PN=$TOP/PNR/PNR_5NS_PADALL_RO_BF/outputs/uart_chip_top_allpad_pnr.v
SYNS=$TOP/SYN/script/run_synthesis_5ns_padall_ro_bf.tcl
W=~/lec_ro5
stop() { echo "STOP: $*"; exit 1; }

for f in $NL $PN $SYNS; do [ -s $f ] || stop "없음: $f"; done
[ -d $RTL ] || stop "없음: $RTL"

# 라이브러리 경로는 5 ns 합성 스크립트에서 가져온다 (STD + IO)
LIB=$(grep '^set LIB_PATH' $SYNS | cut -d'"' -f2)
IOL=$(grep '^set_db library' $SYNS | grep -o '/[^ ]*\.lib' | head -1)
[ -s "$LIB" ] && [ -s "$IOL" ] || stop "라이브러리 경로 확인 (STD=$LIB IO=$IOL)"

rm -rf $W && mkdir -p $W/rtl $W/netlist $W/log
for f in $RTL/*.v; do
  case $(basename $f) in uart_chip_top.v|uart_v2_top.v) ;; *) cp $f $W/rtl/ ;; esac
done
echo "== RTL ($(ls $W/rtl | wc -l) files):"; ls $W/rtl
grep -q "module uart_chip_top_allpad" $W/rtl/*.v || stop "RTL에 uart_chip_top_allpad 없음"
cp $NL $W/netlist/uart_chip_top_allpad_netlist.v
cp $PN $W/netlist/uart_chip_top_allpad_pnr.v
RLIST=$(cd $W && ls rtl/*.v | sed 's#^#./#' | tr '\n' ' ')

hdr() { cat <<EOD
set dofile abort exit
read library -liberty -both $LIB $IOL
set undefined cell black_box -noascend -both
EOD
}
tail_do() { cat <<'EOD'
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
EOD
}
{ echo "// V3 PAD top RO + BAUDDIV fix : RTL vs Genus 5 ns netlist (chip-level)"
  echo "set log file ./log/lec_ro5_rtl2syn.log -replace"; hdr
  echo "read design -verilog2k -golden $RLIST"
  echo "set root module uart_chip_top_allpad -golden"
  echo "read design -verilog -revised ./netlist/uart_chip_top_allpad_netlist.v"
  echo "set root module uart_chip_top_allpad -revised"; tail_do; } > $W/run_rtl2syn.do
{ echo "// V3 PAD top RO + BAUDDIV fix : Genus 5 ns netlist vs Innovus P&R netlist (chip-level)"
  echo "set log file ./log/lec_ro5_syn2pnr.log -replace"; hdr
  echo "read design -verilog -golden  ./netlist/uart_chip_top_allpad_netlist.v"
  echo "set root module uart_chip_top_allpad -golden"
  echo "read design -verilog -revised ./netlist/uart_chip_top_allpad_pnr.v"
  echo "set root module uart_chip_top_allpad -revised"; tail_do; } > $W/run_syn2pnr.do

cat > $W/run_lec.sh <<'EOS'
#!/bin/bash
cd "$(dirname "$0")"
for d in rtl2syn syn2pnr; do
  lec -XL -nogui -dofile run_$d.do > $d.console 2>&1
  echo "== $d"
  grep -E "Compare Results" $d.console | tail -1
  grep -E "^Equivalent|^Inverted-equivalent|Non-equivalent point|Abort point" $d.console | sort -u | head -6
  grep -A4 "Unmapped points" $d.console | grep -E "Not-mapped|Extra|Unreachable" | sort -u
done
cd .. && tar czf lec_ro5_result.tgz lec_ro5/*.console lec_ro5/log lec_ro5/*.do
echo "== 결과 묶음: $(pwd)/lec_ro5_result.tgz"
EOS

cd ~ && tar czf lec_ro5.tgz lec_ro5 && ls -l ~/lec_ro5.tgz
echo "== hitech001: tar xzf lec_ro5.tgz ; bash lec_ro5/run_lec.sh"
