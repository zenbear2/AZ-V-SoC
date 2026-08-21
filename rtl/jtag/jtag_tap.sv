// ============================================================================
// File: jtag_tap.sv
// Description: IEEE 1149.1 JTAG Test Access Port (TAP) Controller
// Project: AZ_V_SoC JTAG Debug Subsystem
// ============================================================================

`timescale 1ns / 1ps

module jtag_tap #(
  parameter logic [31:0] IDCODE_VALUE = 32'h1A2B3C4D
)(
  input  logic        tck,
  input  logic        trst_n,
  input  logic        tms,
  input  logic        tdi,
  output logic        tdo,
  output logic        tdo_oe,

  // DMI Interface to DTM
  output logic [5:0]  dmi_req_addr,
  output logic [31:0] dmi_req_data,
  output logic [1:0]  dmi_req_op,
  output logic        dmi_req_valid,
  input  logic        dmi_req_ready,

  input  logic [5:0]  dmi_rsp_addr,
  input  logic [31:0] dmi_rsp_data,
  input  logic [1:0]  dmi_rsp_op,
  input  logic        dmi_rsp_valid
);

  // TAP Controller FSM States
  typedef enum logic [3:0] {
    TEST_LOGIC_RESET = 4'h0,
    RUN_TEST_IDLE    = 4'h1,
    SELECT_DR_SCAN   = 4'h2,
    CAPTURE_DR       = 4'h3,
    SHIFT_DR         = 4'h4,
    EXIT1_DR         = 4'h5,
    PAUSE_DR         = 4'h6,
    EXIT2_DR         = 4'h7,
    UPDATE_DR        = 4'h8,
    SELECT_IR_SCAN   = 4'h9,
    CAPTURE_IR       = 4'hA,
    SHIFT_IR         = 4'hB,
    EXIT1_IR         = 4'hC,
    PAUSE_IR         = 4'hD,
    EXIT2_IR         = 4'hE,
    UPDATE_IR        = 4'hF
  } tap_state_e;

  tap_state_e state, next_state;

  // JTAG Instructions (5-bit IR)
  localparam logic [4:0] IR_IDCODE = 5'h01;
  localparam logic [4:0] IR_DTMCS  = 5'h10;
  localparam logic [4:0] IR_DMI    = 5'h11;
  localparam logic [4:0] IR_BYPASS = 5'h1F;

  // Internal Registers
  logic [4:0]  ir_reg, ir_shift;
  logic [31:0] idcode_shift;
  logic        bypass_reg;
  logic [31:0] dtmcs_shift;
  logic [39:0] dmi_shift;

  // DTMCS register layout:
  // [31:18] reserved, [17] dmihardreset, [16] dmireset, [14:12] idle, [11:10] dmistat, [9:4] abits=6, [3:0] version=1
  localparam logic [31:0] DTMCS_DEFAULT = 32'h00000061;

  // TAP State Machine transitions (posedge TCK)
  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      state <= TEST_LOGIC_RESET;
    end else begin
      state <= next_state;
    end
  end

  // Next State Logic (Standard 16-state TAP FSM)
  always_comb begin
    case (state)
      TEST_LOGIC_RESET: next_state = tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
      RUN_TEST_IDLE:    next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      
      SELECT_DR_SCAN:   next_state = tms ? SELECT_IR_SCAN   : CAPTURE_DR;
      CAPTURE_DR:       next_state = tms ? EXIT1_DR         : SHIFT_DR;
      SHIFT_DR:         next_state = tms ? EXIT1_DR         : SHIFT_DR;
      EXIT1_DR:         next_state = tms ? UPDATE_DR        : PAUSE_DR;
      PAUSE_DR:         next_state = tms ? EXIT2_DR         : PAUSE_DR;
      EXIT2_DR:         next_state = tms ? UPDATE_DR        : SHIFT_DR;
      UPDATE_DR:        next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;

      SELECT_IR_SCAN:   next_state = tms ? TEST_LOGIC_RESET : CAPTURE_IR;
      CAPTURE_IR:       next_state = tms ? EXIT1_IR         : SHIFT_IR;
      SHIFT_IR:         next_state = tms ? EXIT1_IR         : SHIFT_IR;
      EXIT1_IR:         next_state = tms ? UPDATE_IR        : PAUSE_IR;
      PAUSE_IR:         next_state = tms ? EXIT2_IR         : PAUSE_IR;
      EXIT2_IR:         next_state = tms ? UPDATE_IR        : SHIFT_IR;
      UPDATE_IR:        next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      
      default:          next_state = TEST_LOGIC_RESET;
    endcase
  end

  // Instruction Register Logic
  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      ir_reg   <= IR_IDCODE;
      ir_shift <= 5'b00001;
    end else begin
      if (state == TEST_LOGIC_RESET) begin
        ir_reg   <= IR_IDCODE;
        ir_shift <= 5'b00001;
      end else if (state == CAPTURE_IR) begin
        ir_shift <= 5'b00001; // Capture pattern (mandatory bit 0 = 1)
      end else if (state == SHIFT_IR) begin
        ir_shift <= {tdi, ir_shift[4:1]};
      end else if (state == UPDATE_IR) begin
        ir_reg   <= ir_shift;
      end
    end
  end

  // Data Registers (DR) Capture & Shift Logic
  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      idcode_shift <= IDCODE_VALUE;
      bypass_reg   <= 1'b0;
      dtmcs_shift  <= DTMCS_DEFAULT;
      dmi_shift    <= 40'd0;
    end else begin
      case (state)
        CAPTURE_DR: begin
          case (ir_reg)
            IR_IDCODE: idcode_shift <= IDCODE_VALUE;
            IR_DTMCS:  dtmcs_shift  <= DTMCS_DEFAULT;
            IR_DMI: begin
              if (dmi_rsp_valid) begin
                dmi_shift <= {dmi_rsp_addr, dmi_rsp_data, dmi_rsp_op};
              end else begin
                dmi_shift <= {dmi_shift[39:2], 2'b00}; // 2'b00 = success
              end
            end
            default:   bypass_reg   <= 1'b0;
          endcase
        end

        SHIFT_DR: begin
          case (ir_reg)
            IR_IDCODE: idcode_shift <= {tdi, idcode_shift[31:1]};
            IR_DTMCS:  dtmcs_shift  <= {tdi, dtmcs_shift[31:1]};
            IR_DMI:    dmi_shift    <= {tdi, dmi_shift[39:1]};
            default:   bypass_reg   <= tdi;
          endcase
        end
      endcase
    end
  end

  // DMI Request Generation on UPDATE_DR
  always_ff @(posedge tck or negedge trst_n) begin
    if (!trst_n) begin
      dmi_req_addr  <= 6'd0;
      dmi_req_data  <= 32'd0;
      dmi_req_op    <= 2'd0;
      dmi_req_valid <= 1'b0;
    end else begin
      if (state == UPDATE_DR && ir_reg == IR_DMI) begin
        dmi_req_addr  <= dmi_shift[39:34];
        dmi_req_data  <= dmi_shift[33:2];
        dmi_req_op    <= dmi_shift[1:0];
        dmi_req_valid <= (dmi_shift[1:0] != 2'b00); // 1 = Read, 2 = Write
      end else if (dmi_req_ready) begin
        dmi_req_valid <= 1'b0;
      end
    end
  end

  // TDO Output Multiplexer
  logic tdo_bit;
  always_comb begin
    if (state == SHIFT_IR) begin
      tdo_bit = ir_shift[0];
    end else case (ir_reg)
      IR_IDCODE: tdo_bit = idcode_shift[0];
      IR_DTMCS:  tdo_bit = dtmcs_shift[0];
      IR_DMI:    tdo_bit = dmi_shift[0];
      default:   tdo_bit = bypass_reg;
    endcase
  end

  assign tdo    = tdo_bit;
  assign tdo_oe = (state == SHIFT_IR) || (state == SHIFT_DR);

endmodule
