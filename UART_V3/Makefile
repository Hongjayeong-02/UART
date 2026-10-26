# UART V3 - open-source reproduction (Icarus Verilog)
#
# Cadence 서버 없이 RTL regression과 동등성 비교를 다시 돌려 보기 위한 Makefile.
# 서버(Xcelium) 결과는 6_verify/regression/*_pf.txt 에 보관 (최종 ⑨ 기준: rsync_pf.txt).
#
#   make regress   : 최종 RTL(⑨)에 regression TB 실행 → 서버 결과와 diff
#   make gl        : gate-level용 TB(내부 신호 참조 없음)를 RTL에 실행 → regress와 diff
#   make mcp       : MCP 근거 assertion(mcp_checker.sv)을 regression과 함께 실행
#   make eq        : ③ vs ④ FIFO·TX 랜덤 비교 + 원본 vs ④ FIFO reset 동등성 비교
#   make clean

IVERILOG ?= iverilog -g2012
VVP      ?= vvp
BUILD    := build

RTL      := $(wildcard 1_rtl/*.v)
EQ       := 6_verify/equivalence

.PHONY: all regress gl mcp eq clean
all: regress gl mcp eq

$(BUILD):
	mkdir -p $(BUILD)

regress: | $(BUILD)
	$(IVERILOG) -s tb_uart_v3_final -o $(BUILD)/regress.vvp 2_tb/tb_uart_v3_final.v $(RTL)
	$(VVP) $(BUILD)/regress.vvp | grep 'PASS\|FAIL' > $(BUILD)/regress_pf.txt
	@echo "== $$(grep -c '^PASS:' $(BUILD)/regress_pf.txt) PASS / $$(grep -c '^FAIL' $(BUILD)/regress_pf.txt) FAIL (+ ALL PASS 요약 줄)"
	diff 6_verify/regression/rsync_pf.txt $(BUILD)/regress_pf.txt && echo "== SAME AS SERVER (Xcelium) RESULT"

gl: regress
	$(IVERILOG) -s tb_uart_v3_final_gl -o $(BUILD)/gl.vvp 2_tb/tb_uart_v3_final_gl.v $(RTL)
	$(VVP) $(BUILD)/gl.vvp | grep 'PASS\|FAIL' > $(BUILD)/gl_pf.txt
	diff $(BUILD)/regress_pf.txt $(BUILD)/gl_pf.txt && echo "== GL TB SAME AS REGRESSION"

mcp: | $(BUILD)
	$(IVERILOG) -s tb_uart_v3_final -s mcp_checker -o $(BUILD)/mcp.vvp 2_tb/tb_uart_v3_final.v 2_tb/mcp_checker.sv $(RTL)
	$(VVP) $(BUILD)/mcp.vvp | grep 'MCP_ASSERT'

eq: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/eq34.vvp $(EQ)/tb_eq_3_vs_4.v $(EQ)/uart_fifo_3.v $(EQ)/uart_tx_3.v 1_rtl/uart_fifo.v 1_rtl/uart_tx.v
	$(VVP) $(BUILD)/eq34.vvp | grep DONE
	$(IVERILOG) -o $(BUILD)/eqrst.vvp $(EQ)/tb_fifo_reset_eq.v $(EQ)/fifo_orig_reconstructed.v $(EQ)/fifo_4.v
	$(VVP) $(BUILD)/eqrst.vvp | grep DONE

clean:
	rm -rf $(BUILD)
