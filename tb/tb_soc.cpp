// ============================================================================
// File: tb_soc.cpp
// Description: Verilator C++ Main Testbench Harness with JTAG Debug Test Suite
// Project: AZ_V_SoC
// ============================================================================

#include <iostream>
#include <memory>
#include <cassert>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vaz_v_soc_tb.h"

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

// ----------------------------------------------------------------------------
// JTAG Driver Helper Functions
// ----------------------------------------------------------------------------

void tick_sys_clk(Vaz_v_soc_tb* top, VerilatedVcdC* tfp, int count = 1) {
    for (int i = 0; i < count; ++i) {
        top->clk = 0;
        top->uart_rx_pin = top->uart_tx_pin;
        top->eval();
        if (tfp) tfp->dump(main_time++);

        top->clk = 1;
        top->eval();
        if (tfp) tfp->dump(main_time++);
    }
}

void jtag_clock_cycle(Vaz_v_soc_tb* top, VerilatedVcdC* tfp, uint8_t tms, uint8_t tdi) {
    top->tms = tms & 1;
    top->tdi = tdi & 1;

    // TCK LOW
    top->tck = 0;
    top->clk = 0;
    top->uart_rx_pin = top->uart_tx_pin;
    top->eval();
    if (tfp) tfp->dump(main_time++);

    top->clk = 1;
    top->eval();
    if (tfp) tfp->dump(main_time++);

    // TCK HIGH
    top->tck = 1;
    top->clk = 0;
    top->uart_rx_pin = top->uart_tx_pin;
    top->eval();
    if (tfp) tfp->dump(main_time++);

    top->clk = 1;
    top->eval();
    if (tfp) tfp->dump(main_time++);

    top->tck = 0;
}

void jtag_reset_tap(Vaz_v_soc_tb* top, VerilatedVcdC* tfp) {
    top->trst_n = 0;
    for (int i = 0; i < 5; ++i) {
        jtag_clock_cycle(top, tfp, 1, 0);
    }
    top->trst_n = 1;
    // Enter Run-Test/Idle
    jtag_clock_cycle(top, tfp, 0, 0);
}

void jtag_shift_ir(Vaz_v_soc_tb* top, VerilatedVcdC* tfp, uint8_t ir_val, uint8_t len = 5) {
    // Run-Test/Idle -> Select-DR -> Select-IR -> Capture-IR -> Shift-IR
    jtag_clock_cycle(top, tfp, 1, 0);
    jtag_clock_cycle(top, tfp, 1, 0);
    jtag_clock_cycle(top, tfp, 0, 0);
    jtag_clock_cycle(top, tfp, 0, 0);

    for (int i = 0; i < len; ++i) {
        uint8_t tms = (i == len - 1) ? 1 : 0; // Exit1-IR on last bit
        uint8_t tdi = (ir_val >> i) & 1;
        jtag_clock_cycle(top, tfp, tms, tdi);
    }

    // Exit1-IR -> Update-IR -> Run-Test/Idle
    jtag_clock_cycle(top, tfp, 1, 0);
    jtag_clock_cycle(top, tfp, 0, 0);
}

uint64_t jtag_shift_dr(Vaz_v_soc_tb* top, VerilatedVcdC* tfp, uint64_t dr_in, uint8_t len) {
    // Run-Test/Idle -> Select-DR -> Capture-DR -> Shift-DR
    jtag_clock_cycle(top, tfp, 1, 0);
    jtag_clock_cycle(top, tfp, 0, 0);
    jtag_clock_cycle(top, tfp, 0, 0);

    uint64_t dr_out = 0;
    for (int i = 0; i < len; ++i) {
        uint8_t tms = (i == len - 1) ? 1 : 0; // Exit1-DR on last bit
        uint8_t tdi = (dr_in >> i) & 1;

        if (top->tdo) {
            dr_out |= (1ULL << i);
        }

        jtag_clock_cycle(top, tfp, tms, tdi);
    }

    // Exit1-DR -> Update-DR -> Run-Test/Idle
    jtag_clock_cycle(top, tfp, 1, 0);
    jtag_clock_cycle(top, tfp, 0, 0);

    return dr_out;
}

void jtag_dmi_write(Vaz_v_soc_tb* top, VerilatedVcdC* tfp, uint8_t addr, uint32_t data) {
    uint64_t payload = ((uint64_t)(addr & 0x3F) << 34) | ((uint64_t)data << 2) | 0x2ULL; // op = 2 (write)
    jtag_shift_dr(top, tfp, payload, 40);
    for (int i = 0; i < 20; ++i) {
        jtag_clock_cycle(top, tfp, 0, 0);
    }
}

uint32_t jtag_dmi_read(Vaz_v_soc_tb* top, VerilatedVcdC* tfp, uint8_t addr) {
    // 1. Send DMI read request (op = 1)
    uint64_t req_payload = ((uint64_t)(addr & 0x3F) << 34) | 0x1ULL;
    jtag_shift_dr(top, tfp, req_payload, 40);

    for (int i = 0; i < 20; ++i) {
        jtag_clock_cycle(top, tfp, 0, 0);
    }

    // 2. Send NOP to capture response (op = 0)
    uint64_t nop_payload = 0ULL;
    uint64_t rsp_payload = jtag_shift_dr(top, tfp, nop_payload, 40);

    uint32_t rdata = (uint32_t)((rsp_payload >> 2) & 0xFFFFFFFFULL);
    return rdata;
}

// ----------------------------------------------------------------------------
// Main Simulator Entry Point
// ----------------------------------------------------------------------------

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    auto top = std::make_unique<Vaz_v_soc_tb>();
    auto tfp = std::make_unique<VerilatedVcdC>();

    top->trace(tfp.get(), 99);
    tfp->open("sim_wave.vcd");

    std::cout << "[AZ_V SoC Sim] Starting Simulation with JTAG Verification..." << std::endl;

    // Global Reset Sequence
    top->clk = 0;
    top->rst_n = 0;
    top->tck = 0;
    top->trst_n = 0;
    top->tms = 1;
    top->tdi = 0;
    top->uart_rx_pin = 1;

    tick_sys_clk(top.get(), tfp.get(), 10);
    top->rst_n = 1;
    tick_sys_clk(top.get(), tfp.get(), 10);

    std::cout << "\n============================================" << std::endl;
    std::cout << "  AZ_V SoC JTAG Debug Subsystem Verification" << std::endl;
    std::cout << "============================================" << std::endl;

    // ------------------------------------------------------------------------
    // TEST 1: TAP Reset & IDCODE Verification
    // ------------------------------------------------------------------------
    jtag_reset_tap(top.get(), tfp.get());
    jtag_shift_ir(top.get(), tfp.get(), 0x01); // IDCODE instruction
    uint64_t idcode = jtag_shift_dr(top.get(), tfp.get(), 0, 32);

    std::cout << "[JTAG Test 1] Reading IDCODE... 0x" << std::hex << idcode << std::dec << std::endl;
    if (idcode == 0x1A2B3C4D) {
        std::cout << "[PASS] JTAG IDCODE Match: 0x1A2B3C4D" << std::endl;
    } else {
        std::cerr << "[FAIL] JTAG IDCODE Mismatch! Expected 0x1A2B3C4D, got 0x" << std::hex << idcode << std::dec << std::endl;
        return 1;
    }

    // ------------------------------------------------------------------------
    // TEST 2: CPU Halt Request
    // ------------------------------------------------------------------------
    jtag_shift_ir(top.get(), tfp.get(), 0x11); // DMI instruction
    std::cout << "[JTAG Test 2] Requesting CPU Halt..." << std::endl;
    jtag_dmi_write(top.get(), tfp.get(), 0x10, 0x01); // DM_CONTROL: Halt = 1

    uint32_t dm_status = jtag_dmi_read(top.get(), tfp.get(), 0x11); // DM_STATUS
    std::cout << "[JTAG Test 2] DM Status: 0x" << std::hex << dm_status << std::dec << std::endl;
    if (dm_status & 0x01) {
        std::cout << "[PASS] CPU Halted successfully via JTAG." << std::endl;
    } else {
        std::cerr << "[FAIL] CPU failed to enter Halted state!" << std::endl;
        return 1;
    }

    // ------------------------------------------------------------------------
    // TEST 3: General Purpose Register (GPR) Read & Write
    // ------------------------------------------------------------------------
    std::cout << "[JTAG Test 3] Writing 0xDEADBEEF into GPR x5..." << std::endl;
    jtag_dmi_write(top.get(), tfp.get(), 0x12, 5);          // GPR_ADDR = 5 (x5)
    jtag_dmi_write(top.get(), tfp.get(), 0x13, 0xDEADBEEF); // GPR_DATA = 0xDEADBEEF

    uint32_t gpr_val = jtag_dmi_read(top.get(), tfp.get(), 0x13);
    std::cout << "[JTAG Test 3] Read back GPR x5: 0x" << std::hex << gpr_val << std::dec << std::endl;
    if (gpr_val == 0xDEADBEEF) {
        std::cout << "[PASS] GPR Read/Write Verified!" << std::endl;
    } else {
        std::cerr << "[FAIL] GPR Read/Write Mismatch! Got 0x" << std::hex << gpr_val << std::dec << std::endl;
        return 1;
    }

    // ------------------------------------------------------------------------
    // TEST 4: Program Counter (PC) Inspect & Override
    // ------------------------------------------------------------------------
    uint32_t pc_orig = jtag_dmi_read(top.get(), tfp.get(), 0x14); // Read current PC
    std::cout << "[JTAG Test 4] Current CPU PC: 0x" << std::hex << pc_orig << std::dec << std::endl;

    std::cout << "[JTAG Test 4] Overriding CPU PC to 0x00000100..." << std::endl;
    jtag_dmi_write(top.get(), tfp.get(), 0x14, 0x00000100);

    uint32_t pc_new = jtag_dmi_read(top.get(), tfp.get(), 0x14);
    std::cout << "[JTAG Test 4] Read back CPU PC: 0x" << std::hex << pc_new << std::dec << std::endl;
    if (pc_new == 0x00000100) {
        std::cout << "[PASS] CPU PC Override Verified!" << std::endl;
    } else {
        std::cerr << "[FAIL] CPU PC Override Mismatch! Got 0x" << std::hex << pc_new << std::dec << std::endl;
        return 1;
    }

    // Restore original PC
    jtag_dmi_write(top.get(), tfp.get(), 0x14, pc_orig);

    // ------------------------------------------------------------------------
    // TEST 5: SRAM Memory Read & Write via Debug Module
    // ------------------------------------------------------------------------
    std::cout << "[JTAG Test 5] Writing 0xCAFEBABE to SRAM at 0x00000800..." << std::endl;
    jtag_dmi_write(top.get(), tfp.get(), 0x15, 0x00000800); // MEM_ADDR = 0x0800 (within 4KB RAM)
    jtag_dmi_write(top.get(), tfp.get(), 0x16, 0xCAFEBABE); // MEM_DATA = 0xCAFEBABE
    jtag_dmi_write(top.get(), tfp.get(), 0x17, 0x02);       // MEM_CTRL = 2 (Write Trigger)
    tick_sys_clk(top.get(), tfp.get(), 10);

    std::cout << "[JTAG Test 5] Reading from SRAM at 0x00000800..." << std::endl;
    jtag_dmi_write(top.get(), tfp.get(), 0x17, 0x01);       // MEM_CTRL = 1 (Read Trigger)
    tick_sys_clk(top.get(), tfp.get(), 10);

    uint32_t mem_val = jtag_dmi_read(top.get(), tfp.get(), 0x16);
    std::cout << "[JTAG Test 5] Read back SRAM data: 0x" << std::hex << mem_val << std::dec << std::endl;
    if (mem_val == 0xCAFEBABE) {
        std::cout << "[PASS] Debug Memory Read/Write Verified!" << std::endl;
    } else {
        std::cerr << "[FAIL] Debug Memory Read/Write Mismatch! Got 0x" << std::hex << mem_val << std::dec << std::endl;
        return 1;
    }

    // ------------------------------------------------------------------------
    // TEST 6: CPU Resume & Continue Full SoC Integration
    // ------------------------------------------------------------------------
    std::cout << "[JTAG Test 6] Requesting CPU Resume..." << std::endl;
    jtag_dmi_write(top.get(), tfp.get(), 0x10, 0x02); // DM_CONTROL: Resume = 1

    dm_status = jtag_dmi_read(top.get(), tfp.get(), 0x11);
    if ((dm_status & 0x01) == 0) {
        std::cout << "[PASS] CPU Resumed execution successfully." << std::endl;
    } else {
        std::cerr << "[FAIL] CPU failed to resume!" << std::endl;
        return 1;
    }

    std::cout << "\n[AZ_V SoC Sim] Continuing normal SoC execution (MLKEM-512 + UART)..." << std::endl;

    vluint64_t max_cycles = 2000000;
    vluint64_t cycle = 0;

    while (!Verilated::gotFinish() && cycle < max_cycles) {
        tick_sys_clk(top.get(), tfp.get(), 1);
        cycle++;

        if (top->sim_exit) {
            std::cout << std::endl;
            std::cout << "[AZ_V SoC Sim] Target exit signal received!" << std::endl;
            std::cout << "[AZ_V SoC Sim] Exit Code: 0x" << std::hex << top->exit_code << std::dec << std::endl;
            if (top->exit_code == 0) {
                std::cout << "\n============================================" << std::endl;
                std::cout << "  [PASS] ALL JTAG & SoC TESTS PASSED!" << std::endl;
                std::cout << "============================================" << std::endl;
            } else {
                std::cout << "[AZ_V SoC Sim] *** TEST FAILED ***" << std::endl;
            }
            break;
        }
    }

    if (cycle >= max_cycles) {
        std::cerr << "[AZ_V SoC Sim] ERROR: Simulation timed out after " << max_cycles << " cycles!" << std::endl;
    }

    tfp->close();
    top->final();

    return (top->sim_exit && top->exit_code == 0) ? 0 : 1;
}
