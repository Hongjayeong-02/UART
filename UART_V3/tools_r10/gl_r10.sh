#!/bin/bash
# ⑩ 1 GHz P&R netlist gate-level regression (⑨ QRC 와 같은 조건: TB clock 48 MHz, SS(max) / FF(min) SDF)
#   bash ~/r10pkg/gl_r10.sh r10e
# 기준 xrun 명령은 ⑨ QRC GL 실행 기록(SIM/GL_RSYNC/glq_max.history)에서 가져와 netlist / SDF / log 만 바꾼다.
T=~/PROJ1/proj1_make/TOP
V=${1:?variant (예: r10e)}
VU=$(echo $V | tr a-z A-Z)
N=$T/PNR/PNR_1GHZ_${VU}_QRC/outputs
OLD=$T/SIM/GL_RSYNC
G=$T/SIM/GL_$VU
stop() { echo "STOP: $*"; exit 1; }

for f in uart_apb_pnr.v uart_apb_pnr_max.sdf uart_apb_pnr_min.sdf; do
  [ -s $N/$f ] || { ls $N; stop "$N/$f 없음"; }
done
H=$OLD/glq_max.history
[ -f $H ] || stop "$H 없음 (⑨ QRC GL 기록)"
BASE=$(grep 'glq_max.cmd' $H | tail -1 | sed 's/^.*\(xrun .*\)$/\1/')   # history 앞의 's1(날짜):' 제거
[ -n "$BASE" ] || { tail -5 $H; stop "history 에 glq_max 명령 없음"; }
case "$BASE" in xrun\ *) ;; *) stop "기준 명령이 xrun 으로 시작하지 않음: $BASE" ;; esac
[ -f $OLD/rtl_pf.txt ] || stop "$OLD/rtl_pf.txt (RTL PASS/FAIL 기준) 없음"

rm -rf $G && mkdir -p $G && cd $G
echo "== 기준 명령 (⑨ QRC)"; echo "$BASE"

for m in max min; do
  M=MAXIMUM; [ $m = min ] && M=MINIMUM
  printf 'SDF_FILE = "%s/uart_apb_pnr_%s.sdf",\nSCOPE = tb_uart_v3_final_gl.uut,\nLOG_FILE = "sdf_gl_%s.log",\nMTM_CONTROL = "%s",\nSCALE_TYPE = "FROM_%s";\n' $N $m $m $M $M > gl_${m}.cmd
  C=$(echo "$BASE" | sed -e "s#-sdf_cmd_file [^ ]*#-sdf_cmd_file gl_${m}.cmd#" \
        -e "s#[^ ]*PNR_1GHZ_RSYNC_QRC/outputs/uart_apb_pnr.v#$N/uart_apb_pnr.v#" \
        -e "s#-l [^ ]*#-l gl_${m}.log#")
  echo "$C" | grep -q "PNR_1GHZ_${VU}_QRC/outputs/uart_apb_pnr.v" || stop "netlist 경로 치환 실패: $C"
  echo; echo "== RUN $m : $C"
  eval "$C" > /dev/null 2>&1
  [ -f gl_${m}.log ] || stop "gl_${m}.log 없음"
  grep 'PASS\|FAIL' gl_${m}.log | grep -v '^xrun' > gl_${m}_pf.txt
  echo "   PASS $(grep -c '^PASS:' gl_${m}_pf.txt) / FAIL $(grep -c '^FAIL' gl_${m}_pf.txt) / *E $(grep -c '\*E,' gl_${m}.log)"
  diff -q $OLD/rtl_pf.txt gl_${m}_pf.txt > /dev/null && echo "   = RTL 결과와 동일" || echo "   !! RTL 결과와 다름: diff $OLD/rtl_pf.txt $G/gl_${m}_pf.txt"
  echo "   $(grep 'Annotation completed' gl_${m}.log | head -1 | sed 's/^ *//')"
  echo "   SDF 경고: $(grep -o '\*W,SDF[A-Z]*' gl_${m}.log | sort | uniq -c | tr '\n' ' ')"
  echo "   Timing violation 줄: $(grep -c 'Timing violation' gl_${m}.log)"
done
echo
echo "== ⑨ QRC 결과와 비교용: ls $OLD/glq_*_pf.txt ; grep -c 'Timing violation' $OLD/glq_*.log"
