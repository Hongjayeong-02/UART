## 설계 가정값과 선택 이유 (5 ns PAD top RO 기준)

외부 인터페이스 사양·PLL 사양이 없는 교육용 환경이라 아래 값 중 일부는 **가정값**이다. 가정값은 결과 해석의 전제이므로 한계와 함께 적는다.

### Clock · SDC (`3_syn/cons/uart_v3_5ns_pad.sdc`)

| 항목 | 값 | 이유 | 한계 · 미검증 |
|---|---|---|---|
| Clock period | 5 ns (200 MHz) | 10 ns 결과의 합성 slack에서 경로 지연을 역산해 같은 RTL·스크립트로 닫히는 주기를 예측 (I2R 예측 +0.75 ns → 실제 +0.84 ns) | 더 줄이면 I2R(RX FIFO count 갱신, read 캡처)이 먼저 깨짐. reg2reg는 +2.659 ns 여유 |
| I/O delay max | 주기의 40 % (2 ns) | 입력 40 % + 출력 40 % = 80 %, 칩 내부에 20 % 남김. 60 %면 입력→출력 조합 경로가 clock과 무관하게 불가능 (10 ns 합성 −2,702 ps) | 실제 APB master 사양이 아닌 비율 가정 |
| I/O delay min | 0 ns | hold에 가장 비관적인 가정 | Tempus hold worst(`i_pwdata[4]` → `.../SI`, +0.010 ns)가 이 가정에서 나옴. 실제 min delay가 정해지면 재확인 |
| Clock uncertainty | setup 0.10 / hold 0.05 ns | (초안) jitter + CTS 전 skew 예상분. hold는 같은 edge 비교라 jitter 영향이 작아 더 작게 | PLL jitter 사양 없음. CTS 후에도 같은 값을 써서 다소 비관적 |
| Clock transition | 0.05 ns | (초안) CTS 전 ideal clock의 slew 가정 | CTS 후에는 실제 clock tree 값 사용 |
| Input transition | 0.5 ns (PAD top) | 블록용 `set_driving_cell BUFX2`를 쓰면 BUFX2가 PADDI PAD 핀(약 2.4 pF)을 구동하는 가정이 돼 transition 29.7 ns, I2R −29.6 ns의 가짜 위반 발생 | 0.5 ns 자체는 가정값. FF corner에서 입력 PAD IOPATH가 음수 → SDF에서 0 처리 → hold 판정은 STA 기준 |
| Output load | 0.01 pF (10 fF) | (초안) 블록 SDC 값을 그대로 사용 | PAD 출력이 구동하는 보드 부하(보통 수 pF)는 반영하지 않음 |
| `i_uartRx` / `o_uartTx` | false path | 비동기 직렬. RX는 2-FF synchronizer로 수신, TX는 상대 장치가 비동기로 샘플 | GLS에서 RX synchronizer 첫 단 하나만 timing check 제외 (`5_gls/ro5/sync1.tfile`) |
| `rst_n` | `set_ideal_network` + false path | reset synchronizer(2단): 비동기 assert, 동기 deassert. 첫 단은 비동기 해제를 전제로 한 회로 | 외부 reset 해제 타이밍은 synchronizer가 보장한다는 전제 |

### Corner · RC (`4_pnr/scripts_5ns_padall_ro_bf/uart_chip_top_allpad.mmmc.view`)

| 항목 | 값 | 이유 | 한계 · 미검증 |
|---|---|---|---|
| Setup corner | SS · 0.9 V · 125 °C | 가장 느린 조건 | 저전압 미세 공정의 temperature inversion(저온 SS가 더 느림) corner는 보지 않음 |
| Hold corner | FF · 1.1 V · 0 °C | 가장 빠른 조건 | TT corner 없음 |
| 합성 corner | SS 하나 | 합성은 setup 최적화가 목적이고 hold는 CTS 후에 수정 | — |
| RC | QRC tech 파일만 (cap table 제거) | 28 nm용 cap table이 섞여 preRoute 추정이 비관적 → 셀 과다 upsizing. 제거 후 ⑨ R2R WNS −110 → −97 ps, 면적 6,400 → 5,830 µm² | BEST/WORST가 같은 QRC 파일에 온도만 다름. RC 편차(cbest/cworst) corner 없음 |
| OCV | `onChipVariation` + CPPR | early/late 분리 계산, 공통 clock 구간 비관성 제거 | `set_timing_derate` 미설정(기본 1.0) → OCV margin은 실제로 반영되지 않음 |

### Floorplan · Power · P&R

| 항목 | 값 | 위치 | 이유 | 한계 · 미검증 |
|---|---|---|---|---|
| Die | 1892 × 1900 µm | `0_InitDesign.tcl` | pad-limited (한 변 PAD 최대 23 × 60 µm + corner 240 × 2). IO filler가 정수 µm라 PAD 간격을 `respace.tcl`로 정수화 | core 높이가 row 정수배가 아님 (IMPFP-7238 경고 2) |
| Core margin | 칩 30 µm / 블록 15 µm | `0_InitDesign.tcl` | core power ring 채널 (초안: 칩은 PAD → ring sroute 여유를 더 둠) | 30 µm의 정량 근거 없음 |
| 블록 util | 0.6 | `scripts_10ns/0_InitDesign.tcl` | sweep에서 0.8까지 통과, 0.9는 hold 22 위반. 검증 끝난 기준과 ECO·hold buffer 여유 때문에 유지 | pin 간격 2 µm에서 0.7 이상이면 일부 pin 미배치 (IMPOPT-576) |
| Core ring | Metal9/8, width 2, spacing 1, offset 1 µm | `1_PowerPlan.tcl` | (초안) 저항이 낮은 최상위 두꺼운 금속 사용 | IR drop 분석으로 확인하지 않음 |
| Stripe | Metal8 수직, width 1, pitch 30 µm | `1_PowerPlan.tcl` | (초안) core 전력 0.336 mW로 작아 넓은 pitch로 충분하다고 판단 | IR drop · EM 분석 없음 |
| 전원 PAD | core VDD/VSS 2쌍(좌·우), IO VDDIOR/VSSIOR 2쌍(위·아래) | `uart_padall.io` | 양쪽 공급, IO 전원과 core 전원 분리 | 전류 · EM 계산 없음. corner LEF 구조로 connectivity info 8건, LVS 공식 미통과 |
| dont_use | CoreSiteDouble 셀 전부 | `2_PlaceOpt.tcl` (placeDesign 전) | floorplan row가 CoreSite만 있어 placement 위반 72건 발생 경험 | Genus 합성 스크립트에는 미적용 |
| CTS 셀 | `CLKBUF*` / `CLKINV*` | `3_PostCTSopt.tcl` | rise/fall 대칭으로 duty · min pulse width 유지 | — |
| hold 목표 | `holdTargetSlack 0.005` | `3_PostCTSopt.tcl` | 0 / 5 / 20 ps 비교: +20 ps는 buffer 170개(+8.3 % 면적)로 여유 4 ps. hold margin은 SDC uncertainty 50 ps로 관리 | — |
| Tie cell | TIEHI/TIELO, maxFanout 8 | `2_PlaceOpt.tcl` | 상수 입력을 gate에 전원 직결하지 않기 위함 (초안: fanout 제한은 배선 길이 제한) | fanout 8의 정량 근거 없음 |

### 검증

| 항목 | 값 | 이유 | 한계 |
|---|---|---|---|
| GLS TB clock | 200 MHz / 48 MHz | 200 MHz는 at-speed, 48 MHz는 (초안) V1부터 쓰던 baud 파라미터 기준 clock으로 주파수와 무관한 기능 동일성 확인 | GLS의 hold는 SDF 음수 지연이 0 처리돼 낙관적 → hold는 STA로 판정 |
| FIFO depth | 8 (parameter) | (직접 작성) | — |
