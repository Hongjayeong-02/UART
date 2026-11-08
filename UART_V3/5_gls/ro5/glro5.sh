#!/bin/bash
# V3 발표용 5 ns PAD top RO + BAUDDIV 수정 : chip-level post-layout GLS
#   netlist/SDF : PNR/PNR_5NS_PADALL_RO_BF/outputs (계층 netlist)
#   TB          : tb_uart_v3_final_gl.v (33 checks), DUT 만 uart_chip_top_allpad 로 교체
#   조합        : SS(max) / FF(min) SDF  x  TB clock 200 MHz(at-speed) / 48 MHz(기존 TB)
#   10 ns RO GLS(~/tools/glro.sh)와 같은 xrun 옵션, 셀/PAD 모델 경로도 그 스크립트에서 가져온다.
#   timing check 제외: RX 2-flop synchronizer 첫 단(r_rxMeta) 하나만 (-tfile).
#     i_uartRx 는 비동기 입력이라 SDC에서도 false path. 첫 단은 metastability를 받는 자리이고
#     셀 모델 notifier가 X를 만들어 퍼뜨리므로 제외한다. 다른 플롭의 timing check는 그대로.
#   bash ~/ro5pkg/glro5.sh
T=~/PROJ1/proj1_make/TOP
N=$T/PNR/PNR_5NS_PADALL_RO_BF/outputs
G=~/uart_work/ro5_gls
R=~/UART_repo/UART_V3
TB=$R/2_tb/tb_uart_v3_final_gl.v
REF=$R/6_verify/regression/rsync_pf.txt
NET=$N/uart_chip_top_allpad_pnr_hier.v
OLD=~/tools/glro.sh
TOPM=tb_uart_v3_final_gl
stop() { echo "STOP: $*"; exit 1; }

[ -f $OLD ] || stop "$OLD 없음 (10 ns RO GLS 스크립트)"
STD=$(grep '^STD=' $OLD | cut -d= -f2)
PAD=$(grep '^PAD=' $OLD | cut -d= -f2)
SSV=$(grep -o 'CELL=\$STD/[A-Za-z0-9_]*\.v' $OLD | head -1 | sed "s#CELL=\$STD#$STD#")
FFV=$(grep -o 'CELL=\$STD/[A-Za-z0-9_]*\.v' $OLD | sed -n 2p | sed "s#CELL=\$STD#$STD#")
SSP=$(grep -o 'PADV=\$PAD/[A-Za-z0-9_]*\.v' $OLD | head -1 | sed "s#PADV=\$PAD#$PAD#")
FFP=$(grep -o 'PADV=\$PAD/[A-Za-z0-9_]*\.v' $OLD | sed -n 2p | sed "s#PADV=\$PAD#$PAD#")
[ -f "$FFV" ] || FFV=$SSV
for f in $NET $N/uart_chip_top_allpad_pnr_max.sdf $N/uart_chip_top_allpad_pnr_min.sdf $TB $REF $SSV $SSP $FFP; do
  [ -f "$f" ] || stop "없음: $f"
done

rm -rf $G && mkdir -p $G && cd $G
for m in max min; do
  M=MAXIMUM; [ $m = min ] && M=MINIMUM
  for f in 200 48; do
    printf 'SDF_FILE = "%s/uart_chip_top_allpad_pnr_%s.sdf",\nSCOPE = %s.uut,\nLOG_FILE = "sdf_ro5_%s_%s.log",\nMTM_CONTROL = "%s",\nSCALE_TYPE = "FROM_%s";\n' \
      $N $m $TOPM $m $f $M $M > ro5_${m}_${f}.cmd
  done
done
sed 's/^uart_apb uut (/uart_chip_top_allpad uut (/' $TB > tb_ro_48m.v
sed 's/^always #10.41667 clk = ~clk;/always #2.5 clk = ~clk;   \/\/ 200 MHz (5 ns) at-speed/' tb_ro_48m.v > tb_ro_200m.v
grep -q '^uart_chip_top_allpad uut (' tb_ro_48m.v || stop "DUT 교체 실패"
grep -q '^always #2.5 clk' tb_ro_200m.v || stop "200 MHz clock 교체 실패"
echo "== clock 줄"; grep -n '^always #' tb_ro_48m.v tb_ro_200m.v
SYNC1=$(grep -o 'uut_uart_core_uut_rx_fifo_uut_rx_r_rxMeta_reg' $NET | head -1)
[ -n "$SYNC1" ] || stop "netlist 에 r_rxMeta_reg 없음"
echo "PATH $TOPM.uut.u_uart_apb.$SYNC1 -tcheck" > sync1.tfile
echo "== tfile (timing check 제외 대상)"; cat sync1.tfile

for m in max min; do
  if [ $m = max ]; then CELL=$SSV; PADV=$SSP; else CELL=$FFV; PADV=$FFP; fi
  for f in 200 48; do
    L=ro5_${m}_${f}
    xrun -64bit -clean -access +r -neg_tchk -sdf_verbose -timescale 1ns/1ps \
         -sdf_cmd_file $L.cmd -tfile sync1.tfile -define NO_DUMP -top $TOPM \
         tb_ro_${f}m.v $NET $CELL $PADV -l $L.log > /dev/null 2>&1
    [ -f $L.log ] || stop "$L.log 없음"
    grep 'PASS\|FAIL' $L.log | grep -v '^xrun\|^xmsim\|^xmelab' > ${L}_pf.txt
    same=$(diff -q $REF ${L}_pf.txt > /dev/null && echo "RTL과 동일" || echo "!! RTL과 다름")
    echo "== $m ${f}MHz : PASS $(grep -c '^PASS:' ${L}_pf.txt) / FAIL $(grep -c '^FAIL' ${L}_pf.txt) / *E $(grep -c '\*E,' $L.log) | $same"
    echo "   $(grep 'Annotation completed' $L.log | head -1 | sed 's/^ *//')"
    echo "   tfile 적용: $(grep -c 'sync1.tfile' $L.log) 줄 | SDF 경고: $(grep -o '\*W,SDF[A-Z]*' $L.log | sort | uniq -c | tr '\n' ' ') | Timing violation $(grep -c 'Timing violation' $L.log) | Glitch $(grep -c 'Glitch suppression' $L.log)"
  done
done
echo
echo "== 10 ns RO 비교용: ls ~/uart_work/ro_gls/*_pf.txt ; grep -c 'Timing violation' ~/uart_work/ro_gls/ro_*.log"
