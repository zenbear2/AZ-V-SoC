/* Linker Script for AZ_V SoC (4KB Unified RAM) */

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00001000
}

SECTIONS
{
  . = 0x00000000;

  .text.init : ALIGN(4) {
    *(.text.init)
  } > ram

  .text : ALIGN(4) {
    *(.text .text.*)
  } > ram

  .rodata : ALIGN(4) {
    *(.rodata .rodata.*)
  } > ram

  .data : ALIGN(4) {
    *(.data .data.*)
    *(.sdata .sdata.*)
  } > ram

  .bss : ALIGN(4) {
    __bss_start = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > ram

  _end = .;
  __stack_top = 0x00001000;
}
