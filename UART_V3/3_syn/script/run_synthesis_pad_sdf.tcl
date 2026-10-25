
# ============================================================
# UART V3 - PAD INCLUDED SYNTHESIS WITH SDF
# Technology : GPDK045
# Tool       : Cadence Genus
# TOP        : uart_chip_top
# Clock      : 1 MHz (1000 ns)
# PAD        : PADDI (RX), PADDO (TX)
#
# Outputs:
#   uart_chip_top_netlist.v
#   uart_chip_top_syn.sdc
#   uart_chip_top_syn.sdf
# ============================================================

# ------------------------------------------------------------
# 1. Directory Setup
# ------------------------------------------------------------

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set SYN_DIR    [file normalize [file join $SCRIPT_DIR ..]]
set TOP_DIR    [file normalize [file join $SYN_DIR ..]]

set RTL_DIR [file join $TOP_DIR RTL UART_V3]

set REPORT_DIR  [file join $SYN_DIR report_pad]
set NETLIST_DIR [file join $SYN_DIR netlist_pad]

file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR

# ------------------------------------------------------------
# 2. Standard Cell / I/O PAD Library
# ------------------------------------------------------------

set STD_LIB "/GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib"

set PAD_LIB "/GPDK045/digital/giolib045_v3.5/timing/pads_SS_s1vg.lib"

set_db library [list $STD_LIB $PAD_LIB]

# ------------------------------------------------------------
# 3. Read UART V3 RTL
# ------------------------------------------------------------

set RTL_FILES [lsort [glob [file join $RTL_DIR *.v]]]

read_hdl -v2001 $RTL_FILES

# ------------------------------------------------------------
# 4. Elaborate UART Chip Top
# ------------------------------------------------------------

elaborate uart_chip_top

check_design -unresolved

# ------------------------------------------------------------
# 5. Preserve UART I/O PAD Instances
# ------------------------------------------------------------

set_db [get_cells u_pad_uart_rx] .dont_touch true
set_db [get_cells u_pad_uart_tx] .dont_touch true

# ------------------------------------------------------------
# 6. Timing Constraint
# ------------------------------------------------------------

read_sdc [file join $SYN_DIR cons uart_v3_1mhz.sdc]

# ------------------------------------------------------------
# 7. Logic Synthesis
# ------------------------------------------------------------

syn_generic
syn_map
syn_opt

# ------------------------------------------------------------
# 8. Synthesis Reports
# ------------------------------------------------------------

report_area > [file join $REPORT_DIR area.rpt]

report_timing > [file join $REPORT_DIR timing.rpt]

report_qor > [file join $REPORT_DIR qor.rpt]

# ------------------------------------------------------------
# 9. Export Gate-Level Netlist
# ------------------------------------------------------------

write_hdl > [file join $NETLIST_DIR uart_chip_top_netlist.v]

# ------------------------------------------------------------
# 10. Export Synthesis SDC
# ------------------------------------------------------------

write_sdc > [file join $NETLIST_DIR uart_chip_top_syn.sdc]

# ------------------------------------------------------------
# 11. Export Pre-Layout SDF
# ------------------------------------------------------------

write_sdf > [file join $NETLIST_DIR uart_chip_top_syn.sdf]

# ------------------------------------------------------------
# 12. Output Verification
# ------------------------------------------------------------

puts "========================================"
puts " UART V3 PAD SYNTHESIS COMPLETED"
puts "========================================"
puts " TOP       : uart_chip_top"
puts " CLOCK     : 1 MHz"
puts " CORNER    : SLOW / SS"
puts " PAD RX    : PADDI"
puts " PAD TX    : PADDO"
puts "----------------------------------------"
puts " NETLIST   : [file join $NETLIST_DIR uart_chip_top_netlist.v]"
puts " SDC       : [file join $NETLIST_DIR uart_chip_top_syn.sdc]"
puts " SDF       : [file join $NETLIST_DIR uart_chip_top_syn.sdf]"
puts "========================================"

exit

