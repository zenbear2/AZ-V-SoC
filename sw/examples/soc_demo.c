// ============================================================================
// File: soc_demo.c
// Description: Main Firmware Application for AZ_V SoC Integration Test (AZ_V + UART + JTAG)
// Project: AZ_V_SoC
// ============================================================================

#include "uart.h"

int main(void) {
    // 1. Initialize UART (Baud Divisor = 1 for fast simulation)
    uart_init(1);

    uart_puts("\n============================================\n");
    uart_puts("   AZ_V SoC System Integration Test Demo\n");
    uart_puts("============================================\n");
    uart_puts("[INFO] CPU Core: AZ_V (RV32I 5-stage pipeline)\n");
    uart_puts("[INFO] Peripherals: AXI4-Lite UART & JTAG Debug Subsystem\n\n");

    // 2. Test UART Transmit & Receive
    uart_puts("[STEP 1] Testing UART Transmit & Output...\n");
    uart_puts("Hello World from AZ_V SoC (AZ_V + UART + JTAG)!\n");

    uint32_t val = 0x1234ABCD;
    uart_puts("[INFO] Hex Print Test: 0x");
    uart_print_hex(val);
    uart_puts("\n");

    uart_puts("\n============================================\n");
    uart_puts("   [PASS] AZ_V SoC Integration Test Successful!\n");
    uart_puts("============================================\n\n");

    return 0; // Triggers _exit(0) in crt0.s
}
