#!/bin/bash
# Floorplan sweep 결과 모으기 : bash ~/collect_fp.sh v3|v4
case "$1" in
  v3) DIRS=$(ls -d ~/PROJ1/proj1_make/TOP/PNR/SW_V3_u* 2>/dev/null); TOPN=uart_apb ;;
  v4) DIRS=$(ls -d ~/UART_V4/pnr_sw_u* 2>/dev/null);              TOPN=uart_v4_apb ;;
  *)  echo "usage: bash collect_fp.sh v3|v4"; exit 1 ;;
esac

printf "%-14s %-15s %9s %7s %8s %8s %6s %5s %5s %6s %6s\n" cfg "die(um)" "die um2" "cell%" "setupWNS" "holdWNS" "viol" FEPHC DRC chkPl unplT
for D in $DIRS; do
  n=$(basename $D | sed 's/.*_\(u[0-9]*_m[0-9]*.*\)$/\1/')
  def=$D/outputs/$TOPN.def
  if [ ! -f $def ]; then printf "%-14s  (no outputs: run failed or still running)\n" $n; continue; fi
  unit=$(grep -m1 "UNITS DISTANCE MICRONS" $def | awk '{print $4}')
  read x1 y1 x2 y2 <<< $(grep -m1 "^DIEAREA" $def | tr -d '()' | awk '{print $2,$3,$4,$5}')
  w=$(awk "BEGIN{printf \"%.1f\", ($x2-$x1)/$unit}"); h=$(awk "BEGIN{printf \"%.1f\", ($y2-$y1)/$unit}")
  dA=$(awk "BEGIN{printf \"%.0f\", $w*$h}")
  cA=$(grep -A3 "Hinst Name" $D/reports/final_area.rpt | tail -1 | awk '{print $NF}')
  cp=$(awk "BEGIN{printf \"%.1f\", 100*$cA/$dA}")
  sw=$(zcat $D/reports/postRoute/postRoute.summary.gz 2>/dev/null | grep -m1 "WNS" | awk -F'|' '{gsub(/ /,"",$3); print $3}')
  hw=$(zcat $D/reports/postRoute/postRoute_hold.summary.gz 2>/dev/null | grep -m1 "WNS" | awk -F'|' '{gsub(/ /,"",$3); print $3}')
  v1=$(zcat $D/reports/postRoute/postRoute.summary.gz 2>/dev/null | grep -m1 "Violating Paths" | awk -F'|' '{gsub(/ /,"",$3); print $3}')
  v2=$(zcat $D/reports/postRoute/postRoute_hold.summary.gz 2>/dev/null | grep -m1 "Violating Paths" | awk -F'|' '{gsub(/ /,"",$3); print $3}')
  fe=$(grep -o "FE_PHC[0-9]*_[A-Za-z0-9_]*" $D/outputs/${TOPN}_pnr.v | sort -u | wc -l)
  drc=$(grep -qi "No DRC violations" $D/$TOPN.final_drc.rpt && echo 0 || echo "X")
  cpl=$(grep -h "Total instances" $D/$TOPN.checkPlace_final.rpt 2>/dev/null | awk '{print $NF}'); cpl=${cpl:-0}
  up=$(grep -m1 "IMPOPT-576" $D/run_sw.log 2>/dev/null | grep -o "[0-9]* nets"); up=${up:-0}
  printf "%-14s %-15s %9s %7s %8s %8s %6s %5s %5s %6s %6s\n" $n "${w}x${h}" $dA $cp "$sw" "$hw" "$v1/$v2" $fe $drc $cpl "$up"
done
echo
echo "== summaryReport (wire length, utilization)"
for D in $DIRS; do
  echo "--- $(basename $D)"
  grep -i "total wire length\|core utilization\|cell utilization\|density" $D/reports/summary.rpt 2>/dev/null | head -4
done
[ "$1" = v4 ] && { echo; echo "== V4 CDC worst slack (p2u / u2p)";
  for D in $DIRS; do echo "$(basename $D): $(grep -m1 'Slack Time' $D/reports/final_cdc_p2u.rpt 2>/dev/null | awk '{print $NF}') / $(grep -m1 'Slack Time' $D/reports/final_cdc_u2p.rpt 2>/dev/null | awk '{print $NF}')"; done; }
true
