# AZ_V System-on-Chip (AZ_V_SoC)

![AZ_V SoC](https://img.shields.io/badge/Architecture-RISC--V%20RV32I-blue)
![BPU](https://img.shields.io/badge/Front--End-BTB%20%7C%20BHT%20%7C%20RAS-brightgreen)
![Debug](https://img.shields.io/badge/Debug-IEEE%201149.1%20JTAG%20(TAP%2FDTM%2FDM)-orange)
![UART](https://img.shields.io/badge/Bus-AXI4--Lite%20UART-yellow)
![ASIC](https://img.shields.io/badge/ASIC%20Flow-LibreLane%20Hierarchical%20Macro-red)
![Sim](https://img.shields.io/badge/Simulator-Verilator-purple)

**AZ_V_SoC** 是一個整合 **AZ_V 32-位元 RISC-V 處理器核心**（具備 Branch Target Buffer, Branch History Table, Return Address Stack 與 Instruction Queue）、**AXI4-Lite UART IP 週邊**、**IEEE 1149.1 JTAG 偵錯子系統** 以及 **4KB SRAM 記憶體陣列** 的完整 System-on-Chip (SoC)。

本專案支援 **階層式硬體巨集 ASIC 流程 (Hierarchical Hard Macro PnR Flow)**，直接引用包含分支預測器與指令佇列的 CPU RTL ([`AZ_V/rtl`](file:///home/user/workspace/AZ_V/rtl)) 與 UART RTL ([`AZ_V_UART/rtl`](file:///home/user/workspace/AZ_V_UART/rtl))，無需複製原始碼檔案。

---

## 系統架構圖 (System Architecture)

```mermaid
graph TD
    subgraph AZ_V_SoC ["AZ_V System-on-Chip Top"]
        subgraph CPU_SUB ["AZ_V CPU Core Macro (az_v_core_top)"]
            CPU["RV32I 5-Stage Pipeline\n(IF, ID, EX, MEM, WB)"]
            BPU["BPU (BTB + BHT + RAS)"]
            IQ["Instruction Queue"]
        end

        subgraph JTAG_SUB ["JTAG Debug Subsystem"]
            TAP["JTAG TAP Controller\n(IDCODE: 0x1A2B3C4D)"]
            DTM["JTAG DTM (Debug Transport Module)"]
            DM["JTAG DM (Debug Module)\n(GPR / PC / Mem Access)"]
        end
        
        subgraph BUS ["az_v_soc_interconnect (Memory-Mapped Bus Decoder)"]
            RAM_CTL["SRAM Controller Arbitrator"]
            UART_AXI["AXI4-Lite Master Bridge (UART)"]
        end

        SRAM_BANK["4KB SRAM Bank Array (sram_bank_array)\n(8 x 512B gf180mcu_fd_ip_sram Macros)"]
        
        subgraph UART_SUB ["UART IP Macro (az_v_uart_top)"]
            UART_CORE["AXI4-Lite UART Core\n(TX/RX FIFOs + Baud Generator)"]
        end

        JTAG_PINS["JTAG Pins\n(TCK, TMS, TDI, TDO, TRST_N)"] --> TAP
        TAP --> DTM --> DM
        DM -->|Halt / Resume / GPR / PC| CPU
        DM -->|Debug Mem Master| BUS

        CPU -->|imem_addr / rdata| SRAM_BANK
        CPU -->|dmem_bus| BUS
        
        BUS --> RAM_CTL --> SRAM_BANK
        BUS --> UART_AXI -->|AXI4-Lite| UART_CORE
    end

    UART_CORE -->|uart_tx_pin / uart_rx_pin| SERIAL_PINS["Serial IO Pins"]
```

---

## 記憶體映射表 (Memory Map)

AZ_V CPU 採用統一的 32 位元實體位址空間：

| 位址範圍 (Address Range) | 容量/區域 | 模組 (Module) | 描述 (Description) |
|---|---|---|---|
| `0x0000_0000` - `0x0000_0FFF` | **4 KB** | **Main SRAM** | 4KB 統一指令與資料 SRAM (8 顆 512B SRAM Macros) |
| `0x1000_0000` - `0x1000_003F` | **64 B** | **UART IP** | AXI4-Lite UART 暫存器區塊 |
| `JTAG DMI Access` | - | **Debug Module** | 透過 JTAG 存取 GPR (x0-x31), PC 及 SRAM 記憶體 |

---

## ASIC 階層式硬體巨集流程 (Hierarchical Macro GDS Flow)

本專案採用 **LibreLane 3-階段階層式 PnR 流程**，實作硬體巨集分階段產出與頂層整合：

```mermaid
flowgraph LR
    RTL_CPU["AZ_V/rtl (CPU RTL)"] --> STEP1["Phase 1: make librelane-cpu\n(Output: final_cpu/ Macro GDS/LEF)"]
    RTL_UART["AZ_V_UART/rtl (UART RTL)"] --> STEP2["Phase 2: make librelane-uart\n(Output: final_uart/ Macro GDS/LEF)"]
    
    STEP1 --> STEP3["Phase 3: make librelane-nodrc\n(Top SoC with JTAG + SRAM Macros)"]
    STEP2 --> STEP3
    RTL_SOC["AZ_V_SoC/rtl (JTAG + Interconnect)"] --> STEP3
    SRAM_IP["GF180MCU SRAM Macros (8x 512B)"] --> STEP3
```

### 1. 金屬層分工設定 (`RT_MAX_LAYER: Metal4`)
* **巨集內部繞線 (Sub-block Macros)**：`az_v_core_top` 與 `az_v_uart_top` 的繞線上限限制為 **Metal4** (`RT_MAX_LAYER: Metal4`)。
* **頂層整合 (Top SoC Integration)**：預留頂層最高金屬層 **Metal5** 給 `chip_top` 進行全晶片電源網格 (Power Straps) 鋪設與跨巨集信號走線。

### 2. LibreLane 執行命令
* **Phase 1: 產出 CPU Hard Macro GDS/LEF**
  ```bash
  make librelane-cpu
  # 使用 --run-tag az_v_cpu_macro，視圖保存至 final_cpu/
  ```
* **Phase 2: 產出 UART Hard Macro GDS/LEF**
  ```bash
  make librelane-uart
  # 使用 --run-tag az_v_uart_macro，視圖保存至 final_uart/
  ```
* **Phase 3: 產出完整帶有 JTAG 的 Top-Level SoC GDS**
  ```bash
  make librelane-nodrc
  # 使用 --run-tag chip_top_soc，整合 JTAG + CPU Macro + UART Macro + 4KB SRAM Macros
  ```
* **一鍵執行全流程**：
  ```bash
  make librelane-all
  ```

---

## 專案目錄結構 (Directory Structure)

```text
AZ_V_SoC/
├── README.md                     # SoC 專案說明文件 (本文件)
├── Makefile                      # Verilator 模擬與 LibreLane 階層式 GDS Makefile
├── librelane/                    # LibreLane 晶片與 Macro 設定檔
│   ├── config_cpu.yaml           # CPU Hard Macro PnR 設定 (RT_MAX_LAYER: Metal4)
│   ├── config_uart.yaml          # UART Hard Macro PnR 設定 (RT_MAX_LAYER: Metal4)
│   └── config.yaml               # Top SoC 晶片層級 PnR 設定 (含 JTAG + Macro 宣告)
├── rtl/                          # SystemVerilog RTL
│   ├── az_v_soc_top.sv           # Top-Level SoC 頂層模組
│   ├── bus/
│   │   └── az_v_soc_interconnect.sv # 記憶體映射匯流排解碼與 AXI4-Lite 轉接器
│   ├── jtag/                     # IEEE 1149.1 JTAG 偵錯子系統
│   │   ├── jtag_tap.sv           # JTAG TAP 控制器
│   │   ├── jtag_dtm.sv           # Debug Transport Module
│   │   └── jtag_dm.sv            # Debug Module 控制器
│   └── asic/
│       ├── sram_bank_array.sv    # 4KB SRAM 陣列 (8 顆 512B GF180MCU SRAM Macros)
│       ├── chip_core.sv          # Core 整合層
│       └── chip_top.sv           # Chip Padring 頂層
├── tb/                           # 模擬測試平台
│   ├── az_v_soc_tb.sv            # SystemVerilog 測試平台模組
│   └── tb_soc.cpp                # Verilator C++ 測試驅動程式 (含 JTAG 驗證與 VCD 波形)
└── sw/                           # 裸機 C 語言韌體
    ├── Makefile                  # 韌體編譯 Makefile
    ├── common/
    │   ├── crt0.s                # RISC-V 啟動組合語言程式
    │   └── link.ld               # 連結器腳本 (4KB SRAM Layout)
    └── examples/
        └── soc_demo.c            # UART 輸出與韌體測試主程式
```

---

## 編譯與模擬驗證 (Build & Simulation)

### 1. 執行 Verilator 全功能模擬 (含 JTAG 驗證)
在 `AZ_V_SoC` 根目錄執行：
```bash
make verilate
```

### 2. 模擬驗證輸出結果

```text
[AZ_V SoC Sim] Starting Simulation with JTAG Verification...

============================================
  AZ_V SoC JTAG Debug Subsystem Verification
============================================

====[JTAG Test 1] Reading IDCODE... 0x1a2b3c4d
[PASS] JTAG IDCODE Match: 0x1A2B3C4D
[JTAG Test 2] Requesting CPU Halt...
[PASS] CPU Halted successfully via JTAG.
[JTAG Test 3] Writing 0xDEADBEEF into GPR x5...
[PASS] GPR Read/Write Verified!
[JTAG Test 4] Overriding CPU PC to 0x00000100...
[PASS] CPU PC Override Verified!
[JTAG Test 5] Writing 0xCAFEBABE to SRAM at 0x00000800...
[PASS] Debug Memory Read/Write Verified!
[JTAG Test 6] Requesting CPU Resume...
[PASS] CPU Resumed execution successfully.

============================================
   AZ_V SoC System Integration Test Demo
============================================
[INFO] CPU Core: AZ_V (RV32I 5-stage pipeline)
[INFO] Peripherals: AXI4-Lite UART & JTAG Debug Subsystem

[STEP 1] Testing UART Transmit & Output...
Hello World from AZ_V SoC (AZ_V + UART + JTAG)!
[INFO] Hex Print Test: 0x1234ABCD

============================================
   [PASS] AZ_V SoC Integration Test Successful!
============================================
```
