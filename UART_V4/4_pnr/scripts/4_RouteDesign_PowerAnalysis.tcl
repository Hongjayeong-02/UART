########################################
# Route + postRoute Opt + Power : uart_v4_apb
########################################

# restoreDesign PostCTSopt.dat uart_v4_apb

## Routing
setNanoRouteMode -routeWithTimingDriven true -routeWithSiDriven true
routeDesign

## postRoute Opt : setup -> hold
setExtractRCMode -engine postRoute
optDesign -postRoute       -outDir reports/postRoute_opt
optDesign -postRoute -hold -outDir reports/postRoute_hold_opt

## Verify
verify_drc -limit 1000 -report uart_v4_apb.route_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_v4_apb.route_conn.rpt
timeDesign -postRoute       -outDir reports/postRoute -prefix postRoute
timeDesign -postRoute -hold -outDir reports/postRoute -prefix postRoute

## Power Analysis (static, default activity)
set_power_analysis_mode -method static -analysis_view FUNC_SS_WORST
report_power -outfile reports/postRoute_power.rpt

## Save Design
saveDesign RouteDesign
