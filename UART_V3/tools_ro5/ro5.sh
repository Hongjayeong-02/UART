#!/bin/bash
# V3 발표용: PAD top RO + BAUDDIV 수정(">=") , 5 ns (200 MHz)
#   bash ~/ro5pkg/ro5.sh sim   : RTL 폴더 생성 + regression / RO read 비교 / ⑨ lockstep / BAUDDIV TB
#   bash ~/ro5pkg/ro5.sh syn   : 5 ns SDC 생성 + Genus
#   bash ~/ro5pkg/ro5.sh cmp   : 10 ns RO vs 5 ns RO+fix 합성 QoR
#   bash ~/ro5pkg/ro5.sh pnr   : P&R 폴더 생성 (10 ns RO 스크립트 복사, netlist/SDC만 교체)
# 실패하면 STOP 출력 후 멈춤. 기존 폴더는 건드리지 않음.
PKG=$(cd "$(dirname "$0")" && pwd)
TOP=~/PROJ1/proj1_make/TOP
REPO=~/UART_repo/UART_V3
RO=$TOP/RTL/UART_V3_padall_ro
BF=$TOP/RTL/UART_V3_padall_ro_bf
RS=$TOP/RTL/UART_V3_rsync
SIM=~/uart_work/ro5_sim
TAG=5ns_padall_ro_bf
stop() { echo "STOP: $*"; exit 1; }

case "$1" in
sim)
  [ -d $RO ] || stop "$RO 없음"
  cmp -s $RO/uart_baud_gen.v $PKG/ref/uart_baud_gen_step9.v || stop "서버 RO의 uart_baud_gen.v 가 ⑨와 다름"
  cmp -s $RS/uart_baud_gen.v $PKG/ref/uart_baud_gen_step9.v || stop "서버 rsync의 uart_baud_gen.v 가 ⑨와 다름"
  [ -d $BF ] && stop "$BF 이미 있음 (다시: rm -rf $BF)"
  cp -r $RO $BF && cp $PKG/rtl/uart_baud_gen.v $BF/
  echo "== RTL: $BF  (RO 대비 차이)"; diff -rq $RO $BF
  [ "$(diff -rq $RO $BF | wc -l)" = 1 ] || stop "uart_baud_gen.v 외 차이"
  rm -rf $SIM && mkdir -p $SIM/rs $SIM/lock $SIM/baud && cd $SIM
  # (1) ⑨ + fix regression (non-RO uart_apb, 기존 33 checks)
  cp $RS/*.v rs/ && cp $PKG/rtl/uart_baud_gen.v rs/ && rm -f rs/uart_chip_top.v rs/uart_v2_top.v
  xrun -64bit -timescale 1ns/1ps rs/*.v $REPO/2_tb/tb_uart_v3_final.v -top tb_uart_v3_final -l reg.log > /dev/null 2>&1
  np=$(grep -c '^PASS' reg.log); nf=$(grep -c FAIL reg.log); ne=$(grep -c '\*E,' reg.log)
  echo "== 1. regression (⑨+fix): PASS $np / FAIL $nf / *E $ne | $(grep -o 'ALL PASS' reg.log)"
  [ "$np" = 33 ] && [ "$nf" = 0 ] && [ "$ne" = 0 ] || stop regression
  # (2) RO + fix read 비교 (V3 조합 read vs RO registered read)
  RTLB=$(ls $BF/*.v | grep -v "chip_top\|v2_top")
  xrun -64bit -timescale 1ns/1ps $RTLB $REPO/6_verify/read_opt/uart_apb_v3_ref.v $REPO/6_verify/read_opt/tb_read_opt_diff.v -top tb_read_opt_diff -l rod.log > /dev/null 2>&1
  echo "== 2. $(grep -h READ_OPT_DIFF rod.log)"; grep -q "READ_OPT_DIFF.*PASS" rod.log || stop read_opt
  # (3) ⑨ vs ⑨+fix lockstep
  cd lock
  for f in ../rs/*.v; do sed -E 's/\b(uart_apb|uart_core|uart_baud_gen|uart_tx|uart_rx|uart_fifo|uart_rx_fifo|uart_tx_fifo|uart_irq|uart_loopback)\b/\1_r10/g' $f > r10_$(basename $f); done
  R9=$(ls $RS/*.v | grep -v "chip_top\|v2_top")
  for s in 1 2 3; do
    xrun -64bit -timescale 1ns/1ps $R9 r10_*.v $PKG/tb/tb_lock.v -top tb_lock +seed=$s -l lock_$s.log > /dev/null 2>&1
    r=$(grep -h LOCKSTEP lock_$s.log); echo "== 3. $(echo $r | grep -oE 'cycles=[0-9]+|mismatches=[0-9]+|direct_fail=[0-9]+|premise_fail=[0-9]+|=> [A-Z]+' | tr '\n' ' ')"
    echo "$r" | grep -q "=> PASS" || stop "lockstep $s"
  done
  cd ../baud
  sed 's/module uart_baud_gen/module baud9/'  $PKG/ref/uart_baud_gen_step9.v > b9.v
  sed 's/module uart_baud_gen/module baud10/' $PKG/rtl/uart_baud_gen.v > b10.v
  xrun -64bit -timescale 1ns/1ps b9.v b10.v $PKG/tb/tb_baud_live.v  -top tb_baud_live -l live.log > /dev/null 2>&1
  xrun -64bit -timescale 1ns/1ps b9.v b10.v $PKG/tb/tb_baud_big_9.v -top tb_baud_big  -l big.log  > /dev/null 2>&1
  echo "== 4. $(grep -h 'BAUD LIVE TB' live.log)"; echo "== 4. $(grep -h 'BAUD BIG TB' big.log)"
  grep -q "BAUD LIVE TB.*=> PASS" live.log && grep -q "BAUD BIG TB.*=> PASS" big.log || stop baud
  date > ../ALL_SIM_PASS; echo "== sim 전부 PASS -> bash $PKG/ro5.sh syn" ;;

syn)
  [ -f $SIM/ALL_SIM_PASS ] || stop "sim 먼저"
  cd $TOP/SYN || stop SYN
  sed -e 's/^set PERIOD 10.0$/set PERIOD 5.0/' -e 's/-waveform {0.0 5.0}/-waveform {0.0 2.5}/' cons/uart_v3_10ns_pad.sdc > cons/uart_v3_5ns_pad.sdc
  echo "== SDC diff (10 ns -> 5 ns)"; diff cons/uart_v3_10ns_pad.sdc cons/uart_v3_5ns_pad.sdc
  [ "$(diff cons/uart_v3_10ns_pad.sdc cons/uart_v3_5ns_pad.sdc | grep -c '^[<>]')" = 4 ] || stop "SDC 차이가 2줄이 아님"
  S=script/run_synthesis_$TAG.tcl
  sed -e "s/UART_V3_padall_ro\\b/UART_V3_padall_ro_bf/g" -e "s/10ns_padall_ro/$TAG/g" -e "s/uart_v3_10ns_pad.sdc/uart_v3_5ns_pad.sdc/" script/run_synthesis_10ns_padall_ro.tcl > $S
  echo "== script diff"; diff script/run_synthesis_10ns_padall_ro.tcl $S
  grep -q "UART_V3_padall_ro_bf" $S && grep -q "uart_v3_5ns_pad.sdc" $S || stop "script 치환"
  rm -rf report_$TAG netlist_$TAG genus_$TAG.log* genus_$TAG.cmd*
  genus -batch -files $S -log genus_$TAG > /dev/null 2>&1; rc=$?
  L=$(ls genus_$TAG.log* 2>/dev/null | head -1); [ -n "$L" ] || stop "Genus 로그 없음 rc=$rc"
  [ -s report_$TAG/qor.rpt ] || { tail -20 $L; stop "qor.rpt 없음 (rc=$rc)"; }
  echo "== Genus 완료 rc=$rc, Error $(grep -c '^Error' $L)"; ls report_$TAG netlist_$TAG ;;

cmp)
  cd $TOP/SYN
  for d in report_10ns_padall_ro report_$TAG; do
    echo "== $d"; grep -E "^(I2O|I2R|R2O|R2R) |Cost Group|Timing Path Group" $d/qor.rpt | head -8
    grep -E "^ *uart_chip_top_allpad |^ *u_uart_apb " $d/area.rpt | head -3
  done ;;

pnr)
  SRC=$TOP/PNR/PNR_10NS_PADALL_RO; DST=$TOP/PNR/PNR_5NS_PADALL_RO_BF; NL=$TOP/SYN/netlist_$TAG
  [ -d $SRC ] || stop "$SRC 없음"; [ -d $DST ] && stop "$DST 이미 있음"
  ls $NL; GS=$(ls $NL/*.sdc | head -1); [ -s "$GS" ] || stop "Genus SDC 없음"
  mkdir -p $DST && cd $SRC && cp *.tcl *.view *.io *.lef $DST/ && cp $SRC/*.sdc $DST/ 2>/dev/null   # *.lef: 로컬 IO LEF(v2) 필요
  cd $DST
  sed -i "s#\\(\\.\\./\\)\\{1,\\}SYN/netlist_10ns_padall_ro/#../../SYN/netlist_$TAG/#" 0_InitDesign.tcl
  echo "== init_verilog"; grep -n init_verilog 0_InitDesign.tcl
  ls -l $(grep init_verilog 0_InitDesign.tcl | awk '{print $3}') || stop "netlist 경로"
  # SDC: 10 ns 와 같은 편집 = Genus SDC + (10 ns P&R SDC에만 있는 줄)
  OLD=$(grep -o '[A-Za-z0-9_]*_pnr\.sdc' uart_chip_top_allpad.mmmc.view | head -1)
  OGS=$(ls $TOP/SYN/netlist_10ns_padall_ro/*.sdc | head -1)
  # group_path 의 셀 목록(get_cells/get_pins)은 파일마다 순서·형식이 달라 비교에서 뺀다
  ADD=$(diff <(grep -v '^#' $OGS) <(grep -v '^#' $OLD) | grep '^>' | grep -v 'get_cells\|get_pins' | sed 's/^> //')
  echo "== 10 ns P&R SDC에서 Genus SDC에 추가했던 줄 (셀 목록 제외):"; echo "$ADD"
  [ "$ADD" = "set_false_path -from [get_ports rst_n]" ] || stop "추가 줄이 rst_n false path 하나가 아님"
  DEL=$(diff <(grep -v '^#' $OGS) <(grep -v '^#' $OLD) | grep '^<' | grep -vc 'get_cells\|get_pins')
  [ "$DEL" = 0 ] || stop "10 ns P&R SDC에서 지운 줄이 있음 ($DEL) - 수동 확인"
  { cat $GS; echo "$ADD"; } > uart_chip_top_allpad_5ns_pnr.sdc
  sed -i "s#$OLD#uart_chip_top_allpad_5ns_pnr.sdc#" uart_chip_top_allpad.mmmc.view
  grep -n "sdc_files" uart_chip_top_allpad.mmmc.view
  grep -n "create_clock\|uncertainty\|false_path -from \[get_ports rst_n\]" uart_chip_top_allpad_5ns_pnr.sdc
  rm -f $OLD
  # placeDesign 이 scan 검사로 멈추지 않게 (기능 넷은 그대로, -ignoreScan 안 씀)
  grep -q "allow_missing_scan_chain" 2_PlaceOpt.tcl || sed -i '/^placeDesign/i setPlaceMode -place_global_exp_allow_missing_scan_chain true' 2_PlaceOpt.tcl
  echo "== holdTargetSlack / scan 옵션"; grep -n "holdTargetSlack\|allow_missing" *.tcl
  echo "== 다른 상대 경로"; grep -n '\.\./' *.tcl *.view | grep -v "netlist_$TAG"
  tail -2 run_all.tcl
  echo "== 실행: cd $DST ; nohup innovus -nowin -files run_all.tcl -log run_all < /dev/null >& run_all.out &" ;;
*) echo "usage: ro5.sh sim|syn|cmp|pnr" ;;
esac
