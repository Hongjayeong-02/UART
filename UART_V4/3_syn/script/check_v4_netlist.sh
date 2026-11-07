#!/bin/bash
# Post-synthesis structural checks on the V4 netlist (no tool license needed).
#   bash script/check_v4_netlist.sh            (run from ~/UART_V4/syn)
# Prints the synchronizer flop counts next to the expected numbers, latches,
# and the CDC report summary.

N=netlist_10ns/uart_v4_apb_netlist.v
R=report_10ns
[ -f "$N" ] || { echo "no netlist: $N"; exit 1; }

cnt() { grep -cE "$1" "$N"; }

echo "== 1st-stage synchronizer flops (FIFO_AW=4 -> 5-bit pointers)"
printf "%-34s %6s %8s\n" "register" "found" "expect"
printf "%-34s %6s %8s\n" "r_reqSync1 (cfg 1 + event 3)"      "$(cnt 'r_reqSync1_reg')"      4
printf "%-34s %6s %8s\n" "r_ackSync1 (cfg 1 + event 3)"      "$(cnt 'r_ackSync1_reg')"      4
printf "%-34s %6s %8s\n" "r_wGraySync1 (TX 5 + RX 5)"        "$(cnt 'r_wGraySync1_reg')"   10
printf "%-34s %6s %8s\n" "r_rGraySync1 (TX 5 + RX 5)"        "$(cnt 'r_rGraySync1_reg')"   10
printf "%-34s %6s %8s\n" "r_doneSync1 (TX done counter)"     "$(cnt 'r_doneSync1_reg')"     5
printf "%-34s %6s %8s\n" "r_rxMeta (RX pin)"                 "$(cnt 'r_rxMeta_reg')"        1
printf "%-34s %6s %8s\n" "r_sync (reset sync, 2 x 2)"        "$(cnt 'r_sync_reg')"          4
echo "== 2nd stages"
printf "%-34s %6s %8s\n" "r_reqSync2 / r_ackSync2"           "$(cnt 'r_(req|ack)Sync2_reg')" 8
printf "%-34s %6s %8s\n" "r_wGraySync2 / r_rGraySync2"       "$(cnt 'r_[wr]GraySync2_reg')" 20
printf "%-34s %6s %8s\n" "r_doneSync2"                       "$(cnt 'r_doneSync2_reg')"     5
printf "%-34s %6s %8s\n" "r_rxSync"                          "$(cnt 'r_rxSync_reg')"        1
echo "(a count lower than expected means a synchronizer flop was removed or merged)"
echo
echo "== latches (expect 0)"
grep -ciE "^\s*(TLAT|LATCH|DLH|DLL)[A-Z0-9]*\s" "$N"
echo
echo "== CDC paths: slack summary (set_max_delay 10 ns)"
for f in $R/cdc_p2u.rpt $R/cdc_u2p.rpt; do
        [ -f "$f" ] || continue
        n=$(grep -c "^Path " "$f")
        neg=$(grep -E "Slack|slack" "$f" | grep -c -- "-[0-9]")
        worst=$(grep -E "^\s*Slack:?=?" "$f" | head -1)
        echo "$f : paths=$n negative=$neg   first: $worst"
done
echo
echo "== I2O / PSLVERR"
grep -m3 -E "Slack|Path 1|Startpoint|Endpoint" $R/pslverr.rpt 2>/dev/null
