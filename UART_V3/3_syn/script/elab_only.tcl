
# ============================================================
# UART V3 - GENUS SYNTHESIS SCRIPT
# Technology : 45 nm PDK
# Library    : std_ss.lib
# TOP        : uart_apb
# Clock      : 1 GHz (Period = 1 ns)
# ============================================================

# ------------------------------------------------------------
# 1. Directory Setup
# ------------------------------------------------------------

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set SYN_DIR    [file normalize [file join $SCRIPT_DIR ..]]
set TOP_DIR    [file normalize [file join $SYN_DIR ..]]

set RTL_DIR    [file join $TOP_DIR RTL UART_V3]

set REPORT_DIR [file join $SYN_DIR report_1ghz]
set NETLIST_DIR [file join $SYN_DIR netlist_1ghz]

file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR

# ------------------------------------------------------------
# 2. Technology Library Setup
# ------------------------------------------------------------

set LIB_PATH "<PDK>/std/stdlib/timing/std_ss.lib"

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
gui_show
