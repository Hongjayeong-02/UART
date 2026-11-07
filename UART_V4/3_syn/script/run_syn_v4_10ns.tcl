# ============================================================
# UART V4 - Genus synthesis, block level (uart_v4_apb)
#   PCLK 100 MHz, UART_CLK 48 MHz (asynchronous), SS corner std cell lib
#
# Run from ~/UART_V4/syn :
#   genus -files script/run_syn_v4_10ns.tcl -log syn_v4_10ns
#
# Library path: not written here (PDK paths stay off GitHub).
#   1. env UART_STD_LIB, if set
#   2. else the LIB_PATH line of the V3 10 ns script on this server
# ============================================================

# ------------------------------------------------------------
# 1. Directories
# ------------------------------------------------------------
set SCRIPT_DIR  [file dirname [file normalize [info script]]]
set SYN_DIR     [file normalize [file join $SCRIPT_DIR ..]]
set V4_DIR      [file normalize [file join $SYN_DIR ..]]

set REPORT_DIR  [file join $SYN_DIR report_10ns]
set NETLIST_DIR [file join $SYN_DIR netlist_10ns]
file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR

# ------------------------------------------------------------
# 2. Library
# ------------------------------------------------------------
proc find_lib_path {} {
        global env
        if {[info exists env(UART_STD_LIB)]} {
                return $env(UART_STD_LIB)
        }
        set cands [glob -nocomplain \
                [file join $env(HOME) PROJ1 proj1_make TOP SYN script run_synthesis_10ns_rsync.tcl] \
                [file join $env(HOME) PROJ1 proj1_make TOP SYN run_synthesis_10ns_rsync.tcl] \
                [file join $env(HOME) PROJ1 proj1_make TOP SYN script run_synthesis_10ns.tcl] \
                [file join $env(HOME) PROJ1 proj1_make TOP SYN run_synthesis_10ns.tcl]]
        foreach f $cands {
                set fh [open $f r]
                set txt [read $fh]
                close $fh
                if {[regexp {set\s+LIB_PATH\s+"([^"]+)"} $txt -> p]} {
                        puts "INFO: LIB_PATH taken from $f"
                        return $p
                }
        }
        error "LIB_PATH not found: setenv UART_STD_LIB <std cell .lib> and rerun"
}

set LIB_PATH [find_lib_path]
if {![file exists $LIB_PATH]} {
        error "LIB_PATH does not exist: $LIB_PATH"
}
set_db init_lib_search_path [file dirname $LIB_PATH]
set_db library $LIB_PATH

# ------------------------------------------------------------
# 3. RTL (explicit list: V3 uart_rx.v in rtl_v3 is not used)
# ------------------------------------------------------------
set RTL_FILES [list \
        [file join $V4_DIR rtl uart_async_fifo.v] \
        [file join $V4_DIR rtl uart_v4_cfg_cdc.v] \
        [file join $V4_DIR rtl uart_v4_baud_gen.v] \
        [file join $V4_DIR rtl uart_v4_rx.v] \
        [file join $V4_DIR rtl uart_v4_core.v] \
        [file join $V4_DIR rtl uart_v4_event_sync.v] \
        [file join $V4_DIR rtl uart_v4_rst_sync.v] \
        [file join $V4_DIR rtl uart_v4_apb.v] \
        [file join $V4_DIR rtl_v3 uart_tx.v] \
        [file join $V4_DIR rtl_v3 uart_irq.v]]

read_hdl -v2001 $RTL_FILES

# ------------------------------------------------------------
# 4. Elaborate
# ------------------------------------------------------------
elaborate uart_v4_apb
check_design -unresolved > [file join $REPORT_DIR check_design_unresolved.rpt]

# ------------------------------------------------------------
# 5. Constraints and path groups
# ------------------------------------------------------------
read_sdc [file join $SYN_DIR cons uart_v4_10ns.sdc]

define_cost_group -name I2R -design uart_v4_apb
define_cost_group -name R2O -design uart_v4_apb
define_cost_group -name R2R -design uart_v4_apb
define_cost_group -name I2O -design uart_v4_apb
path_group -from [all_registers] -to [all_registers] -group R2R -name R2R
path_group -from [all_inputs]    -to [all_registers] -group I2R -name I2R
path_group -from [all_registers] -to [all_outputs]   -group R2O -name R2O
path_group -from [all_inputs]    -to [all_outputs]   -group I2O -name I2O

# ------------------------------------------------------------
# 6. Synthesis
# ------------------------------------------------------------
syn_generic
syn_map
syn_opt

# ------------------------------------------------------------
# 7. Reports
# ------------------------------------------------------------
report_area    > [file join $REPORT_DIR area.rpt]
report_qor     > [file join $REPORT_DIR qor.rpt]
report_gates   > [file join $REPORT_DIR gates.rpt]
report_clocks  > [file join $REPORT_DIR clocks.rpt]
report_timing -max_paths 20 -nworst 1 > [file join $REPORT_DIR timing.rpt]

# per clock domain
report_timing -from [get_clocks PCLK]     -to [get_clocks PCLK]     -max_paths 5 > [file join $REPORT_DIR pclk_r2r.rpt]
report_timing -from [get_clocks UART_CLK] -to [get_clocks UART_CLK] -max_paths 5 > [file join $REPORT_DIR uclk_r2r.rpt]

# CDC paths (constrained by set_max_delay)
report_timing -from [get_clocks PCLK]     -to [get_clocks UART_CLK] -max_paths 50 -nworst 1 > [file join $REPORT_DIR cdc_p2u.rpt]
report_timing -from [get_clocks UART_CLK] -to [get_clocks PCLK]     -max_paths 50 -nworst 1 > [file join $REPORT_DIR cdc_u2p.rpt]

# I/O
report_timing -from [all_inputs] -to [all_outputs] -max_paths 10 > [file join $REPORT_DIR i2o.rpt]
report_timing -to [get_ports o_pslverr] -max_paths 5 > [file join $REPORT_DIR pslverr.rpt]

check_timing_intent -verbose > [file join $REPORT_DIR timing_intent.rpt]
report_constraint -all_violators > [file join $REPORT_DIR violators.rpt]

# ------------------------------------------------------------
# 8. Netlist
# ------------------------------------------------------------
write_hdl > [file join $NETLIST_DIR uart_v4_apb_netlist.v]
write_sdc > [file join $NETLIST_DIR uart_v4_apb_syn.sdc]

puts "========================================"
puts " UART V4 SYNTHESIS COMPLETED"
puts " TOP      : uart_v4_apb"
puts " PCLK     : 10 ns   UART_CLK : 20.833 ns (async)"
puts " REPORTS  : $REPORT_DIR"
puts "========================================"

exit
