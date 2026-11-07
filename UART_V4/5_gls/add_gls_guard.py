#!/usr/bin/env python
# -*- coding: utf-8 -*-
# tb_uart_v4_apb_cdc.v : RTL 내부 신호(uut.xxx)를 보는 검사를 `ifndef GLS 로 감쌈
#   cd ~/UART_V4 ; python add_gls_guard.py tb/tb_uart_v4_apb_cdc.v
# RTL 시뮬레이션(GLS 미정의)은 이전과 완전히 같음. 원본은 .pregls
from __future__ import print_function
import sys, shutil, re

path = sys.argv[1]
L = open(path).read().split("\n")
if any("`ifndef GLS" in x for x in L):
    print("ERROR: 이미 GLS guard 가 있음. 파일을 바꾸지 않았습니다."); sys.exit(1)

out, i, n_single, n_block = [], 0, 0, 0
while i < len(L):
    x = L[i]
    if re.match(r"\s*// -+ P10 -+", x):                    # P10 전체 (u_cfg 내부 toggle 사용)
        j = i
        while j < len(L) and "// restore" not in L[j]:
            j += 1
        if j == len(L):
            print("ERROR: P10 끝(// restore)을 못 찾음."); sys.exit(1)
        out += ["`ifndef GLS   // P10 needs u_cfg internal toggles (RTL only)"] + L[i:j+1] + ["`endif"]
        n_block += 1; i = j + 1; continue
    if "uut." in x and re.match(r"\s*check\(", x) and x.rstrip().endswith(";"):
        out += ["`ifndef GLS   // RTL-internal signal"] + [x] + ["`endif"]
        n_single += 1; i += 1; continue
    out.append(x); i += 1

# 감싸지지 않은 uut. 참조가 남았는지 검사
inside, left = 0, []
for k, x in enumerate(out):
    if x.startswith("`ifndef GLS"): inside += 1
    elif x.startswith("`endif") and inside: inside -= 1
    elif "uut." in x and not inside and not x.strip().startswith("//"): left.append(k + 1)
if left:
    print("ERROR: guard 밖에 uut. 참조가 남음 (lines %s). 파일을 바꾸지 않았습니다." % left); sys.exit(1)

shutil.copyfile(path, path + ".pregls")
open(path, "w").write("\n".join(out))
print("== 완료. 한 줄 check %d개 + P10 블록 %d개 guard. 원본: %s.pregls" % (n_single, n_block, path))
