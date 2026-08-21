// ============================================================================
// File: mlkem512.c
// Description: Bare-Metal Driver Implementation for MLKEM-512 Accelerator
// Project: AZ_V_SoC
// ============================================================================

#include "mlkem512.h"

void mlkem512_init(void) {
    MLKEM_REG_CTRL = 0;
    MLKEM_REG_STREAM_CTRL = 0;
}

void mlkem512_start(uint8_t op_mode) {
    uint32_t ctrl_val = 1 | ((uint32_t)(op_mode & 0x3) << 1);
    MLKEM_REG_CTRL = ctrl_val;
}

bool mlkem512_is_busy(void) {
    return (MLKEM_REG_STATUS & MLKEM_STATUS_BUSY) != 0;
}

bool mlkem512_is_done(void) {
    return (MLKEM_REG_STATUS & MLKEM_STATUS_DONE) != 0;
}

void mlkem512_wait_done(void) {
    while (!mlkem512_is_done());
}

void mlkem512_push_stream_64(uint64_t val, bool is_last) {
    MLKEM_REG_STREAM_CTRL = is_last ? 1 : 0;
    MLKEM_REG_DIN_LOW = (uint32_t)(val & 0xFFFFFFFF);
    MLKEM_REG_DIN_HIGH = (uint32_t)(val >> 32); // Triggers push
}

uint64_t mlkem512_pop_stream_64(void) {
    uint32_t low = MLKEM_REG_DOUT_LOW;
    uint32_t high = MLKEM_REG_DOUT_HIGH; // Triggers pop
    return ((uint64_t)high << 32) | (uint64_t)low;
}
