########################################
# UART V3 chip-level (ALL PAD) P&R : CTS + postCTS Opt
# Top   : uart_chip_top_allpad (clock : clk, 1 MHz)
# Input : PlaceOpt
# Run   : innovus source 3_PostCTSopt.tcl
########################################

# restoreDesign PlaceOpt.dat uart_chip_top_allpad

## 0. Double-height
set dbl_cells {}
foreach c [dbGet head.libCells.name -u] {
    if {[lsearch [dbGet [dbGet head.libCells.name $c -p].site.name] CoreSiteDouble] >= 0} {
        lappend dbl_cells $c
    }
}
foreach c $dbl_cells { setDontUse $c true }
puts "DONT_USE (CoreSiteDouble) : [llength $dbl_cells] cells"

## 1. Analysis mode : OCV + CPPR 
setAnalysisMode -analysisType onChipVariation -cppr both

## 2. CTS cell
set_ccopt_property buffer_cells   [dbGet head.libCells.name CLKBUF* -u]
set_ccopt_property inverter_cells [dbGet head.libCells.name CLKINV* -u]

## 3. Clock tree spec CTS
create_ccopt_clock_tree_spec -file uart_chip_top_allpad.ccopt.spec
ccopt_design

## 4. postCTS optimization : setup → hold
optDesign -postCTS       -outDir reports/postCTS_opt
setOptMode -holdTargetSlack 0.02
optDesign -postCTS -hold -outDir reports/postCTS_hold_opt

## 5. Check & report
checkPlace uart_chip_top_allpad.checkPlace_postCTS.rpt
report_ccopt_clock_trees -file reports/postCTS_clock_trees.rpt
report_ccopt_skew_groups -file reports/postCTS_skew_groups.rpt
timeDesign -postCTS       -outDir reports/postCTS -prefix postCTS
timeDesign -postCTS -hold -outDir reports/postCTS -prefix postCTS_hold

## 6. Save
saveDesign PostCTSopt
