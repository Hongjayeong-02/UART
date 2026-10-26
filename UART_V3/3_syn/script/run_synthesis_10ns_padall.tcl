
# ============================================================
# UART V3 - GENUS SYNTHESIS SCRIPT
# Technology : GPDK045
# Library    : slow_vdd1v0_basicCells.lib
# TOP        : uart_chip_top_allpad
# Clock      : 100 MHz (Period = 10 ns)
# ============================================================

# ------------------------------------------------------------
# 1. Directory Setup
# ------------------------------------------------------------

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set SYN_DIR    [file normalize [file join $SCRIPT_DIR ..]]
set TOP_DIR    [file normalize [file join $SYN_DIR ..]]

set RTL_DIR    [file join $TOP_DIR RTL UART_V3_padall]

set REPORT_DIR [file join $SYN_DIR report_10ns_padall]
set NETLIST_DIR [file join $SYN_DIR netlist_10ns_padall]

file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR

# ------------------------------------------------------------
# 2. Technology Library Setup
# ------------------------------------------------------------

set LIB_PATH "/GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib"

set_db init_lib_search_path [file dirname $LIB_PATH]
set_db library [list $LIB_PATH /GPDK045/digital/giolib045_v3.5/timing/pads_SS_s1vg.lib]

# ------------------------------------------------------------
# 3. Read RTL
# ------------------------------------------------------------

set RTL_FILES [lsort [glob [file join $RTL_DIR *.v]]]

read_hdl -v2001 $RTL_FILES

# ------------------------------------------------------------
# 4. Elaborate TOP Module
# ------------------------------------------------------------

elaborate uart_chip_top_allpad

check_design -unresolved
set pads [get_db insts -if {.base_cell.name == PADDI || .base_cell.name == PADDO}]
puts "PAD insts after elaborate : [llength $pads]"
set_db $pads .preserve true

# ------------------------------------------------------------
# 5. Read Timing Constraint
# ------------------------------------------------------------

read_sdc [file join $SYN_DIR cons uart_v3_10ns_pad.sdc]

define_cost_group -name I2R -design uart_chip_top_allpad
define_cost_group -name R2O -design uart_chip_top_allpad
define_cost_group -name R2R -design uart_chip_top_allpad
define_cost_group -name I2O -design uart_chip_top_allpad
path_group -from [all_registers] -to [all_registers] -group R2R -name R2R
path_group -from [all_inputs]    -to [all_registers] -group I2R -name I2R
path_group -from [all_registers] -to [all_outputs]   -group R2O -name R2O
path_group -from [all_inputs]    -to [all_outputs]   -group I2O -name I2O
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

write_hdl > [file join $NETLIST_DIR uart_chip_top_allpad_netlist.v]

write_sdc > [file join $NETLIST_DIR uart_chip_top_allpad_syn.sdc]

# ------------------------------------------------------------
# 9. Finish
# ------------------------------------------------------------

puts "========================================"
puts " UART V3 SYNTHESIS COMPLETED"
puts " TOP       : uart_chip_top_allpad"
puts " CLOCK     : 100 MHz (10 ns)"
puts " PERIOD    : 10 ns"
puts " LIBRARY   : slow_vdd1v0_basicCells"
puts "========================================"


report_clocks > report_10ns_padall/clocks.rpt
report_timing -max_paths 20 -nworst 1 > report_10ns_padall/top20_paths.rpt
report_gates > report_10ns_padall/gates.rpt
write_db -to_file netlist_10ns_padall/uart_chip_top_allpad_10ns.db

check_timing_intent -verbose > report_10ns_padall/timing_intent.rpt
report_constraint -all_violators > report_10ns_padall/violators.rpt
report_timing -from [all_inputs] -max_paths 5 > report_10ns_padall/in2reg.rpt
report_timing -to [all_outputs] -max_paths 5 > report_10ns_padall/reg2out.rpt
report_timing -from [get_ports rst_n] -max_paths 5 > report_10ns_padall/reset.rpt
report_timing -from [all_registers] -to [all_registers] -max_paths 10 > report_10ns_padall/r2r.rpt
report_timing -from [all_registers] -to [all_outputs] -max_paths 5 > report_10ns_padall/r2o.rpt


exit
