# UART V3 PADALL RO — Init + IO (P&R 준비 단계)

UART V3 칩 레벨 top `uart_chip_top_allpad`(모든 외부 포트에 PAD)를 Innovus에서 **Init → Floorplan → IO 배치 → IO filler**까지 진행한 결과입니다.
최종 P&R(`PNR_10NS_PADALL_RO`, 리포트는 `../reports_10ns_padall_ro/`)에서 쓴 스크립트와 IO 파일을 그대로 사용해, 새 폴더(`PNR_10NS_PADALL_RO_INITIO`)에서 Init + IO만 다시 실행했습니다.

> PDK(GPDK045)의 LEF, LIB, QRC 등 라이브러리 파일은 이 저장소에 포함하지 않습니다. 스크립트에는 서버의 PDK 경로만 적혀 있습니다.

## 1. 입력

| 항목 | 내용 |
|---|---|
| Top | `uart_chip_top_allpad` (단독 UART 테스트 칩 구성) |
| Netlist | Genus 10 ns 합성 결과 (`uart_apb` = read-optimized RTL) |
| Clock | `MAIN_CLOCK` 10 ns (100 MHz) |
| SDC / MMMC | `uart_chip_top_allpad_10ns_pnr.sdc`, `uart_chip_top_allpad.mmmc.view` |
| 표준 셀 / PAD | GPDK045 `gsclib045` / `giolib045` |
| PAD LEF | 수업용 PAD LEF를 바탕으로 PADVDD/PADVSS에 자기 net 가장자리 핀을 추가한 수정본 (서버에만 보관, 비공개) |

## 2. 실행 순서

```tcl
source 0_InitDesign.tcl      ;# init_design -> floorPlan -> io 파일 생성 -> loadIoFile -> respace.tcl -> addIoFiller -> saveDesign InitDesign
checkDesign -all -outdir checkDesign
checkFPlan -outFile checkFPlan.rpt
timeDesign -prePlace -outDir reports/prePlace -prefix prePlace
```

| 단계 | 내용 |
|---|---|
| Floorplan | `floorPlan -site CoreSite -d 1892 1900 30 30 30 30` (PAD 안쪽 30 µm는 core power ring 채널) |
| IO 파일 | `0_InitDesign.tcl`이 netlist의 PAD 인스턴스 이름(PADDI/PADDO)을 읽어 `uart_padall.io`를 생성 |
| IO 간격 | `respace.tcl`: 좌우 변 PAD 사이 간격을 정수 µm로 다시 배분 (1 µm IO filler로 빈틈없이 채우기 위해) |
| IO filler | `addIoFiller` (FEED60/10/5/3/1) |

### Die 크기 결정

1. 한 변 PAD 최대 23개 × 60 µm + corner 240 µm × 2 ≈ 1860 µm → **die 약 1.9 mm (pad-limited)**
2. PAD 사이 간격이 소수 µm가 되면 IO filler 사이에 틈이 남아 IO ring 전원 레일이 끊김 → 가로 1892 µm, 세로 1900 µm로 정하고 `respace.tcl`로 좌우 변 간격을 정수로 맞춤

## 3. PAD 구성

| 변 | 구성 |
|---|---|
| 왼쪽 | 입력 21 + `PVDD_L`, `PVSS_L` |
| 위 | 입력 20 + `PVDDIOR_T`, `PVSSIOR_T` |
| 아래 | 입력 5 + 출력 15 + `PVDDIOR_B`, `PVSSIOR_B` |
| 오른쪽 | 출력 21 + `PVDD_R`, `PVSS_R` |
| 모서리 | `CORNER_TL/TR/BL/BR` |

## 4. 결과

| 항목 | 결과 |
|---|---|
| Die | 1892 × 1900 µm |
| Core | (270, 270.02) ~ (1622, 1629.98) |
| 신호 PAD | 82 (입력 PADDI 46 / 출력 PADDO 36), primary IO port 82 |
| 전원 PAD | 8 (PADVDD 2, PADVSS 2, PADVDDIOR 2, PADVSSIOR 2) |
| Corner / IO filler | 4 / 172 |
| 배치 안 된 PAD·IO 핀 | 0 |
| Floating 포트 / driver 없는 net / 다중 driver | 0 / 0 / 0 |
| Timing 데이터 없는 셀 | 0 |
| prePlace setup (default / reg2reg) | **+3.720 ns / +7.731 ns, 위반 0** |
| Core 사용률 (filler 제외) | 0.198 % (pad-limited) |

prePlace slack이 합성 결과(I2R +3.748 ns, R2R +7.747 ns)와 거의 같으므로 SDC와 MMMC가 정상적으로 적용됐습니다.

### 캡처

`initio_full.gif`(전체 PAD ring), `initio_corner_TL.gif`(왼쪽 위 corner)는 서버에 보관하고 저장소에는 올리지 않았습니다. PAD/셀 형상이 보이는 이미지라 공개 여부를 확인한 뒤 추가합니다.

## 5. checkFPlan / checkDesign 해석

| 항목 | 개수 | 원인 | 판정 |
|---|---|---|---|
| core 꼭짓점이 PlacementGrid 위에 있지 않음 (IMPFP-7238), core row grid | 2 | core 높이 1359.96 µm가 row 높이(1.71 / 3.42 µm)의 정수배가 아님. die 높이를 IO ring 조건에 맞추면서 생긴 결과 | 알려진 제약 (아래 6장) |
| AREAIO PAD가 row와 겹치지 않음 (IMPFP-7244) | 4 | PAD ring에 있는 전원 PAD | INFO, 정상 |
| PG 핀이 없는 라이브러리 셀 | 2 | `SDFF4RX1/2` (이 설계에서 사용하지 않는 셀) | 영향 없음 |
| site 정수배가 아닌 셀 | 1 | `BUFX2` (2단 높이 셀) | 최종 P&R에서 checkPlace 위반 없음 |
| Floating 인스턴스 단자 | 362 | IO filler의 IO ring 트랙 핀 344 + 상수 0이 전파된 PAD 출력 입력핀 17 (`o_prdata[31:16]`, `o_pslverr`) + 리셋 동기화기 첫 플롭 D=1 | 구조상 정상 |
| 출력이 쓰이지 않는 net | 91 | 사용하지 않는 `pwdata[31:16]` 16, 상수 출력 관련 `prdata`/`r_prdata[31:16]` 32, 상수 전파로 생긴 모듈 출력 16, 합성의 미사용 출력 17, FIFO count 10 | 구조상 정상 |
| `VSSIOR : Unrouted` | — | IO ring 전원은 PAD끼리 맞닿아 연결됨. PowerPlan 전 단계 | 정상 |

상수 출력(`o_prdata[31:16]`, `o_pslverr`)은 RTL에서 항상 0인 신호입니다. 칩 단위 LEC(RTL ↔ 합성)에서 386/386 Equivalent로 확인했습니다.

## 6. 알려진 제약과 다음 단계

- **Core grid 경고 2건:** die 높이 1900 µm는 IO ring 조건은 만족하지만 core row 조건은 만족하지 못합니다. core 높이만 row 정수배로 바꾸면 툴이 die를 1900.06 µm로 보정해 corner 전원 연결이 끊기는 것을 확인했습니다(채택하지 않음). 두 조건을 함께 만족하는 die 크기를 찾는 것이 후속 과제입니다.
- **전원 연결:** 최종 P&R 기준 connectivity info 8건(IO ring 전원 abutment 판정 2, corner 경계 레일 6). LVS로 칩 전원 무결성을 확인하지 않았습니다.
- **개선 후보:** clock PAD(`u_pad_clk`)가 이름순 자동 배치로 위쪽 변 끝에 놓였습니다. 로직과 가까운 위치로 옮기는 것을 검토합니다.

## 7. 파일

| 파일 | 내용 |
|---|---|
| `0_InitDesign.tcl` | Init, floorplan, IO 파일 생성/로드, IO filler |
| `respace.tcl` | 좌우 변 PAD 간격 정수화 |
| `uart_padall.io` | IO 배치 파일 |
| `initio_check.tcl` | 이 폴더의 확인 스크립트 (checkDesign, checkFPlan, prePlace timing, 캡처) |
| `initio_summary.txt` | die/core, PAD 종류별 개수 |
| `checkFPlan.rpt`, `checkDesign/` | 검사 리포트 |
| `reports/prePlace/` | prePlace timing |

올리지 않는 파일: PAD LEF 수정본, `InitDesign.dat`(라이브러리 링크 포함), netlist, 로그, 캡처 이미지.

서버 위치: `~/PROJ1/proj1_make/TOP/PNR_10NS_PADALL_RO_INITIO/`
