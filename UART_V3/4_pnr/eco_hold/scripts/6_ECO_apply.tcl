###############################################################
# 6_ECO_apply.tcl - apply Tempus hold ECO (innovus.eco)
# run in PNR_5NS_PADALL_RO_BF_HOLDOFF :
#   innovus -log log/eco3.log      then   source 6_ECO_apply.tcl
###############################################################
restoreDesign RouteDesign_for_ECO.dat uart_chip_top_allpad
file mkdir reports/timing

# 0. before (same DB, Innovus view)
timeDesign -postRoute -hold -outDir reports/timing/eco_before_hold

# 1. apply ECO (netlist + rough placement of FE_ECOC* buffers)
source innovus.eco
refinePlace
ecoRoute
extractRC

# 2. timing = Tempus ECO only (no optDesign)
timeDesign -postRoute       -outDir reports/timing/eco_setup
timeDesign -postRoute -hold -outDir reports/timing/eco_hold

# 3. physical checks
checkPlace
verify_drc -report reports/uart_eco.drc.rpt -limit 1000
verifyConnectivity -type all -error 1000 -warning 50 -report reports/uart_eco.conn.rpt

# 4. save (before filler)
saveDesign -rc RouteDesign_ECO

puts "**ECO buffers in DB = [llength [dbGet -p top.insts.name FE_ECOC*]]"
