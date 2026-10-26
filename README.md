# UART — RTL to Layout

직접 설계한 UART를 단계적으로 확장한 저장소. V1(core) → V2(APB + FIFO + IRQ) → V3(peripheral IP, 합성·P&R·검증).

| 버전 | 내용 | 폴더 |
|---|---|---|
| V1 | UART core (baud gen, TX, RX), loopback TB · 1 GHz 합성·P&R(V3와 같은 flow) | [`UART_V1/`](UART_V1) |
| V2 | APB register, TX/RX FIFO, interrupt, 모듈별 TB · 1 GHz 합성·P&R(V3와 같은 flow) | [`UART_V2/`](UART_V2) |
| **V3** | APB3 peripheral IP, 1 GHz 합성·RTL 최적화·P&R·post-layout GLS | [`UART_V3/`](UART_V3) |

### V1 · V2 · V3 공통 방법론 비교 (post-route, 1 GHz 목표)

같은 SDC 파일(`uart_v3_1ghz.sdc`, 포트를 `all_inputs`/`all_outputs` 집합으로 지정) · 같은 corner(SS setup / FF hold) · QRC MMMC · 같은 P&R 스크립트(util 0.6), 핀 배치만 각 포트에 맞춤.

| | V1 | V2 | **V3 ⑨ QRC** |
|---|---|---|---|
| R2R WNS / TNS | −36 ps / −0.835 ns | −202 ps / −42.683 ns | **−97 ps / −6.970 ns** |
| 전체 WNS / TNS | −159 ps / −3.224 ns | −1,061 ps / −195.182 ns | −1,049 ps / −53.692 ns |
| 전체 최악 경로 | `i_txValid → r_txShift/SE` (입력 → FF) | `i_paddr[2] → o_prdata[1]` (입력 → 출력) | `i_paddr[2] → o_prdata[6]` (입력 → 출력) |
| 셀 / 면적 (`report_area`) | 477 / 1,383 µm² | 2,401 / 8,059 µm² | **1,735 / 5,854 µm²** |
| reset 핀 removal 위반 | 70 | 176 | **0** (reset synchronizer) |
| DRC · Conn | 0 · 0 | 0 · 0 | 0 · 0 |
| check_timing unconstrained endpoint | 2 | 8 | 19 |

- **세 버전 모두 1 GHz setup은 미달성이다.**
- V2·V3의 전체 최악 경로는 `i_paddr → o_prdata`, APB 읽기의 **입력 → 출력 조합 경로**다(`worst_all.rpt`). SDC가 입력 600 ps + 출력 600 ps + uncertainty 100 ps를 잡으므로 로직이 0이어도 −300 ps에서 시작한다. 그래서 V2·V3 전체 WNS가 약 −1.05 ns로 거의 같다. V1에는 이런 경로가 없어 최악 경로가 입력 → FF이고 −159 ps다.
- check_timing의 unconstrained endpoint는 모두 의도된 항목이다: `o_uartTx`(false path), RX 동기화 첫 FF D(`i_uartRx` false path), `o_prdata` 상위 상수 비트·`o_pslverr`(TIELO 상수), V3의 `r_rstSync_reg[0]/D`(상수 1 입력). 그 밖에 `clk` no drive, `i_uartRx` no input delay(false path).
- V2 → V3 개선(면적 −27 %, R2R −202 → −97 ps)은 사양·구조 변경(FIFO 16 → 8, 레지스터 재구성)과 RTL timing 수정(③④⑦), reset synchronizer(⑨)를 **합친 효과**다. 항목별 기여는 분리하지 않았다.
- V1은 V3보다 R2R이 좋지만, APB·FIFO·IRQ가 없는 더 단순한 설계다.
- V1·V2의 hold 위반은 모두 `rst_n → FF/RN` removal이다. V3 ⑨의 2-FF reset synchronizer가 없앤 문제와 같다.

## UART V3 · 1 GHz Timing Closure Study

> **Target: 1 GHz · Timing closure: Not achieved** (최종 ⑨ QRC post-route R2R WNS −97 ps · cell area 5,830 µm²)

| | 결과 |
|---|---|
| RTL 수정 | 타이밍 최적화 4건(③ FIFO mem reset 분리, ④ registered full/empty · TX parity 누적, ⑦ TX 쓰기 파이프라인) + ⑨ reset synchronizer 1건, 기각 2건(⑤ one-hot, ⑧ RX parity) — 합성 R2R TNS −10.98 → −0.83 ns (③→⑦) |
| P&R (post-route, SS) | **최종 ⑨ QRC: R2R WNS −97 ps / TNS −6.97 ns · cell area 5,830 µm² (Liberty 합, `6_verify/area.awk`) · Innovus `report_area` 5,854.014 µm² · density 82.4 % · hold 0 · DRC/Conn 0** |
| RC 설정 수정 | MMMC에 섞인 28 nm cap table 제거 후 ⑦·⑨ 재실행 → 배선 전 예측 TNS가 7~9 ns 비관적이던 것 확인, 면적 −8.9 %. 같은 조건에서 ⑨ −97 vs ⑦ −116 ps |
| 이전 기록 (cap table flow) | R2R WNS −91(④) → −77 ps(⑦), ⑨ −110 ps · 상대 비교용으로 유지 |
| Reset | 2-FF reset synchronizer(⑨) — recovery 181/181, removal 181/181 MET (⑦의 −7 ps 해소, ⑨ QRC에서도 동일) |
| 검증 | regression 33/33 (매 수정), FIFO reset 동등성 50만 cycle, **gate-level regression 33/33 (SS/FF SDF, ⑨ · ⑨ QRC)** · SDF annotation 경고 181건 = reset 핀 REMOVAL/RECREM이 셀 모델($hold/$recovery)과 이름 불일치 → reset timing은 GLS가 아니라 STA(recovery/removal 181/181)로 확인 |
| 타이밍 예외 | MCP 후보를 RTL·assertion으로 선별 → what-if STA WNS +12 ps → **미채택** |
| 상태 | **1 GHz 미달성** · LEC 미실행 · GLS는 48 MHz TB clock (at-speed 아님) |

- 1 MHz P&R placement 이슈: [docs/UART_V3/pnr_placement_issue.md](docs/UART_V3/pnr_placement_issue.md)
- LEC runbook: [docs/UART_V3/lec_runbook.md](docs/UART_V3/lec_runbook.md)

## 도구

Cadence Genus · Innovus · Xcelium · (Conformal LEC 예정) · Icarus Verilog · GPDK045 (교육용 PDK, 미포함)

---
Hong Jayoung · github.com/Hongjayeong-02
