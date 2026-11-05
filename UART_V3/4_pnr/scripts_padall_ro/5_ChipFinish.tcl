########################################
# UART V3 chip-level (ALL PAD) P&R : ChipFinish
# Top   : uart_chip_top_allpad
# Input : RouteDesign
# Run   : innovus source 5_ChipFinish.tcl
########################################

# restoreDesign RouteDesign.dat uart_chip_top_allpad

file mkdir outputs

## 1. Filler 
addFiller -cell FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER

## 2. Filler
checkPlace uart_chip_top_allpad.checkPlace_final.rpt
verify_drc -limit 1000 -report uart_chip_top_allpad.final_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_chip_top_allpad.final_conn.rpt
timeDesign -postRoute       -outDir reports/final -prefix final
timeDesign -postRoute -hold -outDir reports/final -prefix final
report_area > reports/final_area.rpt

## 3. GDS (SoC : GDS merge¥)
streamOut outputs/uart_chip_top_allpad.gds -libName DesignLib -units 2000 -mode ALL

## 4. Post-layout simulation
saveNetlist -flat outputs/uart_chip_top_allpad_pnr.v
write_sdf -view FUNC_SS_WORST -recrem split outputs/uart_chip_top_allpad_pnr_max.sdf
write_sdf -view FUNC_FF_BEST  outputs/uart_chip_top_allpad_pnr_min.sdf

## 5. Parasitic / Physical 
rcOut -spef outputs/uart_chip_top_allpad_worst.spef -rc_corner WORST
defOut -floorplan -netlist -routing outputs/uart_chip_top_allpad.def

## 6. Save
saveDesign ChipFinish
