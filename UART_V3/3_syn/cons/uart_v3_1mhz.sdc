# UART V3 - 1 MHz SDC
# 원본 cons/uart_v3_1mhz.sdc 는 1 GHz 실험(10/21) 때 덮어써짐.
# 이 파일은 1 MHz 합성 때 Genus write_sdc 로 저장한 SYN/netlist/uart_apb_syn.sdc 사본 (2026-10-26).
# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.17-s071_1 on Thu Oct 15 15:03:47 KST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design uart_apb

create_clock -name "MAIN_CLOCK" -period 1000.0 -waveform {0.0 500.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
