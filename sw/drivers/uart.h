// ============================================================================
// File: uart.h
// Description: Bare-Metal UART Driver Header for AZ_V SoC
// Project: AZ_V_SoC
// ============================================================================

#ifndef UART_H
#define UART_H

#include <stdint.h>

#define UART_BASE_ADDR        0x10000000

#define UART_REG_DATA         (*(volatile uint32_t *)(UART_BASE_ADDR + 0x00))
#define UART_REG_STATUS       (*(volatile uint32_t *)(UART_BASE_ADDR + 0x04))
#define UART_REG_CTRL         (*(volatile uint32_t *)(UART_BASE_ADDR + 0x08))
#define UART_REG_BAUD_DIV     (*(volatile uint32_t *)(UART_BASE_ADDR + 0x0C))
#define UART_REG_FIFO_STAT    (*(volatile uint32_t *)(UART_BASE_ADDR + 0x10))

#define UART_STATUS_TX_EMPTY  (1 << 0)
#define UART_STATUS_TX_FULL   (1 << 1)
#define UART_STATUS_RX_VALID  (1 << 2)
#define UART_STATUS_RX_FULL   (1 << 3)

void uart_init(uint16_t baud_div);
void uart_putc(char c);
char uart_getc(void);
int  uart_rx_ready(void);
void uart_puts(const char *str);
void uart_print_hex(uint32_t val);
void uart_print_dec(uint32_t val);

#endif // UART_H
