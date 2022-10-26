import rv32i_types::*;

module id #(
    parameter width = 32
) (
    input clk,
    input rst,
    input ID_load_regfile_i,               // from WB stage
    input logic [width-1:0] ID_instr_i,    // from IF/ID reg
    input logic [width-1:0] ID_pc_out_i,   // from IF/ID reg

    input logic [4:0] ID_rd_wr_i,          // from WB stage
    input logic [width-1:0] ID_wr_data_i,  // from WB stage

    
    // all outputs out to ID/EX reg
    output rv32i_control_word IDEX_ctrl_word_o,
    output logic [width-1:0] IDEX_instr_o,
    output logic[width-1:0] IDEX_pc_out_o, 

    output logic[width-1:0] IDEX_rs1_out_o,
    output logic[width-1:0] IDEX_rs2_out_o,

    output logic[width-1:0] IDEX_i_imm_o,
    output logic[width-1:0] IDEX_s_imm_o,
    output logic[width-1:0] IDEX_b_imm_o,
    output logic[width-1:0] IDEX_u_imm_o,
    output logic[width-1:0] IDEX_j_imm_o,

    output logic[4:0] IDEX_rd_o,

    output logic IDEX_br_en_o
);

rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;

logic [4:0] rs1, rs2, rd;
logic [width-1:0] rs1_out, rs2_out;

rv32i_control_word ctrl_word;
branch_funct3 cmpop;
cmpmux::cmpmux_sel_t cmpmux_sel;

logic br_en;

always_comb begin : instr_decode
    opcode = rv32i_opcode'(ID_instr_i[6:0]);
    funct3 = ID_instr_i[14:12];
    funct7 = ID_instr_i[31:25];

    i_imm = {{21{ID_instr_i[31]}}, ID_instr_i[30:20]};
    s_imm = {{21{ID_instr_i[31]}}, ID_instr_i[30:25], ID_instr_i[11:7]};
    b_imm = {{20{ID_instr_i[31]}}, ID_instr_i[7], ID_instr_i[30:25], ID_instr_i[11:8], 1'b0};
    u_imm = {ID_instr_i[31:12], 12'h000};
    j_imm = {{12{ID_instr_i[31]}}, ID_instr_i[19:12], ID_instr_i[20], ID_instr_i[30:21], 1'b0};

    rs1 = ID_instr_i[19:15];
    rs2 = ID_instr_i[24:20];
    rd = ID_instr_i[11:7];
end

always_comb begin : ctrl_decode
    cmpop = ctrl_word.cmpop;
    cmpmux_sel = ctrl_word.cmpmux_sel
end

always_comb begin : muxes
    unique case (cmpmux_sel)
        1'b0 : cmp_mux_out = rs2_out;
        1'b1 : cmp_mux_out = i_imm;
        default :
            cmp_mux_out = rs2_out;
    endcase
end

control_rom ctrl_rom (
    .opcode (opcode),
    .funct3 (funct3),
    .funct7 (funct7),

    .ctrl   (ctrl_word)
);

cmp cmp (
    .cmpop(cmpop),
    .rs1_out(rs1_out),
    .cmp_mux_out(cmp_mux_out),
    
    .br_en(br_en)
);

regfile regfile (
    .clk    (clk),
    .rst    (rst),
    .load   (ID_load_regfile_i),
    .in     (wr_data_i), 
    .src_a  (rs1),   
    .src_b  (rs2),   
    .dest   (rd_wr_i),   

    .reg_a  (rs1_out),
    .reg_b  (rs2_out)
);

always_comb begin : set_output
    IDEX_ctrl_word_o = ctrl_word;

    IDEX_instr_o = ID_instr_i;
    IDEX_pc_out_o = ID_pc_out_i;

    IDEX_rs1_out_o = rs1_out;
    IDEX_rs2_out_o = rs2_out;

    IDEX_i_imm_o = i_imm;
    IDEX_s_imm_o = s_imm;
    IDEX_b_imm_o = b_imm;
    IDEX_u_imm_o = u_imm;
    IDEX_j_imm_o = j_imm;

    IDEX_rd_o = rd;
    IDEX_br_en_o = br_en;
end

endmodule : id