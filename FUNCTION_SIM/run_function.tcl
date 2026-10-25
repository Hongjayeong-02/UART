#!/bin/bash

#============================================================
# UART Function Simulation
# V1 / V2 / V3 Selectable
#============================================================

VERSION=$1

case "$VERSION" in

    V1|v1)
        RTL_DIR="../../RTL/UART_V1"
        TB_DIR="../TESTBENCH/UART_V1"
        TB_FILE="tb_uart_loopback.v"
        TOP="tb_uart_loopback"
        LOG="func_v1.log"
        ;;

    V2|v2)
        RTL_DIR="../../RTL/UART_V2"
        TB_DIR="../TESTBENCH/UART_V2"
        TB_FILE="tb_uart_v2_top.v"
        TOP="tb_uart_v2_top"
        LOG="func_v2.log"
        ;;

    V3|v3)
        RTL_DIR="../../RTL/UART_V3"
        TB_DIR="../TESTBENCH/UART_V3"
        TB_FILE="tb_uart_v3_final.v"
        TOP="tb_uart_v3_final"
        LOG="func_v3.log"
        ;;

    *)
        echo "Usage: sh run_function.tcl [V1|V2|V3]"
        exit 1
        ;;
esac


echo "========================================"
echo " UART $VERSION FUNCTION SIMULATION"
echo "========================================"
echo "RTL : $RTL_DIR"
echo "TB  : $TB_DIR/$TB_FILE"
echo "TOP : $TOP"
echo "========================================"


xrun -64bit \
    +max_err_count+50 \
    -access +rwc \
    -gui \
    +libext+.v \
    -incdir $RTL_DIR \
    -incdir $TB_DIR \
    -y /GPDK045/digital/gsclib045_all_v4.4/gsclib045_svt_v4.4/gsclib045/verilog \
    $RTL_DIR/*.v \
    $TB_DIR/$TB_FILE \
    -top $TOP \
    -l $LOG
