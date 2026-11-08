#!/bin/bash
# V3 step 10 (1 GHz R2R)   variant V = r10 | r10d (+RX parity 누적, RX FIFO read 분리) | r10e (r10d + core TX write 중복 게이팅 제거) | r10f (r10e + baud 8+8 분할 다운카운터, tick TX/RX 복제)
#   bash ~/r10pkg/run_r10.sh [sim] [V] : RTL copy -> regression 33 -> lockstep vs step 9 -> live BAUDDIV TB
#   bash ~/r10pkg/run_r10.sh syn  [V] [oc] : 1 GHz synthesis (Genus); oc = 합성에서만 setup uncertainty 0.10 -> 0.15
#                                             (P&R SDC는 mk_pnr_r10.sh 가 0.10 으로 되돌림)
#   bash ~/r10pkg/run_r10.sh cmp       : step 9 / r10 / r10d synthesis QoR
# 어느 단계든 실패하면 "STOP:"을 출력하고 멈춘다. 이전 로그는 실행 전에 지운다.
PKG=$(cd "$(dirname "$0")" && pwd)
MODE=${1:-sim}; V=${2:-r10}; OC=${3:-}
case $V in r10) OVL=$PKG/rtl ;; r10d) OVL=$PKG/rtl_r10d ;; r10e) OVL=$PKG/rtl_r10e ;; r10f) OVL=$PKG/rtl_r10f ;; *) echo "STOP: variant $V"; exit 1 ;; esac
TOP=~/PROJ1/proj1_make/TOP
SRC=$TOP/RTL/UART_V3_rsync
DST=$TOP/RTL/UART_V3_$V
TB=~/UART_repo/UART_V3/2_tb/tb_uart_v3_final.v
SIM=~/uart_work/${V}_sim
stop() { echo "STOP: $*"; exit 1; }

if [ "$MODE" = syn ]; then
  [ -f $SIM/ALL_SIM_PASS ] || stop "sim PASS 기록 없음 (먼저 bash run_r10.sh)"
  cd $TOP/SYN || stop "no $TOP/SYN"
  T=$V; [ "$OC" = oc ] && T=${V}_oc
  S=script/run_synthesis_1ghz_$T.tcl
  sed -e "s/UART_V3_rsync/UART_V3_$V/g" -e "s/1ghz_rsync/1ghz_$T/g" script/run_synthesis_1ghz_rsync.tcl > $S
  if [ "$OC" = oc ]; then
    [ -f cons/uart_v3_1ghz_oc.sdc ] || stop "cons/uart_v3_1ghz_oc.sdc 없음"
    echo "== OC SDC vs 기본 SDC (setup uncertainty 한 줄만 달라야 함)"; diff cons/uart_v3_1ghz.sdc cons/uart_v3_1ghz_oc.sdc
    [ "$(diff cons/uart_v3_1ghz.sdc cons/uart_v3_1ghz_oc.sdc | grep -c '^[<>]')" = 2 ] || stop "OC SDC 차이가 1줄이 아님"
    sed -i "s#cons uart_v3_1ghz.sdc#cons uart_v3_1ghz_oc.sdc#" $S
  fi
  if grep -q o_tick16Tx $TOP/RTL/UART_V3_$V/uart_baud_gen.v; then
    # TX/RX tick registers are logically identical: keep both (no flop merging)
    sed -i '/^read_sdc/a set_db optimize_merge_flops false' $S
    grep -q "optimize_merge_flops false" $S || stop "optimize_merge_flops 줄 삽입 실패 (read_sdc 줄 확인)"
  fi
  echo "== script diff (rsync -> $T)"; diff script/run_synthesis_1ghz_rsync.tcl $S
  V=$T
  rm -rf report_1ghz_$V netlist_1ghz_$V genus_1ghz_$V.log* genus_1ghz_$V.cmd*
  genus -batch -files $S -log genus_1ghz_$V > /dev/null 2>&1; rc=$?
  L=$(ls genus_1ghz_$V.log* 2>/dev/null | head -1)
  [ -n "$L" ] || stop "Genus 로그 없음 (rc=$rc)"
  grep -q "UART V3 SYNTHESIS COMPLETED" $L || stop "Genus 미완료 (rc=$rc): grep -n Error $L"
  [ -s report_1ghz_$V/qor.rpt ] || stop "qor.rpt 없음"
  echo "== Genus 완료 (rc=$rc), Error 줄 $(grep -c '^Error' $L)"; ls report_1ghz_$V
  if grep -q "optimize_merge_flops false" $S; then
    nt=$(grep -c "o_tick16Tx_reg\|o_tick16Rx_reg" netlist_1ghz_$V/uart_apb_netlist.v)
    echo "== tick 레지스터 (TX/RX 둘 다 있어야 함): $(grep -o 'o_tick16[TR]x_reg' netlist_1ghz_$V/uart_apb_netlist.v | sort -u | tr '\n' ' ')"
    [ "$(grep -o 'o_tick16[TR]x_reg' netlist_1ghz_$V/uart_apb_netlist.v | sort -u | wc -l)" = 2 ] || stop "tick 레지스터가 합쳐짐"
  fi
  exit 0
fi

if [ "$MODE" = cmp ]; then
  cd $TOP/SYN || stop "no $TOP/SYN"
  for v in rsync r10e r10e_oc r10f r10f_oc; do
    [ -s report_1ghz_$v/qor.rpt ] || { echo "== $v: 결과 없음"; continue; }
    echo "== $v   (group  WNS(ps)  TNS(ps)  violating)  $(ls -l --time-style=+%m/%d_%H:%M report_1ghz_$v/qor.rpt | awk '{print $6}')"
    grep -E "^(I2O|I2R|R2O|R2R) " report_1ghz_$v/qor.rpt
    grep -E "^ *uart_apb " report_1ghz_$v/area.rpt | head -1
  done
  for v in r10f r10f_oc; do [ -s report_1ghz_$v/r2r.rpt ] || continue
    echo "== $v R2R top 10 (start -> end : slack ps)"
    awk '/Startpoint/{s=$NF} /Endpoint/{e=$NF} /Slack:=/{print s" -> "e" : "$2}' report_1ghz_$v/r2r.rpt | head -10 | sed 's/uut_uart_core_//g'
  done
  exit 0
fi

[ -d $SRC ] || stop "$SRC 없음"
echo "== step 9 server RTL vs repo 1_rtl"
D=$(diff -rq $SRC ~/UART_repo/UART_V3/1_rtl | grep -v chip_top)
[ -z "$D" ] || { echo "$D"; stop "서버 ⑨ RTL이 레포와 다름 (패치는 레포 기준)"; }
echo "   same (chip_top 제외)"

[ -d $DST ] && stop "$DST 이미 있음 (다시 하려면: rm -rf $DST)"
mkdir -p $DST && cp $SRC/*.v $DST/ && cp $OVL/*.v $DST/
echo "== step 10 RTL ($V): $DST"; diff -rq $SRC $DST

rm -rf $SIM && mkdir -p $SIM/lock $SIM/baud && cd $SIM
RTL10=$(ls $DST/*.v | grep -v chip_top)
RTL9=$(ls $SRC/*.v | grep -v chip_top)

echo "== 1. regression (step 10)"
xrun -64bit -timescale 1ns/1ps $RTL10 $TB -top tb_uart_v3_final -l reg_r10.log > /dev/null 2>&1
[ -f reg_r10.log ] || stop "xrun 로그 없음"
np=$(grep -c '^PASS' reg_r10.log); nf=$(grep -c 'FAIL' reg_r10.log); ne=$(grep -c '\*E,' reg_r10.log)
echo "   PASS $np / FAIL $nf / *E $ne | $(grep -o 'ALL PASS' reg_r10.log)"
[ "$np" = 33 ] && [ "$nf" = 0 ] && [ "$ne" = 0 ] && grep -q "ALL PASS" reg_r10.log || stop "regression"

echo "== 2. lockstep step 9 vs step 10 (BAUDDIV 고정 구간, 출력 5개 매 cycle 비교)"
cd lock
for f in $RTL10; do
  sed -E 's/\b(uart_apb|uart_core|uart_baud_gen|uart_tx|uart_rx|uart_fifo|uart_rx_fifo|uart_tx_fifo|uart_irq|uart_loopback|uart_v2_top)\b/\1_r10/g' $f > r10_$(basename $f)
done
for s in 1 2 3 4 5; do
  xrun -64bit -timescale 1ns/1ps $RTL9 r10_*.v $PKG/tb/tb_lock.v -top tb_lock +seed=$s -l lock_$s.log > /dev/null 2>&1
  r=$(grep -h LOCKSTEP lock_$s.log)
  echo "   $(echo $r | grep -oE 'cycles=[0-9]+|tx_frames=[0-9]+|mismatches=[0-9]+|direct_fail=[0-9]+|push=[0-9]+|premise_fail=[0-9]+|=> [A-Z]+' | tr '\n' ' ') *E $(grep -c '\*E,' lock_$s.log)"
  echo "$r" | grep -q "=> PASS" || stop "lockstep seed $s"
done
cd ..

echo "== 3. live BAUDDIV TB (⑩: 변경 시 카운터 재시작 / ⑨: 참고)"
cd baud
sed 's/module uart_baud_gen/module baud9/'  $SRC/uart_baud_gen.v > b9.v
sed 's/module uart_baud_gen/module baud10/' $DST/uart_baud_gen.v > b10.v
if grep -q o_tick16Tx b10.v; then
  xrun -64bit -timescale 1ns/1ps b9.v b10.v $PKG/tb/tb_baud_live_f.v -top tb_baud_live -l baud.log > /dev/null 2>&1
  xrun -64bit -timescale 1ns/1ps b9.v b10.v $PKG/tb/tb_baud_big.v -top tb_baud_big -l baud_big.log > /dev/null 2>&1
  grep -h "BAUD BIG TB" baud_big.log | sed 's/^/   /'
  grep -q "BAUD BIG TB.*=> PASS" baud_big.log || stop "big BAUDDIV TB"
else
  xrun -64bit -timescale 1ns/1ps b9.v b10.v $PKG/tb/tb_baud_live.v -top tb_baud_live -l baud.log > /dev/null 2>&1
fi
grep -h "BAUD LIVE TB" baud.log | sed 's/^/   /'
grep -q "BAUD LIVE TB.*=> PASS" baud.log || stop "live BAUDDIV TB"
cd ..

date > ALL_SIM_PASS
echo "== sim 전부 PASS -> 다음: bash $PKG/run_r10.sh syn $V"
