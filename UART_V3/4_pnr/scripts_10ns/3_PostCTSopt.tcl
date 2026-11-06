########################################
# CTS + postCTS Opt : uart_apb (100 MHz)
########################################

# restoreDesign PlaceOpt.dat uart_apb

## Analysis Mode : OCV + CPPR
setAnalysisMode -analysisType onChipVariation -cppr both

## CTS
set_ccopt_property buffer_cells   [dbGet head.libCells.name CLKBUF* -u]
set_ccopt_property inverter_cells [dbGet head.libCells.name CLKINV* -u]
create_ccopt_clock_tree_spec -file uart_apb.ccopt.spec
ccopt_design

## postCTS Opt : setup -> hold
optDesign -postCTS       -outDir reports/postCTS_opt
setOptMode -holdTargetSlack 0.005
optDesign -postCTS -hold -outDir reports/postCTS_hold_opt

## Verify
checkPlace uart_apb.checkPlace_postCTS.rpt
report_ccopt_clock_trees -file reports/postCTS_clock_trees.rpt
report_ccopt_skew_groups -file reports/postCTS_skew_groups.rpt
timeDesign -postCTS       -outDir reports/postCTS -prefix postCTS
timeDesign -postCTS -hold -outDir reports/postCTS -prefix postCTS

## Save Design
saveDesign PostCTSopt
