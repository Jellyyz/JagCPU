
module ID_EX 
import rv32i_types::*;
#(parameter width = 32)
(   
    input clk, 
    input rst,
    input load_i,

    // all outputs out to ID/EX reg
    input rv32i_control_word ID_EX_ctrl_word_i,
    input logic [width-1:0] ID_EX_instr_i,
    input logic[width-1:0] ID_EX_pc_out_i,
    input logic[width-1:0] ID_EX_rs1_out_i,
    input logic[width-1:0] ID_EX_rs2_out_i,
    input logic[width-1:0] ID_EX_i_imm_i,
    input logic[width-1:0] ID_EX_s_imm_i,
    input logic[width-1:0] ID_EX_b_imm_i,
    input logic[width-1:0] ID_EX_u_imm_i,
    input logic[width-1:0] ID_EX_j_imm_i,
    input logic[4:0] ID_EX_rs1_i,
    input logic[4:0] ID_EX_rs2_i,
    input logic[4:0] ID_EX_rd_i,
    input logic ID_EX_br_en_i,
    input ctrl_flow_preds ID_EX_br_pred_i,
    input logic ID_EX_halt_en_i,

    output rv32i_control_word ID_EX_ctrl_word_o,
    output logic[width-1:0] ID_EX_instr_o,
    output logic[width-1:0] ID_EX_pc_out_o, 
    output logic[width-1:0] ID_EX_rs1_out_o,
    output logic[width-1:0] ID_EX_rs2_out_o,
    output logic[width-1:0] ID_EX_i_imm_o,
    output logic[width-1:0] ID_EX_s_imm_o,
    output logic[width-1:0] ID_EX_b_imm_o,
    output logic[width-1:0] ID_EX_u_imm_o,
    output logic[width-1:0] ID_EX_j_imm_o,
    output logic[4:0] ID_EX_rs1_o,
    output logic[4:0] ID_EX_rs2_o,
    output logic[4:0] ID_EX_rd_o,
    output logic ID_EX_br_en_o,

    output ctrl_flow_preds ID_EX_br_pred_o,
    output logic ID_EX_halt_en_o
);

    rv32i_control_word ID_EX_ctrl_word;
    logic [width-1:0] ID_EX_instr;
    logic [width-1:0] ID_EX_pc_out;
    logic [width-1:0] ID_EX_rs1_out;
    logic [width-1:0] ID_EX_rs2_out;
    logic [width-1:0] ID_EX_i_imm;
    logic [width-1:0] ID_EX_s_imm;
    logic [width-1:0] ID_EX_b_imm;
    logic [width-1:0] ID_EX_u_imm;
    logic [width-1:0] ID_EX_j_imm;
    logic [4:0] ID_EX_rs1;
    logic [4:0] ID_EX_rs2;
    logic [4:0] ID_EX_rd;
    logic ID_EX_br_en;
    ctrl_flow_preds ID_EX_br_pred;
    logic ID_EX_halt_en;


always_ff @(posedge clk) begin
    if (rst) begin
        ID_EX_ctrl_word <= '0;
        ID_EX_instr <= '0;
        ID_EX_pc_out <= '0;
        ID_EX_rs1_out <= '0;
        ID_EX_rs2_out <= '0;
        ID_EX_i_imm <= '0;
        ID_EX_s_imm <= '0;
        ID_EX_b_imm <= '0;
        ID_EX_u_imm <= '0;
        ID_EX_j_imm <= '0;
        ID_EX_rs1 <= '0;
        ID_EX_rs2 <= '0;
        ID_EX_rd <= '0;
        ID_EX_br_en <= '0;

        ID_EX_br_pred <= '0;
        ID_EX_halt_en <= '0;
    end else if (load_i) begin
        ID_EX_ctrl_word <= ID_EX_ctrl_word_i;
        ID_EX_instr <= ID_EX_instr_i;
        ID_EX_pc_out <= ID_EX_pc_out_i;
        ID_EX_rs1_out <= ID_EX_rs1_out_i;
        ID_EX_rs2_out <= ID_EX_rs2_out_i;
        ID_EX_i_imm <= ID_EX_i_imm_i;
        ID_EX_s_imm <= ID_EX_s_imm_i;
        ID_EX_b_imm <= ID_EX_b_imm_i;
        ID_EX_u_imm <= ID_EX_u_imm_i;
        ID_EX_j_imm <= ID_EX_j_imm_i;
        ID_EX_rs1 <= ID_EX_rs1_i;
        ID_EX_rs2 <= ID_EX_rs2_i;
        ID_EX_rd <= ID_EX_rd_i;
        ID_EX_br_en <= ID_EX_br_en_i;

        ID_EX_br_pred <= ID_EX_br_pred_i;
        ID_EX_halt_en <= ID_EX_halt_en_i;
    end else begin // practically, load is fixed high, so this will never execute
        ID_EX_ctrl_word <= ID_EX_ctrl_word;
        ID_EX_instr <= ID_EX_instr;
        ID_EX_pc_out <= ID_EX_pc_out;
        ID_EX_rs1_out <= ID_EX_rs1_out;
        ID_EX_rs2_out <= ID_EX_rs2_out;
        ID_EX_i_imm <= ID_EX_i_imm;
        ID_EX_s_imm <= ID_EX_s_imm;
        ID_EX_b_imm <= ID_EX_b_imm;
        ID_EX_u_imm <= ID_EX_u_imm;
        ID_EX_j_imm <= ID_EX_j_imm;
        ID_EX_rs1 <= ID_EX_rs1;
        ID_EX_rs2 <= ID_EX_rs2;
        ID_EX_rd <= ID_EX_rd;
        ID_EX_br_en <= ID_EX_br_en;

        ID_EX_br_pred <= ID_EX_br_pred;
        ID_EX_halt_en <= ID_EX_halt_en;
    end
end

always_comb begin
    ID_EX_ctrl_word_o = ID_EX_ctrl_word;
    ID_EX_instr_o = ID_EX_instr;
    ID_EX_pc_out_o = ID_EX_pc_out; 
    ID_EX_rs1_out_o = ID_EX_rs1_out;
    ID_EX_rs2_out_o = ID_EX_rs2_out;
    ID_EX_i_imm_o = ID_EX_i_imm;
    ID_EX_s_imm_o = ID_EX_s_imm;
    ID_EX_b_imm_o = ID_EX_b_imm;
    ID_EX_u_imm_o = ID_EX_u_imm;
    ID_EX_j_imm_o = ID_EX_j_imm;
    ID_EX_rs1_o = ID_EX_rs1;
    ID_EX_rs2_o = ID_EX_rs2;
    ID_EX_rd_o = ID_EX_rd;
    ID_EX_br_en_o = ID_EX_br_en;

    ID_EX_br_pred_o = ID_EX_br_pred;
    ID_EX_halt_en_o = ID_EX_halt_en;
end

endmodule : ID_EX 
