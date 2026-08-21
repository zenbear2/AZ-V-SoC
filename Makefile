# ============================================================================
# File: Makefile
# Description: Top-Level Makefile for AZ_V SoC (AZ_V CPU + AXI4-Lite UART + JTAG)
# Project: AZ_V_SoC
# ============================================================================

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PDK_ROOT ?= $(shell if [ -d "$(MAKEFILE_DIR)/gf180mcu" ]; then echo "$(MAKEFILE_DIR)/gf180mcu"; else echo "/home/user/workspace/gf180mcu-project-template/gf180mcu"; fi)
PDK ?= gf180mcuD
PDK_TAG ?= 1.8.0

AVAILABLE_SLOTS = 1x1 0p5x1 1x0p5 0p5x0p5
DEFAULT_SLOT = 1x1
SLOT ?= $(DEFAULT_SLOT)

ifeq ($(SLOT),default)        
    SLOT = $(DEFAULT_SLOT)
endif

VERILATOR := verilator
PYTHON    := python3
MAKE      := make

# Workspace directories
AZ_V_DIR     := /home/user/workspace/AZ_V
UART_DIR     := /home/user/workspace/AZ_V_UART
SOC_DIR      := /home/user/workspace/AZ_V_SoC

OBJ_DIR      := obj_dir
SW_DIR       := sw
HEX_FILE     := $(SW_DIR)/build/soc_demo.hex

# Verilator Flags
VERILATOR_FLAGS := -Wall -Wno-IMPORTSTAR -Wno-UNUSED -Wno-PINCONNECTEMPTY -Wno-TIMESCALEMOD -Wno-PINMISSING -Wno-ASSIGNDLY -Wno-CASEINCOMPLETE -Wno-fatal --trace --timescale 1ns/1ps -DSLOT_1X1 --cc \
                   -I$(AZ_V_DIR)/rtl/pkg \
                   -I$(AZ_V_DIR)/rtl/frontend \
                   -I$(AZ_V_DIR)/rtl/core \
                   -I$(AZ_V_DIR)/rtl/pipeline \
                   -I$(AZ_V_DIR)/rtl/top \
                   -I$(UART_DIR)/rtl/pkg \
                   -I$(UART_DIR)/rtl/core \
                   -I$(UART_DIR)/rtl/axi \
                   -I$(UART_DIR)/rtl/top \
                   -I$(SOC_DIR)/rtl \
                   -I$(SOC_DIR)/rtl/bus \
                   -I$(SOC_DIR)/rtl/jtag \
                   -I$(SOC_DIR)/rtl/asic

# SystemVerilog Sources
JTAG_SRCS  := $(SOC_DIR)/rtl/jtag/jtag_tap.sv \
              $(SOC_DIR)/rtl/jtag/jtag_dtm.sv \
              $(SOC_DIR)/rtl/jtag/jtag_dm.sv

AZ_V_SRCS  := $(AZ_V_DIR)/rtl/pkg/riscv_pkg.sv \
              $(AZ_V_DIR)/rtl/frontend/btb.sv \
              $(AZ_V_DIR)/rtl/frontend/bht.sv \
              $(AZ_V_DIR)/rtl/frontend/ras.sv \
              $(AZ_V_DIR)/rtl/frontend/instr_queue.sv \
              $(AZ_V_DIR)/rtl/frontend/fetch_unit.sv \
              $(AZ_V_DIR)/rtl/core/regfile.sv \
              $(AZ_V_DIR)/rtl/core/decode_stage.sv \
              $(AZ_V_DIR)/rtl/core/alu.sv \
              $(AZ_V_DIR)/rtl/core/execute_stage.sv \
              $(AZ_V_DIR)/rtl/core/memory_stage.sv \
              $(AZ_V_DIR)/rtl/core/writeback_stage.sv \
              $(AZ_V_DIR)/rtl/pipeline/hazard_unit.sv \
              $(AZ_V_DIR)/rtl/top/az_v_core_top.sv

UART_SRCS  := $(UART_DIR)/rtl/pkg/uart_pkg.sv \
              $(UART_DIR)/rtl/core/baud_rate_gen.sv \
              $(UART_DIR)/rtl/core/sync_fifo.sv \
              $(UART_DIR)/rtl/core/uart_rx.sv \
              $(UART_DIR)/rtl/core/uart_tx.sv \
              $(UART_DIR)/rtl/axi/axi_lite_slave.sv \
              $(UART_DIR)/rtl/top/az_v_uart_top.sv

SOC_SRCS   := $(JTAG_SRCS) \
              $(SOC_DIR)/rtl/bus/az_v_soc_interconnect.sv \
              $(SOC_DIR)/rtl/az_v_soc_top.sv \
              $(AZ_V_DIR)/tb/ram_model.sv \
              $(SOC_DIR)/tb/az_v_soc_tb.sv

SRAM_VERILOG := $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_ip_sram/verilog/gf180mcu_fd_ip_sram__sram512x8m8wm1.v

RTL_SRCS   := $(AZ_V_SRCS) $(UART_SRCS) $(SOC_SRCS)
TB_CPP     := $(SOC_DIR)/tb/tb_soc.cpp
TOP_MODULE := az_v_soc_tb

.PHONY: help all sw verilate build sim clean librelane-cpu librelane-uart librelane librelane-nodrc librelane-all

help: ## Show this help message
	@echo 'AZ_V_SoC Makefile Targets:'
	@echo '  make sw             - Build bare-metal C firmware'
	@echo '  make verilate       - Run Verilator simulation'
	@echo '  make librelane-cpu  - Phase 1: Generate AZ_V CPU Macro GDS/LEF'
	@echo '  make librelane-uart - Phase 2: Generate UART Macro GDS/LEF'
	@echo '  make librelane-nodrc- Phase 3: Generate full Chip Top GDS (with JTAG)'
	@echo '  make librelane-all  - Run Phase 1, Phase 2, and Phase 3 in sequence'

all: sw verilate

sw:
	$(MAKE) -C $(SW_DIR)

verilate: build
	./$(OBJ_DIR)/V$(TOP_MODULE) +HEX=$(HEX_FILE)

build: sw
	$(VERILATOR) $(VERILATOR_FLAGS) --exe --build -j 4 $(RTL_SRCS) $(SRAM_VERILOG) $(TB_CPP) --top-module $(TOP_MODULE) -o V$(TOP_MODULE)

TAG_CPU  ?= az_v_cpu_macro
TAG_UART ?= az_v_uart_macro
TAG_SOC  ?= chip_top_soc

librelane-cpu: ## Phase 1: Generate AZ_V CPU Macro GDS & LEF
	librelane librelane/config_cpu.yaml --run-tag $(TAG_CPU) --save-views-to $(MAKEFILE_DIR)/final_cpu --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip Odb.CheckDesignAntennaProperties --skip KLayout.DRC --skip Magic.DRC --overwrite

librelane-uart: ## Phase 2: Generate UART Macro GDS & LEF
	librelane librelane/config_uart.yaml --run-tag $(TAG_UART) --save-views-to $(MAKEFILE_DIR)/final_uart --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip Odb.CheckDesignAntennaProperties --skip KLayout.DRC --skip Magic.DRC --overwrite

librelane: ## Phase 3: Generate full Chip Top GDS
	librelane librelane/slots/slot_${SLOT}.yaml librelane/config.yaml --run-tag $(TAG_SOC) --save-views-to $(MAKEFILE_DIR)/final --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --overwrite

librelane-nodrc: ## Phase 3: Generate full Chip Top GDS without DRC checks
	librelane librelane/slots/slot_${SLOT}.yaml librelane/config.yaml --run-tag $(TAG_SOC) --save-views-to $(MAKEFILE_DIR)/final --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip KLayout.DRC --skip Magic.DRC --overwrite

librelane-all: librelane-cpu librelane-uart librelane-nodrc ## Run full 3-phase Hierarchical Macro GDS flow

clean:
	rm -rf $(OBJ_DIR) sim_wave.vcd final/ final_cpu/ final_uart/
	$(MAKE) -C $(SW_DIR) clean
