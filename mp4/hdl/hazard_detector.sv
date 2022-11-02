module hazard_detector #(
    parameter width = 32
) (
    input clk,
    input rst,

    input logic EX_mem_read_i,
    input rv32i_reg EX_rd_i,
    input rv32i_reg ID_rs1_i,
    input rv32i_reg ID_rs2_i,

    output controlmux::controlmux_sel_t HD_controlmux_sel_o,
    output logic HD_PC_write_o,
    output logic HD_IF_ID_write_o
);
logic stall;

always_comb begin : hazard_detection
    stall = EX_mem_read_i & ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i));

    if (stall) begin
        controlmux_sel_o = controlmux::zero;
        PC_wr_o = 1'b0;
        IF_ID_wr_o = 1'b0;
    end else begin
        controlmux_sel_o = controlmux::ctrl;
        PC_wr_o = 1'b1;
        IF_ID_wr_o = 1'b1;
    end
end
    
endmodule