#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Synchronizer 1단 -> 2단 직결 확인 (gate-level netlist, tool license 불필요)
#   python script/check_sync_path.py netlist_10ns/uart_v4_apb_netlist.v
# 1단 flop의 Q net 부하(load)가 같은 비트의 2단 flop D pin 하나뿐이면 PASS.
# 사이에 조합 cell이 있거나 다른 곳으로도 fanout되면 FAIL로 표시.
from __future__ import print_function
import re, sys

PAIRS = [  # (1단 이름, 2단 이름)
    ("r_reqSync1",   "r_reqSync2"),
    ("r_ackSync1",   "r_ackSync2"),
    ("r_wGraySync1", "r_wGraySync2"),
    ("r_rGraySync1", "r_rGraySync2"),
    ("r_doneSync1",  "r_doneSync2"),
    ("r_rxMeta",     "r_rxSync"),
]
Q_PINS = ("Q", "QN")
D_PINS = ("D",)

def strip_comments(t):
    t = re.sub(r"/\*.*?\*/", " ", t, flags=re.S)
    return re.sub(r"//[^\n]*", " ", t)

def clean(n):
    n = n.strip()
    if n.startswith("\\"):
        n = n[1:]
    return n.strip()

def parse(path):
    text = strip_comments(open(path).read())
    mods = {}
    for m in re.finditer(r"\bmodule\s+(\S+?)\s*[\(;](.*?)\bendmodule\b", text, re.S):
        name, body = m.group(1), m.group(2)
        insts, nets = {}, {}
        for st in body.split(";"):
            st = st.strip()
            mm = re.match(r"(\\\S+|\w+)\s+(\\\S+\s|\w+)\s*\((.*)\)\s*$", st, re.S)
            if not mm or mm.group(1) in ("input", "output", "inout", "wire", "reg", "assign"):
                continue
            cell, inst = clean(mm.group(1)), clean(mm.group(2))
            pins = {}
            for pm in re.finditer(r"\.(\w+)\s*\(\s*([^()]*?)\s*\)", mm.group(3)):
                net = clean(pm.group(2))
                if net:
                    pins[pm.group(1)] = net
                    nets.setdefault(net, []).append((inst, cell, pm.group(1)))
            insts[inst] = (cell, pins)
        mods[name] = (insts, nets)
    return mods

def bit(n):
    b = re.search(r"\[(\d+)\]\s*$", n)
    return b.group(1) if b else None

def main():
    mods = parse(sys.argv[1])
    total = fail = 0
    for s1, s2 in PAIRS:
        for mname, (insts, nets) in sorted(mods.items()):
            for inst in sorted(i for i in insts if re.search(r"(^|[/_.])" + s1 + r"(_reg)?(\[\d+\])?$", i)):
                cell, pins = insts[inst]
                q = [(p, pins[p]) for p in Q_PINS if p in pins]
                if not q:
                    print("SKIP  %-40s (%s) Q pin 없음" % (inst, cell)); continue
                loads = []
                for p, net in q:
                    loads += [x for x in nets.get(net, []) if x[0] != inst]
                ok = (len(loads) == 1 and loads[0][2] in D_PINS
                      and re.search(s2 + r"(_reg)?(\[\d+\])?$", loads[0][0])
                      and bit(loads[0][0]) == bit(inst))
                total += 1
                if not ok:
                    fail += 1
                desc = ", ".join("%s/%s(%s)" % (l[0], l[2], l[1]) for l in loads) or "부하 없음"
                print("%s  %-40s -> %s   [%s]" % ("PASS" if ok else "FAIL", inst, desc, mname))
    print("== 1단 flop %d개 중 FAIL %d" % (total, fail))

if __name__ == "__main__":
    main()
