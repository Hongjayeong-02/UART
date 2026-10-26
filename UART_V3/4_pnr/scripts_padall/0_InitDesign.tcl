########################################
# UART V3 chip-level P&R (ALL PAD) : InitDesign
# Top   : uart_chip_top_allpad (signal PAD 82 + power PAD 8 + corner 4)
# Clock : 100 MHz (10 ns) (MMMC: uart_chip_top_allpad_10ns_pnr.sdc)
# Pad   : GPDK045 giolib045 v3.5 (60 x 240 um, corner 240 x 240 um)
########################################
set GPDK /GPDK045/digital/gsclib045_all_v4.4
set GIO  /GPDK045/digital/giolib045_v3.5

## 1. Initialization (standard cell + PAD LEF)
set init_lef_file  [list $GPDK/gsclib045_tech/lef/gsclib045_tech.lef \
                         $GPDK/gsclib045/lef/gsclib045_macro.lef \
                         $GIO/lef/giolib045_modify.lef]
set init_verilog   ../SYN/netlist_10ns_padall/uart_chip_top_allpad_netlist.v
set init_mmmc_file uart_chip_top_allpad.mmmc.view
set init_top_cell  uart_chip_top_allpad
set init_pwr_net   {VDD VDDIOR}
set init_gnd_net   {VSS VSSIOR}
init_design

## 2. Global power connection (core VDD/VSS, IO ring VDDIOR/VSSIOR)
globalNetConnect VDD    -type pgpin -pin VDD    -inst * -override
globalNetConnect VSS    -type pgpin -pin VSS    -inst * -override
globalNetConnect VDDIOR -type pgpin -pin VDDIOR -inst * -override
globalNetConnect VSSIOR -type pgpin -pin VSSIOR -inst * -override

## 3. Floorplan
##    side: 23 pad x 60 um = 1380 um + corner 240 x 2 = 1860 um  -> die 1900 x 1900 um
##    core-to-die 270 um = pad 240 + 30 um channel for the core power ring
floorPlan -site CoreSite -d 1892 1908 30 30 30 30

## 4. IO file (generated from the netlist pad instances)
##    left  : power VDD/VSS 2  + input 21
##    top   : power IOR 2      + input 20
##    bottom: power IOR 2      + input 5 + output 15
##    right : power VDD/VSS 2  + output 21
set inPads  [lsort -dictionary [dbGet [dbGet top.insts.cell.name PADDI -p2].name]]
set outPads [lsort -dictionary [dbGet [dbGet top.insts.cell.name PADDO -p2].name]]
puts "PAD count : PADDI [llength $inPads]  PADDO [llength $outPads]"

proc pad_lines {names} {
    set s ""
    foreach n $names { append s "        (inst name=\"$n\")\n" }
    return $s
}
set L [lrange $inPads 0 20]
set T [lrange $inPads 21 40]
set B [concat [lrange $inPads 41 end] [lrange $outPads 0 14]]
set R [lrange $outPads 15 end]

set fp [open uart_padall.io w]
puts $fp "(globals\n    version = 3\n    io_order = default\n)"
puts $fp "(iopad"
puts $fp "    (topleft\n        (inst name=\"CORNER_TL\" cell=\"padIORINGCORNER\")\n    )"
puts $fp "    (top"
puts -nonewline $fp [pad_lines [lrange $T 0 9]]
puts $fp "        (inst name=\"PVDDIOR_T\" cell=\"PADVDDIOR\")\n        (inst name=\"PVSSIOR_T\" cell=\"PADVSSIOR\")"
puts -nonewline $fp [pad_lines [lrange $T 10 end]]
puts $fp "    )"
puts $fp "    (topright\n        (inst name=\"CORNER_TR\" cell=\"padIORINGCORNER\")\n    )"
puts $fp "    (left"
puts -nonewline $fp [pad_lines [lrange $L 0 10]]
puts $fp "        (inst name=\"PVDD_L\" cell=\"PADVDD\")\n        (inst name=\"PVSS_L\" cell=\"PADVSS\")"
puts -nonewline $fp [pad_lines [lrange $L 11 end]]
puts $fp "    )"
puts $fp "    (right"
puts -nonewline $fp [pad_lines [lrange $R 0 10]]
puts $fp "        (inst name=\"PVDD_R\" cell=\"PADVDD\")\n        (inst name=\"PVSS_R\" cell=\"PADVSS\")"
puts -nonewline $fp [pad_lines [lrange $R 11 end]]
puts $fp "    )"
puts $fp "    (bottomleft\n        (inst name=\"CORNER_BL\" cell=\"padIORINGCORNER\")\n    )"
puts $fp "    (bottom"
puts -nonewline $fp [pad_lines [lrange $B 0 9]]
puts $fp "        (inst name=\"PVDDIOR_B\" cell=\"PADVDDIOR\")\n        (inst name=\"PVSSIOR_B\" cell=\"PADVSSIOR\")"
puts -nonewline $fp [pad_lines [lrange $B 10 end]]
puts $fp "    )"
puts $fp "    (bottomright\n        (inst name=\"CORNER_BR\" cell=\"padIORINGCORNER\")\n    )"
puts $fp ")"
close $fp
puts "IO side count : L [llength $L]+2  T [llength $T]+2  B [llength $B]+2  R [llength $R]+2"

loadIoFile uart_padall.io
## IO ring 전원 핀도 다시 연결 (loadIoFile 이 만든 power pad / corner 포함)
globalNetConnect VDD    -type pgpin -pin VDD    -inst * -override
globalNetConnect VSS    -type pgpin -pin VSS    -inst * -override
globalNetConnect VDDIOR -type pgpin -pin VDDIOR -inst * -override
globalNetConnect VSSIOR -type pgpin -pin VSSIOR -inst * -override

## 5. IO filler (pad 사이 빈칸을 채워 IO ring 전원선을 잇는다)
addIoFiller -cell {padIORINGFEED60 padIORINGFEED10 padIORINGFEED5 padIORINGFEED3 padIORINGFEED1} -prefix IOFILL

## 6. Check & Save
checkDesign -netlist -physicalLibrary -powerGround -timingLibrary -floorplan -outdir checkDesign
saveDesign InitDesign
