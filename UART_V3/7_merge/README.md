# Merge · Stream Out (Virtuoso) · V3 5 ns PAD top

교재 2권 13장 흐름: design GDS(팬텀 셀) → 표준셀 GDS → IO GDS 순으로 같은 라이브러리에 Stream In(동일 이름 셀 Overwrite) → SEALRING · Move Origin · LOGO → Stream Out.

## 1. layer map: 교재에서 막힌 지점을 해결

교재는 design GDS를 Innovus 기본 `streamOut`(map 지정 없음)으로 뽑아 Stream In 하고, 대량 경고와 "Metal이 Via 레이어로 잡히는" 현상을 교육용 PDK의 한계로 정리한다(13.3.1). 같은 방식으로 재현한 뒤 원인을 확인했다.

| | Innovus 자동 map (1차) | PDK Innovus map `soce/streamOut.map` (2차) |
|---|---|---|
| design GDS 크기 | 29.0 MB | 5.7 MB |
| Stream In warning | 182,170 | **113** |
| XSTRM-36 (도형 무시) | 182,058 | **1** (`235:0` = DIEAREA) |
| XSTRM-267 (참조 셀 없음) | 111 | 111 (표준셀 · IO Stream In으로 채워짐) |

- 원인: `streamOut`에 `-mapFile`이 없으면 Innovus가 자체 순번 map을 만든다(예: Metal1 NET = 8). PDK Virtuoso layermap에서 8은 Via1이다. 번호가 없는 층은 버려지고, 번호가 겹치는 층은 **다른 레이어로 들어간다**.
- 버려진 18.2만 개 중 17.6만 개는 `NAME COMP`(232) · `COMP ALL`(233), 즉 셀 이름 · 경계 표시용이었다.
- 해결: PDK가 제공하는 Innovus 형식 map으로 design GDS만 다시 출력([`scripts/stream_pdkmap.tcl`](scripts/stream_pdkmap.tcl)). Virtuoso용 PDK Virtuoso layermap은 Stream In / Out에만 쓴다.
- 같은 map이 [§7.6](../../docs/UART_V3/ro5_200mhz.md) PVS DRC 21,648 → 826의 원인이기도 했다.

## 2. Stream In (Library `UART_MERGE`, Attach Tech = PDK tech library, PDK Virtuoso layermap)

| 순서 | 파일 | error | warning |
|---|---|---|---|
| ① | design GDS (PDK map) | 0 | 113 (267 ×111 · 36 ×1 DIEAREA · 75 ×1) |
| ② | 표준셀 GDS | 0 | 로그 미보존 (화면에서 셀 내부 채워짐 확인) |
| ③ | IO GDS | 0 | 3 (107 Overwrite 안내 · 207 IO 셀 내부 짧은 path · 75) |

관찰: 표준셀 · filler · PAD 내부 패턴이 채워짐. corner 셀 안에서 IO ring Metal이 L자로 끊김 없이 이어짐 → Innovus `verifyConnectivity`의 corner open(§7.8)이 도구상 판정임을 GDS로 확인.

## 3. SEALRING · Move Origin · LOGO (교재 13.3.2)

| 항목 | 방법 | 결과 (최종 GDS에서 확인) |
|---|---|---|
| SEALRING | SEALRING(66:0) 사각형, (−10, −10) ~ (1902, 1910) | 1개, (0, 0) ~ (1912, 1920) |
| Move Origin | (−10, −10) → (0, 0) | 칩 1912 × 1920 µm |
| LOGO | LOGO(67:0) 4 µm 픽셀 "UART" 셀([`scripts/uart_logo.il`](scripts/uart_logo.il)), 왼쪽 아래 빈 영역에 instance | `UART_LOGO` 사각형 62개, 92 × 28 µm |

원래 die는 (0, 0) ~ (1892, 1900) µm.

## 4. Stream Out

`uart_chip_final.gds` (65.8 MB) · **0 error**, warning 1 (XSTRM-20 기존 파일 덮어쓰기). 교재 실측은 0 error · 138 warning.

## 5. Sign-off DRC (PVS, 최종 GDS)

§7.6과 같은 rule deck · 실행 옵션(`pvs -drc -dp 4`), 입력만 `uart_chip_final.gds`로 교체.

| Rule | §7.6 (Innovus `-merge` GDS) | 최종 GDS (Virtuoso merge + SEALRING · LOGO) |
|---|---|---|
| METAL4.SP.1.6 | 276 | 276 |
| METAL4.W.2 | 454 | 454 |
| soft_check_4 | 95 | 95 |
| soft_check_5 | 1 | 1 |
| 합계 | 826 | **826** |

Merge 경로(Innovus `streamOut -merge` ↔ Virtuoso Stream In ×3)가 달라도 같은 결과 → 두 도면의 도형이 같다. SEALRING · LOGO · 원점 이동으로 새로 생긴 위반 0. 남은 826건은 §7.6에서 분류한 PAD ring Metal4 항목이다.

## 6. 남은 것

| 항목 | 상태 |
|---|---|
| re-stream (최종 GDS를 새 라이브러리로 다시 읽기) | 선택 |
| LVS | §7.10: IO 기판 모델링으로 미통과 |
