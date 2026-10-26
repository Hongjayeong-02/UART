# UART V3 Conformal LEC 실행 Runbook

| 항목 | 상태 |
|---|---|
| Conformal 실제 실행 | **완료 (2026-10-26, 수업 서버)** |
| RTL ⑨ ↔ 10 ns 합성 netlist (`uart_apb`) | **PASS** (Equivalent 368, Non-eq 0, Abort 0) |
| 합성 netlist ↔ P&R netlist | 미실행 |
| dofile · log | `UART_V3/6_verify/lec/` (`run_lec.do` 1차, `run_lec2.do` 2차) |

## 실행 결과 (2026-10-26)

| | 1차 `run_lec.do` | 2차 `run_lec2.do` |
|---|---|---|
| 추가 설정 | `set flatten model -seq_constant` | + `-seq_constant_x_to 0`, `set analyze option -auto` |
| Compare Results | FAIL:NONEQ | **PASS** |
| Equivalent | PO 36 + DFF 330 = 366 | PO 36 + DFF 332 = **368** |
| Non-equivalent | 2 (`uut_tx_fifo/r_fifoRdEn_reg`, `uut_tx_fifo/r_state_reg[0]`) | 0 |
| Not-mapped DFF | 1 (`uut_tx/o_txReady_reg`) | 0 |
| Inverted-equivalent | — | 1 (sequential merge) |
| Unreachable DFF | 2 | 2 (`uut_rx/o_falseStart_reg`, `uut_rx/o_rxBusy_reg`) |

- 원인: `o_txReady`는 모든 state에서 `~o_txBusy`라 Genus가 flop을 하나로 합쳤다. LEC는 golden의 `o_txReady_reg` 짝을 못 찾아 자유 입력으로 보고, 이를 쓰는 TX FIFO flop 2개를 Non-eq로 냈다. `set analyze option -auto`가 "Modeling sequential merge"로 처리.
- Unreachable 2개는 상위 모듈에서 쓰지 않는 RX 상태 출력이라 Genus가 삭제. 기능 문제 아님 (RTL 정리 후보).
- Golden 파일: `uart_apb` 아래 10개. `uart_chip_top.v`(PAD top), `uart_v2_top.v`(옛 wrapper)는 다른 top이라 제외.
- 원본 RTL → ③ 사이의 FIFO 저장칸 reset 변경은 이 LEC의 범위가 아니다(⑨ RTL ↔ ⑨ netlist 비교).

---

아래는 실행 전에 작성한 계획(1 MHz PAD netlist 기준 템플릿)이다.

> 이 문서의 dofile은 보고서에 남은 발췌본을 바탕으로 **구조를 정리한 템플릿**이다. 서버 원본(`run_lec.do`)이 아니다. 실행 전에 반드시 원본과 비교한다.

---

## 1. 목적

- **Golden**: UART V3 RTL (`uart_chip_top`)
- **Revised**: Genus 합성 netlist `../SYN/netlist_pad/uart_chip_top_netlist.v`
- 확인하려는 것: 합성 과정에서 기능이 바뀌지 않았는지 (RTL ≡ Gate netlist)

LEC는 시뮬레이션처럼 입력 벡터에 의존하지 않는다. 모든 compare point(flop, output 등)를 형식적으로(formal) 비교하므로, GLS smoke test로는 증명할 수 없는 "모든 입력에서 같다"를 보장한다.

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| 작업 서버 | hah006 (작성) |
| LEC 실행 서버 | hitech001 (수업 시간에만 사용 가능) |
| 원본 경로 | `/home/hah006/PROJ1/proj1_make/TOP/EC/script/run_lec.do` |
| 실행 디렉터리 | `.../TOP/EC/` (dofile 안의 상대경로 `../SYN/...`, `./log/` 기준) |

## 3. 수업 전 체크리스트 (hah006에서 미리)

- [ ] `cat .../EC/script/run_lec.do`로 원본 확인, `...`로 생략된 부분 채우기
- [ ] Golden RTL 파일 목록이 **합성에 실제로 사용한 파일과 같은지** 확인 (Genus 스크립트의 `read_hdl` 목록과 대조)
- [ ] Revised netlist가 **최종 합성 결과**인지 확인 (타임스탬프, `ls -l`)
- [ ] Library: std cell `.lib`(또는 Verilog model) **+ PAD cell 라이브러리** 경로 확인. `uart_chip_top`은 PAD를 포함하므로 PAD 셀 정의가 없으면 black box로 처리된다
- [ ] hitech001로 옮길 파일 목록 정리 (RTL, netlist, lib, dofile). 상대경로 구조를 그대로 유지
- [ ] `EC/log/` 디렉터리 존재 확인 (`set log file ./log/...`가 디렉터리를 만들지 않음)

## 4. Dofile 템플릿

```tcl
// ===== run_lec.do (템플릿, 원본과 대조 필요) =====
set log file ./log/uart_v3_lec.log -replace

// 1) Library: golden/revised 양쪽에 동일하게
read library -liberty -both \
    <std_cell_slow.lib> \
    <pad_cell.lib>
//   (원본은 -verilog -both: Verilog cell model을 쓰는 경우)

// 2) Golden RTL
read design -verilog -golden \
    <rtl 파일 목록 ...>
set root module uart_chip_top -golden

// 3) Revised netlist
read design -verilog -revised \
    ../SYN/netlist_pad/uart_chip_top_netlist.v
set root module uart_chip_top -revised

// 4) 읽기 결과 점검 (mode 전환 전)
report design data
report black box
report rule check -verbose

// 5) Mapping + 비교
set system mode lec
report unmapped points -summary
add compare points -all
compare

// 6) 결과
report verification
report statistics
report compare data -class nonequivalent
report compare data -class abort

exit -force
```

## 5. 실행 명령 (hitech001)

```bash
cd <...>/TOP/EC
mkdir -p log
lec -XL -nogui -dofile script/run_lec.do
# 라이선스 옵션(-XL / -LP 등)은 수업에서 쓰는 옵션을 따른다
```

## 6. 결과 판정 기준

| 항목 | PASS 조건 |
|---|---|
| Non-equivalent | 0 |
| Aborted | 0 |
| Equivalent | 전체 compare point와 일치 |
| Unmapped points | 0이 아니면 **각각 원인을 설명할 수 있어야 함** (예: 합성에서 제거된 상수 flop) |
| Black box | PAD 등 의도한 것만 존재. 의도하지 않은 black box는 비교 범위가 빠진 것 |
| Rule check | Error 0, Warning은 내용 확인 |

**`compare` 결과에 Non-equivalent가 0이어도, 의도하지 않은 black box나 설명되지 않는 unmapped point가 있으면 PASS로 기록하지 않는다.** 비교 대상에서 빠진 로직은 검증되지 않은 것이다.

## 7. 실패 시 1차 확인

| 증상 | 가능한 원인 | 확인 |
|---|---|---|
| Unmapped point 다수 | flop 이름 규칙 차이, 합성 중 상수 flop 제거 | `report unmapped points -notmapped` |
| Non-equivalent | RTL 파일 버전 불일치, 합성 옵션(예: 최적화로 바뀐 reset 동작) | `report compare data -class nonequivalent`, `diagnose` |
| 의도하지 않은 black box | library 누락 (특히 PAD) | `report black box` |
| Abort | 복잡한 logic cone | 이 크기의 설계에서는 드묾. 발생 시 기록 후 문의 |

## 8. 이후 단계: P&R 후 LEC

P&R에서 ECO 셀 교체(`BUFX2` → `BUFX3`, `pnr_placement_issue.md` 참고)와 최적화 buffer 삽입이 있었으므로, 다음 비교도 필요하다.

- **Golden**: 합성 netlist
- **Revised**: Innovus `saveNetlist`로 저장한 P&R 후 netlist

RTL 대 합성 LEC만으로는 P&R 단계의 netlist 변경을 보장하지 못한다.

## 9. 실행 기록 (실행 후 작성)

| 일자 | 서버 | Equivalent | Non-eq | Abort | Unmapped | Black box | 판정 |
|---|---|---|---|---|---|---|---|
| | hitech001 | | | | | | |
