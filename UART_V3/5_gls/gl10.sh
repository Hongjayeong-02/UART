#!/bin/bash
# 10 ns 최종 netlist(PNR_10NS_V3_H5) gate-level regression : SS(max) / FF(min) SDF, TB clock 100 MHz (at-speed) + 48 MHz(기존)
#   bash ~/packgl10/gl10.sh prep   : SIM/GL_10NS 폴더, SDF cmd 4개, 100 MHz TB, 실행 명령 확인 (실행 안 함)
#   bash ~/packgl10/gl10.sh run    : 4개 실행 (max/min × 100/48 MHz) + PASS/FAIL 비교
T=~/PROJ1/proj1_make/TOP
G=$T/SIM/GL_10NS; OLD=$T/SIM/GL_RSYNC; N=$T/PNR_10NS_V3_H5/outputs
TB=$T/SIM/TESTBENCH/UART_V3/tb_uart_v3_final_gl.v
if [ "$1" = prep ]; then
  [ -f $N/uart_apb_pnr.v ] && [ -f $N/uart_apb_pnr_max.sdf ] && [ -f $N/uart_apb_pnr_min.sdf ] || { echo "ERROR: $N 에 netlist/SDF 없음"; ls $N; exit 1; }
  [ -f $TB ] || { echo "ERROR: $TB 없음"; exit 1; }
  mkdir -p $G
  for m in max min; do
    M=MAXIMUM; [ $m = min ] && M=MINIMUM
    for f in 100 48; do
      top=tb_uart_v3_final_gl
      printf 'SDF_FILE = "%s/uart_apb_pnr_%s.sdf",\nSCOPE = %s.uut,\nLOG_FILE = "sdf_g10_%s_%s.log",\nMTM_CONTROL = "%s",\nSCALE_TYPE = "FROM_%s";\n' $N $m $top $m $f $M $M > $G/g10_${m}_${f}.cmd
    done
  done
  cp $TB $G/tb_gl_48m.v
  sed 's/^always #10.41667 clk = ~clk;/always #5.0 clk = ~clk;   \/\/ 100 MHz (10 ns) at-speed/' $TB > $G/tb_gl_100m.v
  echo "== clock 줄"; grep -n '^always #' $G/tb_gl_48m.v $G/tb_gl_100m.v
  H=$OLD/glq_max.history
  [ -f $H ] || { echo "ERROR: $H 없음 → 1 GHz GL 때 쓴 xrun 명령을 알려줘"; exit 1; }
  CMD=$(grep 'glq_max.cmd' $H | tail -1)
  [ -n "$CMD" ] || CMD=$(grep 'gl_max.cmd' $H | tail -1)
  [ -n "$CMD" ] || { echo "ERROR: history 에 glq_max/gl_max 명령 없음"; tail -5 $H; exit 1; }
  echo "$CMD" > $G/base_cmd.txt
  echo "== 1 GHz GL 명령 (기준)"; cat $G/base_cmd.txt
  echo "== RTL 기준 결과: $(ls $OLD/rtl_pf.txt)"
  exit 0
fi
if [ "$1" = run ]; then
  cd $G || exit 1
  BASE=$(cat base_cmd.txt)
  for m in max min; do for f in 100 48; do
    C=$(echo "$BASE" | sed -e "s#-sdf_cmd_file [^ ]*#-sdf_cmd_file g10_${m}_${f}.cmd#" \
          -e "s#[^ ]*PNR_1GHZ_RSYNC_QRC/outputs/uart_apb_pnr.v#$N/uart_apb_pnr.v#" \
          -e "s#[^ ]*tb_uart_v3_final_gl.v#tb_gl_${f}m.v#" \
          -e "s#-l [^ ]*#-l g10_${m}_${f}.log#")
    echo "== RUN $m ${f}MHz : $C"
    eval "$C" > /dev/null 2>&1
    grep 'PASS\|FAIL' g10_${m}_${f}.log | grep -v '^xrun' > g10_${m}_${f}_pf.txt
    echo "   PASS $(grep -c '^PASS:' g10_${m}_${f}_pf.txt) / FAIL $(grep -c '^FAIL' g10_${m}_${f}_pf.txt)"
    diff -q $OLD/rtl_pf.txt g10_${m}_${f}_pf.txt > /dev/null && echo "   = RTL 결과와 동일" || echo "   !! RTL 결과와 다름 (diff $OLD/rtl_pf.txt $G/g10_${m}_${f}_pf.txt)"
    { echo "== g10_${m}_${f}.log : SDF annotation / timing check summary";
      grep 'Annotation completed' g10_${m}_${f}.log;
      grep 'SDFNET\|SDFNDP' g10_${m}_${f}.log | cut -c1-90 | sort | uniq -c;
      echo "Timing violation lines: $(grep -c 'Timing violation' g10_${m}_${f}.log)";
      echo "Glitch suppression lines: $(grep -c 'Glitch suppression' g10_${m}_${f}.log)"; } > g10_${m}_${f}_sdf_summary.txt
    grep 'Annotation completed\|Timing violation lines' g10_${m}_${f}_sdf_summary.txt | sed 's/^/   /'
  done; done
  exit 0
fi
echo "usage: bash gl10.sh prep | run"
