
# ============================================================
# UART V3 - GENUS SYNTHESIS SCRIPT
# Technology : GPDK045
# Library    : slow_vdd1v0_basicCells.lib
# TOP        : uart_apb
# Clock      : 1 MHz (Period = 1000 ns)
# ============================================================

# ------------------------------------------------------------
# 1. Directory Setup
# ------------------------------------------------------------

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set SYN_DIR    [file normalize [file join $SCRIPT_DIR ..]]
set TOP_DIR    [file normalize [file join $SYN_DIR ..]]

set RTL_DIR    [file join $TOP_DIR RTL UART_V3]

set REPORT_DIR [file join $SYN_DIR report]
set NETLIST_DIR [file join $SYN_DIR netlist]

file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR

# ------------------------------------------------------------
# 2. Technology Library Setup
# ------------------------------------------------------------

set LIB_PATH "/GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib"

set_db init_lib_search_path [file dirname $LIB_PATH]
set_db library $LIB_PATH

# ------------------------------------------------------------
# 3. Read RTL
# ------------------------------------------------------------

set RTL_FILES [lsort [glob [file join $RTL_DIR *.v]]]

read_hdl -v2001 $RTL_FILES

# ------------------------------------------------------------
# 4. Elaborate TOP Module
# ------------------------------------------------------------

elaborate uart_apb

check_design -unresolved

# ------------------------------------------------------------
# 5. Read Timing Constraint
# ------------------------------------------------------------

read_sdc [file join $SYN_DIR cons uart_v3_1mhz.sdc]

# ------------------------------------------------------------
# 6. Logic Synthesis
# ------------------------------------------------------------

syn_generic
syn_map
syn_opt

# ------------------------------------------------------------
# 7. Generate Reports
# ------------------------------------------------------------

report_area > [file join $REPORT_DIR area.rpt]

report_timing > [file join $REPORT_DIR timing.rpt]

report_qor > [file join $REPORT_DIR qor.rpt]

# ------------------------------------------------------------
# 8. Write Gate-Level Netlist
# ------------------------------------------------------------

write_hdl > [file join $NETLIST_DIR uart_apb_netlist.v]

write_sdc > [file join $NETLIST_DIR uart_apb_syn.sdc]

# ------------------------------------------------------------
# 9. Finish
# ------------------------------------------------------------

puts "========================================"
puts " UART V3 SYNTHESIS COMPLETED"
puts " TOP       : uart_apb"
puts " CLOCK     : 1 MHz"
puts " PERIOD    : 1000 ns"
puts " LIBRARY   : slow_vdd1v0_basicCells"
puts "========================================"

exit

