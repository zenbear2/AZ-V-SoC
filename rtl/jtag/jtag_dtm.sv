// ============================================================================
// File: jtag_dtm.sv
// Description: JTAG Debug Transport Module (DTM) & Clock Domain Crosser (CDC)
// Project: AZ_V_SoC JTAG Debug Subsystem
// ============================================================================

`timescale 1ns / 1ps

module jtag_dtm (
  // TCK Domain Signals (from jtag_tap)
  input  logic        tck,
  input  logic        trst_n,

  input  logic [5:0]  tap_dmi_req_addr,
  input  logic [31:0] tap_dmi_req_data,
  input  logic [1:0]  tap_dmi_req_op,
  input  logic        tap_dmi_req_valid,
  output logic        tap_dmi_req_ready,

  output logic [5:0]  tap_dmi_rsp_addr,
  output logic [31:0] tap_dmi_rsp_data,
  output logic [1:0]  tap_dmi_rsp_op,
  output logic        tap_dmi_rsp_valid,

  // System Clock Domain Signals (to jtag_dm)
  input  logic        clk,
  input  logic        rst_n,

  output logic [5:0]  sys_dmi_req_addr,
  output logic [31:0] sys_dmi_req_data,
  output logic [1:0]  sys_dmi_req_op,
  output logic        sys_dmi_req_valid,
  input  logic        sys_dmi_req_ready,

  input  logic [5:0]  sys_dmi_rsp_addr,
  input  logic [31:0] sys_dmi_rsp_data,
  input  logic [1:0]  sys_dmi_rsp_op,
  input  logic        sys_dmi_rsp_valid
);

  // --------------------------------------------------------------------------
  // CDC Handshake Logic (TCK <-> CLK)
  // --------------------------------------------------------------------------
  logic        tck_req_toggle;
  logic [5:0]  tck_req_addr;
  logic [31:0] tck_req_data;
  logic [1:0]  tck_req_op;

  logic [2:0]  sys_req_sync;
  logic        sys_req_pending;

  logic        sys_ack_toggle;
  logic [5:0]  sys_rsp_addr;
  logic [31:0] sys_rsp_data;
  logic [1:0]  sys_rsp_op;

  logic [2:0]  tck_ack_sync;

  // 1. TCK Domain: Latch request and toggle handshake flag
  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      tck_req_toggle    <= 1'b0;
      tck_req_addr      <= 6'd0;
      tck_req_data      <= 32'd0;
      tck_req_op        <= 2'd0;
      tap_dmi_req_ready <= 1'b1;
    end else begin
      if (tap_dmi_req_valid && tap_dmi_req_ready) begin
        tck_req_toggle    <= ~tck_req_toggle;
        tck_req_addr      <= tap_dmi_req_addr;
        tck_req_data      <= tap_dmi_req_data;
        tck_req_op        <= tap_dmi_req_op;
        tap_dmi_req_ready <= 1'b0;
      end else if (tck_ack_sync[2] == tck_ack_sync[1] && !tap_dmi_req_ready) begin
        tap_dmi_req_ready <= 1'b1;
      end
    end
  end

  // 2. Synchronize TCK req toggle to System Clock Domain
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sys_req_sync <= 3'b000;
    end else begin
      sys_req_sync <= {sys_req_sync[1:0], tck_req_toggle};
    end
  end

  // Detect edge transition on sys_req_sync
  logic sys_req_event;
  assign sys_req_event = sys_req_sync[2] ^ sys_req_sync[1];

  // 3. System Clock Domain: Dispatch request to jtag_dm
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sys_dmi_req_addr  <= 6'd0;
      sys_dmi_req_data  <= 32'd0;
      sys_dmi_req_op    <= 2'd0;
      sys_dmi_req_valid <= 1'b0;
      sys_req_pending   <= 1'b0;
      sys_ack_toggle    <= 1'b0;
      sys_rsp_addr      <= 6'd0;
      sys_rsp_data      <= 32'd0;
      sys_rsp_op        <= 2'd0;
    end else begin
      if (sys_req_event && !sys_req_pending) begin
        sys_dmi_req_addr  <= tck_req_addr;
        sys_dmi_req_data  <= tck_req_data;
        sys_dmi_req_op    <= tck_req_op;
        sys_dmi_req_valid <= 1'b1;
        sys_req_pending   <= 1'b1;
      end else if (sys_dmi_req_valid && sys_dmi_req_ready) begin
        sys_dmi_req_valid <= 1'b0;
      end

      if (sys_req_pending && sys_dmi_rsp_valid) begin
        sys_rsp_addr    <= sys_dmi_rsp_addr;
        sys_rsp_data    <= sys_dmi_rsp_data;
        sys_rsp_op      <= sys_dmi_rsp_op;
        sys_ack_toggle  <= ~sys_ack_toggle;
        sys_req_pending <= 1'b0;
      end
    end
  end

  // 4. Synchronize System ack toggle back to TCK Domain
  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      tck_ack_sync <= 3'b000;
    end else begin
      tck_ack_sync <= {tck_ack_sync[1:0], sys_ack_toggle};
    end
  end

  // 5. TCK Domain Response Synchronization & Latching
  logic [5:0]  tck_rsp_addr_reg;
  logic [31:0] tck_rsp_data_reg;
  logic [1:0]  tck_rsp_op_reg;
  logic        tck_rsp_valid_reg;

  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      tck_rsp_addr_reg  <= 6'd0;
      tck_rsp_data_reg  <= 32'd0;
      tck_rsp_op_reg    <= 2'd0;
      tck_rsp_valid_reg <= 1'b0;
    end else begin
      if (tap_dmi_req_valid) begin
        tck_rsp_valid_reg <= 1'b0;
      end else if (tck_ack_sync[2] ^ tck_ack_sync[1]) begin
        tck_rsp_addr_reg  <= sys_rsp_addr;
        tck_rsp_data_reg  <= sys_rsp_data;
        tck_rsp_op_reg    <= sys_rsp_op;
        tck_rsp_valid_reg <= 1'b1;
      end
    end
  end

  assign tap_dmi_rsp_addr  = tck_rsp_addr_reg;
  assign tap_dmi_rsp_data  = tck_rsp_data_reg;
  assign tap_dmi_rsp_op    = tck_rsp_op_reg;
  assign tap_dmi_rsp_valid = tck_rsp_valid_reg;

endmodule
