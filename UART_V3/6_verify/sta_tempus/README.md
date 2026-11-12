# Signoff STA (Tempus) · V3 5 ns PAD top

교재 2권 10장 Practice 0 흐름으로 수행. 원본 DB(`ChipFinish.dat`)는 수정하지 않았다.

| 순서 | 명령 | 이유 |
|---|---|---|
| 1 | `read_design ChipFinish.dat uart_chip_top_allpad` | P&R DB 읽기 |
| 2 | `read_spef -rc_corner WORST/BEST` | DB를 `-rc` 없이 저장해 RC가 없음 (주석 0 % → 93.8 %) |
| 3 | `set_interactive_constraint_modes [all_constraint_modes -active]` → `set_propagated_clock [all_clocks]` | 없으면 clock이 ideal (`ideal_clock_waveform`), 모드 지정 없으면 TCLCMD-1048 |
| 4 | `update_timing -full` | SPEF 주석은 timing 갱신 때 붙음 |
| 5 | `check_timing` · `report_annotated_parasitics` · `report_analysis_coverage` | 교재 점검 3종 |
| 6 | `report_timing -late / -early` | setup / hold |
| 7 | `write_sdf -recompute_delay_calc -view FUNC_SS_WORST / FUNC_FF_BEST` | post-layout GLS 입력 |

| 결과 | 값 |
|---|---|
| setup WNS (FUNC_SS_WORST) | **+0.224 ns** · `i_paddr[0]` → `rx_fifo r_count_reg[4]` (Innovus +0.226) |
| hold WNS (FUNC_FF_BEST) | **+0.010 ns** · `i_pwdata[4]` → `r_txPushData_reg[4]/SI` (Innovus +0.012) |
| coverage Violated | 0 (setup · hold · recovery · removal · pulse width · external delay) |
| SPEF 주석 (real net) | 93.8 % (1,241 / 1,323) · 빠진 82개 = top 포트 ↔ PAD net (top term에 물리 핀 없음) |

check_timing 경고 분류 (검사에서 빠진 동기 경로 0):

| 대상 | 개수 | 이유 |
|---|---|---|
| `o_prdata[31:16]`, `o_pslverr` | 17 | 상수 출력 (coverage Reason = const) |
| `o_uartTx` / `i_uartRx` | 1 / 1 | 비동기 직렬, SDC false path |
| `r_rstSync_reg[0]/D` | 1 | 상수 1 |
| `r_rstSync_reg[0:1]/RN` | 2 | 비동기 assert (`set_ideal_network rst_n`), 해제는 2단 동기화 |
| `no_drive` | 입력 전부 | `set_driving_cell` 대신 `set_input_transition 0.5` |

| 파일 | 내용 |
|---|---|
| `check_timing.rpt`, `check_timing_v.rpt` | 요약 / 핀 단위 |
| `annot.rpt` | parasitics 주석률 |
| `coverage.rpt`, `cov_untested.rpt` | coverage 요약 / untested 상세 |
| `setup.rpt`, `hold.rpt` | worst 5 경로 |
