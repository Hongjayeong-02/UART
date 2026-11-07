#!/bin/bash
# Floorplan sweep (core utilization / core-to-IO margin) for V3 or V4 block-level P&R
#   nohup bash ~/sweep_fp.sh v3 >& ~/sweep_v3.out &
#   nohup bash ~/sweep_fp.sh v4 >& ~/sweep_v4.out &
# 기준 디렉토리의 0~5 tcl, mmmc, sdc 를 복사하고 0번 floorPlan 한 줄만 바꿔서 순서대로 실행.
# 기준 디렉토리는 건드리지 않음. 결과 표: bash ~/collect_fp.sh v3|v4
# 3번째 인자: pin spacing (um). 주면 editPin -spacing 2.0 을 그 값으로 바꾸고 디렉토리 이름에 _p<값> 추가
#   nohup bash ~/sweep_fp.sh v3 "70:10 80:10 90:10" 1.0 >& ~/sweep_v3_p1.out &
CFGS=${2:-"60:15 70:10 80:10 90:10"}    # util% : margin(um)
SP=$3

case "$1" in
  v3) BASE=~/PROJ1/proj1_make/TOP/PNR/PNR_10NS_V3_H5; OUT=~/PROJ1/proj1_make/TOP/PNR; PRE=SW_V3 ;;
  v4) BASE=~/UART_V4/pnr;                              OUT=~/UART_V4;                  PRE=pnr_sw ;;
  *)  echo "usage: bash sweep_fp.sh v3|v4"; exit 1 ;;
esac

for c in $CFGS; do
  u=${c%:*}; m=${c#*:}
  D=$OUT/${PRE}_u${u}_m${m}${SP:+_p${SP%.*}}
  if [ -d $D ]; then echo "== skip $D (already exists)"; continue; fi
  mkdir -p $D
  cp $BASE/[0-5]_*.tcl $BASE/run_all.tcl $BASE/*.view $D/
  ls $BASE/*.sdc > /dev/null 2>&1 && cp $BASE/*.sdc $D/
  sed -i "s/^floorPlan -site CoreSite -r .*/floorPlan -site CoreSite -r 1.0 0.$u $m $m $m $m/" $D/0_InitDesign.tcl
  [ -n "$SP" ] && sed -i "s/-spacing 2.0 /-spacing $SP /" $D/0_InitDesign.tcl
  sed -i '/^saveDesign ChipFinish/i summaryReport -noHtml -outfile reports/summary.rpt' $D/5_ChipFinish.tcl
  grep -q "0\.$u $m $m $m $m" $D/0_InitDesign.tcl || { echo "ERROR: floorPlan line not changed in $D"; exit 1; }
  echo "== RUN $D  ($(date '+%H:%M'))"
  (cd $D && innovus -nowin -files run_all.tcl -log run_sw > /dev/null 2>&1)
  echo "   done ($(date '+%H:%M')), ChipFinish.dat: $( [ -d $D/ChipFinish.dat ] && echo yes || echo NO )"
done
echo "== all done"
