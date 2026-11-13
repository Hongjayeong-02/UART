########################################
# 7_ChipFinish_ECO.tcl : ChipFinish_after_ECO (uart_chip_top_allpad)
# = 5_ChipFinish.tcl + restore ECO DB + _eco output names + saveDesign -rc
# innovus -log log/eco4.log   ->   source 7_ChipFinish_ECO.tcl
########################################
restoreDesign RouteDesign_ECO.dat uart_chip_top_allpad

file mkdir outputs
file mkdir reports/final_eco

## Core Filler
addFiller -cell {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1} -prefix FILLER
extractRC

## Verify
checkPlace uart_chip_top_allpad.checkPlace_eco.rpt
verify_drc -limit 1000 -report uart_chip_top_allpad.eco_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_chip_top_allpad.eco_conn.rpt
timeDesign -postRoute       -outDir reports/final_eco -prefix eco
timeDesign -postRoute -hold -outDir reports/final_eco -prefix eco
report_area > reports/final_eco_area.rpt

## Output
streamOut outputs/uart_chip_top_allpad_eco.gds -libName DesignLib -units 2000 -mode ALL
saveNetlist -flat outputs/uart_chip_top_allpad_eco.v
saveNetlist       outputs/uart_chip_top_allpad_eco_hier.v
write_sdf -view FUNC_SS_WORST -recrem split outputs/uart_chip_top_allpad_eco_max.sdf
write_sdf -view FUNC_FF_BEST  -recrem split outputs/uart_chip_top_allpad_eco_min.sdf
rcOut -spef outputs/uart_chip_top_allpad_eco_worst.spef -rc_corner WORST
rcOut -spef outputs/uart_chip_top_allpad_eco_best.spef  -rc_corner BEST
defOut -floorplan -netlist -routing outputs/uart_chip_top_allpad_eco.def

## Save Design (with RC, for Tempus Practice 2)
saveDesign -rc ChipFinish_after_ECO
