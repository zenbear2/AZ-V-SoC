// ============================================================================
// File: az_v_soc_top.sv
// Description: Top-Level System-on-Chip (SoC) Module
// Project: AZ_V_SoC (AZ_V CPU + AXI4-Lite UART + MLKEM-512 Accelerator)
// ============================================================================

`timescale 1ns / 1ps

module az_v_soc_top #(
  parameter string HEX_FILE = ""
)(
  input  logic        clk,
  input  logic        rst_n,

  // External UART Interface
  input  logic        uart_rx_pin,
  output logic        uart_tx_pin,

  // Simulation Control Signals
  output logic        sim_exit,
  output logic [31:0] exit_code,

  // Combined Interrupt Line
  output logic        irq_out,

  // JTAG External Pins
  input  logic        tck,
  input  logic        trst_n,
  input  logic        tms,
  input  logic        tdi,
  output logic        tdo,
  output logic        tdo_oe
);

  // --------------------------------------------------------------------------
  // Interconnect & Debug Wires
  // --------------------------------------------------------------------------

  // JTAG TAP -> DTM Wires
  logic [5:0]  tap_dmi_req_addr;
  logic [31:0] tap_dmi_req_data;
  logic [1:0]  tap_dmi_req_op;
  logic        tap_dmi_req_valid;
  logic        tap_dmi_req_ready;

  logic [5:0]  tap_dmi_rsp_addr;
  logic [31:0] tap_dmi_rsp_data;
  logic [1:0]  tap_dmi_rsp_op;
  logic        tap_dmi_rsp_valid;

  // DTM -> DM Wires
  logic [5:0]  sys_dmi_req_addr;
  logic [31:0] sys_dmi_req_data;
  logic [1:0]  sys_dmi_req_op;
  logic        sys_dmi_req_valid;
  logic        sys_dmi_req_ready;

  logic [5:0]  sys_dmi_rsp_addr;
  logic [31:0] sys_dmi_rsp_data;
  logic [1:0]  sys_dmi_rsp_op;
  logic        sys_dmi_rsp_valid;

  // DM -> CPU Debug Wires
  logic        debug_halt_req;
  logic        debug_resume_req;
  logic        debug_step_req;
  logic        debug_halted;

  logic [4:0]  debug_gpr_addr;
  logic [31:0] debug_gpr_rdata;
  logic [31:0] debug_gpr_wdata;
  logic        debug_gpr_wen;

  logic [31:0] debug_pc_rdata;
  logic [31:0] debug_pc_wdata;
  logic        debug_pc_wen;

  // DM -> Memory Master Wires
  logic [31:0] debug_mem_addr;
  logic [31:0] debug_mem_wdata;
  logic [3:0]  debug_mem_byte_enable;
  logic        debug_mem_req;
  logic        debug_mem_we;
  logic [31:0] debug_mem_rdata;

  // CPU Memory Interface Wires
  logic [31:0] imem_addr;
  logic [31:0] imem_rdata;

  logic [31:0] dmem_addr;
  logic [31:0] dmem_wdata;
  logic [3:0]  dmem_byte_enable;
  logic        dmem_req;
  logic        dmem_we;
  logic [31:0] dmem_rdata;

  // RAM Interface Wires
  logic [31:0] ram_dmem_addr;
  logic [31:0] ram_dmem_wdata;
  logic [3:0]  ram_dmem_byte_enable;
  logic        ram_dmem_req;
  logic        ram_dmem_we;
  logic [31:0] ram_dmem_rdata;

  // UART AXI4-Lite Interface Wires
  logic [31:0] uart_s_axi_awaddr;
  logic [2:0]  uart_s_axi_awprot;
  logic        uart_s_axi_awvalid;
  logic        uart_s_axi_awready;
  logic [31:0] uart_s_axi_wdata;
  logic [3:0]  uart_s_axi_wstrb;
  logic        uart_s_axi_wvalid;
  logic        uart_s_axi_wready;
  logic [1:0]  uart_s_axi_bresp;
  logic        uart_s_axi_bvalid;
  logic        uart_s_axi_bready;
  logic [31:0] uart_s_axi_araddr;
  logic [2:0]  uart_s_axi_arprot;
  logic        uart_s_axi_arvalid;
  logic        uart_s_axi_arready;
  logic [31:0] uart_s_axi_rdata;
  logic [1:0]  uart_s_axi_rresp;
  logic        uart_s_axi_rvalid;
  logic        uart_s_axi_rready;
  logic        uart_irq;

  assign irq_out = uart_irq;

  // --------------------------------------------------------------------------
  // JTAG Subsystem Instantiations (TAP + DTM + DM)
  // --------------------------------------------------------------------------
  jtag_tap #(
    .IDCODE_VALUE (32'h1A2B3C4D)
  ) u_jtag_tap (
    .tck           (tck),
    .trst_n        (trst_n),
    .tms           (tms),
    .tdi           (tdi),
    .tdo           (tdo),
    .tdo_oe        (tdo_oe),

    .dmi_req_addr  (tap_dmi_req_addr),
    .dmi_req_data  (tap_dmi_req_data),
    .dmi_req_op    (tap_dmi_req_op),
    .dmi_req_valid (tap_dmi_req_valid),
    .dmi_req_ready (tap_dmi_req_ready),

    .dmi_rsp_addr  (tap_dmi_rsp_addr),
    .dmi_rsp_data  (tap_dmi_rsp_data),
    .dmi_rsp_op    (tap_dmi_rsp_op),
    .dmi_rsp_valid (tap_dmi_rsp_valid)
  );

  jtag_dtm u_jtag_dtm (
    .tck               (tck),
    .trst_n            (trst_n),
    .tap_dmi_req_addr  (tap_dmi_req_addr),
    .tap_dmi_req_data  (tap_dmi_req_data),
    .tap_dmi_req_op    (tap_dmi_req_op),
    .tap_dmi_req_valid (tap_dmi_req_valid),
    .tap_dmi_req_ready (tap_dmi_req_ready),
    .tap_dmi_rsp_addr  (tap_dmi_rsp_addr),
    .tap_dmi_rsp_data  (tap_dmi_rsp_data),
    .tap_dmi_rsp_op    (tap_dmi_rsp_op),
    .tap_dmi_rsp_valid (tap_dmi_rsp_valid),

    .clk               (clk),
    .rst_n             (rst_n),
    .sys_dmi_req_addr  (sys_dmi_req_addr),
    .sys_dmi_req_data  (sys_dmi_req_data),
    .sys_dmi_req_op    (sys_dmi_req_op),
    .sys_dmi_req_valid (sys_dmi_req_valid),
    .sys_dmi_req_ready (sys_dmi_req_ready),
    .sys_dmi_rsp_addr  (sys_dmi_rsp_addr),
    .sys_dmi_rsp_data  (sys_dmi_rsp_data),
    .sys_dmi_rsp_op    (sys_dmi_rsp_op),
    .sys_dmi_rsp_valid (sys_dmi_rsp_valid)
  );

  jtag_dm u_jtag_dm (
    .clk                   (clk),
    .rst_n                 (rst_n),
    .dmi_req_addr          (sys_dmi_req_addr),
    .dmi_req_data          (sys_dmi_req_data),
    .dmi_req_op            (sys_dmi_req_op),
    .dmi_req_valid         (sys_dmi_req_valid),
    .dmi_req_ready         (sys_dmi_req_ready),
    .dmi_rsp_addr          (sys_dmi_rsp_addr),
    .dmi_rsp_data          (sys_dmi_rsp_data),
    .dmi_rsp_op            (sys_dmi_rsp_op),
    .dmi_rsp_valid         (sys_dmi_rsp_valid),

    .debug_halt_req        (debug_halt_req),
    .debug_resume_req      (debug_resume_req),
    .debug_step_req        (debug_step_req),
    .cpu_halted            (debug_halted),

    .debug_gpr_addr        (debug_gpr_addr),
    .debug_gpr_rdata       (debug_gpr_rdata),
    .debug_gpr_wdata       (debug_gpr_wdata),
    .debug_gpr_wen         (debug_gpr_wen),

    .debug_pc_rdata        (debug_pc_rdata),
    .debug_pc_wdata        (debug_pc_wdata),
    .debug_pc_wen          (debug_pc_wen),

    .debug_mem_addr        (debug_mem_addr),
    .debug_mem_wdata       (debug_mem_wdata),
    .debug_mem_byte_enable (debug_mem_byte_enable),
    .debug_mem_req         (debug_mem_req),
    .debug_mem_we          (debug_mem_we),
    .debug_mem_rdata       (debug_mem_rdata)
  );

  // --------------------------------------------------------------------------
  // 1. Instantiate AZ_V CPU Core Top
  // --------------------------------------------------------------------------
  az_v_core_top u_cpu (
    .clk              (clk),
    .rst_n            (rst_n),
    .imem_addr        (imem_addr),
    .imem_rdata       (imem_rdata),
    .dmem_addr        (dmem_addr),
    .dmem_wdata       (dmem_wdata),
    .dmem_byte_enable (dmem_byte_enable),
    .dmem_req         (dmem_req),
    .dmem_we          (dmem_we),
    .dmem_rdata       (dmem_rdata),

    .debug_halt_req   (debug_halt_req),
    .debug_resume_req (debug_resume_req),
    .debug_halted     (debug_halted),
    .debug_gpr_addr   (debug_gpr_addr),
    .debug_gpr_rdata  (debug_gpr_rdata),
    .debug_gpr_wdata  (debug_gpr_wdata),
    .debug_gpr_wen    (debug_gpr_wen),
    .debug_pc_wen     (debug_pc_wen),
    .debug_pc_wdata   (debug_pc_wdata),
    .debug_pc_rdata   (debug_pc_rdata)
  );

  // --------------------------------------------------------------------------
  // 2. Instantiate System Interconnect & Memory Map Decoder
  // --------------------------------------------------------------------------
  az_v_soc_interconnect u_interconnect (
    .clk                  (clk),
    .rst_n                (rst_n),
    .dmem_addr            (dmem_addr),
    .dmem_wdata           (dmem_wdata),
    .dmem_byte_enable     (dmem_byte_enable),
    .dmem_req             (dmem_req),
    .dmem_we              (dmem_we),
    .dmem_rdata           (dmem_rdata),

    .ram_dmem_addr        (ram_dmem_addr),
    .ram_dmem_wdata       (ram_dmem_wdata),
    .ram_dmem_byte_enable (ram_dmem_byte_enable),
    .ram_dmem_req         (ram_dmem_req),
    .ram_dmem_we          (ram_dmem_we),
    .ram_dmem_rdata       (ram_dmem_rdata),

    .uart_s_axi_awaddr    (uart_s_axi_awaddr),
    .uart_s_axi_awprot    (uart_s_axi_awprot),
    .uart_s_axi_awvalid   (uart_s_axi_awvalid),
    .uart_s_axi_awready   (uart_s_axi_awready),
    .uart_s_axi_wdata     (uart_s_axi_wdata),
    .uart_s_axi_wstrb     (uart_s_axi_wstrb),
    .uart_s_axi_wvalid    (uart_s_axi_wvalid),
    .uart_s_axi_wready    (uart_s_axi_wready),
    .uart_s_axi_bresp     (uart_s_axi_bresp),
    .uart_s_axi_bvalid    (uart_s_axi_bvalid),
    .uart_s_axi_bready    (uart_s_axi_bready),
    .uart_s_axi_araddr    (uart_s_axi_araddr),
    .uart_s_axi_arprot    (uart_s_axi_arprot),
    .uart_s_axi_arvalid   (uart_s_axi_arvalid),
    .uart_s_axi_arready   (uart_s_axi_arready),
    .uart_s_axi_rdata     (uart_s_axi_rdata),
    .uart_s_axi_rresp     (uart_s_axi_rresp),
    .uart_s_axi_rvalid    (uart_s_axi_rvalid),
    .uart_s_axi_rready    (uart_s_axi_rready),

    .debug_mem_addr        (debug_mem_addr),
    .debug_mem_wdata       (debug_mem_wdata),
    .debug_mem_byte_enable (debug_mem_byte_enable),
    .debug_mem_req         (debug_mem_req),
    .debug_mem_we          (debug_mem_we),
    .debug_mem_rdata       (debug_mem_rdata)
  );

  // --------------------------------------------------------------------------
  // 3. Instantiate Main SRAM Memory (ASIC Macro Array vs Simulation RAM Model)
  // --------------------------------------------------------------------------
`ifdef ASIC_SYNTHESIS
  sram_bank_array u_sram_bank_array (
    .clk              (clk),
    .rst_n            (rst_n),
    .imem_addr        (imem_addr),
    .imem_rdata       (imem_rdata),
    .dmem_addr        (ram_dmem_addr),
    .dmem_wdata       (ram_dmem_wdata),
    .dmem_byte_enable (ram_dmem_byte_enable),
    .dmem_req         (ram_dmem_req),
    .dmem_we          (ram_dmem_we),
    .dmem_rdata       (ram_dmem_rdata)
  );
  assign sim_exit  = 1'b0;
  assign exit_code = 32'd0;
`else
  ram_model #(
    .MEM_SIZE_BYTES (4096),
    .HEX_FILE       (HEX_FILE)
  ) u_ram (
    .clk              (clk),
    .rst_n            (rst_n),
    .imem_addr        (imem_addr),
    .imem_rdata       (imem_rdata),
    .dmem_addr        (ram_dmem_addr),
    .dmem_wdata       (ram_dmem_wdata),
    .dmem_byte_enable (ram_dmem_byte_enable),
    .dmem_req         (ram_dmem_req),
    .dmem_we          (ram_dmem_we),
    .dmem_rdata       (ram_dmem_rdata),
    .sim_exit         (sim_exit),
    .exit_code        (exit_code)
  );
`endif

  // --------------------------------------------------------------------------
  // 4. Instantiate AXI4-Lite UART IP Top
  // --------------------------------------------------------------------------
  az_v_uart_top u_uart (
    .clk           (clk),
    .rst_n         (rst_n),
    .uart_rx_pin   (uart_rx_pin),
    .uart_tx_pin   (uart_tx_pin),
    .irq           (uart_irq),

    .s_axi_awaddr  (uart_s_axi_awaddr),
    .s_axi_awprot  (uart_s_axi_awprot),
    .s_axi_awvalid (uart_s_axi_awvalid),
    .s_axi_awready (uart_s_axi_awready),
    .s_axi_wdata   (uart_s_axi_wdata),
    .s_axi_wstrb   (uart_s_axi_wstrb),
    .s_axi_wvalid  (uart_s_axi_wvalid),
    .s_axi_wready  (uart_s_axi_wready),
    .s_axi_bresp   (uart_s_axi_bresp),
    .s_axi_bvalid  (uart_s_axi_bvalid),
    .s_axi_bready  (uart_s_axi_bready),
    .s_axi_araddr  (uart_s_axi_araddr),
    .s_axi_arprot  (uart_s_axi_arprot),
    .s_axi_arvalid (uart_s_axi_arvalid),
    .s_axi_arready (uart_s_axi_arready),
    .s_axi_rdata   (uart_s_axi_rdata),
    .s_axi_rresp   (uart_s_axi_rresp),
    .s_axi_rvalid  (uart_s_axi_rvalid),
    .s_axi_rready  (uart_s_axi_rready)
  );

endmodule
