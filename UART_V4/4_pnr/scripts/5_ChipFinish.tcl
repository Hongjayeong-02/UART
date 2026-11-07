########################################
# ChipFinish : uart_v4_apb
########################################

# restoreDesign RouteDesign.dat uart_v4_apb

file mkdir outputs

## Core Filler
addFiller -cell {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1} -prefix FILLER

## Verify
checkPlace uart_v4_apb.checkPlace_final.rpt
verify_drc -limit 1000 -report uart_v4_apb.final_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_v4_apb.final_conn.rpt
timeDesign -postRoute       -outDir reports/final -prefix final
timeDesign -postRoute -hold -outDir reports/final -prefix final
report_area > reports/final_area.rpt

## CDC paths (set_max_delay 10 ns, D23) after route
report_timing -clock_from PCLK -clock_to UART_CLK -max_paths 50 > reports/final_cdc_p2u.rpt
report_timing -clock_from UART_CLK -clock_to PCLK     -max_paths 50 > reports/final_cdc_u2p.rpt

## Output
streamOut outputs/uart_v4_apb.gds -libName DesignLib -units 2000 -mode ALL
saveNetlist -flat outputs/uart_v4_apb_pnr.v
write_sdf -view FUNC_SS_WORST -recrem split outputs/uart_v4_apb_pnr_max.sdf
write_sdf -view FUNC_FF_BEST  -recrem split outputs/uart_v4_apb_pnr_min.sdf
rcOut -spef outputs/uart_v4_apb_worst.spef -rc_corner WORST
defOut -floorplan -netlist -routing outputs/uart_v4_apb.def

## Save Design
summaryReport -noHtml -outfile reports/summary.rpt
saveDesign ChipFinish
