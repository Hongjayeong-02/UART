# UART V3 발표 최종 · 5 ns (200 MHz) PAD top RO + BAUDDIV 수정

> **5 ns · chip-level (`uart_chip_top_allpad`, 82 pad) · setup +0.226 ns · hold +0.012 ns · 위반 0 · DRC 0**
> gate-level regression 33/33 × SS/FF × TB clock **200 MHz(at-speed)** / 48 MHz · LEC RTL→합성 · 합성→P&R PASS

10 ns PAD top RO(과제 조건 최종)와 같은 RTL 구조 · 같은 P&R 스크립트로, clock만 5 ns로 줄이고 1 GHz 실험 중 찾은 BAUDDIV 버그를 고쳐 다시 구현했다.

## 1. RTL: BAUDDIV 수정 (`1_rtl_bf/uart_baud_gen.v`, `patches/12`)

- **버그 (⑨ 이후 모든 V3 RTL)**: UART 동작 중 BAUDDIV를 현재 카운트보다 작게 쓰면 `r_clkCnt == i_baudDiv`가 다시 참이 될 때까지 16-bit 카운터가 한 바퀴(65,536 cycle) 돈다. 무작위 400건 중 113건. 1 GHz ⑩ 실험의 lookahead 리뷰에서 반례를 돌려 보다 찾았다([step10_r2r.md](step10_r2r.md) 2절).
- **수정**: 비교를 `==` → `>=` 한 글자. 새 값이 더 작으면 다음 cycle에 tick을 내고 0부터 다시 센다. **추가 플롭 0.**
- BAUDDIV가 고정이면 카운트가 BAUDDIV를 넘지 않으므로 ⑨와 동작이 같다. 다른 파일(RO `uart_apb` 포함)은 10 ns RO와 같다.
- 1 GHz용 ⑩(변경 감지 레지스터 17개)보다 단순하다. 5 ns에서는 크기 비교기 지연이 문제가 되지 않는다.

| 검증 (Xcelium) | 결과 |
|---|---|
| regression (`tb_uart_v3_final`, ⑨+수정) | 33/33 |
| RO read 비교 (`6_verify/read_opt`, V3 조합 read vs RO+수정) | reads 191 · writes 209 · mismatch 0 |
| ⑨ ↔ ⑨+수정 lockstep (`2_tb/r10/tb_lock.v`, BAUDDIV 고정 구간) | 3 seeds, 불일치 0 |
| live BAUDDIV (변경 400건, 고정 0~40) | 오류 0 (⑨는 113/400 stall) |
| 큰 BAUDDIV (255~0x1234, 변경 60건, enable 후 첫 tick ⑨와 동일) | 108 checks 오류 0 |

## 2. 합성 (Genus, SS)

SDC는 `uart_v3_10ns_pad.sdc`에서 `PERIOD 10.0 → 5.0`, waveform `{0 5} → {0 2.5}` 두 줄만 바꿨다(`3_syn/cons/uart_v3_5ns_pad.sdc`). I/O delay는 같은 식(주기의 40 % = 2 ns), uncertainty setup 0.10 / hold 0.05 ns 그대로.

| (ps) | 10 ns RO | **5 ns RO + 수정** |
|---|---|---|
| I2O | No paths | No paths |
| I2R | +3,748 | **+839** |
| R2O | +4,404 | **+1,404** |
| R2R | +7,747 | **+2,885** |
| `u_uart_apb` (µm² / 셀) | 3,635.5 / 982 | 3,657.0 / 1,004 (+0.6 %) |

5 ns로 가기 전에 10 ns 합성 slack에서 경로 지연을 역산해 5 ns 결과를 추정했다(I2R 약 +0.75, R2O 약 +1.40, R2R 약 +2.75 ns). 실제와 0.1 ns 안에서 맞았다.

## 3. Chip P&R (Innovus)

10 ns RO 폴더(`PNR_10NS_PADALL_RO`)의 스크립트를 그대로 복사하고 바꾼 것:
- netlist → `netlist_5ns_padall_ro_bf`
- P&R SDC = 5 ns Genus SDC + `set_false_path -from [get_ports rst_n]` (10 ns P&R SDC에서 Genus SDC에 더했던 유일한 줄. `group_path` 셀 목록은 비교에서 제외)
- `2_PlaceOpt.tcl`: `setPlaceMode -place_global_exp_allow_missing_scan_chain true` (scan 플롭 비율이 높을 때 `placeDesign`이 `IMPSP-9099`로 중단되는 것을 막음. SE/SI는 기능 신호라 `-ignoreScan`은 쓰지 않음)
- hold 목표 `holdTargetSlack 0.005` 그대로
- 주의: 10 ns RO 폴더의 로컬 IO LEF(v2)를 같이 복사해야 한다(첫 run에서 빠져 PAD 82개 크기 없음 → 28초 만에 중단)

| | 10 ns RO | **5 ns RO + 수정** |
|---|---|---|
| setup WNS (all / reg2reg) | +3.255 ns / — | **+0.226 ns / +2.659 ns**, 위반 0 |
| hold WNS | +0.012 ns | **+0.012 ns**, 위반 0 |
| DRC | 0 | 0 |
| Conn | info 8 | info 8 (10 ns RO와 내용 동일: VDD·VSS ring open 6, VDDIOR·VSSIOR 배선 없음 2 → 칩 레벨 전원 무결성 미검증) |
| `u_uart_apb` (`report_area`) | 3,929.9 µm² / 1,079 inst | **3,940.9 µm² / 1,104 inst (+0.3 %)** |
| 칩 전체 | — | 1,184,937 µm² / 1,271 inst (대부분 PAD, density 0.225 %) |
| ERROR (OpenAccess 환경 메시지 제외) | — | 0 |

- 가장 빠듯한 경로는 default 그룹(PAD를 지나는 I/O 경로)이다. 레지스터 사이는 +2.659 ns 여유.
- die 크기는 PAD ring으로 정해지는 pad-limited 칩이라(`floorPlan -d 1892 1900`) core util이나 주파수를 바꿔도 칩 면적은 거의 그대로다.

## 4. Gate-level regression (`5_gls/ro5/`)

10 ns RO GLS와 같은 xrun 옵션 · 셀/PAD 모델, 계층 netlist(`hier_net.tcl`) + SDF.

| SDF | TB clock | 결과 | timing violation |
|---|---|---|---|
| SS (max) | **200 MHz (at-speed)** | 33/33, RTL과 동일 | 0 |
| SS (max) | 48 MHz | 33/33 | 0 |
| FF (min) | **200 MHz (at-speed)** | 33/33 | 0 |
| FF (min) | 48 MHz | 33/33 | 0 |

**RX synchronizer 첫 단 timing check 제외**: 첫 run의 SS 두 조합에서 FAIL 11 · timing violation 6이 나왔다. 6건 모두 `uut_rx/r_rxMeta_reg`(비동기 `i_uartRx`를 받는 2-flop synchronizer 첫 단)의 `$setuphold<hold>`였고, 셀 모델 notifier가 Q를 X로 만들어 RX 데이터로 퍼진 것이다(`actual=xx`). 48 MHz에서도 같이 실패해 주파수 문제가 아니라 RX 엣지가 SS 지연에서 hold 창에 떨어진 경우다.
`i_uartRx`는 SDC에서 false path이고 첫 단은 metastability를 받는 자리이므로, STA와 같은 기준으로 **이 플롭 하나만** xrun `-tfile`로 timing check에서 뺐다(`sync1.tfile`). 다시 돌린 4조합 모두 33/33, 다른 플롭 위반 0. SDFNET 198 → 197은 이 플롭 몫이다. 10 ns RO는 이 처리 없이 통과했지만 엣지 위치가 우연히 창 밖이었을 뿐이다.

## 5. LEC (Conformal, `6_verify/lec/ro5_bf/`)

| | 결과 |
|---|---|
| RTL → 합성 (칩 단위, STD + IO lib) | **PASS** · Equivalent 386 (PO 36 + DFF 350) · Inverted-equivalent 1 · Non-eq 0 · Abort 0 |
| 합성 → P&R | **PASS** · Equivalent 386 · unmapped 0 |

RTL → 합성 Unreachable 19개는 모두 칩에서 쓰지 않는 플롭이다: `r_prdata_reg[31:16]` 16개(PAD로 나가는 PRDATA는 하위 16비트), `r_rdErr_reg`(read 오류 응답을 끈 `STRICT_APB_ERR=0`), RX `o_falseStart` · `o_rxBusy`(⑨ 블록 LEC와 같음). Inverted-equivalent 1개는 ⑨ LEC의 `o_txReady = ~o_txBusy` sequential merge와 같은 패턴으로 보이며, 이번 dofile은 이름을 출력하지 않았다.

## 6. 파일

| 저장소 | 내용 |
|---|---|
| `UART_V3/1_rtl_bf/uart_baud_gen.v`, `patches/12_bauddiv_ge_fix.diff` | 수정 RTL (다른 파일은 `1_rtl` + `1_rtl_ro` + `1_rtl_pad`) |
| `UART_V3/3_syn/cons/uart_v3_5ns_pad.sdc`, `3_syn/reports/5ns_padall_ro_bf/` | SDC, 합성 스크립트·리포트 |
| `UART_V3/4_pnr/scripts_5ns_padall_ro_bf/`, `4_pnr/reports_5ns_padall_ro_bf/` | 바뀐 P&R 입력(0_InitDesign, 2_PlaceOpt, MMMC, P&R SDC), 리포트 |
| `UART_V3/5_gls/ro5/` | `glro5.sh`, `sync1.tfile`, SDF cmd, PASS/FAIL 목록, 요약 |
| `UART_V3/6_verify/lec/ro5_bf/`, `6_verify/ro5_sim/` | LEC dofile·console, sim 요약 |
| `UART_V3/tools_ro5/` | `ro5.sh`(sim · syn · cmp · pnr), `mk_lec_ro5.sh` |

## 7. 추가 분석 (발표 준비, 2026-11)

모든 실험은 `ChipFinish` DB를 복원해서 실행했고 DB는 저장하지 않았다(제출 결과물 변경 없음).

### 7.1 전원 connectivity 8건: 원인 좁히기

| 넷 | 건수 | 위치 (µm) |
|---|---|---|
| VDD | 3 (special 1 + regular 2) | regular: 아래 PAD 행 y 145.38–156.61, 위 PAD 행 y 1743.39–1754.62, 둘 다 x 239–1653 |
| VSS | 3 | 같은 구조 (아래 y 159.27–170.5, 위 y 1729.5–1740.74) |
| VDDIOR · VSSIOR | 각 1 (NoRoute) | PAD 핀(Metal4)만 있고 배선 없음 |

- 끊긴 x = 239 / 1653 = die 폭 1892에서 corner 셀(240 × 240) 경계. 넷마다 3조각: 좌우 PAD 행 + core / 아래 PAD 행 / 위 PAD 행.
- 가설 1 "corner 셀에 PG 핀이 없다" → 기각. corner LEF에 VDD · VSS · VDDIOR · VSSIOR 핀이 있다(Metal4).
- 가설 2 "corner 핀이 넷에 안 붙었다" → 기각. 4개 corner 모두 같은 이름 넷에 연결돼 있고, `globalNetConnect`를 다시 적용해도 3/3/1/1 그대로.
- 가설 3 "flow에 padRing sroute가 빠졌다" → 기각. `sroute -connect padRing`을 추가하면 VDD/VSS는 그대로, VDDIOR/VSSIOR는 1 → 122로 악화(DRC 0). 적용하지 않음.
- 남은 원인: corner VDD 핀이 1 µm 폭 조각(y 65.5–76.6)이라 PAD 레일(y 145–157)과 겹치지 않는다 → IO 라이브러리 abstract의 도형 불일치로 생긴 도구상 open으로 판단. 칩 레벨 전원 무결성은 미검증으로 유지.

### 7.2 블록 vs 칩

같은 `uart_apb` 로직의 10 ns 블록 P&R(`reports_10ns_v3_h5`)은 `verify_drc` 0, `verifyConnectivity` "no problems"(0). 8건은 core가 아니라 PAD ring에서 생긴다.

### 7.3 slack 분포 (`report_timing -max_paths 3000 -nworst 1 -path_type end`)

| | 경로 | 최소 / 최대 | 분포 |
|---|---|---|---|
| setup (SS) | 1,101 | +0.226 / +4.544 ns | 0.2–1.75 ns 133개 (input delay 2 ns가 걸린 입력 경로: `r_count`, `r_prdata`, `r_baudDiv`), 2.5 ns 이상 968개 |
| hold (FF) | 1,101 | +0.012 / +0.542 ns | 50 ps 미만 641개 (hold 목표 +5 ps까지만 buffer 삽입) |

주기를 더 줄이면 먼저 깨지는 경로는 RX FIFO count 갱신과 read 캡처(I2R)이고, reg2reg는 여유가 크다.

### 7.4 power (static, 기본 activity)

`u_uart_apb` 0.336 mW (internal 0.259 · switching 0.077 · leakage 0.00008) = 칩 전체 28.6 mW의 1.2 %. 나머지는 PAD.

### 7.5 레이아웃 관찰

pad-limited라 core 대부분이 비어 있고, 표준셀은 연결된 입력 PAD가 많은 왼쪽·아래 변 근처에 모였다. clk PAD는 오른쪽 위라 clock net이 core를 대각선으로 건너온다 → insertion delay 약 1 ns의 주요 원인으로 보임(skew 2 ps). clk PAD를 셀 쪽 변으로 옮기면 줄일 수 있다.

### 7.6 PVS DRC · LVS 첫 실행 (병합 GDS: 표준셀 + IO)

| | 결과 |
|---|---|
| PVS DRC | 29 rule · 21,648건(rule당 1000개 상한 포함). 상위 금속·bondpad 층(M10/M11/CMET/VIA10), implant·well(NLVT · NW · NWR)에 집중. 하위 배선(M2/VIA1/M4/M6)은 수백 건, 위치 분류 전 |
| PVS LVS | MISMATCH. 표준셀 내부 pmos 소자 인식 실패("can't match any device statement", NAND4BX1 · NOR3BX2 · MXI4XL 등), PAD 셀의 PAD 라벨 미연결 경고, psubstrate soft connection 398 |

위반·불일치가 표준셀 내부와 IO·implant 층에 몰려 있어 라이브러리 GDS와 rule deck의 정합 문제로 추정한다. 분리 전이라 이 결과로 PAD ring 전원 연결은 판정하지 않는다. 다음 단계: 표준셀 1개 단독 LVS로 라이브러리 자체 문제인지 확인.

참고: PVS 실행 시 Innovus 환경의 `OA_HOME`이 남아 있으면 "OA2.2 library directory does not seem to exist"로 바로 종료된다 → PVS 자체 OA로 바꿔서 실행. DRC deck에는 `layout_path "CELLNAME.gds"`가 주석 없이 들어 있어 실제 경로로 바꿔야 한다.
