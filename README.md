# UART — RTL to Layout

직접 설계한 UART를 단계적으로 확장한 저장소. V1(core) → V2(APB + FIFO + IRQ) → V3(peripheral IP, 합성·P&R·검증).

| 버전 | 내용 | 폴더 |
|---|---|---|
| V1 | UART core (baud gen, TX, RX), loopback TB | [`UART_V1/`](UART_V1) |
| V2 | APB register, TX/RX FIFO, interrupt, 모듈별 TB | [`UART_V2/`](UART_V2) |
| **V3** | APB3 peripheral IP, 1 GHz 합성·RTL 최적화·P&R·post-layout GLS | [`UART_V3/`](UART_V3) |

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
