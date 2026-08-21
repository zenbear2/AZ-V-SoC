// ============================================================================
// File: sram_bank_array.sv
// Description: 4KB SRAM Bank Array consisting of 8 x 512B GF180MCU SRAM Macros
// Project: AZ_V_SoC
// ============================================================================

`timescale 1ns / 1ps

module sram_bank_array (
  input  logic        clk,
  input  logic        rst_n,

  // Instruction Memory Interface (Read-Only)
  input  logic [31:0] imem_addr,
  output logic [31:0] imem_rdata,

  // Data Memory Interface (Read/Write)
  input  logic [31:0] dmem_addr,
  input  logic [31:0] dmem_wdata,
  input  logic [3:0]  dmem_byte_enable,
  input  logic        dmem_req,
  input  logic        dmem_we,
  output logic [31:0] dmem_rdata
);

  // 4KB Memory = 1024 Words (Addresses 0x0000_0000 to 0x0000_0FFF)
  // Bank 0 (Lower 2KB): Addresses 0x000 - 0x7FF (512 words x 4 bytes = 4 SRAMs)
  // Bank 1 (Upper 2KB): Addresses 0x800 - 0xFFF (512 words x 4 bytes = 4 SRAMs)

  logic [8:0] i_addr_512;
  logic [8:0] d_addr_512;
  logic       d_bank_sel; // 0: Bank 0, 1: Bank 1

  assign i_addr_512 = imem_addr[10:2];
  assign d_addr_512 = dmem_addr[10:2];
  assign d_bank_sel = dmem_addr[11];

  // Bank 0 SRAM Read Data
  logic [7:0] b0_rdata [4];
  // Bank 1 SRAM Read Data
  logic [7:0] b1_rdata [4];

  // --------------------------------------------------------------------------
  // Bank 0 (Lower 2KB: 4 x 512B SRAM Macros)
  // --------------------------------------------------------------------------
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : gen_bank0
      gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram_b0 (
        .CLK  (clk),
        .CEN  (!(dmem_req && !d_bank_sel)),
        .GWEN (!(dmem_we && dmem_byte_enable[i])),
        .WEN  (~(dmem_we ? {8{dmem_byte_enable[i]}} : 8'b0)),
        .A    (d_addr_512),
        .D    (dmem_wdata[8*i +: 8]),
        .Q    (b0_rdata[i])
      );
    end
  endgenerate

  // --------------------------------------------------------------------------
  // Bank 1 (Upper 2KB: 4 x 512B SRAM Macros)
  // --------------------------------------------------------------------------
  generate
    for (i = 0; i < 4; i++) begin : gen_bank1
      gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram_b1 (
        .CLK  (clk),
        .CEN  (!(dmem_req && d_bank_sel)),
        .GWEN (!(dmem_we && dmem_byte_enable[i])),
        .WEN  (~(dmem_we ? {8{dmem_byte_enable[i]}} : 8'b0)),
        .A    (d_addr_512),
        .D    (dmem_wdata[8*i +: 8]),
        .Q    (b1_rdata[i])
      );
    end
  endgenerate

  // Mux Read Data
  logic d_bank_sel_reg;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) d_bank_sel_reg <= 1'b0;
    else        d_bank_sel_reg <= d_bank_sel;
  end

  assign dmem_rdata = d_bank_sel_reg ? {b1_rdata[3], b1_rdata[2], b1_rdata[1], b1_rdata[0]}
                                     : {b0_rdata[3], b0_rdata[2], b0_rdata[1], b0_rdata[0]};

  assign imem_rdata = dmem_rdata; // Shared memory bus model for simulation/ASIC

endmodule
