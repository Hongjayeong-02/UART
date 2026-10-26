########################################
# UART V1 Block-level P&R : ChipFinish
# Top   : uart_core
# Input : RouteDesign
# Run   : innovus source 5_ChipFinish.tcl
########################################

# restoreDesign RouteDesign.dat uart_core

file mkdir outputs

## 1. Filler 
addFiller -cell FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER

## 2. Filler
checkPlace uart_core.checkPlace_final.rpt
verify_drc -limit 1000 -report uart_core.final_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_core.final_conn.rpt
timeDesign -postRoute       -outDir reports/final -prefix final
timeDesign -postRoute -hold -outDir reports/final -prefix final
report_area > reports/final_area.rpt

## 3. GDS (SoC : GDS merge¥)
streamOut outputs/uart_core.gds -libName DesignLib -units 2000 -mode ALL

## 4. Post-layout simulation
saveNetlist -flat outputs/uart_core_pnr.v
write_sdf -view FUNC_SS_WORST -recrem split outputs/uart_core_pnr_max.sdf
write_sdf -view FUNC_FF_BEST  outputs/uart_core_pnr_min.sdf

## 5. Parasitic / Physical 
rcOut -spef outputs/uart_core_worst.spef -rc_corner WORST
defOut -floorplan -netlist -routing outputs/uart_core.def

## 6. Save
saveDesign ChipFinish
