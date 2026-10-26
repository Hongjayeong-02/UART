########################################
# UART V1 Block-level P&R : Placement + preCTS Opt
# Top   : uart_core
# Input : PowerPlan
# Run   : innovus source 2_PlaceOpt.tcl
########################################

# restoreDesign PowerPlan.dat uart_core

## 1. Design mode
setDesignMode -process 45

## 2. Double-height(CoreSiteDouble) 
##    GPDK045: (Retention/LS/ISO/Switch) + BUFX2
##    floorplan 
set dbl_cells {}
foreach c [dbGet head.libCells.name -u] {
    if {[lsearch [dbGet [dbGet head.libCells.name $c -p].site.name] CoreSiteDouble] >= 0} {
        lappend dbl_cells $c
    }
}
foreach c $dbl_cells { setDontUse $c true }
puts "DONT_USE (CoreSiteDouble) : [llength $dbl_cells] cells"
puts "DONT_USE BUFX2 : [dbGet [dbGet head.libCells.name BUFX2 -p].dontUse]"

## 3. Placement
placeDesign

## 4. Tie cell
if {[dbGet head.libCells.name TIEHI] != "0x0" && [dbGet head.libCells.name TIELO] != "0x0"} {
    setTieHiLoMode -cell {TIEHI TIELO} -maxFanout 8
    addTieHiLo
    puts "TIE CELL : inserted"
} else {
    puts "TIE CELL : TIEHI/TIELO not found, skipped"
}

## 5. preCTS optimization (setup)
optDesign -preCTS -outDir reports/preCTS_opt

## 6. Check & report
checkPlace uart_core.checkPlace.rpt
timeDesign -preCTS -outDir reports/preCTS -prefix preCTS
report_area > reports/preCTS_area.rpt

## 7. Save
saveDesign PlaceOpt
