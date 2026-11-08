########################################
# InitDesign (Setup, Floorplan) : uart_chip_top_allpad
########################################

## Initialization
set PDK_STD <PDK>/std
set init_lef_file  [list $PDK_STD/std_tech/lef/std_tech.lef \
                         $PDK_STD/stdlib/lef/std_macro.lef \
                         iolib_v2.lef]
set init_verilog   ../../SYN/netlist_5ns_padall_ro_bf/uart_chip_top_allpad_netlist.v
set init_mmmc_file uart_chip_top_allpad.mmmc.view
set init_top_cell  uart_chip_top_allpad
set init_pwr_net   {VDD VDDIOR}
set init_gnd_net   {VSS VSSIOR}
init_design

## Check Design
checkDesign -io -netlist -physicalLibrary -powerGround -timingLibrary -floorplan -outdir checkDesign

## Floorplan
floorPlan -site CoreSite -d 1892 1900 30 30 30 30

## IO Placement (after floorPlan)
loadIoFile uart_padall.io

## Global Net Connect
globalNetConnect VDD    -type pgpin -pin VDD    -inst * -override
globalNetConnect VSS    -type pgpin -pin VSS    -inst * -override
globalNetConnect VDDIOR -type pgpin -pin VDDIOR -inst * -override
globalNetConnect VSSIOR -type pgpin -pin VSSIOR -inst * -override

## Move IO Cells
source respace.tcl

## IO Filler Insertion
addIoFiller -cell {padIORINGFEED60 padIORINGFEED10 padIORINGFEED5 padIORINGFEED3 padIORINGFEED1} -prefix IOFILL

## Verify Timing
report_analysis_views
timeDesign -prePlace

## Save Design
saveDesign InitDesign
