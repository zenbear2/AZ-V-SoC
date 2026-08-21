// ============================================================================
// File: mlkem512_soc_wrapper.sv
// Description: AXI4-Lite CSR & Streaming Wrapper for MLKEM-512 Accelerator
// Project: AZ_V_SoC
// ============================================================================

`timescale 1ns / 1ps

module mlkem512_soc_wrapper #(
  parameter int C_S_AXI_DATA_WIDTH = 32,
  parameter int C_S_AXI_ADDR_WIDTH = 6
)(
  input  logic                          clk,
  input  logic                          rst_n,

  // AXI4-Lite Slave CSR Interface
  input  logic [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
  input  logic                          s_axi_awvalid,
  output logic                          s_axi_awready,
  input  logic [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
  input  logic [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
  input  logic                          s_axi_wvalid,
  output logic                          s_axi_wready,
  output logic [1:0]                    s_axi_bresp,
  output logic                          s_axi_bvalid,
  input  logic                          s_axi_bready,

  input  logic [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
  input  logic                          s_axi_arvalid,
  output logic                          s_axi_arready,
  output logic [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
  output logic [1:0]                    s_axi_rresp,
  output logic                          s_axi_rvalid,
  input  logic                          s_axi_rready,

  // Interrupt Output
  output logic                          irq
);

  // Stream Interface Wires
  logic [63:0] s_axis_tdata;
  logic        s_axis_tvalid;
  logic        s_axis_tready;
  logic        s_axis_tlast;

  logic [63:0] m_axis_tdata;
  logic        m_axis_tvalid;
  logic        m_axis_tready;
  logic        m_axis_tlast;

  // Stream MMIO Registers
  logic [31:0] din_low_reg;
  logic [31:0] dout_low_reg;
  logic [31:0] dout_high_reg;
  logic        tlast_next_reg;
  logic        pop_stream;

  // Wires from MLKEM core AXI CSR
  logic [31:0] core_rdata;
  logic        core_rvalid;
  logic        core_awready, core_wready, core_bvalid, core_arready;

  // AXI4-Lite Handshake Registers
  logic awready_reg, wready_reg, bvalid_reg, arready_reg, rvalid_reg;
  logic [31:0] local_rdata;

  assign s_axi_awready = awready_reg | core_awready;
  assign s_axi_wready  = wready_reg  | core_wready;
  assign s_axi_bvalid  = bvalid_reg  | core_bvalid;
  assign s_axi_bresp   = 2'b00;
  assign s_axi_arready = arready_reg | core_arready;
  assign s_axi_rvalid  = rvalid_reg  | core_rvalid;

  // Combinational read data selector
  always_comb begin
    if (s_axi_araddr[5:2] < 4'h2) begin
      s_axi_rdata = core_rdata;
    end else begin
      case (s_axi_araddr[5:2])
        4'h2: s_axi_rdata = {28'd0, m_axis_tlast, m_axis_tvalid, s_axis_tready, tlast_next_reg};
        4'h6: s_axi_rdata = m_axis_tvalid ? m_axis_tdata[31:0] : dout_low_reg;
        4'h7: s_axi_rdata = m_axis_tvalid ? m_axis_tdata[63:32] : dout_high_reg;
        default: s_axi_rdata = 32'd0;
      endcase
    end
  end

  assign s_axi_rresp   = 2'b00;
  assign s_axis_tlast  = tlast_next_reg;
  assign m_axis_tready = pop_stream;

  // AXI4-Lite Write Channel
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      awready_reg    <= 1'b0;
      wready_reg     <= 1'b0;
      bvalid_reg     <= 1'b0;
      din_low_reg    <= 32'd0;
      tlast_next_reg <= 1'b0;
      s_axis_tvalid  <= 1'b0;
      s_axis_tdata   <= 64'd0;
    end else begin
      if (s_axis_tvalid && s_axis_tready) begin
        s_axis_tvalid  <= 1'b0;
        tlast_next_reg <= 1'b0;
      end

      if (!awready_reg && s_axi_awvalid && s_axi_wvalid && (s_axi_awaddr[5:2] >= 4'h2)) begin
        awready_reg <= 1'b1;
        wready_reg  <= 1'b1;
      end else begin
        awready_reg <= 1'b0;
        wready_reg  <= 1'b0;
      end

      if (s_axi_awvalid && s_axi_wvalid && !bvalid_reg && (s_axi_awaddr[5:2] >= 4'h2)) begin
        bvalid_reg <= 1'b1;
        case (s_axi_awaddr[5:2])
          4'h2: tlast_next_reg <= s_axi_wdata[0];
          4'h4: din_low_reg    <= s_axi_wdata;
          4'h5: begin
            s_axis_tdata  <= {s_axi_wdata, din_low_reg};
            s_axis_tvalid <= 1'b1;
          end
          default: ;
        endcase
      end else if (s_axi_bready && bvalid_reg) begin
        bvalid_reg <= 1'b0;
      end
    end
  end

  // AXI4-Lite Read Control & Stream Pop logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arready_reg   <= 1'b0;
      rvalid_reg    <= 1'b0;
      dout_low_reg  <= 32'd0;
      dout_high_reg <= 32'd0;
      pop_stream    <= 1'b0;
    end else begin
      pop_stream <= 1'b0;

      if (m_axis_tvalid && m_axis_tready) begin
        dout_low_reg  <= m_axis_tdata[31:0];
        dout_high_reg <= m_axis_tdata[63:32];
      end

      if (!arready_reg && s_axi_arvalid && (s_axi_araddr[5:2] >= 4'h2)) begin
        arready_reg <= 1'b1;
        rvalid_reg  <= 1'b1;
        if (s_axi_araddr[5:2] == 4'h7) begin
          pop_stream <= 1'b1;
        end
      end else begin
        arready_reg <= 1'b0;
        if (s_axi_rready) begin
          rvalid_reg <= 1'b0;
        end
      end
    end
  end

  // Instantiate standard MLKEM-512 Core
  mlkem512_top #(
    .TARGET_TYPE        (0),
    .C_S_AXI_DATA_WIDTH (32),
    .C_S_AXI_ADDR_WIDTH (6)
  ) u_mlkem512_core (
    .clk           (clk),
    .rst_n         (rst_n),

    .s_axi_awaddr  (s_axi_awaddr),
    .s_axi_awvalid (s_axi_awvalid && (s_axi_awaddr[5:2] < 4'h2)),
    .s_axi_awready (core_awready),
    .s_axi_wdata   (s_axi_wdata),
    .s_axi_wstrb   (s_axi_wstrb),
    .s_axi_wvalid  (s_axi_wvalid && (s_axi_awaddr[5:2] < 4'h2)),
    .s_axi_wready  (core_wready),
    .s_axi_bresp   (),
    .s_axi_bvalid  (core_bvalid),
    .s_axi_bready  (s_axi_bready),

    .s_axi_araddr  (s_axi_araddr),
    .s_axi_arvalid (s_axi_arvalid && (s_axi_araddr[5:2] < 4'h2)),
    .s_axi_arready (core_arready),
    .s_axi_rdata   (core_rdata),
    .s_axi_rresp   (),
    .s_axi_rvalid  (core_rvalid),
    .s_axi_rready  (s_axi_rready),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast  (m_axis_tlast),

    .irq           (irq)
  );

endmodule
