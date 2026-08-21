// ============================================================================
// File: az_v_soc_interconnect.sv
// Description: Memory Map Decoder & AXI4-Lite Master Bridge for AZ_V SoC
// Project: AZ_V_SoC (AZ_V CPU + UART + JTAG)
// ============================================================================

`timescale 1ns / 1ps

module az_v_soc_interconnect (
  input  logic        clk,
  input  logic        rst_n,

  // CPU Data Interface
  input  logic [31:0] dmem_addr,
  input  logic [31:0] dmem_wdata,
  input  logic [3:0]  dmem_byte_enable,
  input  logic        dmem_req,
  input  logic        dmem_we,
  output logic [31:0] dmem_rdata,

  // RAM Interface
  output logic [31:0] ram_dmem_addr,
  output logic [31:0] ram_dmem_wdata,
  output logic [3:0]  ram_dmem_byte_enable,
  output logic        ram_dmem_req,
  output logic        ram_dmem_we,
  input  logic [31:0] ram_dmem_rdata,

  // UART AXI4-Lite Interface
  output logic [31:0] uart_s_axi_awaddr,
  output logic [2:0]  uart_s_axi_awprot,
  output logic        uart_s_axi_awvalid,
  input  logic        uart_s_axi_awready,
  output logic [31:0] uart_s_axi_wdata,
  output logic [3:0]  uart_s_axi_wstrb,
  output logic        uart_s_axi_wvalid,
  input  logic        uart_s_axi_wready,
  input  logic [1:0]  uart_s_axi_bresp,
  input  logic        uart_s_axi_bvalid,
  output logic        uart_s_axi_bready,
  output logic [31:0] uart_s_axi_araddr,
  output logic [2:0]  uart_s_axi_arprot,
  output logic        uart_s_axi_arvalid,
  input  logic        uart_s_axi_arready,
  input  logic [31:0] uart_s_axi_rdata,
  input  logic [1:0]  uart_s_axi_rresp,
  input  logic        uart_s_axi_rvalid,
  output logic        uart_s_axi_rready,

  // Debug Module Memory Master Interface
  input  logic [31:0] debug_mem_addr,
  input  logic [31:0] debug_mem_wdata,
  input  logic [3:0]  debug_mem_byte_enable,
  input  logic        debug_mem_req,
  input  logic        debug_mem_we,
  output logic [31:0] debug_mem_rdata
);

  // Address Region Decoding
  logic is_uart;
  logic is_ram;

  assign is_uart = dmem_req && !debug_mem_req && (dmem_addr[31:24] == 8'h10);
  assign is_ram  = dmem_req && !is_uart;

  // 1. RAM Interface Assignment (Arbitrated with Debug Module)
  assign ram_dmem_addr        = debug_mem_req ? debug_mem_addr        : dmem_addr;
  assign ram_dmem_wdata       = debug_mem_req ? debug_mem_wdata       : dmem_wdata;
  assign ram_dmem_byte_enable = debug_mem_req ? debug_mem_byte_enable : dmem_byte_enable;
  assign ram_dmem_req         = debug_mem_req ? 1'b1                  : is_ram;
  assign ram_dmem_we          = debug_mem_req ? debug_mem_we          : dmem_we;
  assign debug_mem_rdata      = ram_dmem_rdata;

  // 2. UART AXI4-Lite Interface Assignment
  assign uart_s_axi_awaddr  = {24'd0, dmem_addr[7:0]};
  assign uart_s_axi_awprot  = 3'b000;
  assign uart_s_axi_awvalid = is_uart && dmem_we;
  assign uart_s_axi_wdata   = dmem_wdata;
  assign uart_s_axi_wstrb   = dmem_byte_enable;
  assign uart_s_axi_wvalid  = is_uart && dmem_we;
  assign uart_s_axi_bready  = 1'b1;

  assign uart_s_axi_araddr  = {24'd0, dmem_addr[7:0]};
  assign uart_s_axi_arprot  = 3'b000;
  assign uart_s_axi_arvalid = is_uart && !dmem_we;
  assign uart_s_axi_rready  = 1'b1;

  // CPU Read Data Muxing
  always_comb begin
    if (is_uart) begin
      dmem_rdata = uart_s_axi_rdata;
    end else begin
      dmem_rdata = ram_dmem_rdata;
    end
  end

endmodule
