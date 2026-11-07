# UART V4 — CDC Specification (draft, 2026-11-05, updated 2026-11-07, step 9)

V4 separates the APB clock (PCLK) from the UART clock (UART_CLK). V3 stays the frozen reference design.

## 1. Decisions

| # | Item | Decision | Reason |
|---|---|---|---|
| D1 | Clock relation | PCLK and UART_CLK fully asynchronous | Most general case; no ratio assumption in RTL or STA |
| D2 | TX/RX data crossing | Async FIFO (Gray pointers + 2-FF sync), depth 16 (TX 8-bit, RX 10-bit) | Industry standard; extra depth absorbs the pointer-sync latency between the two clocks. FIFO_LEVEL widens to 5 bits |
| D3 | Config crossing (CTRL, BAUDDIV) | SW register in PCLK, snapshot + req/ack (toggle) to UART_CLK | Multi-bit value must cross as one consistent word |
| D4 | Write while CFG_BUSY=1 | Write rejected, PSLVERR=1, register unchanged (kept after review of the coalescing alternative) | Simple hardware, few corner cases; SW polls CFG_BUSY |
| D5 | APB write timing | Zero wait (PREADY=1 in ACCESS) | APB never stalls on UART_CLK |
| D6 | Baud counter | Compare `>=` and clear the counter when a new BAUDDIV is applied | Fixes V3 erratum (up to 2^16 cycle stall when BAUDDIV is lowered while enabled) |
| D7 | When config is applied | In UART_CLK, only while TX and RX are idle; then ack back | No baud/format change in the middle of a frame |
| D8 | UART_CLK stopped | APB write still completes; CFG_BUSY stays 1; further config writes get PSLVERR | APB never depends on UART_CLK |
| D9 | RX overflow | Keep stored data, drop the new byte, set sticky overflow flag | Same policy as V3 |
| D10 | CFG_BUSY write error | PSLVERR=1 always, independent of STRICT_APB_ERR | A refused write must never look like success |
| D11 | FIFO_LEVEL register | Same address and fields as V3: TX count [7:0], RX count [15:8] (5-bit counts, 0..16) | V3 already reserves 5 bits per count; counts come from synchronized pointers and may lag by a few cycles |
| D12 | Reset | Both domain resets asserted together; one-side-only reset not supported. Each domain gets a reset synchronizer (async assert, sync deassert) at the top level | Keeps pointers and synchronizers consistent |
| D13 | Driver sequence | CTRL and BAUDDIV are separate writes: write one, poll CFG_BUSY=0, then write the next. Init order: BAUDDIV first, then CTRL (enable) | Direct consequence of D4 (write while busy is refused) |
| D14 | Commit timing | The apply strobe (o_cfgCommit) loads the active config AND clears the baud counter on the same UART_CLK edge; o_applyPulse is a registered status copy | New divider and counter restart are atomic |
| D15 | UART_CLK idle for config apply | `o_uIdle` = TX controller idle, no txValid in flight, uart_tx ready, uart_rx not busy | D7 made concrete; RX in BRK_WAIT counts as idle (no frame in progress) |
| D16 | TX pop vs commit | No TX FIFO pop on the commit edge | The next frame always starts with the new config; a byte is never popped into a TX that was just disabled (it would be lost or stall TX busy forever) |
| D17 | TX pop gating | Pop only when enable && txEn | V3 popped while txEn=0 and sent the byte to a forced-high pin (byte lost). V4 keeps it in the FIFO |
| D18 | RX after frame error | New BRK_WAIT state: after a low stop bit, wait for line high before looking for a start bit | Fixes V3 erratum: start detect is level-based, so the rest of a low stop bit (or a break) was taken as a new start bit |
| D19 | TXDATA write while disabled | Dropped while !enable or !txEn, using the PCLK (software) copy of CTRL. Same as V3 | Keeps V3 software behavior; V3 regression runs unchanged |
| D20 | STATUS[4] TX_BUSY | "TX not finished": PCLK counts accepted pushes, UART_CLK counts finished frames in a Gray counter (2-FF sync to PCLK). TX_BUSY = counts differ | Without it, PCLK could see TX FIFO empty and TX shifter idle (each synchronized separately) while a popped byte is still on its way to the shifter. One comparison of two counters has no such window. V3 meaning was "shifting" only |
| D21 | STATUS[9] CFG_BUSY | New read-only bit | Driver polls it after CTRL / BAUDDIV writes (D13) |
| D22 | Reset | One external rst_n, one reset synchronizer per domain (async assert, sync deassert). Deassert skew between domains is a few cycles; software must not access the UART within the first cycles after reset | D12 made concrete |
| D23 | CDC timing constraints | No `set_clock_groups -asynchronous`. All PCLK <-> UART_CLK paths: `set_max_delay` = shorter period (10 ns); hold false path between the clocks; `rst_n`, `i_uartRx`, `o_uartTx` false path | clock_groups would turn every crossing into a false path, so Gray-bus skew and the quasi-static config bus would never be checked. false path beats max_delay, so the two cannot be mixed |
| D24 | APB write error timing (step 8) | Write error is decided in SETUP from flags that do not depend on the request (address, TX FIFO full, `o_cfgBusy`) and registered into `r_pslverr` together with PREADY. The same registered decision gates the write enables (`w_txWrEn`, `w_cfgWr`). All APB outputs come from flops (no input-to-output path) | Between SETUP and ACCESS these flags can only clear (busy is set only by an accepted config write, full only by a push), so a write accepted in SETUP stays acceptable and a write refused in SETUP stays refused even if the flag clears. Response and side effect always agree (D10). `o_cfgWrErr` must not be used here: it is `i_cfgWr && busy`, and `i_cfgWr` is 0 in SETUP |
| D25 | Unused observation outputs | `uart_v4_cfg_cdc.o_applyPulse` (left open), `uart_tx.o_txBusy` and `uart_v4_rx.o_falseStart` (wired to `w_uTxBusy`, `w_uFalseStart`, never read) | Both wires are UART_CLK domain and must not be read in PCLK without a synchronizer; STATUS[4] uses the D20 counters instead. False start is handled inside RX (return to idle) and is not reported to software. LEC lists the three flops as Unreachable |
| D26 | Block floorplan (step 9) | Core utilization 0.80, core-to-IO margin 10 um (`floorPlan -r 1.0 0.80 10 10 10 10`), pin spacing 2.0 um | Sweep 0.60 / 0.70 / 0.80 / 0.90: die 16626 -> 11172 um2 (-33 %) at 0.80 with no setup/hold/CDC/DRC/placement violation. 0.90 (actual density 95 %) fails hold: no room for hold buffers ("exceeding max density"). 46 left-side pins still fit at 0.80 (V3 needed 1.0 um spacing from 0.70) |

## 2. Signals crossing the boundary

| Signal | Direction | Kind | Method |
|---|---|---|---|
| TX byte | PCLK → UART_CLK | data stream | Async FIFO (TX) |
| RX byte + parity/frame error | UART_CLK → PCLK | data stream | Async FIFO (RX), DW = 10 |
| CTRL / BAUDDIV snapshot | PCLK → UART_CLK | multi-bit, rare | Held snapshot, toggle req → 2-FF → apply → toggle ack back |
| CFG_BUSY | PCLK local | level | Set on accepted write, cleared when ack returns |
| TX busy (STATUS[4]) | UART_CLK → PCLK | counter | Gray-coded done counter (AW+1 bits, 2-FF sync) compared with the PCLK push counter (D20) |
| RX overflow / error events | UART_CLK → PCLK | pulse | Toggle synchronizer + edge detect |
| UART reset | each domain | async assert, sync deassert | One reset synchronizer per domain |

Rule: no multi-bit bus crosses through per-bit 2-FF synchronizers.

## 3. Verification plan

| Check | Method | Status |
|---|---|---|
| Async FIFO directed: fill to 16 -> full, writes while full refused, read while empty, reset with data inside | Directed phase of TB | PASS (Icarus) |
| Async FIFO random: exactly 4000 transfers, wrap-around, order/value, no loss/duplication | Random phase, 5 clock ratios | PASS (Icarus) |
| TB catches functional bugs | Mutations: write ignores full, read ignores empty, wrong full compare | All 3 detected |
| TB cannot catch CDC-only bugs | Mutation: empty uses a 1-stage synchronizer | **Not detected (expected)** -> needs structural CDC check |
| Config CDC T1-T3: write -> CFG_BUSY -> apply (idle only) -> ack; write while busy -> error, value never applied; held while engine busy | `tb_uart_v4_cfg_cdc.v` | PASS (Icarus, 6 clock ratios) |
| Config CDC T4: UART_CLK stopped -> write accepted, busy held, 2nd write refused, applied after restart | same | PASS |
| Config CDC T5: 50 random writes + random idle -> every accepted value applied exactly once, in order | same | PASS |
| Config CDC T6: reset while pending -> busy 0, reset values, nothing applied | same | PASS |
| Config TB catches functional bugs | Mutations: apply ignores idle, accept while busy, busy never set, ack never returns | All 4 detected |
| Config TB cannot catch CDC-only bugs | Mutation: 1-stage request synchronizer (consistent) | **Not detected (expected)** |
| Reset per domain | Assert/deassert order, FIFO restart | PASS for P7/P8 cases (`tb_uart_v4_apb_cdc.v`); one-domain-only reset not supported (D12) |
| Pulse crossing | Back-to-back events at slow/fast ratios, no loss | PASS (step 4, E1-E4, 5 ratios) |
| Baud gen B1: period = div+1 (div 8, 1, 25) | `tb_uart_v4_baud_gen.v` | PASS (Icarus) |
| Baud gen B2/B3: commit lower/higher div -> first tick exactly div+1 edges after commit | same | PASS |
| Baud gen B4: V3 erratum scenario (lower div, no commit) -> tick within 2 cycles | same | PASS |
| Baud gen B5/B6: enable off, div=0 -> no tick | same | PASS |
| Baud TB catches the V3 erratum | Mutation: `==` compare (V3 code) | Detected (B4) |
| Baud TB catches a missing counter clear | Mutation: commit ignored | Detected (B3) |
| Config commit strobe on the load edge | Checker in `tb_uart_v4_cfg_cdc.v` | PASS |
| Level sync L1: 0->1 and 1->0 seen within 3 destination cycles; random level always followed | `tb_uart_v4_status_sync.v`, 5 clock ratios | PASS |
| Event sync E1: one event -> exactly 1 pulse | same | PASS |
| Event sync E2: two back-to-back events -> 2 pulses (2nd held as pending) | same | PASS |
| Event sync E3: burst of 5 -> 1..3 pulses (2 or 3 seen, depends on round trip), never 0 | same | PASS |
| Event sync E4: random events, every event covered by a later send, sends == pulses | same | PASS |
| Event TB catches lost events | Mutation: pending flag never set | Detected (E2, E4) |
| Event TB catches toggle without busy gate | Mutation: send on every event | Detected (E2/E3/E4) |
| Event TB catches level output | Mutation: o_pulse = sync2 level | Detected (E1-E3) |
| 1-stage ack synchronizer | Mutation: busy from ackSync1 | Not detected (expected: metastability is not modeled in RTL sim -> structural CDC check) |
| Core C1: loopback 8N1, 40 bytes with TX FIFO back-pressure | `tb_uart_v4_core.v` (core + cfg_cdc), 7 clock ratios | PASS |
| Core C2/C3: 7E2 and 8O1 on external wire, bit7 = 0 for 7-bit | same | PASS |
| Core C4: RX overflow 16 + 5 -> 5 pulses, first 16 kept | same | PASS |
| Core C5: injected bad parity / bad stop -> entry bit8 / bit9 | same | PASS |
| Core C6/C9: txEn=0 keeps bytes in FIFO (also when cleared mid-burst), none lost | same | PASS |
| Core C7/C8: config written while TX or only RX busy -> applied after the frame | same + commit-while-busy checker | PASS |
| Core TB catches V3 uart_rx (no BRK_WAIT) | Mutation | Detected (C5, 3 of 4 ratios: phase dependent) |
| Core TB catches uIdle without TX / without RX term | Mutation | Detected (checker, C4 / checker, C8) |
| Core TB catches pop while txEn=0 / pop on commit edge | Mutation | Detected (C6 / C9) |
| Core TB catches missing overflow pulse | Mutation | Detected (C4) |
| FIFO levels: wLevel >= true occupancy, wEmpty only when empty, rLevel <= occupancy, rFull only when full; exact after settle | `tb_uart_async_fifo.v` (level checker), 5 ratios | PASS |
| FIFO TB catches missing gray2bin in the level | Mutation | Detected |
| Level from an unsynchronized pointer | Mutation | Not detected (CDC structure only, like a 1-stage sync) |
| **V3 final regression (33 checks) on V4**, FIFO depth 8, UART_CLK = PCLK | `tb_uart_v4_apb.v` (V3 TB + DUT/clock change + CFG_BUSY poll after CTRL/BAUDDIV) | PASS 33/33 |
| Same, UART_CLK separate: half period 4.1 / 5 / 7.3 / 10.42 / 13.1 / 31 ns vs PCLK 10.42 ns | same, `+UHALF=` | PASS 33/33 each |
| V3 regression catches RX pop outside ACCESS1 / TX write ignoring txEn / lost parity event | Mutation | Detected |
| V3 regression does NOT catch: BAUDDIV write clobbering CTRL, CFG_BUSY not reported, TX_BUSY wrong, TX empty IRQ ignoring txEn | Mutation | Not detected -> covered by `tb_uart_v4_apb_cdc.v` |
| APB P1-P9 (P7/P8 reset, P9 counter wrap, 41 bytes): config merge, back-to-back config write (PSLVERR tells the truth), TX_BUSY, TX empty IRQ, FIFO_LEVEL, **UART_CLK stopped** (APB never waits, CFG_BUSY holds, refusal, recovery) | `tb_uart_v4_apb_cdc.v`, 7 ratios | PASS |
| APB TB catches the 4 mutations above + TX_BUSY from FIFO empty only + refused write without PSLVERR | Mutation | Detected (6/6, both test ratios) |
| Structural CDC | Synchronizer on every crossing, no combinational logic before sync | TODO (review / tool) |
| Physical CDC | Synchronizer flops kept (dont_touch), Gray bus max delay / skew constraint in SDC, false path only on the sync first stage | TODO (synthesis / P&R) |
| Step 8 (2026-11-07) registered PSLVERR (D24): V3 regression same/separate clocks, APB CDC normal and slow PCLK | `tb_uart_v4_apb.v`, `tb_uart_v4_apb_cdc.v` | PASS 34 / 34 / 29 / 29, identical to before the change |
| Step 8 first attempt used `o_cfgWrErr` in SETUP: PSLVERR=0 while the config write was refused | APB CDC P2 (back-to-back) and P6 | Detected (FAIL), fixed by deciding on `o_cfgBusy` |
| Synthesis 10 ns after step 8: I2O group has no paths, `o_pslverr` from `r_pslverr_reg` (R2O slack 5.524 ns), latches 0, CDC max_delay paths no violation | `syn/script/check_v4_netlist.sh`, `report_10ns/` | PASS |
| Synchronizer structure: every 1st-stage flop (34) drives only the same bit of its 2nd stage D pin, no logic in between | `syn/script/check_sync_path.py` | PASS 34/34 |
| LEC RTL vs Genus 10 ns netlist (Conformal) | `syn/lec_v4/` | PASS: Equivalent 629 (PO 36 + DFF 593), Non-eq 0, Abort 0, Not-mapped 0, sequential merge 10 equivalent. Unreachable 19 = `r_prdata[31:16]` (constant 0) + 3 unused outputs (D25) |
| Step 9 P&R at D26 (Innovus, SS setup / FF hold): setup WNS 3.689 ns, hold WNS 6 ps (after the 50 ps SDC hold uncertainty), 0 violating paths, hold buffers 42, CTS 2 skew groups (PCLK 247, UART_CLK 346 sinks, skew 3-4 ps), CDC max_delay worst 8.738 / 8.525 ns, checkPlace / DRC / unplaced terms 0 | `pnr/` | PASS (Innovus timeDesign; no Tempus signoff) |
| LEC Genus netlist vs P&R netlist (D26 run) | `pnr/lec_syn2pnr/` | PASS: Equivalent 629, unmapped 0 (u60 run also 629) |
| Post-layout GLS: P&R netlist + SDF, SS(max)/FF(min) x {PCLK 100 MHz, 13.5 MHz} with UART_CLK 48 MHz, `-neg_tchk -nonotifier` | `gls/`, `tb_uart_v4_apb_cdc.v` with `-define GLS` | 25/25 PASS x 4, same as RTL, SDFINF 0, 305 SDFNET warnings (reset removal check not in cell model) |
| GLS timing violations, classified by time and cell: 1st-stage synchronizer async sampling (expected); slow-PCLK max run 16 hold reports at one instant = async `rst_n` assert near a UART_CLK edge, all on reset flops (DFFR/SDFFR) | `glv4.sh` scope classification | Explained, no other violation. Not reported as "0 violations" |

## 4. Files

| File | Content |
|---|---|
| `rtl/uart_async_fifo.v` | Dual-clock FIFO, parameter DW/AW (V4 uses AW=4, depth 16) |
| `tb/tb_uart_async_fifo.v` | Directed + random TB (`+WHALF= +RHALF= +SEED=`) |
| `rtl/uart_v4_cfg_cdc.v` | Config crossing: SW register (= snapshot), toggle req/ack, apply at idle, apply pulse |
| `tb/tb_uart_v4_cfg_cdc.v` | T1-T6 + always-on checker (`+PHALF= +UHALF= +SEED=`) |
| `rtl/uart_v4_baud_gen.v` | Baud generator: `>=` compare + clear on config commit |
| `tb/tb_uart_v4_baud_gen.v` | B1-B6 |
| `rtl/uart_v4_sync_level.v` | 2-FF level synchronizer (status bits, enable) |
| `rtl/uart_v4_event_sync.v` | Toggle req/ack event synchronizer: at-least-once, events merged while in flight, o_busy |
| `tb/tb_uart_v4_status_sync.v` | L1, E1-E4 (`+SHALF= +DHALF= +SEED=`) |
| `rtl/uart_v4_core.v` | UART_CLK core: baud gen, TX controller + V3 uart_tx, uart_v4_rx, both async FIFOs, o_uIdle |
| `rtl/uart_v4_rx.v` | V3 uart_rx + BRK_WAIT (D18) |
| `rtl_v3/uart_tx.v` | V3 uart_tx, unchanged |
| `tb/tb_uart_v4_core.v` | C1-C9 with real cfg_cdc (`+PHALF= +UHALF= +SEED=`) |
| `rtl/uart_v4_apb.v` | Top: APB3 register map (V3 map + STATUS[9]), cfg merge, read wait 1, event syncs, V3 uart_irq |
| `rtl/uart_v4_rst_sync.v` | Reset synchronizer (one per domain) |
| `rtl_v3/uart_irq.v` | V3 IRQ block, unchanged |
| `tb/tb_uart_v4_apb.v` | V3 final regression ported (`+UHALF=` for a separate UART_CLK) |
| `tb/tb_uart_v4_apb_cdc.v` | V4-only APB tests P1-P6 (`+PHALF= +UHALF=`) |

## 5. Open items found while building

| Item | Note |
|---|---|
| ~~Zero-wait write + PSLVERR~~ | Done in step 8 (D24): write error decided in SETUP and registered; zero-wait write kept; no I2O path. |
| r_swCfg -> active config | Multi-bit crossing qualified by synchronized req: needs a max-delay constraint, not a false path. |
| ~~PSLVERR sampling~~ | Obsolete after D24: PSLVERR no longer depends on `i_cfgWr`. `o_cfgWrErr` itself still does; use `o_cfgBusy` for any decision before ACCESS. |
| ~~SETUP/ACCESS boundary~~ | Done: P10 in tb_uart_v4_apb_cdc.v, both clock ratios, 7 checks PASS (boundary hit confirmed: CFG_BUSY=0 during ACCESS). |
| ~~UART_CLK restart glitch in TB~~ | Fixed in step 9: P6/P8 restarted the gated UART_CLK at a PCLK edge, so `w_uclk = r_uclkRun & r_uclkGate` could get a runt pulse (15 hold reports at one edge in GLS, invisible in RTL). Restart now at `negedge r_uclkRun` like the stop. |
| GLS coverage | GLS uses the APB CDC TB only (25 checks; RTL-internal checks under `ifndef GLS`). The V3 regression TB waits on internal signals (`w_txBusy`, `w_tick16`) and has no GLS version yet. |
| FIFO write during reset | Not gated on purpose: both pointers are held at 0, so a word written to memory during reset is never visible; gating with the async reset would mix the reset into data logic. Revisit if lint/CDC tools require it. |
| Event sync is at-least-once, not exactly-once | Events are merged while one is in flight. Fine for IRQ/sticky-status sources (set-only flags). Do not use it to count events (e.g. a byte counter): use the async FIFO or a Gray counter. |
| ~~FIFO_LEVEL counts (D11)~~ | Done in step 6 (see D19-D21 and the verification table). |
| ~~TX empty status / IRQ in PCLK~~ | Done in step 6 (see D19-D21 and the verification table). |
| ~~TX write gating~~ | Done in step 6 (see D19-D21 and the verification table). |
| RX error save registers | In V3 uart_rx the error pulses and rxValid come in the same cycle (PUSH), so the save registers are redundant. Kept for V3 equivalence. |
| TX pin output | `o_uartTx` is a mux of config flops and the TX flop (same as V3). Can glitch when enable/txEn change; register it if the pin must be glitch-free. |
| ~~RX overflow status~~ | Done in step 6 (see D19-D21 and the verification table). |
| ~~TX write while disabled~~ | Done in step 6 (see D19-D21 and the verification table). |
| Back-to-back config writes | Whether the 2nd write is refused depends on the clock ratio (slow PCLK: the handshake finishes first). Hardware is consistent (PSLVERR=1 exactly when the value is not taken); the driver must still poll CFG_BUSY (D13). |
| Xcelium for step 6 | Run `tb_uart_v4_apb` and `tb_uart_v4_apb_cdc` on Xcelium (Icarus only so far). |
| Step 7 | CDC SDC (max-delay / false path on first sync stages only, Gray buses as max-delay bundles), synthesis, structural CDC review. |
| TB pass/fail | `$fatal` is SystemVerilog: Xcelium rejects it in a `.v` file (`*E,NOTSYT`). TBs stay Verilog-2001 and print `... ALL PASS` / `... FAIL`; scripts check the string (`grep -q "ALL PASS"`). If an exit code is needed, compile the TBs with `-sv` and switch to `$fatal`. |
| Reset coverage | P7 (reset with data in both FIFOs + pending config) and P8 (reset while UART_CLK stopped, release, clock starts later) pass. Different reset deassert times between domains are covered only as far as P8 (UART_CLK side released much later). A reset on only one domain is still not supported (D12). |

## 6. Step 7 files

| File | Role |
|---|---|
| `syn/cons/uart_v4_10ns.sdc` | PCLK 10 ns, UART_CLK 20.833 ns (48 MHz), D23 CDC constraints, APB I/O 4 ns |
| `syn/script/run_syn_v4_10ns.tcl` | Genus flow (same structure as V3 10 ns), per-domain and CDC reports. Library path from `UART_STD_LIB` or the V3 script on the server (not stored in the repo) |
| `syn/script/check_v4_netlist.sh` | Synchronizer flop count vs expected, latches, CDC slack summary |

Expected first-stage synchronizers (FIFO_AW = 4): reqSync1 4, ackSync1 4, wGraySync1 10, rGraySync1 10, doneSync1 5, rxMeta 1, reset sync 2 x 2.

## 7. Step 8 changes (2026-11-07)

| File | Change |
|---|---|
| `rtl/uart_v4_apb.v` | `r_rdErr` -> `r_pslverr` (write: SETUP, read: capture); `o_pslverr = r_pslverr`; `w_txWrEn`, `w_cfgWr` gated by `!r_pslverr`; CTRL/BAUDDIV write error uses `w_cfgBusy` (D24). Original kept as `uart_v4_apb.v.orig` |
| `syn/script/check_sync_path.py` | New: synchronizer 1st -> 2nd stage direct-connection check on the netlist (no license) |
| `rerun_apb.sh` | New: reruns the 4 APB-level TBs and diffs PASS/FAIL lines against `log_pre_pslverr/` |
| `syn/lec_v4/` | LEC dofiles, console and log (RTL vs 10 ns netlist) |

## 8. Step 9 changes (2026-11-07)

| File | Change |
|---|---|
| `pnr/` | Block P&R at D26 (was `pnr_sw_u80_m10`); previous u60 run kept in `pnr_base_u60/`. `5_ChipFinish.tcl` CDC reports use `report_timing -clock_from/-clock_to` (legacy mode does not accept `-from [get_clocks]`) |
| `tb/tb_uart_v4_apb_cdc.v` | `ifndef GLS` around 10 RTL-internal checks; DUT instance without `#(.FIFO_AW(4))` under `ifdef GLS`; UART_CLK restart at `negedge r_uclkRun`. RTL result unchanged (35/35 checks) |
| `gls/`, `glv4.sh`, `add_gls_guard.py` | Post-layout GLS flow and violation classification |
| `pnr_sw_u*_m*`, `sweep_fp.sh`, `collect_fp.sh` | Floorplan sweep runs and result table (unplaced-term column) |
