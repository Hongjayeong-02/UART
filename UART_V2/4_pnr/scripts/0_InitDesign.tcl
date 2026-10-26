########################################
# UART V3 Block-level P&R : InitDesign
# Top   : uart_apb (PAD 없음, 1 MHz)
# Mode  : Innovus legacy (no -stylus)
# Run   : cd /home/hah006/PROJ1/proj1_make/TOP/PNR
#         innovus -nowin -log InitDesign
#         source 0_InitDesign.tcl
########################################

set GPDK /GPDK045/digital/gsclib045_all_v4.4

## 1. Initialization
set init_lef_file  [list $GPDK/gsclib045_tech/lef/gsclib045_tech.lef \
                         $GPDK/gsclib045/lef/gsclib045_macro.lef]
set init_verilog   ../SYN/netlist_1ghz_v2/uart_apb_netlist.v
set init_mmmc_file uart_apb.mmmc.view
set init_top_cell  uart_apb
set init_pwr_net   VDD
set init_gnd_net   VSS
init_design

## 2. Global power connection
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override

## 3. Floorplan : aspect 1.0, core util 60%, core-to-IO margin 15um (power ring용)
floorPlan -site CoreSite -r 1.0 0.6 15 15 15 15

## 4. Pin placement
##    Left  : clock/reset + APB 입력
##    Right : APB 출력
##    Top   : UART RX/TX + IRQ
set pins_left  [concat clk rst_n i_psel i_penable i_pwrite \
                       [dbGet top.terms.name i_paddr*] \
                       [dbGet top.terms.name i_pwdata*]]
set pins_right [concat [dbGet top.terms.name o_prdata*] o_pready o_pslverr]
set pins_top   [list i_uartRx o_uartTx o_irq]

editPin -side Left  -layer 3 -spreadType center -spacing 2.0 -unit MICRON -fixOverlap 1 -pin $pins_left
editPin -side Right -layer 3 -spreadType center -spacing 2.0 -unit MICRON -fixOverlap 1 -pin $pins_right
editPin -side Top   -layer 2 -spreadType center -spacing 4.0 -unit MICRON -fixOverlap 1 -pin $pins_top

## 5. Check & Save
checkDesign -netlist -physicalLibrary -powerGround -timingLibrary -floorplan -outdir checkDesign
saveDesign InitDesign
