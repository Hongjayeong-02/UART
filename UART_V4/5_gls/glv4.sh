#!/bin/bash
# UART V4 post-layout GLS (block uart_v4_apb, P&R u80_m10 기준)
#   bash ~/glv4.sh prep   : 파일 확인, SDF cmd 생성, RTL 을 -define GLS 로 한 번 돌려 guard 확인
#   bash ~/glv4.sh run    : SS(max)/FF(min) SDF x 2 clock 비율 = 4 run + 요약
# TB : tb/tb_uart_v4_apb_cdc.v (GLS 에서는 내부 신호 검사 10개 제외 -> 26 checks)
# -nonotifier : timing violation 은 보고하되 X 로 만들지 않음. 위반은 instance 로 분류해서
#               synchronizer 1단(비동기 샘플링이 정상)인지, 그 외(진짜 문제)인지 구분
V=~/UART_V4; N=$V/pnr/outputs; G=$V/gls; TB=$V/tb/tb_uart_v4_apb_cdc.v
STD=<PDK>/std/stdlib/verilog
NET=$N/uart_v4_apb_pnr.v
RTL="rtl/uart_async_fifo.v rtl/uart_v4_cfg_cdc.v rtl/uart_v4_baud_gen.v rtl_v3/uart_tx.v rtl/uart_v4_rx.v
rtl/uart_v4_core.v rtl/uart_v4_sync_level.v rtl/uart_v4_event_sync.v rtl/uart_v4_rst_sync.v rtl_v3/uart_irq.v rtl/uart_v4_apb.v"
#        name    PHALF   UHALF      (UHALF 10.4165 = UART_CLK 48 MHz, SDC 값)
RATIOS="spec:5.0:10.4165 slowp:37.0:10.4165"
mkdir -p $G

if [ "$1" = prep ]; then
  for f in $NET $N/uart_v4_apb_pnr_max.sdf $N/uart_v4_apb_pnr_min.sdf $TB $STD/std_ss.v; do
    [ -f $f ] && echo "ok   $f" || { echo "MISSING $f"; exit 1; }
  done
  [ -f $STD/std_ff.v ] && echo "fast cell model 있음 (min 에 사용)" || echo "fast model 없음 -> min 도 slow model"
  grep -q '`ifndef GLS' $TB || { echo "ERROR: TB 에 GLS guard 없음 (add_gls_guard.py 먼저)"; exit 1; }
  echo "== P&R netlist : $(grep -c '^module' $NET) module, hold buffer $(grep -o 'FE_PHC[0-9]*_[A-Za-z0-9_]*' $NET | sort -u | wc -l)"
  for m in max min; do
    M=$([ $m = max ] && echo MAXIMUM || echo MINIMUM)
    printf 'SDF_FILE = "%s/uart_v4_apb_pnr_%s.sdf",\nSCOPE = tb_uart_v4_apb_cdc.uut,\nLOG_FILE = "%s/sdf_%s.log",\nMTM_CONTROL = "%s",\nSCALE_TYPE = "FROM_%s";\n' \
      $N $m $G $m $M $M > $G/sdf_$m.cmd
  done
  ls $G/*.cmd
  echo "== RTL + -define GLS (guard 확인, 26 PASS 기대)"
  (cd $V && xrun -64bit -clean -timescale 1ns/1ps -define GLS $RTL $TB -top tb_uart_v4_apb_cdc -l $G/rtl_gls.log > /dev/null 2>&1)
  echo "   PASS $(grep -c '^PASS' $G/rtl_gls.log) / FAIL $(grep -c '^FAIL' $G/rtl_gls.log) : $(grep 'APB_CDC' $G/rtl_gls.log | tail -1)"
  exit 0
fi

[ "$1" = run ] || { echo "usage: bash glv4.sh prep|run"; exit 1; }
cd $G
for m in max min; do
  if [ $m = max ]; then CELL=$STD/std_ss.v
  else CELL=$STD/std_ff.v; [ -f $CELL ] || CELL=$STD/std_ss.v; fi
  for r in $RATIOS; do
    IFS=: read nm ph uh <<< "$r"
    L=gl_${m}_${nm}
    echo "== RUN $L  (PHALF=$ph UHALF=$uh)"
    xrun -64bit -clean -access +r -neg_tchk -nonotifier -sdf_verbose -timescale 1ns/1ps -define GLS \
         -sdf_cmd_file sdf_$m.cmd $CELL $NET $TB -top tb_uart_v4_apb_cdc +PHALF=$ph +UHALF=$uh -l $L.log > /dev/null 2>&1
    p=$(grep -c '^PASS' $L.log); f=$(grep -c '^FAIL' $L.log)
    echo "   PASS $p / FAIL $f : $(grep 'APB_CDC' $L.log | tail -1)"
    echo "   $(grep 'Annotation completed' $L.log | head -1 | sed 's/^ *//')   SDFINF $(grep -c 'SDFINF' $L.log)"
    echo "   xrun errors (*E,) $(grep -c '\*E,' $L.log)"
    # timing violation 위치 분류
    grep -A4 "Timing violation" $L.log | grep -o "Scope: [^ ;]*" | sed 's/Scope: //' > ${L}_viol_scope.txt
    t=$(wc -l < ${L}_viol_scope.txt)
    s=$(grep -c -E "Sync1|rxMeta|rstSync|r_sync" ${L}_viol_scope.txt)
    echo "   timing violations $t  (synchronizer 1st stage $s, other $((t - s)))   [raw 'Timing violation' lines: $(grep -c 'Timing violation' $L.log)]"
    [ $((t - s)) -gt 0 ] && { echo "   -- other (first 5):"; grep -v -E "Sync1|rxMeta|rstSync|r_sync" ${L}_viol_scope.txt | sort | uniq -c | sort -rn | head -5 | sed 's/^/      /'; }
  done
done
echo "== done"
