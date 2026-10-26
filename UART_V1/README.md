# UART V1 — UART core (TX · RX · baud gen)

버스·버퍼 없이 UART의 타이밍만 구현한 첫 버전. top = `uart_core`.

| 폴더 | 내용 |
|---|---|
| `1_rtl/` | `uart_core` · `uart_tx` · `uart_rx` · `uart_baud_gen` (CLK_FREQ 48 MHz / BAUD 9600 parameter) |
| `2_tb/` | loopback TB (0x00 · 0xFF · 0x55 · 0xAA) |
| `3_syn/` | 1 GHz Genus 스크립트 · 리포트 (`report_1ghz_v1`) |
| `4_pnr/` | Innovus 스크립트(V3 ⑨ QRC flow와 동일, 핀 배치만 V1 포트) · post-route 리포트 |

## 1 GHz 합성 · P&R (V3와 같은 조건)

V3 최종 run과 **같은 SDC 파일(`uart_v3_1ghz.sdc`) · corner · QRC MMMC(cap table 없음) · P&R 스크립트 0~5**로 실행했다. 핀 배치만 V1 포트에 맞췄고, **1 GHz setup은 미달성.**
블록 레벨이라 PAD는 없다 (`1_rtl/uart_core.v` 그대로).

| post-route (SS setup / FF hold) | 결과 |
|---|---|
| R2R WNS / TNS | −36 ps / −0.835 ns (위반 44 / 104) |
| 전체 WNS / TNS | −159 ps / −3.224 ns |
| hold | reg2reg +8 ps · **reset 핀 removal 위반 70 (WNS −75 ps)** |
| 셀 / 면적 (`report_area`) | 477 / 1,383.390 µm² |
| DRC · Conn | 0 · 0 |
| 전체 최악 경로 | `i_txValid → u_uart_tx_r_txShift_reg/SE` (입력 → FF, −159 ps) |
| check_timing | unconstrained endpoint `o_uartTx`(false path) · `u_uart_rx_r_rxMeta_reg/D`(`i_uartRx` false path) — 2개 모두 의도된 항목 |

hold 위반은 모두 `rst_n → FF/RN` removal 검사다. `rst_n`이 모든 FF reset 핀에 직접 들어가고
SDC가 `set_input_delay -min 0`이라, clock tree 지연(약 95 ps)보다 먼저 reset이 풀리는 경우가 생긴다.
V3 ⑨의 2-FF reset synchronizer가 이 문제를 없앤 구조다 (V3 recovery/removal 181/181).

> 처음 실행 때는 PAD를 넣은 수업용 `uart_core`(clk도 `PADDI` 경유)로 합성해, PAD 셀이 블랙박스가 되어
> clock이 FF까지 전파되지 않았다(CTS clock tree 0개, timing path 0개). PAD 없는 core로 다시 실행한 결과가 위 표다.

## 서버 경로 기준

스크립트는 학교 서버의 디렉터리 구조 기준이라 레포를 clone해 바로 실행할 수 없다.

| 서버 (`~/PROJ1/proj1_make/TOP/`) | 저장소 |
|---|---|
| `RTL/UART_V1_core/` | `1_rtl/` |
| `SYN/script/run_synthesis_1ghz_v1.tcl` · `SYN/cons/` | `3_syn/script/` · `3_syn/cons/` |
| `SYN/report_1ghz_v1/` | `3_syn/reports/` |
| `PNR_1GHZ_V1/` (netlist는 `../SYN/netlist_1ghz_v1/`) | `4_pnr/scripts/` · `4_pnr/reports/` |

공통 SDC의 `APB_INPUTS` 변수는 "clk · rst_n · i_uartRx를 뺀 모든 입력"이라 V1에서는 `i_txValid` · `i_txData`를 뜻한다.
