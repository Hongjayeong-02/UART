########################################
# 8_DRV_fix_ECO.tcl : max_transition fix after hold ECO (uart_chip_top_allpad)
# start : ChipFinish_after_ECO.dat (280 x CLKBUFX2 from Tempus)
# issue : 7 nets max_tran violation (worst -0.563 ns, limit 0.280 ns)
#         -> buffers sit next to i_pwdata PADs and drive ~1 mm wire to r_baudDiv_reg[9..15]/SI
# fix   : add one CLKBUFX4 at the midpoint of each long wire (FE_ECOT1..7),
#         FE_ECOT1 (baudDiv[10]) upsized to CLKBUFX6
# innovus -log log/eco2.log   ->   source 8_DRV_fix_ECO.tcl
########################################
restoreDesign ChipFinish_after_ECO.dat uart_chip_top_allpad

## filler out (cells move/insert)
deleteFiller -prefix FILLER

## Step 1 (tried, not kept as final): upsize the 7 buffers CLKBUFX2 -> CLKBUFX4
##   max_tran -0.563 -> -0.173 (still 7 nets), hold WNS -0.005 (baudDiv[10]/SI)
##   -> wire length is the cause, not drive strength. Step 1 result stays in the DB.
set ecoBufs {FE_ECOC127_w_pwdata_10 FE_ECOC181_w_pwdata_13 FE_ECOC154_w_pwdata_11 FE_ECOC167_w_pwdata_12 FE_ECOC168_w_pwdata_14 FE_ECOC131_w_pwdata_9 FE_ECOC147_w_pwdata_15}
foreach i $ecoBufs { ecoChangeCell -inst $i -cell CLKBUFX4 }

## Step 2: split each long wire with a repeater at the midpoint (buffer <-> flop)
set k 0
foreach {b f} {FE_ECOC127_w_pwdata_10 {u_uart_apb/r_baudDiv_reg[10]} FE_ECOC181_w_pwdata_13 {u_uart_apb/r_baudDiv_reg[13]} FE_ECOC154_w_pwdata_11 {u_uart_apb/r_baudDiv_reg[11]} FE_ECOC167_w_pwdata_12 {u_uart_apb/r_baudDiv_reg[12]} FE_ECOC168_w_pwdata_14 {u_uart_apb/r_baudDiv_reg[14]} FE_ECOC131_w_pwdata_9 {u_uart_apb/r_baudDiv_reg[9]} FE_ECOC147_w_pwdata_15 {u_uart_apb/r_baudDiv_reg[15]}} {
    set bp [lindex [dbGet [dbGetInstByName $b].pt] 0]
    set fp [lindex [dbGet [dbGetInstByName $f].pt] 0]
    set mx [expr ([lindex $bp 0] + [lindex $fp 0]) / 2.0]
    set my [expr ([lindex $bp 1] + [lindex $fp 1]) / 2.0]
    incr k
    ecoAddRepeater -cell CLKBUFX4 -term "$f/SI" -loc "$mx $my" -name FE_ECOT$k
    puts "$f -> FE_ECOT$k at $mx $my"
}

## Step 3: last net (FE_ECOT1 -> baudDiv[10]/SI, 0.289 / 0.280) -> upsize
ecoChangeCell -inst FE_ECOT1 -cell CLKBUFX6

refinePlace
ecoRoute
addFiller -cell {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1} -prefix FILLER

## Verify
file mkdir reports/final_eco4
timeDesign -postRoute       -outDir reports/final_eco4 -prefix eco4
timeDesign -postRoute -hold -outDir reports/final_eco4 -prefix eco4
report_constraint -drv_violation_type max_transition  -all_violators
report_constraint -drv_violation_type max_capacitance -all_violators
checkPlace uart_chip_top_allpad.checkPlace_eco4.rpt
verify_drc -limit 1000 -report uart_chip_top_allpad.eco4_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_chip_top_allpad.eco4_conn.rpt
report_area > reports/final_eco4_area.rpt
saveDesign ChipFinish_after_ECO4

## Output
file mkdir outputs_eco4
streamOut outputs_eco4/uart_chip_top_allpad.gds -libName DesignLib -units 2000 -mode ALL
saveNetlist -flat outputs_eco4/uart_chip_top_allpad_pnr.v
write_sdf -view FUNC_SS_WORST -recrem split outputs_eco4/uart_chip_top_allpad_pnr_max.sdf
write_sdf -view FUNC_FF_BEST  -recrem split outputs_eco4/uart_chip_top_allpad_pnr_min.sdf
rcOut -spef outputs_eco4/uart_chip_top_allpad_worst.spef -rc_corner WORST
defOut -floorplan -netlist -routing outputs_eco4/uart_chip_top_allpad.def
