// ============================================================================
// File: chip_core.sv
// Description: Top-Level ASIC Chip Core interfacing Padring to AZ_V SoC
// Project: AZ_V_SoC
// ============================================================================

`default_nettype none

module chip_core #(
  parameter NUM_INPUT_PADS  = 12,
  parameter NUM_BIDIR_PADS  = 40,
  parameter NUM_ANALOG_PADS = 2
)(
  `ifdef USE_POWER_PINS
  inout  wire VDD,
  inout  wire VSS,
  `endif

  input  wire clk,       // System clock from clk_pad
  input  wire rst_n,     // System reset (active low) from rst_n_pad

  // Input-only Pads (from West Padring)
  input  wire [NUM_INPUT_PADS-1:0] input_in,
  output wire [NUM_INPUT_PADS-1:0] input_pu,
  output wire [NUM_INPUT_PADS-1:0] input_pd,

  // Bidirectional Pads (from South, East, North Padring)
  input  wire [NUM_BIDIR_PADS-1:0] bidir_in,
  output wire [NUM_BIDIR_PADS-1:0] bidir_out,
  output wire [NUM_BIDIR_PADS-1:0] bidir_oe,
  output wire [NUM_BIDIR_PADS-1:0] bidir_cs,
  output wire [NUM_BIDIR_PADS-1:0] bidir_sl,
  output wire [NUM_BIDIR_PADS-1:0] bidir_ie,
  output wire [NUM_BIDIR_PADS-1:0] bidir_pu,
  output wire [NUM_BIDIR_PADS-1:0] bidir_pd,

  // Analog Pads
  inout  wire [NUM_ANALOG_PADS-1:0] analog
);

  // --------------------------------------------------------------------------
  // Pad Configuration Defaults
  // --------------------------------------------------------------------------
  assign input_pu = '0;
  assign input_pd = '0;

  assign bidir_cs = '0; // Standard CMOS inputs
  assign bidir_sl = '0; // Fast slew rate
  assign bidir_pu = '0;
  assign bidir_pd = '0;

  // --------------------------------------------------------------------------
  // JTAG & UART Pad Mapping
  // --------------------------------------------------------------------------
  // Inputs (from West pads)
  // input_in[0] : JTAG TCK
  // input_in[1] : JTAG TRST_N
  // input_in[2] : JTAG TMS
  // input_in[3] : JTAG TDI
  // input_in[4] : UART RX
  wire jtag_tck    = input_in[0];
  wire jtag_trst_n = input_in[1];
  wire jtag_tms    = input_in[2];
  wire jtag_tdi    = input_in[3];
  wire uart_rx     = input_in[4];

  // Outputs (to South/East pads)
  wire uart_tx;
  wire irq_out;
  wire jtag_tdo;
  wire jtag_tdo_oe;
  wire sim_exit;
  wire [31:0] exit_code;

  // --------------------------------------------------------------------------
  // AZ_V SoC Top-Level Instance
  // --------------------------------------------------------------------------
  az_v_soc_top u_soc (
    .clk         (clk),
    .rst_n       (rst_n),
    .uart_rx_pin (uart_rx),
    .uart_tx_pin (uart_tx),
    .sim_exit    (sim_exit),
    .exit_code   (exit_code),
    .irq_out     (irq_out),
    .tck         (jtag_tck),
    .trst_n      (jtag_trst_n),
    .tms         (jtag_tms),
    .tdi         (jtag_tdi),
    .tdo         (jtag_tdo),
    .tdo_oe      (jtag_tdo_oe)
  );

  // --------------------------------------------------------------------------
  // Bidir Output Assignment & Output Enables
  // --------------------------------------------------------------------------
  // bidir[0] : UART TX
  // bidir[1] : Interrupt Out
  // bidir[2] : JTAG TDO
  // bidir[3] : JTAG TDO_OE monitor
  // bidir[4] : sim_exit indicator
  // bidir[36:5] : exit_code[31:0]
  // bidir[39:37] : tied to 0

  logic [NUM_BIDIR_PADS-1:0] b_out;
  logic [NUM_BIDIR_PADS-1:0] b_oe;

  always_comb begin
    b_out = '0;
    b_oe  = '0;

    // Pin 0: UART TX
    b_out[0] = uart_tx;
    b_oe[0]  = 1'b1;

    // Pin 1: IRQ Out
    b_out[1] = irq_out;
    b_oe[1]  = 1'b1;

    // Pin 2: JTAG TDO
    b_out[2] = jtag_tdo;
    b_oe[2]  = jtag_tdo_oe;

    // Pin 3: JTAG TDO OE Monitor
    b_out[3] = jtag_tdo_oe;
    b_oe[3]  = 1'b1;

    // Pin 4: Sim Exit
    b_out[4] = sim_exit;
    b_oe[4]  = 1'b1;

    // Pins 5..36: Exit Code (32-bit)
    b_out[36:5] = exit_code;
    b_oe[36:5]  = 32'hFFFF_FFFF;

    // Pins 37..39: Unused / Available GPIO
    b_out[39:37] = '0;
    b_oe[39:37]  = '0;
  end

  assign bidir_out = b_out;
  assign bidir_oe  = b_oe;
  assign bidir_ie  = ~b_oe;

  // Unused input tie-off
  wire _unused = &{input_in[NUM_INPUT_PADS-1:5], bidir_in[NUM_BIDIR_PADS-1:0]};

endmodule

`default_nettype wire
