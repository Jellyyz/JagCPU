import rv32i_types::*;

module EX_MEM #(parameter width = 32)
(   
    input clk, 
    input rst,
    input load_i,

    input rv32i_word EX_MEM_pc_out_i, 
    input rv32i_word EX_MEM_pc_plus4_i, 
    input rv32i_word EX_MEM_instr_i,
    input rv32i_word EX_MEM_i_imm_i,
    input rv32i_word EX_MEM_s_imm_i,
    input rv32i_word EX_MEM_b_imm_i,
    input rv32i_word EX_MEM_u_imm_i,
    input rv32i_word EX_MEM_j_imm_i,
    input rv32i_word EX_MEM_rs2_out_i,
    input rv32i_control_word EX_MEM_ctrl_word_i,
    input logic [4:0] EX_MEM_rd_i,
    input rv32i_word  EX_MEM_alu_out_i,
    input logic EX_MEM_br_en_i,

    output rv32i_word EX_MEM_pc_out_o, 
    output rv32i_word EX_MEM_pc_plus4_o, 
    output rv32i_word EX_MEM_instr_o,
    output rv32i_word EX_MEM_i_imm_o,
    output rv32i_word EX_MEM_s_imm_o,
    output rv32i_word EX_MEM_b_imm_o,
    output rv32i_word EX_MEM_u_imm_o,
    output rv32i_word EX_MEM_j_imm_o,
    output rv32i_word EX_MEM_rs2_out_o,
    output rv32i_control_word EX_MEM_ctrl_word_o,
    output logic [4:0] EX_MEM_rd_o,
    output rv32i_word  EX_MEM_alu_out_o,
    output logic EX_MEM_br_en_o
);

always_ff @(posedge clk) begin
    if (rst) begin
        EX_MEM_pc_out_o  <= '0;
        EX_MEM_pc_plus4_o  <= '0;
        EX_MEM_instr_o <= '0;
        EX_MEM_i_imm_o <= '0;
        EX_MEM_s_imm_o <= '0;
        EX_MEM_b_imm_o <= '0;
        EX_MEM_u_imm_o <= '0;
        EX_MEM_j_imm_o <= '0;
        EX_MEM_rs2_out_o <= '0;
        EX_MEM_ctrl_word_o <= '0;
        EX_MEM_rd_o <= '0;
        EX_MEM_alu_out_o <= '0;
        EX_MEM_br_en_o <= '0;
    end else if (load_i) begin
        EX_MEM_pc_out_o  <= EX_MEM_pc_out_i;
        EX_MEM_pc_plus4_o  <= EX_MEM_pc_plus4_i;
        EX_MEM_instr_o <= EX_MEM_instr_i;
        EX_MEM_i_imm_o <= EX_MEM_i_imm_i;
        EX_MEM_s_imm_o <= EX_MEM_s_imm_i;
        EX_MEM_b_imm_o <= EX_MEM_b_imm_i;
        EX_MEM_u_imm_o <= EX_MEM_u_imm_i;
        EX_MEM_j_imm_o <= EX_MEM_j_imm_i;
        EX_MEM_rs2_out_o <= EX_MEM_rs2_out_i;
        EX_MEM_ctrl_word_o <= EX_MEM_ctrl_word_i;
        EX_MEM_rd_o <= EX_MEM_rd_i;
        EX_MEM_alu_out_o <= EX_MEM_alu_out_i;
        EX_MEM_br_en_o <= EX_MEM_br_en_i;
    end else begin 
        EX_MEM_pc_out_o  <= EX_MEM_pc_out_i;
        EX_MEM_pc_plus4_o  <= EX_MEM_pc_plus4_i;
        EX_MEM_instr_o <= EX_MEM_instr_i;
        EX_MEM_i_imm_o <= EX_MEM_i_imm_i;
        EX_MEM_s_imm_o <= EX_MEM_s_imm_i;
        EX_MEM_b_imm_o <= EX_MEM_b_imm_i;
        EX_MEM_u_imm_o <= EX_MEM_u_imm_i;
        EX_MEM_j_imm_o <= EX_MEM_j_imm_i;
        EX_MEM_rs2_out_o <= EX_MEM_rs2_out_i;
        EX_MEM_ctrl_word_o <= EX_MEM_ctrl_word_i;
        EX_MEM_rd_o <= EX_MEM_rd_i;
        EX_MEM_alu_out_o <= EX_MEM_alu_out_i;
        EX_MEM_br_en_o <= EX_MEM_br_en_i;
    end
end

always_comb begin
    EX_MEM_pc_out_o = EX_MEM_pc_out_i;
    EX_MEM_pc_plus4_o  = EX_MEM_pc_plus4_i;
    EX_MEM_instr_o = EX_MEM_instr_i;
    EX_MEM_i_imm_o = EX_MEM_i_imm_i;
    EX_MEM_s_imm_o = EX_MEM_s_imm_i;
    EX_MEM_b_imm_o = EX_MEM_b_imm_i;
    EX_MEM_u_imm_o = EX_MEM_u_imm_i;
    EX_MEM_j_imm_o = EX_MEM_j_imm_i;
    EX_MEM_rs2_out_o = EX_MEM_rs2_out_i;
    EX_MEM_ctrl_word_o= EX_MEM_ctrl_word_i;
    EX_MEM_rd_o = EX_MEM_rd_i;
    EX_MEM_alu_out_o = EX_MEM_alu_out_i;
    EX_MEM_br_en_o = EX_MEM_br_en_i;
end

endmodule : EX_MEM 
