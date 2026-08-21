// ============================================================================
// File: az_v_soc_tb.sv
// Description: Top-Level SystemVerilog Testbench for AZ_V SoC
// Project: AZ_V_SoC
// ============================================================================

`timescale 1ns / 1ps

module az_v_soc_tb #(
  parameter string HEX_FILE = "sw/build/soc_demo.hex"
)(
  input  logic        clk,
  input  logic        rst_n,
  output logic        sim_exit,
  output logic [31:0] exit_code,
  output logic        uart_tx_pin,
  input  logic        uart_rx_pin,

  // JTAG Ports
  input  logic        tck,
  input  logic        trst_n,
  input  logic        tms,
  input  logic        tdi,
  output logic        tdo,
  output logic        tdo_oe
);

  logic irq_out;

  // Instantiate Top SoC
  az_v_soc_top #(
    .HEX_FILE (HEX_FILE)
  ) u_soc (
    .clk         (clk),
    .rst_n       (rst_n),
    .uart_rx_pin (uart_rx_pin),
    .uart_tx_pin (uart_tx_pin),
    .sim_exit    (sim_exit),
    .exit_code   (exit_code),
    .irq_out     (irq_out),
    .tck         (tck),
    .trst_n      (trst_n),
    .tms         (tms),
    .tdi         (tdi),
    .tdo         (tdo),
    .tdo_oe      (tdo_oe)
  );

endmodule
