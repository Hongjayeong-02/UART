# UART V3 — APB3 UART Peripheral IP

APB3 slave UART IP. 8개 memory-mapped register, TX/RX FIFO(depth 8, parameterized), 7/8-bit data,
even/odd parity, 1/2 stop bit, RX data / parity·frame error / overflow interrupt(W1C), internal loopback.


## 폴더

| 폴더 | 내용 |
|---|---|
| `1_rtl/` | **최종 RTL (⑨ = ⑦ + reset synchronizer)**. top: `uart_apb`(peripheral), `uart_chip_top`(RX/TX PAD) |
| `1_rtl_pad/` | `uart_chip_top_allpad.v`: 외부 포트 82개 전부 PAD (PADDI 46 · PADDO 36), 10 ns 칩 레벨 P&R용 |
| `patches/` | 원본 → ③ → ④ → ⑦ → ⑨ 단계별 `diff -ruN`, ⑤ 기각안, ⑧ 미채택안 |
| `2_tb/` | `tb_uart_v3_final.v`(regression 33 checks), `tb_uart_v3_final_gl.v`(같은 33 checks, 내부 신호 참조 없음 → gate-level용), `mcp_checker.sv`(MCP 근거 assertion), GLS·PAD TB |
| `3_syn/` | 1 GHz SDC(`cons/`), Genus 스크립트(`script/`), 핵심 리포트(④ `opt4`, ⑦ `pipe7`, ⑧ `rxp8`, ⑨ `rsync9`, 계층 유지 `hier`) · **10 ns**: `uart_v3_10ns.sdc`, `uart_v3_10ns_pad.sdc`, `run_synthesis_10ns_{rsync,pad2,padall}.tcl`, `reports/10ns_*` |
| `4_pnr/` | Innovus 스크립트 0~5, MMMC(cap table 제거본), P&R SDC, sweep 스크립트, MCP what-if(`scripts/mcp_whatif.tcl`), 리포트(**최종 ⑨ QRC `reports_rsync9_qrc/`**, ⑦ QRC `reports_pipe7_qrc/`, cap table flow: ⑦ `reports_pipe7/`, ⑧ `reports_rxp8/`, ⑨ `reports_rsync9/`) |
| `4_pnr/` (10 ns) | `scripts_10ns/`(V3: 바뀐 파일만 · hold 목표 · rst_n false path SDC), `scripts_padall/`(PAD top 전체 flow, IO 파일 생성 · modify LEF), `reports_10ns_v3/`, `reports_10ns_padall/` (각 `run1/` = 1차) |
| `5_gls/` | post-layout GLS용 SDF 설정 (smoke: max / min / recrem split, gate-level regression: `gl_max` / `gl_min`, ⑨ QRC: `glq_max` / `glq_min`) |
| `6_verify/` | regression 결과(`regression/*_pf.txt`), 동등성 비교 TB(`equivalence/`), 면적 합산 `area.awk`, **Conformal LEC**(`lec/`: dofile 2개 · log 2개) |

## 바로 돌려 보기 (Icarus Verilog)

```sh
cd UART_V3
make regress   # 최종 RTL에 33-check regression → 서버(Xcelium) 결과와 diff
make gl        # gate-level용 TB를 RTL에 실행 → regress와 diff
make mcp       # MCP 근거 assertion
make eq        # ③ vs ④ FIFO·TX 랜덤 비교, 원본 vs ④ FIFO reset 동등성
```

## 서버 flow (Cadence)

스크립트는 학교 서버의 디렉터리 구조를 기준으로 작성되어 있다. 이 저장소와의 대응:

| 서버 (`~/PROJ1/proj1_make/TOP/`) | 저장소 |
|---|---|
| `RTL/UART_V3_rsync/` | `1_rtl/` |
| `SIM/TESTBENCH/UART_V3/` | `2_tb/` |
| `SYN/cons`, `SYN/script` | `3_syn/cons`, `3_syn/script` |
| `PNR_1GHZ_RSYNC_QRC/` (최종 ⑨), `PNR_1GHZ_PIPE_QRC/` (⑦), `PNR_1GHZ_RSYNC/`·`PNR_1GHZ_PIPE/` (cap table flow) | `4_pnr/scripts/` |
| `SIM/POST_1GHZ/`, `SIM/GL_RSYNC/` | `5_gls/` |
| `PNR_10NS_V3/`, `PNR_10NS_PADALL/` | `4_pnr/scripts_10ns/`, `4_pnr/scripts_padall/` |
| `RTL/UART_V3_padall/` | `1_rtl/` + `1_rtl_pad/` |
| (수업 서버) `EC_10ns/` | `6_verify/lec/` |

```tcsh
# regression (Xcelium)
xrun -64bit -clean -access +r -timescale 1ns/1ps ../TESTBENCH/UART_V3/tb_uart_v3_final.v -y ../../RTL/UART_V3_rsync +libext+.v -l rsync.log
# synthesis
genus -files script/run_synthesis_1ghz_rsync.tcl -log syn_rsync
# P&R
innovus -nowin -log run_all.log < run_all.tcl >& console.log
# post-layout GLS (SS SDF)
xrun -64bit -clean -access +rwc -neg_tchk -sdf_verbose -sdf_cmd_file sdf_max.cmd -top tb_uart_v3_gls \
     ../TESTBENCH/UART_V3/tb_uart_v3_post_gls.v ../../PNR_1GHZ/outputs/uart_apb_pnr.v <GPDK045 cell verilog> -l gls_max.log
# gate-level regression — 최종 ⑨ QRC (SS SDF). min은 glq_min.cmd
xrun -64bit -clean -access +r -neg_tchk -sdf_verbose -sdf_cmd_file glq_max.cmd -define NO_DUMP -top tb_uart_v3_final_gl \
     ../TESTBENCH/UART_V3/tb_uart_v3_final_gl.v ../../PNR_1GHZ_RSYNC_QRC/outputs/uart_apb_pnr.v <GPDK045 cell verilog> -l glq_max.log
# (이전 cap table flow 기록: gl_max.cmd / gl_min.cmd + PNR_1GHZ_RSYNC)
```

MCP what-if는 ChipFinish DB를 연 뒤 `set_interactive_constraint_modes [all_constraint_modes -active]` → `source mcp_whatif.tcl` 순서로 실행한다
(interactive mode를 지정하지 않으면 SDC 명령이 반영되지 않는다).

## RC 설정 (cap table flow → QRC flow)

처음 MMMC의 RC corner에는 `gpdk045.tch`와 함께 28 nm용 cap table(`-cap_table ...capTbl`)이 지정돼 있었다(Innovus IMPEXT-6202 경고).
배선 후 추출은 두 경우 모두 TQuantus + `gpdk045.tch`였지만, 배치·CTS 단계의 preRoute 추정은 cap table을 썼다.
`sed -i '/-cap_table/d' uart_apb.mmmc.view`로 두 줄만 지우고 RTL·SDC·util은 그대로 재실행했다(`_QRC` 폴더). 저장소의 `uart_apb.mmmc.view`는 제거본이다.

| R2R TNS (ns) | postCTS 예측 | postRoute 실제 | R2R WNS | area (µm²) |
|---|---|---|---|---|
| ⑦ cap table | −13.03 | −3.82 | −77 | 6,676 |
| ⑨ cap table | −12.74 | −5.15 | −110 | 6,400 |
| ⑦ QRC | −6.48 | −7.91 | −116 | 6,204 |
| **⑨ QRC (최종)** | −6.40 | −6.97 | **−97** | **5,830** |

cap table flow는 배선 전 예측이 비관적이라 셀이 과하게 upsizing됐다. run은 조건마다 1회씩이다.

## check_timing (최종 ⑨ QRC, `4_pnr/reports_rsync9_qrc/check_timing.rpt`)

unconstrained endpoint 19개는 모두 의도된 항목이다: `o_prdata[31:16]` 16개 · `o_pslverr`(TIELO 상수 출력), `o_uartTx`(false path), `r_rstSync_reg[0]/D`(상수 1 입력). 그 밖에 `clk` no drive, `i_uartRx` no input delay(false path). 전체 최악 경로는 `i_paddr[2] → o_prdata[6]`(APB 읽기 입력 → 출력 조합 경로, `worst_all.rpt`).

`5_gls/*.cmd`의 `SDF_FILE`은 학교 서버의 절대 경로(`/home/hah006/...`)다. 다른 환경에서는 SDF 경로를 바꿔야 한다.

10 ns · PAD · LEC 결과 요약은 저장소 루트 README의 "과제 조건 10 ns" 절.

GPDK045 라이브러리(.lib/.lef/capTbl), netlist, SDF, GDS, Innovus DB는 라이선스·용량 때문에 포함하지 않는다.
