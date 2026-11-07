########################################
# Placement + preCTS Opt : uart_v4_apb
########################################

# restoreDesign PowerPlan.dat uart_v4_apb

setDesignMode -process 45

## Dont Use : CoreSiteDouble cells (floorplan row is CoreSite only)
foreach c [dbGet [dbGet head.libCells.site.name CoreSiteDouble -p2].name] {
    setDontUse $c true
}

## Placement
placeDesign

## Tie Cell
setTieHiLoMode -cell {TIEHI TIELO} -maxFanout 8
addTieHiLo

## preCTS Opt
optDesign -preCTS -outDir reports/preCTS_opt

## Verify
checkPlace uart_v4_apb.checkPlace.rpt
timeDesign -preCTS -outDir reports/preCTS -prefix preCTS
report_area > reports/preCTS_area.rpt

## Save Design
saveDesign PlaceOpt
