# UART — RTL to Layout

직접 설계한 UART를 단계적으로 확장한 저장소. V1(core) → V2(APB + FIFO + IRQ) → V3(peripheral IP, 합성·P&R·검증).

| 버전 | 내용 | 폴더 |
|---|---|---|
| V1 | UART core (baud gen, TX, RX), loopback TB · 1 GHz / 10 ns 합성·P&R(V3와 같은 flow) | [`UART_V1/`](UART_V1) |
| V2 | APB register, TX/RX FIFO, interrupt, 모듈별 TB · 1 GHz / 10 ns 합성·P&R(V3와 같은 flow) | [`UART_V2/`](UART_V2) |
| **V3** | APB3 peripheral IP, 1 GHz 합성·RTL 최적화·P&R·post-layout GLS · **10 ns 과제 P&R · PAD top · LEC** | [`UART_V3/`](UART_V3) |

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
| 상태 | **1 GHz 미달성** · GLS는 48 MHz TB clock (at-speed 아님) · LEC는 아래 10 ns 절 |

- 1 MHz P&R placement 이슈: [docs/UART_V3/pnr_placement_issue.md](docs/UART_V3/pnr_placement_issue.md)
- LEC runbook: [docs/UART_V3/lec_runbook.md](docs/UART_V3/lec_runbook.md)

## 과제 조건 10 ns (100 MHz) · PAD top · LEC

같은 RTL(⑨)을 과제 제출 조건인 10 ns로 다시 합성·P&R하고, Conformal LEC를 실행했다. 1 GHz 결과는 연구 기록으로 그대로 둔다.

| | V3 블록 (`uart_apb`) | PAD top B (`uart_chip_top_allpad`, 82 pad) |
|---|---|---|
| SDC | `uart_v3_10ns.sdc` (period 10 ns, I/O delay **40 %**) | `uart_v3_10ns_pad.sdc` (위 + 입력 `set_input_transition 0.5`) |
| 합성 I2O / I2R / R2O / R2R (ps) | +758 / +4,276 / +4,906 / +7,709 | −82 / +3,846 / +4,099 / +7,785 |
| **post-route setup WNS** | **+0.367 ns** (위반 0) | −0.321 ns (17 paths, 모두 I2O) |
| **post-route hold WNS** | **+0.002 ns** (위반 0) | +0.021 ns (위반 0) |
| DRC · Conn | 0 · 0 | 0 · 28 (pad ring, 아래) |
| 면적 (`report_area`) | **3,716.5 µm²** (1,046 inst, hold buffer 17개) | 1,185,575 µm² (대부분 pad, density 0.258 %) |
| **gate-level regression** (최종 netlist + SDF) | **33/33** × SS/FF × TB clock **100 MHz(at-speed)** / 48 MHz, RTL과 diff 0, timing violation 0 | — |
| **Conformal LEC** RTL ⑨ ↔ 합성 netlist | **PASS** · Equivalent 368 (PO 36 + DFF 332) · Non-eq 0 · Abort 0 | — |
| **Conformal LEC** 합성 netlist ↔ P&R netlist (최종) | **PASS** · Equivalent 368 · Non-eq 0 · Abort 0 · unmapped 0 | — |

| | V1 | V2 | **V3 ⑨** |
|---|---|---|---|
| post-route setup WNS | +5.173 ns | +0.382 ns | **+0.367 ns** |
| hold 위반 (reset 핀 removal) | 68 | 169 | **0** |
| 셀 / 면적 | 239 / 759 µm² | 1,304 / 4,708 µm² | 1,046 / 3,717 µm² |
| DRC · Conn | 0 · 0 | 0 · 0 | 0 · 0 |

V1 · V2 · V3 모두 같은 10 ns SDC와 P&R 스크립트다. V3만 rst_n false path(reset synchronizer 첫 단)와 hold 목표 +5 ps를 넣었다.

- **I/O 40 %**: 60 %면 입력 + 출력 delay가 12 ns > 10 ns라 I2O 경로(`i_paddr → o_prdata`)는 clock과 무관하게 불가능하다(합성 −2,702 ps). 40 %에서 +758 ps.
- **PAD top SDC**: 블록용 `set_driving_cell BUFX2`를 그대로 쓰면 BUFX2가 PADDI의 PAD 핀(≈ 2.4 pF)을 구동하는 가정이 돼 transition 29.7 ns, I2R −29.6 ns의 가짜 위반이 생긴다. PAD top 전용 SDC에서 `set_input_transition 0.5`(가정값)로 바꿨다.
- **B setup −0.321 ns**: PADDI(604 ps) + PADDO(932 ps)가 칩 안 예산을 차지하고, die 1.9 mm라 pad ↔ core 배선이 길다. 통과시키려고 예산을 줄이지 않았다.
- **pad 보존**: 안 쓰는·상수 포트의 pad가 합성에서 지워지지 않도록 elaborate 직후 PADDI/PADDO에 `preserve`(82/82 유지).
- **B 전원**: `giolib045_modify.lef`(PADVDD/PADVSS `CLASS PAD AREAIO`)로 sroute가 전원 pad 4개를 core ring에 연결. 남은 Conn 28건은 IO ring 구간이며 pad LEF에 ring 모양이 없어 연속성을 증명할 수 없다 → **칩 레벨 전원 무결성은 미검증**.
- **hold**: 1차 run의 위반 3개 중 2개는 `rst_n → r_rstSync_reg[0/1]/RN` removal. 10 ns P&R SDC에는 `set_ideal_network rst_n`이 있어 hold 수정이 "IPO ignored"로 건너뛰었다(1 GHz P&R SDC에는 이 줄이 없음). reset synchronizer 첫 단은 비동기 해제를 전제로 한 회로라 `set_false_path -from [get_ports rst_n]`(V3·B만, V1/V2는 rst_n이 모든 flop에 가므로 적용 안 함). 나머지 1개(−4 ps)는 `setOptMode -holdTargetSlack`(최종 0.005)로 해결.
- **hold 목표 비교 (V3)**: 같은 조건에서 `holdTargetSlack`만 바꿔 세 번 돌렸다. 최종은 +5 ps(`reports_10ns_v3_h5/`).

  | hold 목표 | 0 ps (1차, rst_n 예외 전) | **+5 ps (최종)** | +20 ps (2차) |
  |---|---|---|---|
  | hold buffer (FE_PHC) | 11 | **17** | 181 |
  | 면적 | 3,703.5 µm² | **3,716.5 µm²** | 4,013.0 µm² |
  | hold WNS | −76 ps (위반 3) | **+2 ps** | +6 ps |
  | setup WNS | +0.370 ns | **+0.367 ns** | +0.385 ns |

  min input delay 0인 입력 → FF 경로 대부분이 hold 여유 0~20 ps라, +20 ps 목표는 buffer 170개(+8.3 % 면적)를 더 써서 여유 4 ps를 산 셈이다.
- **LEC**: 1차는 FAIL(Non-eq 2, Not-mapped 1). Genus가 항상 반대 값인 `o_txReady`를 `~o_txBusy`로 sequential merge한 것이 원인. `set analyze option -auto`로 merge를 모델링해 PASS, `o_txReady`는 Inverted-equivalent. Unreachable 2(`uut_rx` `o_falseStart`, `o_rxBusy`: 상위에서 안 쓰는 출력). 합성 netlist ↔ P&R netlist(CTS · hold buffer 17개 포함)도 PASS(368 Equivalent, unmapped 0) → **RTL → 합성 → P&R 전 구간 동등성 확인**.
- 서버 `**ERROR` 25건은 OpenAccess 라이브러리 없음(17) · MS constraint 저장(6) · scan chain 미정의(2)로, 1 GHz run과 같은 환경 메시지다.

## 도구

Cadence Genus · Innovus · Xcelium · Conformal LEC · Icarus Verilog · GPDK045 (교육용 PDK, 미포함)

---
Hong Jayoung · github.com/Hongjayeong-02
