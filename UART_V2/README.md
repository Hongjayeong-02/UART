# UART V2 — APB slave · FIFO · IRQ

V1에 APB slave(메모리 맵 레지스터 9개), TX/RX FIFO 16단, IRQ, parity · 7bit · 2stop, loopback을 붙인 버전. top = `uart_apb`.

| 폴더 | 내용 |
|---|---|
| `1_rtl/` | RTL 11개 (`uart_v2_top`은 TB용 wrapper) |
| `2_tb/` | 모듈별 TB + `tb_uart_v2_top` 통합 regression |
| `3_syn/` | 1 GHz Genus 스크립트 · 리포트 (`report_1ghz_v2`) |
| `4_pnr/` | Innovus 스크립트(V3 ⑨ QRC flow와 동일) · post-route 리포트 |

## 1 GHz 합성 · P&R (V3와 같은 조건)

V3 최종 run과 **같은 SDC 파일 · corner · QRC MMMC · P&R 스크립트 0~5**로 실행했다. 블록 레벨, PAD 없음. check_timing은 따로 돌리지 않았다. **1 GHz setup은 미달성.**

| post-route (SS setup / FF hold) | V2 | V3 ⑨ QRC (비교) |
|---|---|---|
| R2R WNS / TNS | −202 ps / −42.683 ns | −97 ps / −6.970 ns |
| 전체 WNS / TNS | −1,061 ps / −195.182 ns | −1,049 ps / −53.692 ns |
| hold | reg2reg +3 ps · **reset 핀 removal 위반 176 (WNS −127 ps)** | 0 |
| 셀 / 면적 (`report_area`) | 2,401 / 8,059.230 µm² | 1,735 / 5,854.014 µm² |
| DRC · Conn | 0 · 0 | 0 · 0 |

V2 → V3: FIFO 16단 → 8단(parameter), 메모리 맵 레지스터 재구성(9 → 8), RTL timing 수정(③④⑦), reset synchronizer(⑨). 면적·R2R 개선은 이 변경들을 **합친 효과**이고, 항목별 기여는 분리하지 않았다. 전체 WNS(−1.061 vs −1.049 ns)는 I/O 경로 때문에 거의 같다.
V2의 hold 위반은 V1과 같은 `rst_n → FF/RN` removal이다.
