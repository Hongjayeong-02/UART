# Hold ECO 실습 (Tempus → Innovus) · V3 5 ns PAD top

교재 2권 11장 ECO 흐름을 실제 위반으로 연습하기 위해, **hold fix만 끈 별도 P&R run**을 만들고 Tempus에서 처방(`add_repeater`) → `write_eco` → Innovus 적용 → signoff STA까지 수행했다. 발표 최종 칩(`reports_5ns_padall_ro_bf/`)은 건드리지 않았다.

## 1. 위반 만들기 (HOLDOFF run)

원본 run과 스크립트 차이는 아래 두 파일뿐이다(`diff -q`로 확인). SDC · floorplan · 나머지 단계는 같다.

| 파일 | 주석 처리한 줄 |
|---|---|
| `3_PostCTSopt.tcl` | `setOptMode -holdTargetSlack 0.005`, `optDesign -postCTS -hold` |
| `4_RouteDesign_PowerAnalysis.tcl` | `optDesign -postRoute -hold` |

| Innovus `timeDesign -hold` (FUNC_FF_BEST) | all | reg2reg | default |
|---|---|---|---|
| WNS (ns) | **−0.075** | −0.007 | −0.075 |
| TNS (ns) | −3.738 | −0.036 | −3.702 |
| 위반 path | **110** | 5 | 105 |

105개는 입력 PAD → 레지스터(in2reg) 경로다. FF corner에서 입력 min delay가 작아 데이터가 clock보다 일찍 도착한다.

## 2. Tempus ECO ([`scripts/tempus_hold_eco.tcl`](scripts/tempus_hold_eco.tcl))

1. Innovus에서 `RouteDesign.dat` → `extractRC` → `saveDesign -rc RouteDesign_for_ECO` (filler 전 DB, RC 포함)
2. Tempus `read_design` → constraint mode 지정 후 `set_propagated_clock` → `update_timing -full`
3. 첫 endpoint 하나는 손으로: `add_repeater -cell CLKBUFX2 -term <pin>` 후 slack 변화 확인
4. 나머지는 루프: 위반 endpoint마다 slack ≥ +10 ps가 될 때까지 buffer 추가(최대 8개)
5. `write_eco -format innovus -output innovus.eco`

| 선택 | 이유 |
|---|---|
| `CLKBUFX2` (BUFX2 아님) | BUFX2는 CoreSiteDouble → 이전 placement 위반 72건의 원인 |
| `-term`만 사용 | `-net`과 같이 주면 IMPTCM-67 |
| 목표 +10 ps | 배선 전 추정치이므로 margin |

| 결과 | 값 |
|---|---|
| 처리 endpoint | 110 (실패 0) |
| 추가 buffer | **280** (수동 1 + 루프 279) · endpoint당 1~5개 (1:28, 2:31, 3:21, 4:24, 5:6) |
| endpoint 핀 | SE 48 · SI 33 · D 24 · RN 5 |
| Tempus 기준 hold 위반 (후) | 0 |

SI/SE 핀이 많은 이유: 설계에 scan이 없지만 Genus가 load-enable FF를 scan FF로 매핑해 SI = 기능 데이터, SE = enable(mux 선택)로 쓴다. 따라서 `i_pwdata → r_irqEn_reg/SI` 같은 경로는 실제 기능 경로다.

## 3. Innovus 적용 ([`scripts/6_ECO_apply.tcl`](scripts/6_ECO_apply.tcl), [`7_ChipFinish_ECO.tcl`](scripts/7_ChipFinish_ECO.tcl))

`source innovus.eco` → `refinePlace` → `ecoRoute` → `extractRC` → timeDesign → `checkPlace` · `verify_drc` · `verifyConnectivity` → `saveDesign -rc RouteDesign_ECO` → filler → `saveDesign -rc ChipFinish_after_ECO` → GDS · netlist · SDF · SPEF.

| 검사 | 결과 |
|---|---|
| DRC | **0** |
| Connectivity | 8건 (VFC-98 ×2 VDDIOR/VSSIOR no routing, VFC-200 ×2, VFC-92 ×4) |
| ↳ 원본 `ChipFinish.dat`를 새로 검사한 결과 | **같은 8건 · 같은 좌표** → ECO가 만든 open 0 |
| netlist `FE_ECOC*` | 280 (Tempus 처방 전부 반영) |

원본 디렉토리의 이전 `conn.rpt`(5건)는 다른 세션에서 DB를 수정한 상태로 쓴 파일이라 기준으로 쓰지 않았다. 8건의 원인은 [§7.8](../../../docs/UART_V3/ro5_200mhz.md)(corner LEF PORT 구조, IO ring은 PAD abutment로 연결)과 같다.

## 4. Signoff STA (Tempus Practice 2, `ChipFinish_after_ECO.dat`)

| 항목 | ECO 전 (HOLDOFF) | **ECO 후** | 원본 칩 (Innovus hold fix) |
|---|---|---|---|
| Hold WNS (Tempus) | −0.071 | **+0.001** · `r_rstSync_reg[0]` → `[1]` | +0.010 |
| Hold WNS (Innovus) | −0.075 | +0.001 | +0.012 |
| Setup WNS (Tempus) | +0.287 | **+0.063** · `i_paddr[7]` → `r_prdata_reg[0]/D` | +0.224 |
| Setup WNS (Innovus) | +0.290 | +0.072 | +0.226 |
| `report_constraint -all_violators` | — | **max_transition 7 net (14 pin), 최악 −0.572** → §5.1에서 수정 | 0 |
| coverage setup / hold | — | 887 / 888 (untested 1 = const) | 같음 |
| real net / RC 주석 | — | 1,553 / 1,471 (94.7 %), 빠진 82개 | 1,323 / 1,241, 빠진 82개 |
| u_uart_apb 셀 / 면적 | — | 1,361 / 4,356 µm² | 1,104 / 3,941 µm² |

- net 증가 +230 = ECO buffer +280 − 원본의 Innovus hold 셀 50. RC 주석이 빠진 82개(top 포트 ↔ PAD net)는 그대로라 ECO가 만든 검증 공백은 없다.
- max_transition 위반은 ECO가 새로 만든 것이다(ECO 전 0). 처음 정리할 때 이 항목을 "위반 0"으로 잘못 적었고, 2026-11-29 보고서를 다시 확인하며 바로잡았다.
- Tempus 목표 +10 ps가 배선 후 +1 ps가 됐다. `add_repeater`가 새 buffer의 배선을 추정으로 계산했기 때문이며, ECO에서 margin을 남기는 이유다. 위반은 아니지만 derate · uncertainty를 더하면 음수가 될 수준이다.

## 5. 비교: endpoint ECO vs Innovus 자동 hold fix

| | Innovus `optDesign -hold` (원본) | Tempus endpoint ECO |
|---|---|---|
| 추가 셀 | 50 | 280 |
| setup 손실 (hold fix 전 +0.290 기준) | −0.064 ns | **−0.227 ns** |
| 넣는 위치 | 여러 endpoint가 공유하는 지점 | endpoint 바로 앞, 각각 따로 |
| 통제 | 도구 자동 | 위치 · 셀을 엔지니어가 지정 |

endpoint 단위 처방은 셀 수와 setup 여유 양쪽에서 비싸다. 국소 수정(late ECO, metal-only 등)에 맞는 방식이고, 대량 위반은 P&R 단계 최적화가 효율적이다.

## 5.1 2차 ECO: max_transition 수정 ([`scripts/8_DRV_fix_ECO.tcl`](scripts/8_DRV_fix_ECO.tcl), 2026-11-29)

1차 ECO 후 Innovus DRV: **max_tran 7 net (14 pin), 최악 −0.563 ns** (한도 0.280 ns, FUNC_SS_WORST). 7개 모두 `r_baudDiv_reg[9..15]/SI` 앞에 1개씩 들어간 `CLKBUFX2`다.

| 원인 확인 (`dbGet` 좌표, µm) | y |
|---|---|
| `i_pwdata[9..15]` PAD · ECO buffer | 1,448 ~ 1,628 (칩 위쪽) |
| `r_baudDiv_reg[9..15]` | 484 ~ 497 (칩 아래쪽) |

`add_repeater -term`은 buffer를 driver(PAD) 옆에 두어 buffer 하나가 약 1 mm 배선을 구동했다. 1차 ECO가 hold delay만 맞추고 transition은 보지 않은 결과다.

| 시도 | max_tran | hold WNS | 판단 |
|---|---|---|---|
| 1차 ECO 후 | 7 net, −0.563 | +0.001 | — |
| ① buffer 7개 `CLKBUFX2 → X4` | 7 net, −0.173 | **−0.005** (`baudDiv[10]/SI`) | 셀 크기보다 배선 길이가 원인, hold 악화 |
| ② buffer↔FF 중간점에 `CLKBUFX4` 추가 (`FE_ECOT1~7`, `-loc`) | 1 net, −0.009 (`FE_ECOT1`) | +0.001 | 배선 분할로 transition · hold 동시 개선 |
| ③ `FE_ECOT1 → CLKBUFX6` | **0** | **+0.001** | 완료 |

최종 (`ChipFinish_after_ECO4`, Innovus `timeDesign`):

| 항목 | NanoRoute 후 (HOLDOFF) | 1차 ECO 후 | **2차 ECO 후** |
|---|---|---|---|
| Setup WNS all / reg2reg | +0.290 / +2.662 | +0.072 / +2.433 | **+0.072 / +2.433** |
| Hold WNS · 위반 | −0.075 · 110 | +0.001 · 0 | **+0.001 · 0** (`r_rstSync_reg[0]→[1]`) |
| max_tran / max_cap / fanout / length | 0 | 7 net / 0 / 0 / 0 | **0 / 0 / 0 / 0** |
| DRC · checkPlace | 0 · 0 | 0 · 0 | **0 · 0** |
| Connectivity | 8 | 8 | 8 (같은 항목) |
| top 인스턴스 | 1,221 | 1,501 | 1,508 (+7) |

보고서: `reports/innovus/eco4_*`, `*eco4*.rpt`. 추가 buffer는 top 레벨이라 `u_uart_apb` 셀 수 · 면적(1,361 / 4,356 µm²)은 그대로다.

## 6. LEC (Conformal, [`lec/`](lec))

Genus 5 ns netlist(golden) ↔ ECO 후 P&R netlist `uart_chip_top_allpad_eco.v`(revised), liberty(SS std + IO)로 읽어 원본 5 ns LEC([`6_verify/lec/ro5_bf/`](../../6_verify/lec/ro5_bf))와 같은 조건.

| 항목 | 결과 |
|---|---|
| Mapped key points (PI / PO / DFF) | 46 / 36 / 350, unmapped 0 |
| Compared points | **386 Equivalent**, Non-eq 0, Abort 0 → **PASS** |
| black box | 0 |
| BUF primitive (golden → revised) | 82 → 426 (ECO 280 + CTS 등 P&R 버퍼) |

buffer는 key point가 아니므로 비교점 수가 ECO 전(386)과 같다. 논리 변경 없이 delay만 더했다는 근거다.

## 7. 남은 것

| 항목 | 상태 |
|---|---|
| LEC: Genus netlist ↔ ECO4 netlist | 미수행 (§6 PASS는 1차 ECO netlist 기준). buffer 7개만 추가돼 PASS 예상이나 확인 전 |
| Tempus signoff (§4) 재실행 | 미수행 (§5.1 수치는 Innovus `timeDesign`) |
| Post-layout GLS (ECO SDF) | 선택 (미수행) |

## 8. 파일

| 경로 | 내용 |
|---|---|
| `scripts/` | Tempus 루프 · Innovus 적용 · ChipFinish · 2차 DRV ECO |
| `reports/innovus.eco` | Tempus가 쓴 ECO (`ecoAddRepeater` 280줄) |
| `reports/tempus_eco/` | 00 hold 전 · 10 setup 전 · 20 endpoint별 log · 30 hold 후 · 40 setup 후 |
| `reports/tempus_p2/` | Practice 2: check_timing · parasitics · coverage · setup · hold · violators |
| `reports/innovus/` | timeDesign summary (전 · 후 · final), DRC, conn, area |
| `lec/` | dofile · console (PASS 386/386) |
