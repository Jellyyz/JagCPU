
module EX 
import rv32i_types::*;
#(parameter width = 32) 
(
    input rv32i_word EX_pc_out_i, 
    input rv32i_word EX_instr_i, 
    input rv32i_word EX_rs1_out_i,
    input rv32i_word EX_rs2_out_i, 
    // input logic EX_cmpop_i, 
    input rv32i_control_word EX_ctrl_word_i, 
    input rv32i_word  EX_i_imm_i,
    input rv32i_word  EX_s_imm_i,  
    input rv32i_word  EX_b_imm_i, 
    input rv32i_word  EX_u_imm_i, 
    input rv32i_word  EX_j_imm_i,
    input logic EX_br_en_i,
    input logic [4:0] EX_rd_i,
    input forwardingmux::forwardingmux_sel_t EX_forwardA_i,
    input forwardingmux::forwardingmux_sel_t EX_forwardB_i,
    input rv32i_word WB_regfilemux_out_i,
    input rv32i_word EX_MEM_alu_out_i,

    output rv32i_word EX_pc_out_o, 
    output rv32i_word EX_pc_plus4_o, 
    output rv32i_word EX_instr_o,
    output rv32i_word EX_i_imm_o,
    output rv32i_word EX_s_imm_o,
    output rv32i_word EX_b_imm_o,
    output rv32i_word EX_u_imm_o,
    output rv32i_word EX_j_imm_o,
    output rv32i_word EX_rs2_out_o,
    output rv32i_control_word EX_ctrl_word_o,
    output logic [4:0] EX_rd_o,
    
    output rv32i_word  EX_alu_out_o,
    output logic EX_br_en_o,

    output logic EX_mem_read_o

); 
rv32i_word forwardmuxA_out;
rv32i_word forwardmuxB_out;
rv32i_word alumux1_out;
rv32i_word alumux2_out; 

// alu_ops alu_op;
// alumux::alumux1_sel_t alumux1_sel;
// alumux::alumux2_sel_t alumux2_sel;

always_comb begin : set_output
    EX_instr_o = EX_instr_i;
    EX_ctrl_word_o = EX_ctrl_word_i;

    EX_mem_read_o = EX_ctrl_word_i.mem_read;

    EX_rs2_out_o = EX_rs2_out_i; 
    EX_pc_out_o = EX_pc_out_i;
    EX_pc_plus4_o = EX_pc_out_i + 4;

    EX_i_imm_o = EX_i_imm_i; 
    EX_u_imm_o = EX_u_imm_i; 
    EX_b_imm_o = EX_b_imm_i; 
    EX_s_imm_o = EX_s_imm_i; 
    EX_j_imm_o = EX_j_imm_i; 

    EX_br_en_o = EX_br_en_i;
    EX_rd_o = EX_rd_i;
end

always_comb begin : Forwarding_MUXES
    unique case (EX_forwardA_i)
        forwardingmux::id_ex : forwardmuxA_out = EX_rs1_out_i;
        forwardingmux::ex_mem : forwardmuxA_out = EX_MEM_alu_out_i;
        forwardingmux::mem_wb : forwardmuxA_out = WB_regfilemux_out_i;
        default : ;
    endcase

    unique case (EX_forwardB_i)
        forwardingmux::id_ex : forwardmuxB_out = EX_rs2_out_i;
        forwardingmux::ex_mem : forwardmuxB_out = EX_MEM_alu_out_i;
        forwardingmux::mem_wb : forwardmuxB_out = WB_regfilemux_out_i;
        default : ;
    endcase
end

always_comb begin : ALU_MUX
    unique case (EX_ctrl_word_i.alumux1_sel)
        alumux::rs1_out : alumux1_out = forwardmuxA_out; 
        alumux::pc_out : alumux1_out = EX_pc_out_i; 
        default: $display("hit alumux1 error");
    endcase 
    unique case (EX_ctrl_word_i.alumux2_sel)
        alumux::i_imm : alumux2_out = EX_i_imm_i; 
        alumux::u_imm : alumux2_out = EX_u_imm_i; 
        alumux::b_imm : alumux2_out = EX_b_imm_i; 
        alumux::s_imm : alumux2_out = EX_s_imm_i; 
        alumux::j_imm : alumux2_out = EX_j_imm_i; 
        alumux::rs2_out : alumux2_out = forwardmuxB_out;
        default: $display("hit alumux2 error");
    endcase
end 

alu alu (
    .aluop(EX_ctrl_word_i.aluop),
    .a(alumux1_out),
    .b(alumux2_out), 

    .f(EX_alu_out_o)
);



endmodule : EX
