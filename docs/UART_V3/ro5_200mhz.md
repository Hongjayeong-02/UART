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
- 원인: corner LEF가 VDD/VSS 핀을 두 변에 **별도 PORT**로 정의하고, 둘을 잇는 L자 링 금속은 OBS로만 둔다. Innovus는 모서리를 지나는 연결을 따라가지 못해 아래·위 PAD 행이 별도 조각으로 보인다 (자세한 근거는 7.8). ~~corner 핀(y 65.5–76.6)과 PAD 레일(y 145–157)이 80 µm 어긋남~~ → LEF 원본 좌표와 DB 좌표를 섞어 비교한 실수로 철회.

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

### 7.6 PVS DRC · LVS (병합 GDS: 표준셀 + IO)

**1차 실행 (P&R 폴더의 streamOut map 사용)**

| | 결과 |
|---|---|
| PVS DRC | 29 rule · 21,648건(rule당 1000개 상한 포함). 상위 금속·bondpad 층, implant·well 층에 집중 |
| PVS LVS | MISMATCH. 표준셀 내부 pmos 소자 인식 실패("can't match any device statement"), PAD 라벨 미연결 경고, psubstrate soft connection 398 |

**가설 검증: 라이브러리 문제인가?** 1차 결과만 보고 라이브러리 GDS와 rule deck의 정합 문제로 추정했으나, 표준셀 5종(INVX1 · NAND2X1 · NAND4BX1 · NOR3BX2 · DFFRHQX1)을 GDS 2종으로 단독 LVS 한 결과 **10/10 MATCH** → 라이브러리 가설 기각.

**원인: streamOut layer map 불일치.** P&R 폴더의 map과 PDK가 제공하는 map을 비교하니 349줄이 달랐고, Cont · Metal1 · implant · Metal4 등의 GDS layer 번호가 rule deck 기대값과 어긋나 있었다. 셀 내부 소자가 인식되지 않은 이유가 이것으로 설명된다.

**PDK map으로 다시 streamOut 후**

| | 1차 | map 수정 후 |
|---|---|---|
| DRC | 29 rule · 21,648 | **4 rule · 826** |
| DRC 위치 | – | 위치 분류된 550건(METAL4.W.2 454, soft_check 96) 전부 PAD ring, core 0. METAL4.SP.1.6 276건은 미분류 |
| LVS 소자 인식 | 실패 다수 | malformed device 0, parameter mismatch 없음 |
| LVS 결과 | MISMATCH | MISMATCH (cell 92 match / 7 mismatch, stamping conflict 22, psubstrate softchk 26) |

남은 LVS mismatch 7종은 모두 "extra pin"이고 CTS · hold 버퍼와 delay 셀(CLKBUFX2, DLY1X1, DLY1X4 등)이다. 비교 리포트에 schematic `VDD` 핀에 대응하는 layout net이 없다는 항목이 있다.

**판정**: core DRC 0은 확인, PVS LVS는 **미통과**. 이 결과로 PAD ring 전원 연결(7.1)은 아직 판정하지 않는다.
다음 단계: (1) extra pin 셀 7종의 CDL 핀 순서·전원 핀 이름 확인, (2) 누락 VDD net 추적, (3) PAD ring Metal4 위반 위치 확인.

참고: PVS 실행 시 Innovus 환경의 `OA_HOME`이 남아 있으면 "OA2.2 library directory does not seem to exist"로 바로 종료된다 → PVS 자체 OA로 바꿔서 실행. DRC deck에는 `layout_path "CELLNAME.gds"`가 주석 없이 들어 있어 실제 경로로 바꿔야 한다. streamOut은 반드시 PDK 제공 map으로 한다.

### 7.7 LVS mismatch 원인 분리 (2026-11-11)

7.6의 LVS MISMATCH를 실험으로 하나씩 분리했다. 아래 실험들은 모두 **복사본**(GDS · CDL · deck)으로 돌렸고, 원본 결과는 그대로 두었다. LVS는 **아직 통과가 아니다**.

| 실험 | 바꾼 것 | 결과 | 판정 |
|---|---|---|---|
| lvs2 | PDK map으로 다시 streamOut | 계층 비교: cell 92 match / 7 mismatch | 출발점 |
| 가설 확인 | CDL 핀 순서 · Verilog PG 연결 · 같은 이름 module | 셋 다 정상 | 기각 |
| lvs3 | IO CDL의 `!` global 이름 제거 (`VSS!`→`VSS`) | 전원 이름 mismatch 0, PAD 셀 mismatch는 남음 | 이름 문제 해결 |
| lvs4 | flat 비교 (automatch 끔) | core MOS **unmatched 0** (PMOS 4,368 / NMOS 4,070) | 표준셀 3종(CLKBUFX2 · DLY1X1 · DLY1X4) mismatch는 계층 추출 착시 |
| lvs5 | CDL에서 BONDPAD52 인스턴스 제외 | 남은 것: top pin 0 : 86, IO bulk, IO 소자 2+2 | bondpad와 나머지 분리 |
| lvs6 | deck이 label texttype 3도 읽게 | 변화 없음 | 기각 |
| GDS 직접 확인 | top 셀 TEXT 개수 | **0개**. top term 82개가 위치만 있고 핀 도형 없음 | 라벨 없음 확정 |
| lvs8 | LEF 핀 위치(instTerm pt)에 라벨 추가 | 라벨 84개 unattached | 그 위치에 금속 없음 |
| lvs9 | GDS 실제 PAD 금속 위치에 라벨 추가 | **Pins 84 : 86**, Nets 4,931 : 4,929, 이름 안 맞는 pin 2 (VDDIOR · VSSIOR) | 라벨 원인 확정 |

**IO LEF ↔ GDS 80 µm 불일치.** PAD 입력 셀의 LEF PAD 핀은 셀 안쪽 y 80.00–81.42 µm인데, streamOut된 GDS에서 실제 Metal11 PAD 금속은 다이 가장자리(LEF 좌표 y −0.005–1.415)에 있다. 차이 80 µm. 그래서 LEF 핀 좌표에 붙인 라벨은 금속을 못 만났다. (이 80 µm 차이는 PAD **신호 핀**에만 해당한다. 전원 링은 7.8 참고.) GDS의 PAD 금속은 4 × 1.42 µm 조각뿐이고 bondpad 구조가 없어 BONDPAD52(82개)가 인식되지 않는 것과도 맞는다.

**남은 항목 (설계 결함으로 보지 않는 근거와 함께)**

| 항목 | 내용 | 성격 |
|---|---|---|
| IO bulk | IO NMOS bulk 연결 layout 54 ↔ schematic 95 불일치, IO MP2/MN2 각 2개 차이 | CDL은 IO NMOS bulk를 VSS / VSSIOR로 나누는데 deck에는 기판 분리 규칙이 없어 하나의 p-substrate로 묶임 (stamping conflict 22, softchk 26). 라이브러리 · deck 한계 |
| BONDPAD52 | 82개 layout 미인식 | IO GDS에 bondpad 인식층 없음 |
| VDDIOR · VSSIOR 라벨 | net은 대응되나 이름 없음 | 두 net이 NoRoute라 라벨 위치를 못 뽑음 |

**정식 수정 방향**: 라벨을 GDS에 직접 넣은 것은 원인 확인용 실험이다. 정식으로는 IO 라이브러리 LEF와 GDS의 PAD 핀 위치를 맞추고, top term에 실제 PAD 금속 위치로 physical pin을 만든 뒤 다시 streamOut해야 한다.

**배운 것**: 세운 가설 중 라이브러리 결함 · CDL 핀 · texttype은 틀렸다. 매번 한 가지만 바꾼 복사본 실험과 GDS 직접 파싱으로 원인을 좁혔다.

### 7.8 전원 open 8건: corner LEF PORT 구조 (2026-11-12)

7.1의 "corner 핀–레일 80 µm 어긋남"은 **철회**한다. corner 핀 좌표(65.5–76.6)는 LEF 원본 좌표였고, PAD 레일(145–157)은 DB 좌표였다. 둘 사이의 80 µm는 LEF ORIGIN 차이일 뿐이다.

| 확인 | 결과 |
|---|---|
| DB 좌표로 본 corner 경계 VDD 핀 | corner (x 239–240) → IO filler (240–244) → PAD (244–245), 모두 y 145.5–156.6 Metal4로 **빈틈없이 맞붙음** (corner 4곳 동일) |
| GDS | corner와 PAD 셀 모두 GDS 셀 높이 160 / LEF 240, SREF가 똑같이 80 µm 밀려 배치. 레일 높이가 같아 **링 금속 연속** |
| verifyConnectivity 마커 | open 5개가 "아래 행 VDD", "아래 행 VSS", "위 행 VDD", "위 행 VSS", "좌우 열 + core"의 **조각 bbox**. 조각 끝이 모두 corner 경계 |
| corner LEF | `PIN VDD`에 **PORT 2개** (오른쪽 변 1 µm 조각, 위쪽 변 1 µm 조각). 둘을 잇는 금속은 OBS |
| PAD LEF (비교) | `PIN VDD`의 양쪽 rect가 **한 PORT** 안에 있음 → 행 방향으로는 이어짐 |
| flat LVS (7.7 lvs9) | VDD, VSS 각각 한 net으로 추출 |

**판정**: open 8건은 corner LEF abstract가 내부 연결을 표현하지 않아 생긴 **도구상 open**으로 판단한다. GDS와 flat LVS에서는 링이 연결돼 있다. 다만 Innovus 안에서 corner 내부에 링을 직접 그려 open이 0이 되는지 확인하는 실험은 아직 하지 않았다.

**유지되는 것**: PAD **신호 핀**(Metal11)의 LEF ↔ GDS 80 µm 차이는 SREF offset까지 포함해 계산한 값이라 그대로 유효하다 (7.7).

### 7.9 Signoff STA (Tempus) + post-layout GLS (2026-11-12)

**흐름**: ChipFinish DB → Innovus `extractRC` + `rcOut` (WORST · BEST SPEF) → Tempus `read_design` + `read_spef` + propagated clock → 점검 3종 → `write_sdf` → 같은 TB로 GLS.

**Tempus 설정에서 놓치기 쉬운 것**

| 증상 | 원인 | 조치 |
|---|---|---|
| `report_annotated_parasitics` 0 % | `read_design`은 DB만 읽고 RC는 안 읽음 | `read_spef -rc_corner WORST/BEST` 후 `update_timing -full` |
| `check_timing`의 `ideal_clock_waveform` | SDC에 propagated clock이 없음 (Innovus는 CTS 후 자동 전환) | `set_interactive_constraint_modes [all_constraint_modes -active]` → `set_propagated_clock [all_clocks]` |
| `set_propagated_clock` 거부 (TCLCMD-1048) | MMMC에서 constraint mode를 지정하지 않음 | 위와 같음 |

**결과 (5 ns, SS 0.9 V 125 °C / FF 1.1 V 0 °C)**

| | Innovus | Tempus | 차이 |
|---|---|---|---|
| setup worst (SS · WORST RC) | +0.226 ns | **+0.224 ns** | 2 ps |
| hold worst (FF · BEST RC) | +0.012 ns | **+0.010 ns** | 2 ps |
| coverage Violated | – | 0 | – |
| SPEF 주석 (real net) | – | 93.8 % (1,241 / 1,323) | 빠진 82개 = top 포트 ↔ PAD net (top term에 물리 핀이 없어 SPEF에 없음, 7.7) |

- setup worst: `i_paddr[0]` → `rx_fifo r_count_reg[4]` (I2R)
- hold worst: `i_pwdata[4]` → `r_txPushData_reg[4]/SI`. `IO_DELAY_MIN = 0` 가정에서 나온 값이라 외부 인터페이스 min delay가 정해지면 다시 확인해야 한다.
- 위반이 없어 ECO(`add_repeater`)는 하지 않았다.

**check_timing 경고 분류: 검사에서 빠진 동기 경로 0**

| 대상 | 개수 | 이유 |
|---|---|---|
| `o_prdata[31:16]`, `o_pslverr` | 17 | 상수 출력 (coverage Reason = const) |
| `o_uartTx` / `i_uartRx` | 1 / 1 | 비동기 직렬, SDC `set_false_path` |
| `r_rstSync_reg[0]/D` | 1 | 상수 `1'b1` |
| `r_rstSync_reg[0:1]/RN` | 2 | 비동기 assert (`set_ideal_network rst_n`), 해제는 2단 동기화 |
| `no_drive` | 입력 전부 | `set_driving_cell` 대신 `set_input_transition 0.5` 사용 |

**post-layout GLS (Tempus SDF, 같은 TB · netlist)**

| 실행 | PASS | FAIL | timing violation |
|---|---|---|---|
| max (SS SDF) · 200 MHz / 48 MHz TB | 33 / 33 | 0 / 0 | 0 / 0 |
| min (FF SDF) · 200 MHz / 48 MHz TB | 33 / 33 | 0 / 0 | 0 / 0 |

- min 쪽 `SDFNDP` 경고 44개(Innovus SDF 때도 동일): FF corner 입력 PAD `IOPATH PAD Y`가 음수(예: PADDI rise −0.084 ns). 입력 transition 0.5 ns에 비해 PAD 출력이 빨라 50 %–50 % 지연이 음수가 되는 것으로 보인다. GLS는 0으로 바꿔 적용하므로 hold 쪽으로 낙관적이다 → **hold 판정은 STA(+0.010 ns) 기준**, GLS는 기능 검증으로 본다.

### 7.10 선택 과제 결과: corner 링 실험 · LVS 86/86 (2026-11-12)

**1. Innovus에서 corner 안에 L자 Metal4 링을 추가해 open 0 확인: 실행 불가로 종료**

| 시도 | 결과 |
|---|---|
| `setEdit`/`setEditMode` + `editAddRoute`/`editCommitRoute` (batch · GUI) | 에러 없이 wire 생성 안 됨 (VDD sWire 1249 → 1249) |
| `addStripe -area` | `IMPPP-354`: IO 영역에 stripe를 만들지 않음 |

옵션으로 억지로 넣는 실험은 증거 가치가 낮아 하지 않았다. 판정은 7.8 근거(LEF PORT 구조 · open 조각 위치 · GDS 링 연속 · flat LVS 단일 net)로 유지한다.

**2. VDDIOR · VSSIOR 라벨 추가 → top pin 86/86**

두 net은 NoRoute라 Innovus에서 라벨 위치를 뽑을 수 없다. PAD 셀 GDS에서 Metal4는 레일 전체가 아니라 셀 양 끝의 1 µm 핀 조각뿐이라, 레일 중간에 둔 라벨은 unattached였다. 핀 조각 중심으로 옮긴 뒤:

| | lvs5 (라벨 없음) | lvs9 (신호 라벨) | lvs10 (+ VDDIOR · VSSIOR) |
|---|---|---|---|
| Pins | 0 : 86 | 84 : 86 | **86 : 86** |
| Nets | 5,015 : 4,929 | 4,931 : 4,929 | **4,929 : 4,929** |
| core MOS unmatched | 0 | 0 | 0 |

**3. 남은 불일치는 IO 기판 하나**

| 항목 | 값 |
|---|---|
| bulk 짝 (layout ↔ schematic) | `B: VSS` 46 ↔ `B: VSSIOR` 46 (그 외 net 없음) |
| 나머지 schematic 쪽 bulk 목록 | 출력 PAD 셀(PADDO: prdata · irq · pready · pslverr · uart_tx) 내부 NMOS |
| stamping conflict | 22 |

회로도(IO CDL)는 IO NMOS bulk를 VSSIOR로 두고, layout은 단일 p-substrate가 VSS · VSSIOR 탭에 함께 닿아 VSS 하나로 묶인다. deck에 기판 분리 규칙이 없어 생기는 불일치로, 회로 결함이 아니라 라이브러리 · deck 한계로 판단한다. IO 두꺼운 산화막 MP/MN 각 2개 차이도 bulk가 달라 병렬 reduction이 달라진 결과로 본다(미확인).

**정리**: 원본 GDS · CDL은 그대로 두고 복사본(라벨 추가, BONDPAD52 제외)으로 원인을 분리했다. LVS 공식 결과는 여전히 **미통과**이며, 남은 원인은 IO 기판 모델링 하나다.
