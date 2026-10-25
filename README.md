# UART — RTL to Layout

직접 설계한 UART를 단계적으로 확장한 저장소. V1(core) → V2(APB + FIFO + IRQ) → V3(peripheral IP, 합성·P&R·검증).

| 버전 | 내용 | 폴더 |
|---|---|---|
| V1 | UART core (baud gen, TX, RX), loopback TB | [`UART_V1/`](UART_V1) |
| V2 | APB register, TX/RX FIFO, interrupt, 모듈별 TB | [`UART_V2/`](UART_V2) |
| **V3** | APB3 peripheral IP, 1 GHz 합성·RTL 최적화·P&R·post-layout GLS | [`UART_V3/`](UART_V3) |

## UART V3 · 1 GHz Timing Closure Study

> **Target: 1 GHz · Timing closure: Not achieved** (post-route R2R WNS: ⑦ −77 ps, 최종 ⑨ −110 ps)

| | 결과 |
|---|---|
| RTL 최적화 | report 역추적으로 5곳 수정(③④⑦⑨), 2건 기각(⑤⑧) — 합성 R2R TNS −10.98 → −0.83 ns |
| P&R (post-route, SS) | R2R WNS −91 → **−77 ps**(⑦), 최종 ⑨ −110 ps(reset sync 추가, 원인 미분리) · DRC/Conn 0 |
| Reset | 2-FF reset synchronizer(⑨) — recovery 181/181, removal 181/181 MET (⑦의 −7 ps 해소) |
| 검증 | regression 34/34 (매 수정), FIFO reset 동등성 50만 cycle, **gate-level regression 34/34 (SS/FF SDF)** |
| 타이밍 예외 | MCP 후보를 RTL·assertion으로 선별 → what-if STA WNS +12 ps → **미채택** |
| 상태 | **1 GHz 미달성** · LEC 미실행 · GLS는 48 MHz TB clock (at-speed 아님) |

- 1 MHz P&R placement 이슈: [docs/UART_V3/pnr_placement_issue.md](docs/UART_V3/pnr_placement_issue.md)
- LEC runbook: [docs/UART_V3/lec_runbook.md](docs/UART_V3/lec_runbook.md)

## 도구

Cadence Genus · Innovus · Xcelium · (Conformal LEC 예정) · Icarus Verilog · GPDK045 (교육용 PDK, 미포함)

---
Hong Jayoung · github.com/Hongjayeong-02
