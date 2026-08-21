// ============================================================================
// File: mlkem512.h
// Description: Bare-Metal Driver Header for MLKEM-512 Accelerator
// Project: AZ_V_SoC
// ============================================================================

#ifndef MLKEM512_H
#define MLKEM512_H

#include <stdint.h>
#include <stdbool.h>

#define MLKEM_BASE_ADDR        0x20000000

#define MLKEM_REG_CTRL         (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x00))
#define MLKEM_REG_STATUS       (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x04))
#define MLKEM_REG_STREAM_CTRL  (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x08))
#define MLKEM_REG_DIN_LOW      (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x10))
#define MLKEM_REG_DIN_HIGH     (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x14))
#define MLKEM_REG_DOUT_LOW     (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x18))
#define MLKEM_REG_DOUT_HIGH    (*(volatile uint32_t *)(MLKEM_BASE_ADDR + 0x1C))

#define MLKEM_OP_KEYGEN        0x00
#define MLKEM_OP_ENCAPS        0x01
#define MLKEM_OP_DECAPS        0x02

#define MLKEM_STATUS_DONE      (1 << 0)
#define MLKEM_STATUS_BUSY      (1 << 1)

void mlkem512_init(void);
void mlkem512_start(uint8_t op_mode);
bool mlkem512_is_busy(void);
bool mlkem512_is_done(void);
void mlkem512_wait_done(void);
void mlkem512_push_stream_64(uint64_t val, bool is_last);
uint64_t mlkem512_pop_stream_64(void);

#endif // MLKEM512_H
