
# ============================================================
# UART V3 - 1 GHz SDC
# ============================================================
# Design       : uart_apb (Block-level, NO PAD)
# Technology   : GPDK045
# Library      : slow_vdd1v0_basicCells.lib
# PVT          : SS / 0.9 V / 125 C
# Clock        : MAIN_CLOCK
# Frequency    : 1 GHz
# Clock Period : 1.0 ns
#
# Assumptions:
# 1. APB master/slave operate in the same PCLK domain.
# 2. rst_n deassertion is synchronized to MAIN_CLOCK
#    by an external reset controller.
# 3. UART RX is asynchronous and uses a 2-FF synchronizer.
# 4. UART TX is received asynchronously by another device.
# 5. o_irq is received in the MAIN_CLOCK domain.
# 6. Input/output budget: 60% of one clock period.
#
# NOTE:
# These constraints are for timing experiments.
# They do not establish 1 GHz timing closure.
# ============================================================


# ------------------------------------------------------------
# 1. Timing Parameters
# ------------------------------------------------------------

set PERIOD           1.0

set IO_RATIO         0.60
set IO_DELAY_MAX     [expr {$PERIOD * $IO_RATIO}]
set IO_DELAY_MIN     0.00

set CLK_UNC_SETUP    0.10
set CLK_UNC_HOLD     0.05
set CLK_TRANSITION   0.05

# Confirm .lib capacitive_load_unit.
# Assumed unit: pF
set OUTPUT_LOAD      0.01


# ------------------------------------------------------------
# 2. Clock Definition
# ------------------------------------------------------------

create_clock \
    -name MAIN_CLOCK \
    -period $PERIOD \
    -waveform {0.0 0.5} \
    [get_ports clk]


# ------------------------------------------------------------
# 3. Clock Uncertainty
# ------------------------------------------------------------

set_clock_uncertainty \
    -setup $CLK_UNC_SETUP \
    [get_clocks MAIN_CLOCK]

set_clock_uncertainty \
    -hold $CLK_UNC_HOLD \
    [get_clocks MAIN_CLOCK]


# ------------------------------------------------------------
# 4. Clock Transition
# ------------------------------------------------------------

set_clock_transition \
    $CLK_TRANSITION \
    [get_clocks MAIN_CLOCK]


# ------------------------------------------------------------
# 5. Port Collections
# ------------------------------------------------------------

set CLK_PORT [get_ports clk]
set RST_PORT [get_ports rst_n]

set UART_RX  [get_ports i_uartRx]
set UART_TX  [get_ports o_uartTx]

# All external inputs except clock
set ALL_DATA_INPUTS \
    [remove_from_collection [all_inputs] $CLK_PORT]

# Synchronous APB inputs
# Exclude reset and asynchronous UART RX
set APB_INPUTS \
    [remove_from_collection $ALL_DATA_INPUTS $RST_PORT]

set APB_INPUTS \
    [remove_from_collection $APB_INPUTS $UART_RX]

# Synchronous outputs, including APB and IRQ
set SYNC_OUTPUTS \
    [remove_from_collection [all_outputs] $UART_TX]


# ------------------------------------------------------------
# 6. APB Input Delay
# ------------------------------------------------------------

set_input_delay \
    -max $IO_DELAY_MAX \
    -clock MAIN_CLOCK \
    $APB_INPUTS

set_input_delay \
    -min $IO_DELAY_MIN \
    -clock MAIN_CLOCK \
    $APB_INPUTS


# ------------------------------------------------------------
# 7. Reset Input Delay
# ------------------------------------------------------------

# Assumption:
# rst_n deassertion is synchronized to MAIN_CLOCK
# outside the UART IP.
#
# Do not set a false path on rst_n.
# Recovery/removal checks must remain analyzable.
#
# These delay values are illustrative.
# Actual reset timing must come from the reset
# controller specification.

set_input_delay \
    -max $IO_DELAY_MAX \
    -clock MAIN_CLOCK \
    $RST_PORT

set_input_delay \
    -min $IO_DELAY_MIN \
    -clock MAIN_CLOCK \
    $RST_PORT


# ------------------------------------------------------------
# 8. Synchronous Output Delay
# ------------------------------------------------------------

# APB read data, response signals, and IRQ
# are assumed to be captured in MAIN_CLOCK domain.

set_output_delay \
    -max $IO_DELAY_MAX \
    -clock MAIN_CLOCK \
    $SYNC_OUTPUTS

set_output_delay \
    -min $IO_DELAY_MIN \
    -clock MAIN_CLOCK \
    $SYNC_OUTPUTS


# ------------------------------------------------------------
# 9. Driving Cell
# ------------------------------------------------------------

# Model external drive for all input data ports,
# including rst_n and asynchronous UART RX.
#
# BUFX2 is a study assumption.
# Replace with realistic external driver data
# when available.

set_driving_cell \
    -lib_cell BUFX2 \
    -pin Y \
    $ALL_DATA_INPUTS


# ------------------------------------------------------------
# 10. Output Load
# ------------------------------------------------------------

# Example: 0.01 pF = 10 fF
# Only if .lib uses pF.

set_load \
    $OUTPUT_LOAD \
    [all_outputs]


# ------------------------------------------------------------
# 11. Asynchronous UART RX
# ------------------------------------------------------------

# UART RX is asynchronous to MAIN_CLOCK.
#
# This broad exception is appropriate only if
# i_uartRx feeds the intended synchronizer path
# and has no unverified functional fanout.
#
# For signoff, constrain the actual first-stage
# synchronizer D pin and verify CDC separately.

set_false_path \
    -from $UART_RX


# ------------------------------------------------------------
# 12. Asynchronous UART TX
# ------------------------------------------------------------

# UART TX is consumed by a receiver that does
# not use MAIN_CLOCK as its capture clock.
#
# Exclude synchronous reg-to-output timing analysis.
# Functional and electrical timing requirements
# must be checked separately.

set_false_path \
    -to $UART_TX


# ------------------------------------------------------------
# 13. Verification Requirements
# ------------------------------------------------------------

# After applying the SDC:
#
# 1. Verify create_clock:
#    MAIN_CLOCK = 1.0 ns
#
# 2. Verify I/O constraints:
#    All APB inputs have input delays.
#    rst_n has input delay.
#    APB outputs and o_irq have output delays.
#
# 3. Verify exceptions:
#    Only UART RX and UART TX are false paths.
#    rst_n is NOT a false path.
#
# 4. Analyze:
#    Setup WNS / TNS
#    Hold WNS / TNS
#    Recovery/removal timing checks
#    Unconstrained paths
#    Max transition / capacitance / fanout
#
# 5. Review critical paths:
#    Baud Generator Counter
#    Baud Divider Comparator
#    APB Read Data Multiplexer
#
# 6. Check synchronization assumptions:
#    UART RX synchronizer structure
#    External rst_n deassertion behavior
#
# ============================================================
# END OF FILE
# ============================================================

