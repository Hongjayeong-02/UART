# UART V3 PADALL RO — 10 ns 칩 레벨 합성 결과

칩 top `uart_chip_top_allpad`(외부 포트 82개 전부 PAD)를 10 ns(100 MHz)로 Genus 합성한 결과입니다.
기존 PADALL 합성에서 I/O 경로 setup 위반이 남아, APB read 응답을 레지스터 출력으로 바꾼 **RO(read-optimized) RTL**로 다시 합성했습니다.

> PDK의 LIB, LEF, DB 등 라이브러리 파일과 합성 netlist는 저장소에 넣지 않았습니다. 스크립트에는 PDK 경로만 적혀 있습니다. 스크립트와 리포트의 PDK 경로·라이브러리 이름은 `<PDK>`, `stdlib`/`iolib`, `std_ss`/`std_ff`, `io_ss`/`io_ff`, `qrc.tch`로 바꿔 적었습니다(실행 시 실제 경로로 치환).

## 1. 합성 조건

| 항목 | 내용 |
|---|---|
| Top | `uart_chip_top_allpad` (PADDI 46, PADDO 36) |
| RTL | `1_rtl_ro/uart_apb.v` (RO, md5 `fccbe021850ac319edccb5d0f9f7ffe8`) + 나머지 모듈은 `1_rtl/`과 동일, PAD top은 `1_rtl_pad/` |
| 라이브러리 | 45 nm PDK `std_ss` (표준 셀) + `io_ss` (PAD), PVT_0P9V_125C |
| SDC | `cons/uart_v3_10ns_pad.sdc`: clock 10 ns, input delay 4 ns, output delay 4 ns, uncertainty 0.1 ns |
| 스크립트 | `script/run_synthesis_10ns_padall_ro.tcl` |
| 리포트 | `reports/10ns_padall_ro/` (`area.rpt`, `qor.rpt`, `timing.rpt`) |

### I/O 경로 예산 (budget)

PAD 입력에서 조합 논리를 거쳐 PAD 출력으로 바로 가는 경로(I2O)는 한 주기 안에 끝나야 합니다.

```
10 ns (clock) - 4 ns (input delay) - 4 ns (output delay) - 0.1 ns (uncertainty) = 1.9 ns
```

PADDI + read 주소 decode + read mux + PADDO가 이 1.9 ns 안에 들어와야 합니다.

## 2. 왜 RO로 바꿨나

기존 V3 `uart_apb`는 `PRDATA`/`PREADY`/`PSLVERR`를 `PADDR`/`PWRITE`에서 조합 논리로 만들었습니다.
모든 포트에 PAD를 붙이면 `i_paddr` PAD → decode → read mux → `o_prdata` PAD가 한 주기 경로가 됩니다.

| 기존 PADALL (`reports/10ns_padall/`) | 값 |
|---|---|
| 합성 I2O worst slack | **−81.8 ps** (`i_paddr[2]` → `o_prdata[3]`) |
| 합성 I2O 위반 경로 / TNS | 16 / −1077.1 ps |
| P&R 후 setup WNS (`4_pnr/reports_10ns_padall/final.summary.txt`) | **−0.321 ns, 위반 17** |

constraint를 완화하는 대신 설계를 바꿨습니다. 실제 칩에서 PAD 지연은 줄일 수 없고, I/O delay는 보드 쪽 가정이기 때문입니다.

RO의 동작은 다음과 같습니다.

- 모든 read에 wait state 1개 추가 (V3에서 RX_DATA read가 이미 쓰던 방식과 같음)
- ACCESS1에서 read mux 값을 `r_prdata`에 저장하고 `PREADY=0`. ACCESS2에서 `PREADY=1`, `PRDATA`는 플롭 출력
- write는 그대로 zero-wait
- RX FIFO pop은 ACCESS1에서만 (`!r_pready` 조건). 이 조건이 없으면 빈 FIFO를 읽는 ACCESS2 동안 들어온 바이트가 pop되어 사라지는 문제를 비교 TB(`6_verify/read_opt/`)로 찾았습니다.
- 비용: read 1회당 +1 clock (RX_DATA는 V3와 같음)

## 3. 결과

### Timing (`reports/10ns_padall_ro/qor.rpt`, 단위 ps)

| Path group | 기존 PADALL | **RO** |
|---|---|---|
| I2O | −81.8 (위반 16) | **No paths** |
| I2R | 3846.3 | 3748.0 |
| R2O | 4099.1 | 4404.3 |
| R2R | 7785.0 | 7747.4 |
| TNS | −1077.1 | **0** |

I2O 경로가 없어졌다는 것은 입력 PAD에서 출력 PAD로 가는 조합 경로가 남지 않았다는 뜻입니다. PRDATA/PREADY는 플롭에서만 나옵니다.

`PSLVERR`의 write error는 아직 조합 경로입니다. 다만 `STRICT_APB_ERR=1`일 때만 존재하고, 기본값 0에서는 상수 0이라 경로가 없습니다.

### Area / Cell (`reports/10ns_padall_ro/area.rpt`)

| 항목 | 기존 PADALL | **RO** |
|---|---|---|
| Leaf instance | 1217 | **1064** (`uart_apb` 982 + PAD 82) |
| Total cell area (µm²) | 791,092.576 | **790,835.460** |
| `uart_apb` area (µm²) | 3,892.576 (계산값) | **3,635.460** |

PAD 82개의 면적이 787,200 µm²로 전체 면적의 대부분입니다(pad-limited). 기존 `uart_apb` 면적은 전체에서 PAD 면적을 뺀 계산값입니다.
RO에서 core 면적이 약 6.6 % 줄었습니다. 플롭은 늘었지만 I/O 1.9 ns를 맞추려고 넣던 고속 셀이 필요 없어진 것으로 보입니다. 셀 종류별 비교(`report_gates`)로는 아직 확인하지 않았습니다.

## 4. 이후 단계에서 확인한 것

| 항목 | 결과 | 위치 |
|---|---|---|
| P&R (같은 RO netlist) | setup +3.128 ns, hold +0.020 ns, DRC 0 | `4_pnr/reports_10ns_padall_ro/` |
| Init + IO (P&R 준비) | 별도 정리 | `4_pnr/init_io/README.md` |

## 5. 확인하지 않은 것

- RO RTL의 `STRICT_APB_ERR=1` 설정은 Xcelium에서 검증하지 않았습니다.
- 칩 단위 전원 무결성(LVS)은 확인하지 않았습니다.
- 위 결과는 SS corner 한 가지 조건의 합성/P&R 결과이며 signoff 완료를 뜻하지 않습니다.

## 6. 재실행

```tcsh
cd ~/PROJ1/proj1_make/TOP/SYN
genus -files script/run_synthesis_10ns_padall_ro.tcl -log syn_padall_ro
```
