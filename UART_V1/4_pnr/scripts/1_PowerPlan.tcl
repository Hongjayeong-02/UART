########################################
# UART V1 Block-level P&R : PowerPlan
# Top   : uart_core
# Input : InitDesign (같은 세션이면 restore 불필요)
# Run   : innovus 프롬프트에서 source 1_PowerPlan.tcl
########################################

## 새 세션에서 시작할 때만 주석 해제
# restoreDesign InitDesign.dat uart_core

puts "CORE BOX : [dbGet top.fPlan.coreBox]"
puts "DIE  BOX : [dbGet top.fPlan.box]"

## 1. Global net connection (tie cell 포함)
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type tiehi -inst * -override
globalNetConnect VSS -type tielo -inst * -override

## 2. Core power ring
##    가로 변: Metal9 (horizontal), 세로 변: Metal8 (vertical)
##    폭 2um, VDD-VSS 간격 1um → 링 전체 폭 5um (코어 여백 15um 안에 배치)
addRing -nets {VDD VSS} -type core_rings -follow core \
        -layer   {top Metal9 bottom Metal9 left Metal8 right Metal8} \
        -width   {top 2 bottom 2 left 2 right 2} \
        -spacing {top 1 bottom 1 left 1 right 1} \
        -offset  {top 1 bottom 1 left 1 right 1} \
        -center 1

## 3. Vertical power stripes (Metal8)
##    VDD/VSS 한 쌍을 30um 간격으로 반복
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical \
          -width 1 -spacing 1 \
          -set_to_set_distance 30 \
          -start_from left -start_offset 15

## 4. Standard cell rail (Metal1) → ring/stripe 연결
sroute -connect {corePin} -nets {VDD VSS} \
       -allowJogging 1 -allowLayerChange 1 \
       -layerChangeRange {Metal1 Metal9} \
       -corePinTarget {ring stripe}

## 5. Power 연결 및 DRC 점검
verifyConnectivity -type special -error 1000 -warning 50 -report uart_core.powerConn.rpt
verify_drc -limit 1000 -report uart_core.powerDrc.rpt

## 6. Save
saveDesign PowerPlan
