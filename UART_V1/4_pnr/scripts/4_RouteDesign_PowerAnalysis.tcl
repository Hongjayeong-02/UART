########################################
# UART V3 Block-level P&R : Route + postRoute Opt + Power
# Top   : uart_core
# Input : PostCTSopt
# Run   : innovus source 4_RouteDesign_PowerAnalysis.tcl
########################################

# restoreDesign PostCTSopt.dat uart_core

## 0. Double-height(CoreSiteDouble)
set dbl_cells {}
foreach c [dbGet head.libCells.name -u] {
    if {[lsearch [dbGet [dbGet head.libCells.name $c -p].site.name] CoreSiteDouble] >= 0} {
        lappend dbl_cells $c
    }
}
foreach c $dbl_cells { setDontUse $c true }
puts "DONT_USE (CoreSiteDouble) : [llength $dbl_cells] cells"

## 1. Routing
setNanoRouteMode -routeWithTimingDriven true -routeWithSiDriven true
routeDesign

## 2. postRoute extraction & analysis mode
setExtractRCMode -engine postRoute
setAnalysisMode -analysisType onChipVariation -cppr both

## 3. postRoute optimization : setup → hold
optDesign -postRoute       -outDir reports/postRoute_opt
optDesign -postRoute -hold -outDir reports/postRoute_hold_opt

## 4. Physical verification
verify_drc -limit 1000 -report uart_core.route_drc.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report uart_core.route_conn.rpt

## 5. Timing report
timeDesign -postRoute       -outDir reports/postRoute -prefix postRoute
timeDesign -postRoute -hold -outDir reports/postRoute -prefix postRoute

## 6. Power analysis (static, 기본 switching activity)
set_power_analysis_mode -method static -analysis_view FUNC_SS_WORST
report_power -outfile reports/postRoute_power.rpt

## 7. Save
saveDesign RouteDesign
