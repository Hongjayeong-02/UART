#!/bin/bash
# UART V4 : PSLVERR 레지스터화 후 APB top TB 4개 재실행 + 이전 결과와 비교
#   cd ~/UART_V4 ; bash rerun_apb.sh
# 이전 로그는 log_pre_pslverr/ 에 있어야 함
cd ~/UART_V4 || exit 1
RTL="rtl/uart_async_fifo.v rtl/uart_v4_cfg_cdc.v rtl/uart_v4_baud_gen.v rtl_v3/uart_tx.v rtl/uart_v4_rx.v \
rtl/uart_v4_core.v rtl/uart_v4_sync_level.v rtl/uart_v4_event_sync.v rtl/uart_v4_rst_sync.v rtl_v3/uart_irq.v rtl/uart_v4_apb.v"
X="xrun -64bit -clean -timescale 1ns/1ps"

run() {  # name tb top extra-args
  echo "== RUN $1"
  $X $RTL tb/$2.v -top $2 $3 -l $1.log > /dev/null 2>&1
}
run v3reg_same   tb_uart_v4_apb     ""
run v3reg_sep    tb_uart_v4_apb     "+UHALF=7.3"
run apbcdc       tb_uart_v4_apb_cdc ""
run apbcdc_slowp tb_uart_v4_apb_cdc "+PHALF=37 +UHALF=5.3"

echo
printf "%-14s %6s %6s %6s %6s  %s\n" log PASS FAIL "*E," "*W," "last result line"
for n in v3reg_same v3reg_sep apbcdc apbcdc_slowp; do
  for d in log_pre_pslverr .; do
    f=$d/$n.log
    [ -f $f ] || { echo "$f 없음"; continue; }
    tag=$([ $d = . ] && echo new || echo old)
    p=$(grep -c "PASS" $f); q=$(grep -ci "FAIL" $f)
    e=$(grep -c '\*E,' $f); w=$(grep -c '\*W,' $f)
    last=$(grep -i "all pass\|fail\|pass" $f | tail -1 | cut -c1-60)
    printf "%-14s %6s %6s %6s %6s  %s\n" "$n($tag)" $p $q $e $w "$last"
  done
done

echo
echo "== PASS/FAIL 줄이 이전과 달라진 곳 (비어 있으면 동일)"
for n in v3reg_same v3reg_sep apbcdc apbcdc_slowp; do
  diff <(grep -i "pass\|fail" log_pre_pslverr/$n.log) <(grep -i "pass\|fail" $n.log) > /tmp/d_$n.txt
  [ -s /tmp/d_$n.txt ] && { echo "--- $n"; head -20 /tmp/d_$n.txt; }
done
echo "== done"
