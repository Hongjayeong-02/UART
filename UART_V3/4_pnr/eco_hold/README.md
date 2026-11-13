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
| `report_constraint -all_violators` | — | 위반 0 | 0 |
| coverage setup / hold | — | 887 / 888 (untested 1 = const) | 같음 |
| real net / RC 주석 | — | 1,553 / 1,471 (94.7 %), 빠진 82개 | 1,323 / 1,241, 빠진 82개 |
| u_uart_apb 셀 / 면적 | — | 1,361 / 4,356 µm² | 1,104 / 3,941 µm² |

- net 증가 +230 = ECO buffer +280 − 원본의 Innovus hold 셀 50. RC 주석이 빠진 82개(top 포트 ↔ PAD net)는 그대로라 ECO가 만든 검증 공백은 없다.
- Tempus 목표 +10 ps가 배선 후 +1 ps가 됐다. `add_repeater`가 새 buffer의 배선을 추정으로 계산했기 때문이며, ECO에서 margin을 남기는 이유다. 위반은 아니지만 derate · uncertainty를 더하면 음수가 될 수준이다.

## 5. 비교: endpoint ECO vs Innovus 자동 hold fix

| | Innovus `optDesign -hold` (원본) | Tempus endpoint ECO |
|---|---|---|
| 추가 셀 | 50 | 280 |
| setup 손실 (hold fix 전 +0.290 기준) | −0.064 ns | **−0.227 ns** |
| 넣는 위치 | 여러 endpoint가 공유하는 지점 | endpoint 바로 앞, 각각 따로 |
| 통제 | 도구 자동 | 위치 · 셀을 엔지니어가 지정 |

endpoint 단위 처방은 셀 수와 setup 여유 양쪽에서 비싸다. 국소 수정(late ECO, metal-only 등)에 맞는 방식이고, 대량 위반은 P&R 단계 최적화가 효율적이다.

## 6. 남은 것

| 항목 | 상태 |
|---|---|
| LEC (합성 netlist ↔ `uart_chip_top_allpad_eco.v`) | 예정 (buffer만 추가 → Non-eq 0 예상, 미확인) |
| Post-layout GLS (ECO SDF) | 선택 |

## 7. 파일

| 경로 | 내용 |
|---|---|
| `scripts/` | Tempus 루프 · Innovus 적용 · ChipFinish |
| `reports/innovus.eco` | Tempus가 쓴 ECO (`ecoAddRepeater` 280줄) |
| `reports/tempus_eco/` | 00 hold 전 · 10 setup 전 · 20 endpoint별 log · 30 hold 후 · 40 setup 후 |
| `reports/tempus_p2/` | Practice 2: check_timing · parasitics · coverage · setup · hold · violators |
| `reports/innovus/` | timeDesign summary (전 · 후 · final), DRC, conn, area |
