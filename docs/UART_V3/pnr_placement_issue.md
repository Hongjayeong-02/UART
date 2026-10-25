# UART V3 P&R — Placement Site 불일치 위반 72건 분석 및 해결

| 항목 | 내용 |
|---|---|
| 일자 | 2026-10-17 |
| 대상 | `uart_apb` 블록 레벨 P&R (Cadence Innovus, GPDK045) |
| 증상 | `checkPlace` 위반 72건 |
| 결과 | ECO 후 `checkPlace` 위반 0건 (기록 기준) |
| 상태 | 해결됨. 나머지 1건의 원본 메시지 등 일부 항목은 서버에서 재확인 필요 (아래 "미확인 항목" 참고) |

---

## 1. 증상 (Symptom)

`checkPlace` 실행 결과 placement 위반이 72건 보고됨. 핵심 메시지는 다음과 같다.

```
Insts placed on techSites not matching their cells' (71)
```

- 72건 중 71건이 위 항목(셀이 요구하는 site와 배치된 row의 site가 다름)에 해당한다.
- **나머지 1건의 정확한 메시지는 아직 원본 로그에서 확보하지 못했다.** 수정 후 전체 위반이 0건이 되었으므로 함께 해소된 것으로 보이지만, 원인은 확인되지 않았다.

## 2. 원인 (Root Cause)

| 항목 | 값 |
|---|---|
| Floorplan row의 site | `CoreSite` |
| Innovus 최적화가 삽입한 셀 | `BUFX2` |
| `BUFX2`의 library site | `CoreSiteDouble` |

Standard cell은 LEF에서 자신이 놓일 수 있는 site를 `SITE` 문으로 지정한다. Floorplan은 `CoreSite` row만 만들었는데, 최적화 단계(timing/DRV 보정용 buffering)에서 `CoreSiteDouble`을 요구하는 `BUFX2`가 삽입되었다. 그 결과 셀이 자기 site와 맞지 않는 row 위에 놓였다.

즉, 문제는 RTL이나 합성 netlist가 아니라 **Innovus가 사용할 수 있는 셀 집합(cell set)과 floorplan의 row 정의가 서로 맞지 않았던 것**이다.

> 확인 필요: `CoreSiteDouble`이 double-height site인지, 다른 크기의 site인지는 LEF의 `SITE CoreSiteDouble` 정의(`SIZE`, `CLASS`)로 확인해 기록한다.
> ```bash
> grep -A4 'SITE CoreSite' <gpdk045 tech/std cell LEF 경로>
> ```

## 3. 해결 (Fix)

### 3.1 접근 방법

| 단계 | 목적 |
|---|---|
| ① `CoreSiteDouble` 셀 전체를 `dont_use` 지정 | 이후 최적화에서 다시 삽입되지 않도록 원인을 차단 |
| ② 이미 배치된 `BUFX2` → `BUFX3` ECO 교체 | `dont_use`는 앞으로의 최적화에만 적용되므로, 이미 들어간 셀은 따로 교체해야 함 |
| ③ `refinePlace` 후 `checkPlace` 재확인 | 교체된 셀을 legal 위치로 재배치하고 위반 0건 확인 |

### 3.2 사용한 Tcl (Innovus)

```tcl
# ① CoreSiteDouble site를 쓰는 lib cell 수집 후 dont_use 지정
set dbl_cells {}

foreach c [dbGet head.libCells.name -u] {
    if {[lsearch [dbGet [dbGet head.libCells.name $c -p].site.name] CoreSiteDouble] >= 0} {
        lappend dbl_cells $c
    }
}

foreach c $dbl_cells {
    setDontUse $c true
}

# ② 이미 배치된 BUFX2 인스턴스를 BUFX3로 교체
foreach i [dbGet [dbGet top.insts.cell.name BUFX2 -p2].name] {
    ecoChangeCell -inst $i -cell BUFX3
}

# ③ 재배치 후 검증
refinePlace
checkPlace
```

### 3.3 트러블슈팅: 첫 `setDontUse` 시도 실패

- 처음에는 `setDontUse`를 적용했는데도 의도한 속성이 반영되지 않았다.
- 원인: slow/fast 라이브러리(MMMC corner)에 같은 이름의 lib cell이 **중복으로 존재**해서, 한쪽에만 적용되었다.
- 조치: `-u`로 이름을 유일화한 뒤 이름 기준으로 모든 lib cell 객체에 적용하고, `dbGet`으로 실제 속성값을 직접 확인하도록 바꿨다.

```tcl
# 검증: 같은 이름의 lib cell이 모두 dontUse = 1 인지 확인
dbGet [dbGet head.libCells.name BUFX2 -p].dontUse
# 교체 대상 셀의 site 확인 (CoreSite 여야 함)
dbGet [dbGet head.libCells.name BUFX3 -p].site.name
```

배운 점: **명령을 실행한 것과 속성이 실제로 적용된 것은 다르다.** 설정 명령 뒤에는 DB 값을 직접 조회해 확인한다.

## 4. 재검증 (Verification)

| 검사 | 결과 | 근거 |
|---|---|---|
| `checkPlace` | 위반 0건 | 기록 확인 |
| DRC / Connectivity (`verify_drc`, `verifyConnectivity`) | 위반 0건 | 기록 확인 (최종 P&R 결과) |
| Setup / Hold | 위반 0건 | 기록 확인. 적용된 SDC/MMMC 조건 기준 |
| ECO 이후 타이밍 | 위반 0건 | ECO는 preCTS 단계에서 적용. 이후 postCTS(setup WNS +997.24 ns, hold WNS +0.009 ns)와 postRoute(setup WNS +997.52 ns, hold WNS +0.011 ns) report가 모두 ECO 이후 결과 |

## 5. 설계 리뷰 관점의 한계와 개선점

1. **ECO 교체는 타이밍에 영향을 준다.** `BUFX3`는 `BUFX2`와 구동력(drive strength), 입력 capacitance, 면적이 다르다. 이번에는 ECO를 preCTS 단계에서 적용했기 때문에, 이후 CTS와 postRoute 타이밍 분석이 모두 교체된 셀을 반영한다. ECO를 route 이후에 적용한다면 `ecoRoute`와 타이밍 재분석이 별도로 필요하다.
2. **사후 ECO보다 사전 차단이 근본 해결이다.** 현재 방식은 문제가 생긴 뒤 고친 것이다. 재현 가능한 flow라면 `setDontUse`를 `init_design` 직후, `placeDesign`/`optDesign` **이전**에 넣어야 같은 문제가 다시 생기지 않는다. 반대 방향의 대안은 floorplan에 `CoreSiteDouble` row를 추가하는 것인데, 이 교육용 블록에서는 셀 제한 쪽이 단순하다.
3. **Genus와 Innovus의 dont_use 목록을 맞춘다.** 합성 단계에서 `CoreSiteDouble` 셀이 netlist에 들어가면 Innovus의 `dont_use`로는 막을 수 없다. 이번에는 문제가 최적화 삽입 셀(`BUFX2`)에서만 생겼지만, Genus 스크립트에도 같은 `dont_use`를 적용하는 것이 일관적이다.
4. **ECO는 netlist를 바꾼다.** 셀 교체와 buffer 삽입이 있었으므로, 합성 netlist 대 P&R 후 netlist의 LEC가 별도로 필요하다 (`lec_runbook.md` 참고).

## 6. 미확인 항목 (서버 접속 시 확인)

- [ ] 72건 중 나머지 1건의 원본 메시지
- [x] ECO 적용 단계: preCTS (Place + preCTS opt 단계)
- [x] ECO 이후 timing: postCTS·postRoute report에서 setup/hold 위반 0
- [ ] `CoreSiteDouble`의 LEF 정의
- [ ] 위 Tcl이 실제 P&R 스크립트(`5_pnr/`)에 반영되어 있는지

```bash
grep -RniE 'techSites|checkPlace|CoreSiteDouble|BUFX2' \
    /home/hah006/PROJ1/proj1_make/TOP/PNR/ 2>/dev/null
```


