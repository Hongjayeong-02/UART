# UART V3 ⑩ · 1 GHz R2R 구조 최적화

> **Target: 1 GHz R2R closure · Not achieved.**
> 대표 결과 ⑩-E: post-route R2R WNS **−97 → −46 ps**, TNS **−6.970 → −1.609 ns (−77 %)**, 위반 경로 187 → 91.
> SDC · corner · P&R 스크립트는 ⑨ QRC와 같다(RTL만 변경). hold 0 · DRC 0 · LEC PASS · gate-level regression 33/33.

⑨ QRC를 기준으로, 기존 제약을 그대로 둔 채 **RTL 구조 변경만으로** 1 GHz register-to-register 경로를 줄인 실험이다.
I/O 경로(전체 WNS 약 −1.0 ns)는 대상이 아니다. SDC가 입력 600 ps + 출력 600 ps + uncertainty 100 ps를 잡아 로직이 0이어도 −300 ps이고, clk→Q 305 ps까지 더하면 출력을 레지스터로 끊어도 닫히지 않는다(설계가 아니라 I/O 예산 가정의 문제).

## 1. 단계별 변경

| 단계 | 변경 | 겨냥한 ⑨ P&R 경로 | patch |
|---|---|---|---|
| ⑩-A | baud: terminal count lookahead (`r_cntLast`), `BAUDDIV−1`/`==0` 레지스터, **BAUDDIV 변경 시 카운터 재시작** | `r_clkCnt` 16-bit 비교 → reset MUX | `07` |
| ⑩-B | TX/RX: `r_tickLast` · `r_tickMid` · `r_bitLast` lookahead flag (카운터가 0이 되거나 증가하는 모든 자리에서 같이 갱신 → `flag == (count == N)`이 항상 성립, MCP 가정 불필요) | FSM next-state 안의 4/3-bit 비교 | `07` |
| ⑩-C | TX/RX 데이터 shift register (RX 7-bit는 [6]으로 입력), TX FIFO `o_rdData` 로드를 `w_rdEn` 단독 always로 분리 | `r_bitCnt+1` + 8:1 MUX, write decoder, FIFO enable | `07` |
| ⑩-D | RX parity 누적(`r_parityAcc`, ⑧ 미채택안 재사용), RX FIFO 읽기 레지스터 분리 | `r_rxData → r_parityErr` 8-input XOR, RX FIFO enable | `08` |
| ⑩-E | `uart_core`의 TX 쓰기 재게이팅 제거: `w_txWrEn = i_txWrEn` | ⑩-D P&R 상위 50개 중 34개가 `r_uartEn → TX FIFO r_mem/SE` | `09` |
| ⑩-F | baud 8+8 분할 다운카운터(borrow 레지스터 `r_lowZero`, `r_divM1` 삭제), tick TX/RX 복제 | ⑩-E P&R의 16-bit carry 체인, tick fanout | `10` |

- ⑤ one-hot FSM은 이전에 기각된 안이라 이번에도 쓰지 않았다.
- ⑩-E의 전제: `r_txPush`는 APB 쓰기를 받는 cycle(N)에 이미 `r_uartEn && r_txEn`으로 조건이 걸리고, push는 N+1에 일어난다. CTRL을 바꾸는 APB 전송은 최소 2 cycle이라 그 사이에 바뀔 수 없다(⑦ 설계 주석과 같은 근거). TB assertion으로 확인했다(아래 3절).
- ⑨ → ⑩-E 전체 diff: `patches/11_9_to_10e_total.diff` (6 files).

## 2. ⑨ 기능 버그: BAUDDIV 실행 중 변경 시 65,536-cycle stall

⑩-A 리뷰에서 lookahead의 반례(BAUDDIV를 줄이는 시점에 terminal count를 놓침)가 나왔다. 같은 입력을 ⑨에 넣어 보니 **⑨도 같은 종류의 문제**가 있었다.

- ⑨는 `r_clkCnt == i_baudDiv`를 매 cycle 비교한다. 새 BAUDDIV가 현재 카운트보다 작으면 일치할 때까지 16-bit 카운터가 한 바퀴(65,536 cycle) 돈다.
- 8 → 3 변경, 쓰는 시점 cnt 0~8: ⑨는 cnt 4~8에서 stall. ⑩-A 첫 버전은 cnt 2~3에서 stall.
- 무작위 400건(이전·새 값 1~32, 쓰는 시점 무작위): **⑨ 113/400이 늦거나 stall**.

⑩은 "⑨와 동등"이 아니라 **변경을 감지해 카운터를 재시작**하도록 고쳤다(`r_divD`, `r_divChg`, 감지 비교는 레지스터에 저장 → 카운터 critical path에는 플롭 출력 OR 하나).
- 쓰기 후 2 cycle 안에는 이전 설정의 마지막 tick이 한 번 나올 수 있다(감지 지연).
- 그 뒤 첫 tick은 쓰기 후 (새 값 + 4) cycle 이내, 이후 주기 (새 값 + 1). stall 없음.
- ⑨와 다른 것은 **UART가 켜진 상태에서 BAUDDIV를 바꿀 때뿐**이다(스펙 변경).

> 10 ns 과제 결과(블록, PAD top RO)는 ⑨ RTL 기준이라 이 버그를 그대로 갖고 있다. 결과는 다시 돌리지 않았다.

## 3. 검증

| 항목 | 방법 | 결과 |
|---|---|---|
| regression | `tb_uart_v3_final` 33 checks (Xcelium · iverilog) | 33/33, 종료 시각 ⑨와 동일 (471,469,250 ps) |
| lockstep | ⑨와 ⑩ 모듈을 같은 TB에 두고 같은 입력, 출력 5개(`o_prdata`, `o_pready`, `o_pslverr`, `o_uartTx`, `o_irq`)를 매 cycle 비교. 모든 포맷 · BAUDDIV 0~3 · 내부/외부 loopback · random line · 실행 중 CTRL 변경 · TX_DATA 직후 CTRL 변경(back-to-back) · 직접 self-check 144건 | seed당 약 20만 cycle, **불일치 0** (BAUDDIV는 UART를 끈 상태에서만 바꿈 = 동등성 주장 범위) |
| ⑩-E 전제 | ⑨ 쪽에 assertion: push가 core에 도착하는 cycle마다 `r_uartEn && r_txEn == 1` | push 약 250회/seed, 위반 0. ⑨ APB에서 `r_uartEn` 조건을 일부러 빼면 위반 111건 (검사기 동작 확인) |
| live BAUDDIV | 고정 0~40 주기, 실행 중 변경 400건 (`tb_baud_live*.v`) | ⑩ 오류 0, ⑨ 113/400 stall |
| 큰 BAUDDIV (⑩-F) | 255/256/257/325/511/512/4096/0x1234 등 16개 고정값(enable 후 첫 tick이 ⑨와 cycle 단위로 같은지 포함), 200~1223 사이 변경 60건 (`tb_baud_big.v`) | 108 checks 오류 0 |
| mutation | 일부러 넣은 버그로 검사기가 잡는지 확인 | lookahead · shift · parity · baud borrow 등 대부분 검출. 미검출 1종(빈 FIFO 읽기 enable)은 APB 응답이 0으로 고정돼 관측 불가한 경우 |
| LEC (⑩-E) | Conformal, `-seq_constant_x_to 0`, `analyze option -auto` | RTL → 합성 **PASS**, 합성 → P&R **PASS** (PO 36 + DFF 374 = 410, Non-eq 0, Abort 0; RTL→합성 Unreachable DFF 2개 — ⑨ 10 ns LEC와 같은 수, 이번 dofile은 -notmapped만 출력해 이름은 확인하지 않음) |
| GLS (⑩-E) | ⑨ QRC와 같은 명령 (`tb_uart_v3_final_gl`, TB clock 48 MHz, SS/FF SDF) | SS 33/33 · FF 33/33, RTL과 PASS/FAIL 목록 동일, timing violation 0. SDFNET 181 → 222 (+41 = 추가된 async-reset 플롭 수), SDFNDP(FF) 4 → 12 |

## 4. 합성 (Genus, 1 GHz, SS, 같은 SDC)

| | ⑨ | ⑩ (A–C) | ⑩-D | **⑩-E** | ⑩-E OC | ⑩-F | ⑩-F OC |
|---|---|---|---|---|---|---|---|
| R2R WNS (ps) | −55.1 | −42.3 | 0.0 | **+0.1** | −31.1 | 0.0 | −26.3 |
| R2R TNS (ps) | −806.6 | −437.5 | 0 | **0** | −752.5 | 0 | −991.4 |
| R2R 위반 | 29 | 44 | 0 | 0 | 56 | 0 | 62 |
| I2R WNS (ps) | −372.2 | −401.5 | −381.4 | **−342.8** | −404.8 | −372.5 | −405.8 |
| 면적 (µm²) | 4,257.6 | 4,589.5 | 4,545.1 | **4,513.0** | 4,690.9 | 4,372.2 | 4,456.8 |
| 셀 | 1,468 | 1,573 | 1,492 | 1,527 | 1,617 | 1,445 | 1,618 |

- OC = 합성에서만 setup uncertainty 0.10 → 0.15 ns(`cons/uart_v3_1ghz_oc.sdc`, 이전부터 있던 파일). OC의 R2R 값은 0.15 기준이라, 0.10 기준으로는 ⑩-E OC 약 +19 ps, ⑩-F OC 약 +24 ps 여유다.
- 합성 0.0 ps는 여유가 아니라 Genus가 목표(slack 0)에서 멈춘 값이다.
- **⑩-D 면적 증가 분해**: sequential +41개 / +262.7 µm²(증가분의 91 %). 41 = baud 35(`r_divM1` 16, `r_divD` 16, 플래그 3) + TX 2 + RX 4 → BAUDDIV 사본 32개가 대부분. ⑩-F는 `r_divM1`과 16-bit 감산·비교를 없애 ⑨보다 셀 수가 적다.
- ⑩-F 합성에는 `set_db optimize_merge_flops false`를 넣었다(TX/RX tick 레지스터가 논리적으로 같아 합쳐지는 것을 막음. netlist에 두 레지스터가 남았는지 확인).

## 5. P&R (Innovus, 1 GHz, QRC, P&R SDC는 ⑨와 같음)

| | ⑨ QRC | ⑩-D | **⑩-E** | ⑩-E OC | ⑩-F | ⑩-F OC |
|---|---|---|---|---|---|---|
| R2R WNS | −97 ps | −69 ps | **−46 ps** | −34 ps | −76 ps | −61 ps |
| R2R TNS | −6.970 ns | −6.170 ns | **−1.609 ns** | −1.169 ns | −2.288 ns | −2.292 ns |
| R2R 위반 | 187 | 201 | **91** | 90 | 85 | 104 |
| 전체 WNS (I/O) | −1.049 ns | −1.011 ns | −0.989 ns | −1.041 ns | −0.978 ns | −0.976 ns |
| hold | 0 | −0.000 ns (1개) | **0** | +0.001 ns (0개) | −0.001 ns (1개) | 0 |
| DRC | 0 | 0 | 0 | 0 | 0 | 0 |
| `report_area` (µm² / inst) | 5,854.0 / 1,735 | 6,373.9 / 1,867 | **6,097.5 / 1,917** (+4.2 %) | 6,262.7 / 1,851 | 5,830.4 / 1,753 | 5,934.7 / 1,885 |
| density | 82.4 % | 84.0 % | 80.9 % | 80.0 % | 79.8 % | 79.8 % |
| flow 변경 | — | — | **없음** | 합성 OC, scan 검사 옵션 | merge flops off, scan 검사 옵션 | 셋 다 |

- **대표 결과는 ⑩-E**: ⑨와 합성·P&R flow가 완전히 같아 RTL 변경 효과만 비교된다.
- P&R SDC는 각 variant의 Genus SDC에서 `set_ideal_network [get_ports rst_n]` 한 줄을 지운 것(⑨ P&R SDC와 같은 편집). Genus가 `group_path`의 레지스터를 이름으로 나열하므로 ⑨ SDC를 그대로 쓰면 새 레지스터가 그룹에서 빠진다. 셀 목록 외 차이 0을 스크립트로 확인했다.
- netlist 경로만 바꾼 ⑨ P&R 스크립트(`_archive/PNR_1GHZ_RSYNC_QRC`)를 그대로 썼다.
- **scan 검사 옵션**: Genus가 enable 플롭을 scan 플롭(SE = enable MUX, SI = data)으로 매핑한다. 실제 scan chain이 없는 플롭 비율이 ⑨ 45.05 %, ⑩-E 44.12 %일 때는 `IMPSP-9099`가 출력만 되고 진행했지만, ⑩-E OC는 53.74 %에서 `placeDesign`이 중단됐다. `setPlaceMode -place_global_exp_allow_missing_scan_chain true`로 검사만 넘겼다. SE/SI는 기능 신호라 `-ignoreScan`은 쓰지 않았다.
- ⑩-D hold −0.000 ns 1개: `i_pwdata[5] → r_txPushData_reg[5]/SI` (입력 → 플롭, 0.5 ps 미만). ⑩-E에서는 사라졌다. ⑩-F hold −0.001 ns 1개(default 그룹)는 경로를 확인하지 않았다.
- ⑩ (A–C) 단독 P&R은 돌리지 않았다.

### 남은 위반 분포 (post-route 상위 50 경로의 시작점)

| | 1위 | 2위 | 3위 |
|---|---|---|---|
| ⑩-D | `r_uartEn` 34 (→ TX FIFO `r_mem/SE` 30) | TX `r_state` 8 | RX `r_state` 6 |
| ⑩-E | RX `r_state` 20 | TX `r_state` 9 | `o_tick16` 8 |
| ⑩-E OC | `o_tick16` 14, baud `r_clkCnt` 10 | TX `r_state` 8 | RX FIFO `rdPtr` 7 |
| ⑩-F | TX `r_state` 22 | RX `r_state` 13 | TX FIFO `r_empty` 9 |

⑩-F에서 baud 덩어리는 사라졌지만 TX FSM이 1위가 됐고 WNS는 ⑩-E보다 나빠졌다. 합성에서는 ⑩-F가 더 좋았다. 남은 경로들이 비슷한 깊이로 퍼져 있어 배치에 따라 최악 경로가 수십 ps씩 흔들리는 구간으로 본다(variant마다 run 1회). 남은 −34 ~ −76 ps를 닫으려면 FSM 다음 상태 구조와 FIFO 읽기 구조(prefetch 등)를 바꿔야 하고, 국소 수정의 수확은 줄고 있다.

## 6. 파일

| 저장소 | 내용 |
|---|---|
| `UART_V3/1_rtl_r10e/` | ⑩-E RTL (`uart_apb` 아래 10개 모듈) |
| `UART_V3/patches/07`–`11` | ⑨ → ⑩(A–C) → ⑩-D → ⑩-E → ⑩-F, ⑨ → ⑩-E 전체 |
| `UART_V3/2_tb/r10/` | `tb_lock.v`(lockstep + 전제 assertion), `tb_baud_live.v` / `tb_baud_live_f.v`, `tb_baud_big.v` |
| `UART_V3/tools_r10/` | `run_r10.sh`(RTL 복사 · sim · 합성 · 비교, 실패 시 STOP), `mk_pnr_r10.sh`, `mk_lec_r10.sh`, `gl_r10.sh` |
| `UART_V3/3_syn/reports/r10*/` | qor · area · gates · r2r, 합성 스크립트 |
| `UART_V3/4_pnr/reports_r10*_qrc/` | final summary(setup/hold), reg2reg 경로, area, DRC/Conn, 바뀐 `2_PlaceOpt.tcl` |
| `UART_V3/5_gls/r10e/` | SDF cmd, PASS/FAIL 목록, 요약 |
| `UART_V3/6_verify/lec/r10e/`, `6_verify/r10_sim/` | LEC dofile·console, sim 결과 요약 |
