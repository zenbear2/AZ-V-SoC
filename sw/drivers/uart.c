// ============================================================================
// File: uart.c
// Description: Bare-Metal UART Driver Implementation for AZ_V SoC
// Project: AZ_V_SoC
// ============================================================================

#include "uart.h"

#define SIM_STDOUT (*(volatile uint32_t *)0x0000FFF0)

void uart_init(uint16_t baud_div) {
    UART_REG_BAUD_DIV = baud_div;
    UART_REG_CTRL = 0x0000001B; // Enable TX & RX, 8N1
}

void uart_putc(char c) {
    // Wait until TX FIFO is not full
    while (UART_REG_STATUS & UART_STATUS_TX_FULL);
    UART_REG_DATA = (uint32_t)c;
    SIM_STDOUT = (uint32_t)c; // Echo to host simulation stdout
}

int uart_rx_ready(void) {
    return (UART_REG_STATUS & UART_STATUS_RX_VALID) ? 1 : 0;
}

char uart_getc(void) {
    while (!uart_rx_ready());
    return (char)(UART_REG_DATA & 0xFF);
}

void uart_puts(const char *str) {
    while (*str) {
        if (*str == '\n') {
            uart_putc('\r');
        }
        uart_putc(*str++);
    }
}

void uart_print_hex(uint32_t val) {
    const char hex_chars[] = "0123456789ABCDEF";
    uart_puts("0x");
    for (int i = 7; i >= 0; i--) {
        uint8_t nibble = (val >> (i * 4)) & 0xF;
        uart_putc(hex_chars[nibble]);
    }
}

void uart_print_dec(uint32_t val) {
    if (val == 0) {
        uart_putc('0');
        return;
    }
    char buf[12];
    int idx = 0;
    while (val > 0) {
        uint32_t rem = 0;
        uint32_t quot = 0;
        for (int i = 31; i >= 0; i--) {
            rem = (rem << 1) | ((val >> i) & 1);
            if (rem >= 10) {
                rem -= 10;
                quot |= (1U << i);
            }
        }
        buf[idx++] = '0' + rem;
        val = quot;
    }
    for (int i = idx - 1; i >= 0; i--) {
        uart_putc(buf[i]);
    }
}
