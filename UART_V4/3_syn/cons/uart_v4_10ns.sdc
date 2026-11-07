# ============================================================
# UART V4 (uart_v4_apb) - block-level SDC, two asynchronous clocks
#
#   PCLK     : APB clock, 100 MHz (10 ns)          port i_pclk
#   UART_CLK : baud / shifting clock, 48 MHz        port i_uclk
#              (unrelated to PCLK, no common source)
#
# CDC policy (cdc_spec.md D23):
#   - NO set_clock_groups -asynchronous: it would make every crossing a false
#     path, and then nothing checks Gray-bus skew or the quasi-static config
#     bus delay.
#   - Every PCLK <-> UART_CLK path gets set_max_delay = the shorter period
#     (10 ns). That bounds:
#       * Gray pointers (TX/RX FIFO, TX done counter): bit-to-bit skew < one
#         destination period, so the synchronizer sees at most one bit change
#       * config word r_swCfg -> o_activeCfg: settles long before the
#         handshake toggle arrives (>= 2 UART_CLK later)
#       * FIFO RAM -> read mux in the other domain: stable while the pointer
#         protocol says the entry is valid
#       * toggle -> first synchronizer flop (req/ack, event syncs)
#   - Hold across the two clocks is not meaningful (no fixed phase): false
#     path for hold only.
#   - Reset: rst_n only drives the async clear of the two reset
#     synchronizers. Deassert is synchronized inside each domain, so recovery
#     / removal of the synchronized resets is checked per domain normally.
# ============================================================

set PCLK_PERIOD  10.0
set UCLK_PERIOD  20.833
set CDC_MAX      [expr {($PCLK_PERIOD < $UCLK_PERIOD) ? $PCLK_PERIOD : $UCLK_PERIOD}]

set IO_DELAY_MAX [expr {$PCLK_PERIOD * 0.4}]
set IO_DELAY_MIN 0.0

# ---------------- clocks ----------------
create_clock -name PCLK     -period $PCLK_PERIOD -waveform [list 0.0 [expr {$PCLK_PERIOD / 2.0}]] [get_ports i_pclk]
create_clock -name UART_CLK -period $UCLK_PERIOD -waveform [list 0.0 [expr {$UCLK_PERIOD / 2.0}]] [get_ports i_uclk]

set_clock_uncertainty -setup 0.10 [get_clocks {PCLK UART_CLK}]
set_clock_uncertainty -hold  0.05 [get_clocks {PCLK UART_CLK}]
set_clock_transition  0.05        [get_clocks {PCLK UART_CLK}]

# ---------------- CDC ----------------
set_max_delay $CDC_MAX -from [get_clocks PCLK]     -to [get_clocks UART_CLK]
set_max_delay $CDC_MAX -from [get_clocks UART_CLK] -to [get_clocks PCLK]
set_false_path -hold   -from [get_clocks PCLK]     -to [get_clocks UART_CLK]
set_false_path -hold   -from [get_clocks UART_CLK] -to [get_clocks PCLK]

# ---------------- ports ----------------
set CLK_PORTS   [get_ports {i_pclk i_uclk}]
set RST_PORT    [get_ports rst_n]
set UART_RX     [get_ports i_uartRx]
set UART_TX     [get_ports o_uartTx]

set APB_INPUTS  [remove_from_collection [all_inputs] $CLK_PORTS]
set APB_INPUTS  [remove_from_collection $APB_INPUTS $RST_PORT]
set APB_INPUTS  [remove_from_collection $APB_INPUTS $UART_RX]
set APB_OUTPUTS [remove_from_collection [all_outputs] $UART_TX]

# APB side: PCLK
set_input_delay  -max $IO_DELAY_MAX -clock PCLK $APB_INPUTS
set_input_delay  -min $IO_DELAY_MIN -clock PCLK $APB_INPUTS
set_output_delay -max $IO_DELAY_MAX -clock PCLK $APB_OUTPUTS
set_output_delay -min $IO_DELAY_MIN -clock PCLK $APB_OUTPUTS

# async reset input (assert is asynchronous, deassert synchronized per domain)
set_false_path -from $RST_PORT

# UART pins: asynchronous to both clocks
#   RX goes into the 2-FF synchronizer inside the receiver
#   TX is a UART_CLK flop through the enable mux (no board timing here)
set_false_path -from $UART_RX
set_false_path -to   $UART_TX

set_driving_cell -lib_cell BUFX2 -pin Y [remove_from_collection [all_inputs] $CLK_PORTS]
set_load 0.01 [all_outputs]
