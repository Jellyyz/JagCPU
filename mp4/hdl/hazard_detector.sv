module hazard_detector
import rv32i_types::*;
 #(
    parameter width = 32
) (
    input rv32i_control_word EX_ctrl_word_i,
    input rv32i_reg EX_rd_i,
    input rv32i_reg ID_rs1_i,
    input rv32i_reg ID_rs2_i,

    // output controlmux::controlmux_sel_t HD_controlmux_sel_o,
    output logic HD_controlmux_sel_o,
    output logic HD_PC_write_o,
    output logic HD_IF_ID_write_o
);
logic stall;
logic mem_read;

assign mem_read = EX_ctrl_word_i.mem_read;

always_comb begin : hazard_detection
    stall = mem_read & ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i)); // & |EX_rd_i;

    if (stall) begin
        HD_controlmux_sel_o = 1'b0;
        HD_PC_write_o = 1'b0;
        HD_IF_ID_write_o = 1'b0;
    end else begin
        HD_controlmux_sel_o = 1'b1;
        HD_PC_write_o = 1'b1;
        HD_IF_ID_write_o = 1'b1;
    end
end
    
endmodule