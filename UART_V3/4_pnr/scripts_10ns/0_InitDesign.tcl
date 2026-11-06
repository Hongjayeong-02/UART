########################################
# InitDesign (Setup, Floorplan) : uart_apb (block-level, no PAD)
########################################

## Initialization
set PDK_STD <PDK>/std
set init_lef_file  [list $PDK_STD/std_tech/lef/std_tech.lef \
                         $PDK_STD/stdlib/lef/std_macro.lef]
set init_verilog   ../SYN/netlist_10ns_rsync/uart_apb_netlist.v
set init_mmmc_file uart_apb.mmmc.view
set init_top_cell  uart_apb
set init_pwr_net   VDD
set init_gnd_net   VSS
init_design

## Global Net Connect
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override

## Check Design
checkDesign -netlist -physicalLibrary -powerGround -timingLibrary -floorplan -outdir checkDesign

## Floorplan : aspect 1.0, util 60%, core-to-IO 15 um (power ring)
floorPlan -site CoreSite -r 1.0 0.6 15 15 15 15

## Pin Placement : Left = clk/rst/APB in, Right = APB out, Top = UART/IRQ
set pins_left  [concat clk rst_n i_psel i_penable i_pwrite \
                       [dbGet top.terms.name i_paddr*] \
                       [dbGet top.terms.name i_pwdata*]]
set pins_right [concat [dbGet top.terms.name o_prdata*] o_pready o_pslverr]
set pins_top   [list i_uartRx o_uartTx o_irq]

editPin -side Left  -layer 3 -spreadType center -spacing 2.0 -unit MICRON -fixOverlap 1 -pin $pins_left
editPin -side Right -layer 3 -spreadType center -spacing 2.0 -unit MICRON -fixOverlap 1 -pin $pins_right
editPin -side Top   -layer 2 -spreadType center -spacing 4.0 -unit MICRON -fixOverlap 1 -pin $pins_top

## Verify Timing
report_analysis_views
timeDesign -prePlace

## Save Design
saveDesign InitDesign
