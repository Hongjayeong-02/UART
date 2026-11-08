# UART V4 — Dual-Clock APB UART (CDC)

V3 UART를 **APB 클럭(PCLK)과 UART 클럭(UART_CLK)이 완전히 비동기**인 구조로 확장한 버전.
사양과 결정 기록(D1~D26), 검증 기록은 [`cdc_spec.md`](cdc_spec.md)에 있다.

## 구조

| 경계를 넘는 것 | 방식 |
|---|---|
| TX / RX 데이터 | Async FIFO, depth 16 (Gray pointer + 2-FF synchronizer) |
| CTRL / BAUDDIV 설정 | PCLK 쪽 SW 레지스터 snapshot + req/ack toggle handshake. 적용은 UART_CLK 쪽에서 TX/RX idle일 때만 |
| 오류 이벤트 (parity, frame, overflow) | event synchronizer 3개 |
| STATUS TX_BUSY | PCLK push 카운터 vs UART_CLK 완료 카운터(Gray, 2-FF sync) 비교 |
| Reset | 외부 `rst_n` 하나, 도메인마다 reset synchronizer (async assert, sync deassert) |

- 설정 쓰기 중(CFG_BUSY=1) 들어온 CTRL/BAUDDIV 쓰기는 거절하고 PSLVERR=1 (D4, D10)
- **모든 APB 출력은 레지스터.** write 에러는 SETUP에서 판단하고, 같은 판단으로 응답(PSLVERR)과 쓰기 enable을 함께 막는다 (D24) → 입력→출력 조합 경로 없음

## 결과 (PCLK 10 ns, UART_CLK 20.833 ns)

| 단계 | 결과 |
|---|---|
| RTL 시뮬레이션 | V3 regression (같은 / 분리된 clock) 34 + 34, APB CDC TB 2개 clock 비율 × STRICT_APB_ERR 0·1 × 44 (P11 포함), 단위 TB 5종 PASS ([`2_tb/sim_results.txt`](2_tb/sim_results.txt)) |
| SETUP/ACCESS 경계 | P10: CFG_BUSY가 SETUP 끝 edge에서는 1, ACCESS에서는 0인 cycle을 찾아 쓰기 → 거절 확인. 수정 전 RTL에서는 FAIL (구분력 확인) |
| TX FIFO full | P11: 느린 TX에 연속 쓰기 → 17개 수락 후 거절, PSLVERR는 STRICT일 때 거절된 쓰기에만 1. full이 SETUP 끝 edge에서 1, ACCESS에서 0인 cycle에 쓰기 → STRICT=0 수락 / STRICT=1 거절(SETUP 결정)로 PSLVERR와 실제 수락 여부가 항상 일치. 수락된 byte만 loopback으로 순서대로 한 번씩 돌아옴. ACCESS full 검사나 SETUP 결정을 뺀 RTL에서는 FAIL (구분력 확인) |
| 합성 (Genus) | 위반 0, I2O 경로 없음, latch 0, CDC `set_max_delay 10 ns` worst 9.110 / 8.940 ns |
| Synchronizer 구조 | 1단 flop 34개 모두 같은 비트 2단 D에 직결, 사이 로직·fanout 없음 ([`check_sync_path.py`](3_syn/script/check_sync_path.py)) |
| LEC (Conformal) | RTL ↔ 합성 PASS (Equivalent 629, Unreachable 19 = 상수 상위 read data 16 + 미사용 출력 3), 합성 ↔ P&R PASS (629, unmapped 0) |
| P&R (Innovus, floorplan u80) | setup WNS 3.689 ns, hold WNS 6 ps (SDC hold uncertainty 50 ps 적용 후), 위반 0, CTS skew group 2개, CDC worst 8.738 / 8.525 ns, checkPlace · DRC 0, die 105.8 × 105.6 µm |
| Post-layout GLS | SS/FF SDF × PCLK 100 / 13.5 MHz (UART_CLK 48 MHz) **25/25 PASS × 4**, SDFINF 0. timing violation은 synchronizer 1단 비동기 샘플링과 async reset assert 순간(reset flop)으로 모두 분류 ([`5_gls/gls_results.txt`](5_gls/gls_results.txt)) |

Timing은 Innovus `timeDesign` 기준이며 Tempus signoff STA는 하지 않았다.

## Floorplan sweep

| util / margin | die (µm²) | setup / hold WNS | 위반 | 비고 |
|---|---|---|---|---|
| 0.60 / 15 µm | 16626 | 3.624 ns / 5 ps | 0 | 이전 기준 |
| 0.70 / 10 µm | 12476 | 3.685 ns / 5 ps | 0 | |
| **0.80 / 10 µm** | **11172 (−33 %)** | 3.689 ns / 6 ps | 0 | **현재 기준** |
| 0.90 / 10 µm | 10171 | 3.644 ns / −11 ps | hold 10 | 실제 density 95 %, hold buffer 넣을 자리 없음 (max density 초과) |

결과 표: [`4_pnr/floorplan_sweep/`](4_pnr/floorplan_sweep). V3에 같은 sweep을 하면 0.70부터 pin 45개가 한 변에 다 들어가지 않아 `clk`, `i_pwdata[0]` pin이 배치되지 않는 문제가 있었고, pin 간격 2 → 1 µm로 해결했다 (`sweep_v3.txt`의 `_p1`).

## GLS에서 찾은 TB 문제

UART_CLK을 멈췄다가 다시 켤 때 TB가 `w_uclk = r_uclkRun & r_uclkGate`의 gate를 PCLK edge에서 올려서 짧은 pulse가 생겼다. RTL 시뮬레이션은 timing check가 없어 통과했고, GLS에서 UART_CLK flop 15개가 같은 edge에서 hold 위반으로 드러났다. 재시작도 `negedge r_uclkRun`에 맞춰 해결.

## 폴더

| 폴더 | 내용 |
|---|---|
| `1_rtl/` | V4 RTL (`v3_reuse/`: V3에서 그대로 쓰는 `uart_tx.v`, `uart_irq.v`) |
| `2_tb/` | TB, `rerun_apb.sh`, 시뮬레이션 결과 요약 |
| `3_syn/` | Genus 스크립트, SDC, 리포트, netlist 구조 검사 |
| `4_pnr/` | Innovus 0~5 스크립트 (u80), 리포트, floorplan sweep |
| `5_gls/` | GLS 스크립트, SDF 설정, 결과 요약 |
| `6_verify/lec/` | Conformal dofile과 console (RTL↔합성, 합성↔P&R) |

PDK 경로와 라이브러리 이름은 일반 이름(`<PDK>/std`, `std_ss` 등)으로 바꿔 두었다. netlist, SDF, SPEF, DEF, GDS는 올리지 않는다.
