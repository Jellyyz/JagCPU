module hazard_detector
import rv32i_types::*;
 #(
    parameter width = 32
) (
    input logic EX_mem_read_i,
    input rv32i_reg EX_rd_i,
    input rv32i_reg ID_rs1_i,
    input rv32i_reg ID_rs2_i,
    input logic i_mem_resp,
    input logic i_mem_read,
    input logic d_mem_resp,
    input logic d_mem_read,
    input logic d_mem_write,

    output controlmux::controlmux_sel_t ID_HD_controlmux_sel_o,
    output logic IF_HD_PC_write_o,
    output logic IF_ID_HD_write_o,
    output logic stall_signal
);

logic stall;
assign stall_signal = stall;

always_comb begin : hazard_detection
    stall = (!i_mem_resp & i_mem_read)
            | (!d_mem_resp & (d_mem_read | d_mem_write))
            | (EX_mem_read_i & ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i)) & |EX_rd_i);

    if (stall) begin
        ID_HD_controlmux_sel_o = controlmux::zero;
        IF_HD_PC_write_o = 1'b0;
        IF_ID_HD_write_o = 1'b0;
    end else begin
        ID_HD_controlmux_sel_o = controlmux::norm;
        IF_HD_PC_write_o = 1'b1;
        IF_ID_HD_write_o = 1'b1;
    end
end
    
endmodule