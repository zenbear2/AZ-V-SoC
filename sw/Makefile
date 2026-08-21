# ============================================================================
# File: Makefile
# Description: Software Build System for AZ_V SoC Integration Firmware
# Project: AZ_V_SoC
# ============================================================================

RISCV_PREFIX ?= $(shell which riscv64-unknown-elf-gcc 2>/dev/null || \
                        echo /home/user/miniconda3/pkgs/riscv-tools-1.0.6-0_h1234567_g56c29e0/riscv-tools/bin/riscv64-unknown-elf-)

CC            := $(dir $(RISCV_PREFIX))riscv64-unknown-elf-gcc
OBJCOPY       := $(dir $(RISCV_PREFIX))riscv64-unknown-elf-objcopy
OBJDUMP       := $(dir $(RISCV_PREFIX))riscv64-unknown-elf-objdump
PYTHON        := python3

BUILD_DIR     := build
COMMON_DIR    := common
DRIVERS_DIR   := drivers
EXAMPLES_DIR  := examples
TOOLS_DIR     := tools

CFLAGS        := -march=rv32i -mabi=ilp32 -O2 -ffreestanding -nostdlib -Wall -I$(COMMON_DIR) -I$(DRIVERS_DIR)
LDFLAGS       := -T $(COMMON_DIR)/link.ld -nostdlib

SRCS_S        := $(COMMON_DIR)/crt0.s
SRCS_C        := $(DRIVERS_DIR)/uart.c $(DRIVERS_DIR)/mlkem512.c $(EXAMPLES_DIR)/soc_demo.c

OBJS          := $(patsubst %.s,$(BUILD_DIR)/%.o,$(notdir $(SRCS_S))) \
                 $(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(SRCS_C)))

TARGET_ELF    := $(BUILD_DIR)/soc_demo.elf
TARGET_BIN    := $(BUILD_DIR)/soc_demo.bin
TARGET_HEX    := $(BUILD_DIR)/soc_demo.hex
TARGET_DUMP   := $(BUILD_DIR)/soc_demo.dump

.PHONY: all clean

all: $(TARGET_HEX) $(TARGET_DUMP)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/crt0.o: $(COMMON_DIR)/crt0.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/uart.o: $(DRIVERS_DIR)/uart.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/mlkem512.o: $(DRIVERS_DIR)/mlkem512.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/soc_demo.o: $(EXAMPLES_DIR)/soc_demo.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET_ELF): $(OBJS) $(COMMON_DIR)/link.ld
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

$(TARGET_BIN): $(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

$(TARGET_HEX): $(TARGET_BIN) $(TOOLS_DIR)/elf2hex.py
	$(PYTHON) $(TOOLS_DIR)/elf2hex.py $< $@

$(TARGET_DUMP): $(TARGET_ELF)
	$(OBJDUMP) -D -S $< > $@

clean:
	rm -rf $(BUILD_DIR)
