#!/bin/bash
# ⑩ 1 GHz P&R 폴더 만들기 (⑨ PNR_1GHZ_RSYNC_QRC 의 스크립트/SDC만 복사, DB는 복사 안 함)
#   bash ~/r10pkg/mk_pnr_r10.sh r10d     -> TOP/PNR/PNR_1GHZ_R10D_QRC
TOP=~/PROJ1/proj1_make/TOP
V=${1:?variant (r10 .. r10f, _oc)}
SRC=$TOP/_archive/PNR_1GHZ_RSYNC_QRC
DST=$TOP/PNR/PNR_1GHZ_$(echo $V | tr a-z A-Z)_QRC
NL=$TOP/SYN/netlist_1ghz_$V
stop() { echo "STOP: $*"; exit 1; }

[ -s $NL/uart_apb_netlist.v ] || stop "$NL/uart_apb_netlist.v 없음 (합성 먼저)"
[ -d $DST ] && stop "$DST 이미 있음"
mkdir -p $DST
cp $SRC/[0-5]_*.tcl $SRC/run_all.tcl $SRC/uart_apb.mmmc.view $SRC/uart_apb_1ghz_pnr.sdc $DST/
[ -f $SRC/streamOut.map ] && cp $SRC/streamOut.map $DST/

# netlist: ../SYN/netlist_1ghz_rsync -> ../../SYN/netlist_1ghz_$V  (TOP/PNR/<dir> 기준)
sed -i "s#\.\./SYN/netlist_1ghz_rsync/#../../SYN/netlist_1ghz_$V/#" $DST/0_InitDesign.tcl
# placeDesign aborts when > ~50 % of flops are scan flops without a scan chain
# (Genus maps enable flops to SDFF; SE/SI are functional). Allow the missing
# chain definition; scan nets are NOT ignored (-ignoreScan stays default).
sed -i '/^placeDesign/i setPlaceMode -place_global_exp_allow_missing_scan_chain true' $DST/2_PlaceOpt.tcl
grep -q "allow_missing_scan_chain true" $DST/2_PlaceOpt.tcl || stop "2_PlaceOpt.tcl 에 placeDesign 줄이 없음"
echo "== init_verilog"; grep -n "init_verilog" $DST/0_InitDesign.tcl
( cd $DST && ls -l $(grep init_verilog 0_InitDesign.tcl | awk '{print $3}') ) || stop "netlist 경로 확인"

echo "== 다른 상대 경로 (../ 로 시작하는 것: 한 단계 더 깊어졌으니 확인 필요)"
grep -n '\.\./' $DST/*.tcl $DST/*.view | grep -v "netlist_1ghz_$V"

echo "== ccopt spec / 이전 결과 참조 여부"
grep -n "ccopt.spec\|source .*spec\|restoreDesign\|PNR_1GHZ" $DST/*.tcl

echo "== run_all.tcl 끝 (exit 있는지)"
tail -3 $DST/run_all.tcl

echo "== SDC: ⑩ Genus SDC - set_ideal_network rst_n (⑨ P&R SDC와 같은 편집)"
mv $DST/uart_apb_1ghz_pnr.sdc $DST/uart_apb_1ghz_pnr_step9.sdc
grep -v '^set_ideal_network \[get_ports rst_n\]' $NL/uart_apb_syn.sdc \
  | sed 's/^set_clock_uncertainty -setup 0\.15 /set_clock_uncertainty -setup 0.1 /' > $DST/uart_apb_1ghz_pnr.sdc
echo "   setup uncertainty (P&R): $(grep 'uncertainty -setup' $DST/uart_apb_1ghz_pnr.sdc)"
n1=$(grep -c "set_ideal_network" $DST/uart_apb_1ghz_pnr.sdc)
n2=$(diff <(grep -v '^#' $DST/uart_apb_1ghz_pnr_step9.sdc) <(grep -v '^#' $DST/uart_apb_1ghz_pnr.sdc) | grep '^[<>]' | grep -vc get_cells)
echo "   set_ideal_network 남은 줄: $n1 (0이어야 함) | ⑨ P&R SDC와 셀 목록 외 차이: $n2 (0이어야 함)"
[ "$n1" = 0 ] && [ "$n2" = 0 ] || stop "SDC 확인"
echo
echo "== 실행 (tcsh):  cd $DST ; nohup innovus -nowin -files run_all.tcl -log run_all < /dev/null >& run_all.out &"
echo
echo "== 준비 끝: $DST"
