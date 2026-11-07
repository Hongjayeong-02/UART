#!/bin/bash
# UART V3 padall_read_opt : chip-level (PAD 포함) post-layout GLS
#   netlist/SDF : PNR_10NS_PADALL_RO/outputs (LEF v2 + respace + read_opt RTL)
#   TB          : tb_uart_v3_final_gl.v (33 checks, 내부 신호 참조 없음), DUT 만 uart_chip_top_allpad 로 교체
#   조합        : SS(max) / FF(min) SDF  x  TB clock 100 MHz(at-speed) / 48 MHz(기존 TB)
#   bash ~/glro.sh prep  : ~/ro_gls 폴더, SDF cmd 4개, TB 2개 생성 + 확인 (실행 안 함)
#   bash ~/glro.sh run   : 4개 실행 + RTL 결과(rsync_pf.txt)와 비교 + SDF annotation 요약
T=~/PROJ1/proj1_make/TOP
N=$T/PNR/PNR_10NS_PADALL_RO/outputs
G=~/ro_gls
R=~/UART_repo/UART_V3
TB=$R/2_tb/tb_uart_v3_final_gl.v
REF=$R/6_verify/regression/rsync_pf.txt
NET=$N/uart_chip_top_allpad_pnr_hier.v
STD=<PDK>/std/stdlib/verilog
PAD=<PDK>/io/vlog
TOP=tb_uart_v3_final_gl

if [ "$1" = prep ]; then
  for f in $NET $N/uart_chip_top_allpad_pnr_max.sdf $N/uart_chip_top_allpad_pnr_min.sdf $TB $REF \
           $STD/std_ss.v $PAD/io_ss.v $PAD/io_ff.v; do
    [ -f $f ] || { echo "ERROR: 없음 $f"; exit 1; }
  done
  [ -f $STD/std_ff.v ] && echo "fast cell model 있음 (min 에 사용)" || echo "fast cell model 없음 -> min 도 slow model (지연은 SDF 가 덮어씀)"
  mkdir -p $G
  for m in max min; do
    M=MAXIMUM; [ $m = min ] && M=MINIMUM
    for f in 100 48; do
      printf 'SDF_FILE = "%s/uart_chip_top_allpad_pnr_%s.sdf",\nSCOPE = %s.uut,\nLOG_FILE = "sdf_ro_%s_%s.log",\nMTM_CONTROL = "%s",\nSCALE_TYPE = "FROM_%s";\n' \
        $N $m $TOP $m $f $M $M > $G/ro_${m}_${f}.cmd
    done
  done
  sed 's/^uart_apb uut (/uart_chip_top_allpad uut (/' $TB > $G/tb_ro_48m.v
  sed 's/^always #10.41667 clk = ~clk;/always #5.0 clk = ~clk;   \/\/ 100 MHz (10 ns) at-speed/' $G/tb_ro_48m.v > $G/tb_ro_100m.v
  echo "== DUT 줄 (uart_chip_top_allpad 이어야 함)"; grep -n ' uut (' $G/tb_ro_48m.v
  echo "== clock 줄";  grep -n '^always #' $G/tb_ro_48m.v $G/tb_ro_100m.v
  echo "== SDF cmd";   ls $G/*.cmd
  echo "== netlist top module"; grep -n '^module uart_chip_top_allpad' $NET
  exit 0
fi

if [ "$1" = run ]; then
  cd $G || { echo "ERROR: 먼저 bash ~/glro.sh prep"; exit 1; }
  for m in max min; do
    if [ $m = max ]; then CELL=$STD/std_ss.v; PADV=$PAD/io_ss.v
    else CELL=$STD/std_ff.v; [ -f $CELL ] || CELL=$STD/std_ss.v; PADV=$PAD/io_ff.v; fi
    for f in 100 48; do
      L=ro_${m}_${f}
      echo "== RUN $m ${f}MHz"
      xrun -64bit -clean -access +r -neg_tchk -sdf_verbose -timescale 1ns/1ps \
           -sdf_cmd_file $L.cmd -define NO_DUMP -top $TOP \
           tb_ro_${f}m.v $NET $CELL $PADV -l $L.log > /dev/null 2>&1
      grep 'PASS\|FAIL' $L.log | grep -v '^xrun\|^xmsim\|^xmelab' > ${L}_pf.txt
      echo "   PASS $(grep -c '^PASS:' ${L}_pf.txt) / FAIL $(grep -c '^FAIL' ${L}_pf.txt)"
      diff -q $REF ${L}_pf.txt > /dev/null && echo "   = RTL 결과와 동일" || echo "   !! RTL 결과와 다름 : diff $REF $G/${L}_pf.txt"
      { echo "== $L.log : SDF annotation / timing check summary"
        grep 'Annotation completed' $L.log
        grep 'SDFNET\|SDFNDP\|SDFNEP\|SDFNL' $L.log | cut -c1-90 | sort | uniq -c
        echo "Timing violation lines: $(grep -c 'Timing violation' $L.log)"
        echo "Glitch suppression lines: $(grep -c 'Glitch suppression' $L.log)"
        echo "xmelab/xmsim errors: $(grep -c '\*E,' $L.log)"; } > ${L}_sdf_summary.txt
      grep 'Annotation completed\|Timing violation lines\|errors:' ${L}_sdf_summary.txt | sed 's/^/   /'
    done
  done
  exit 0
fi
echo "usage: bash ~/glro.sh prep | run"
