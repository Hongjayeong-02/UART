########################################
# UART V3 chip-level P&R (ALL PAD) : PowerPlan
# Top   : uart_chip_top_allpad
# Input : InitDesign
########################################

# restoreDesign InitDesign.dat uart_chip_top_allpad

puts "CORE BOX : [dbGet top.fPlan.coreBox]"
puts "DIE  BOX : [dbGet top.fPlan.box]"

## 1. Global net connection (tie cell 포함, IO ring 전원 포함)
globalNetConnect VDD    -type pgpin -pin VDD    -inst * -override
globalNetConnect VSS    -type pgpin -pin VSS    -inst * -override
globalNetConnect VDDIOR -type pgpin -pin VDDIOR -inst * -override
globalNetConnect VSSIOR -type pgpin -pin VSSIOR -inst * -override
globalNetConnect VDD    -type tiehi -inst * -override
globalNetConnect VSS    -type tielo -inst * -override

## 2. Core power ring (블록 flow와 같은 폭·층) : pad 와 core 사이 30 um 채널에 배치
addRing -nets {VDD VSS} -type core_rings -follow core \
        -layer   {top Metal9 bottom Metal9 left Metal8 right Metal8} \
        -width   {top 2 bottom 2 left 2 right 2} \
        -spacing {top 1 bottom 1 left 1 right 1} \
        -offset  {top 1 bottom 1 left 1 right 1} \
        -center 1

## 3. Vertical power stripes (Metal8) : 블록 flow와 같음
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
          -width 1 -spacing 1 \
          -set_to_set_distance 30 \
          -start_from left -start_offset 15

## 4. Standard cell rail + PAD 전원 핀(PADVDD/PADVSS 의 VDD/VSS) -> core ring
sroute -connect {corePin padPin} -nets {VDD VSS} \
       -allowJogging 1 -allowLayerChange 1 \
       -layerChangeRange {Metal1 Metal9} \
       -corePinTarget {ring stripe} \
       -padPinTarget {ring}

## 5. Power 연결 및 DRC 점검
verifyConnectivity -type special -error 1000 -warning 50 -report uart_chip_top_allpad.powerConn.rpt
verify_drc -limit 1000 -report uart_chip_top_allpad.powerDrc.rpt

## 6. Save
saveDesign PowerPlan
