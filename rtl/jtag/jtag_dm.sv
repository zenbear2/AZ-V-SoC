// ============================================================================
// File: jtag_dm.sv
// Description: RISC-V Debug Module (DM) Controller
// Project: AZ_V_SoC JTAG Debug Subsystem
// ============================================================================

`timescale 1ns / 1ps

module jtag_dm (
  input  logic        clk,
  input  logic        rst_n,

  // DMI Request Interface (from jtag_dtm)
  input  logic [5:0]  dmi_req_addr,
  input  logic [31:0] dmi_req_data,
  input  logic [1:0]  dmi_req_op,       // 1 = Read, 2 = Write
  input  logic        dmi_req_valid,
  output logic        dmi_req_ready,

  output logic [5:0]  dmi_rsp_addr,
  output logic [31:0] dmi_rsp_data,
  output logic [1:0]  dmi_rsp_op,       // 0 = Success
  output logic        dmi_rsp_valid,

  // CPU Execution Control Interface
  output logic        debug_halt_req,
  output logic        debug_resume_req,
  output logic        debug_step_req,
  input  logic        cpu_halted,

  // CPU Register File Access Interface
  output logic [4:0]  debug_gpr_addr,
  input  logic [31:0] debug_gpr_rdata,
  output logic [31:0] debug_gpr_wdata,
  output logic        debug_gpr_wen,

  // CPU PC Inspect & Control Interface
  input  logic [31:0] debug_pc_rdata,
  output logic [31:0] debug_pc_wdata,
  output logic        debug_pc_wen,

  // Debug Memory Access Master Interface (to interconnect)
  output logic [31:0] debug_mem_addr,
  output logic [31:0] debug_mem_wdata,
  output logic [3:0]  debug_mem_byte_enable,
  output logic        debug_mem_req,
  output logic        debug_mem_we,
  input  logic [31:0] debug_mem_rdata
);

  // Register Addresses (DMI 6-bit Address)
  localparam logic [5:0] ADDR_CONTROL  = 6'h10;
  localparam logic [5:0] ADDR_STATUS   = 6'h11;
  localparam logic [5:0] ADDR_GPR_ADDR = 6'h12;
  localparam logic [5:0] ADDR_GPR_DATA = 6'h13;
  localparam logic [5:0] ADDR_CPU_PC   = 6'h14;
  localparam logic [5:0] ADDR_MEM_ADDR = 6'h15;
  localparam logic [5:0] ADDR_MEM_DATA = 6'h16;
  localparam logic [5:0] ADDR_MEM_CTRL = 6'h17;

  // Internal Registers
  logic [4:0]  gpr_addr_reg;
  logic [31:0] gpr_wdata_reg;
  logic [31:0] pc_wdata_reg;
  logic [31:0] mem_addr_reg;
  logic [31:0] mem_wdata_reg;
  logic [31:0] mem_rdata_reg;

  logic halt_req_reg;
  logic resume_req_reg;
  logic step_req_reg;
  logic halted_status_reg;

  assign debug_halt_req   = halt_req_reg;
  assign debug_resume_req = resume_req_reg;
  assign debug_step_req   = step_req_reg;

  assign debug_gpr_addr  = gpr_addr_reg;
  assign debug_gpr_wdata = gpr_wdata_reg;

  assign debug_pc_wdata  = pc_wdata_reg;

  assign debug_mem_addr        = mem_addr_reg;
  assign debug_mem_wdata       = mem_wdata_reg;
  assign debug_mem_byte_enable = 4'b1111;

  // Track CPU halted status
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      halted_status_reg <= 1'b0;
    end else begin
      halted_status_reg <= cpu_halted;
    end
  end

  // DMI Command Processing State Machine
  typedef enum logic [1:0] {
    IDLE     = 2'd0,
    PROCESS  = 2'd1,
    MEM_WAIT = 2'd2,
    RESPOND  = 2'd3
  } dm_state_e;

  dm_state_e state;

  logic [5:0]  rsp_addr_reg;
  logic [31:0] rsp_data_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state             <= IDLE;
      gpr_addr_reg      <= 5'd0;
      gpr_wdata_reg     <= 32'd0;
      pc_wdata_reg      <= 32'd0;
      mem_addr_reg      <= 32'd0;
      mem_wdata_reg     <= 32'd0;
      mem_rdata_reg     <= 32'd0;
      halt_req_reg      <= 1'b0;
      resume_req_reg    <= 1'b0;
      step_req_reg      <= 1'b0;
      debug_gpr_wen     <= 1'b0;
      debug_pc_wen      <= 1'b0;
      debug_mem_req     <= 1'b0;
      debug_mem_we      <= 1'b0;
      dmi_req_ready     <= 1'b1;
      dmi_rsp_valid     <= 1'b0;
      rsp_addr_reg      <= 6'd0;
      rsp_data_reg      <= 32'd0;
    end else begin
      // Pulse default resets
      debug_gpr_wen <= 1'b0;
      debug_pc_wen  <= 1'b0;
      if (resume_req_reg) resume_req_reg <= 1'b0;

      case (state)
        IDLE: begin
          dmi_rsp_valid <= 1'b0;
          if (dmi_req_valid && dmi_req_ready) begin
            dmi_req_ready <= 1'b0;
            rsp_addr_reg  <= dmi_req_addr;
            state         <= PROCESS;
          end
        end

        PROCESS: begin
          if (dmi_req_op == 2'b01) begin // READ OPERATION
            case (dmi_req_addr)
              ADDR_CONTROL:  rsp_data_reg <= {29'd0, step_req_reg, resume_req_reg, halt_req_reg};
              ADDR_STATUS:   rsp_data_reg <= {29'd0, step_req_reg, ~cpu_halted, cpu_halted};
              ADDR_GPR_ADDR: rsp_data_reg <= {27'd0, gpr_addr_reg};
              ADDR_GPR_DATA: rsp_data_reg <= debug_gpr_rdata;
              ADDR_CPU_PC:   rsp_data_reg <= debug_pc_rdata;
              ADDR_MEM_ADDR: rsp_data_reg <= mem_addr_reg;
              ADDR_MEM_DATA: rsp_data_reg <= mem_rdata_reg;
              default:       rsp_data_reg <= 32'h00000000;
            endcase
            state <= RESPOND;

          end else if (dmi_req_op == 2'b10) begin // WRITE OPERATION
            case (dmi_req_addr)
              ADDR_CONTROL: begin
                halt_req_reg   <= dmi_req_data[0];
                if (dmi_req_data[1]) begin
                  halt_req_reg   <= 1'b0;
                  resume_req_reg <= 1'b1;
                end
                step_req_reg   <= dmi_req_data[2];
                rsp_data_reg   <= 32'h00000000;
                state          <= RESPOND;
              end

              ADDR_GPR_ADDR: begin
                gpr_addr_reg <= dmi_req_data[4:0];
                rsp_data_reg <= 32'h00000000;
                state        <= RESPOND;
              end

              ADDR_GPR_DATA: begin
                gpr_wdata_reg <= dmi_req_data;
                debug_gpr_wen <= 1'b1;
                rsp_data_reg  <= 32'h00000000;
                state         <= RESPOND;
              end

              ADDR_CPU_PC: begin
                pc_wdata_reg <= dmi_req_data;
                debug_pc_wen <= 1'b1;
                rsp_data_reg <= 32'h00000000;
                state        <= RESPOND;
              end

              ADDR_MEM_ADDR: begin
                mem_addr_reg <= dmi_req_data;
                rsp_data_reg <= 32'h00000000;
                state        <= RESPOND;
              end

              ADDR_MEM_DATA: begin
                mem_wdata_reg <= dmi_req_data;
                rsp_data_reg  <= 32'h00000000;
                state         <= RESPOND;
              end

              ADDR_MEM_CTRL: begin
                if (dmi_req_data[0]) begin // Memory Read
                  debug_mem_req <= 1'b1;
                  debug_mem_we  <= 1'b0;
                  state         <= MEM_WAIT;
                end else if (dmi_req_data[1]) begin // Memory Write
                  debug_mem_req <= 1'b1;
                  debug_mem_we  <= 1'b1;
                  state         <= MEM_WAIT;
                end else begin
                  rsp_data_reg <= 32'h00000000;
                  state        <= RESPOND;
                end
              end

              default: begin
                rsp_data_reg <= 32'h00000000;
                state        <= RESPOND;
              end
            endcase
          end else begin
            rsp_data_reg <= 32'h00000000;
            state        <= RESPOND;
          end
        end

        MEM_WAIT: begin
          // SRAM synchronous read response available next cycle
          mem_rdata_reg <= debug_mem_rdata;
          debug_mem_req <= 1'b0;
          debug_mem_we  <= 1'b0;
          rsp_data_reg  <= 32'h00000000;
          state         <= RESPOND;
        end

        RESPOND: begin
          dmi_rsp_valid <= 1'b1;
          dmi_req_ready <= 1'b1;
          state         <= IDLE;
        end
      endcase
    end
  end

  assign dmi_rsp_addr = rsp_addr_reg;
  assign dmi_rsp_data = rsp_data_reg;
  assign dmi_rsp_op   = 2'b00; // Success

endmodule
