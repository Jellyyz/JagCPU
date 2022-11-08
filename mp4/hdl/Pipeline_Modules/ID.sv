
module ID 
import rv32i_types::*;
#(parameter width = 32) 
(
    input clk,
    input rst,
    input ID_load_regfile_i,               // from WB stage
    input logic [width-1:0] ID_instr_i,    // from IF/ID reg
    input logic [width-1:0] ID_pc_out_i,   // from IF/ID reg

    input logic [4:0] ID_rd_wr_i,          // from WB stage
    input logic [width-1:0] ID_wr_data_i,  // from WB stage

    input controlmux::controlmux_sel_t ID_HD_controlmux_sel_i, // from hazard detector

    
    // all outputs out to ID/EX reg
    output rv32i_control_word ID_ctrl_word_o,
    output logic [width-1:0] ID_instr_o,
    output logic[width-1:0] ID_pc_out_o, 

    output logic[width-1:0] ID_rs1_out_o,
    output logic[width-1:0] ID_rs2_out_o,

    output logic[width-1:0] ID_i_imm_o,
    output logic[width-1:0] ID_s_imm_o,
    output logic[width-1:0] ID_b_imm_o,
    output logic[width-1:0] ID_u_imm_o,
    output logic[width-1:0] ID_j_imm_o,

    output logic[4:0] ID_rs1_o,
    output logic[4:0] ID_rs2_o,
    output logic[4:0] ID_rd_o,

    output logic ID_br_en_o

    // specific wires for control
    // output logic ID_load_regfile_o;
    // output logic ID_mem_read_o;
    // output logic ID_mem_write_o;
    // output logic [3:0] ID_mem_byte_en_o;
);

rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;

logic [4:0] rs1, rs2, rd;
logic [width-1:0] rs1_out, rs2_out;

rv32i_control_word ctrl_word;
branch_funct3_t cmpop;
cmpmux::cmpmux_sel_t cmpmux_sel;

logic br_en;
logic [31:0] cmp_mux_out; 


/****************************************/
/* Start Hazard stuff *******************/
/****************************************/


logic load_regfile;
logic mem_read, mem_write;
logic [3:0] mem_byte_en;

rv32i_control_word ctrl_word_hd;

always_comb begin : blockName
    ctrl_word_hd = ctrl_word;
    unique case (ID_HD_controlmux_sel_i)
        // controlmux::norm : begin
        //     // load_regfile = ctrl_word.load_regfile;
        //     // mem_read = ctrl_word.mem_read;
        //     // mem_write = ctrl_word.mem_write;
        //     // mem_byte_en = ctrl_word.mem_byte_en;
        // end
        controlmux::zero : begin
            // load_regfile = 1'b0;
            // mem_read = 1'b0;
            // mem_write = 1'b0;
            // mem_byte_en = 1'b0;

            ctrl_word_hd.load_regfile = 1'b0;
            ctrl_word_hd.mem_read = 1'b0;
            ctrl_word_hd.mem_write = 1'b0;
            ctrl_word_hd.mem_byte_en = 1'b0;
        end
        default : ;
    endcase 

    if (ID_HD_controlmux_sel_i == controlmux::zero) begin

    end
end



/****************************************/
/* End Hazard stuff **********************/
/****************************************/



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
    cmpmux_sel = ctrl_word.cmpmux_sel;
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
    .datain (ID_wr_data_i), 
    .src_a  (rs1),   
    .src_b  (rs2),   
    .dest   (ID_rd_wr_i),   

    .reg_a  (rs1_out),
    .reg_b  (rs2_out)
);

always_comb begin : set_output
    ID_ctrl_word_o = ctrl_word_hd;
    ID_instr_o = ID_instr_i;
    ID_pc_out_o = ID_pc_out_i;
    ID_rs1_out_o = rs1_out;
    ID_rs2_out_o = rs2_out;
    ID_i_imm_o = i_imm;
    ID_s_imm_o = s_imm;
    ID_b_imm_o = b_imm;
    ID_u_imm_o = u_imm;
    ID_j_imm_o = j_imm;
    ID_rs1_o = rs1;
    ID_rs2_o = rs2;
    ID_rd_o = rd;
    ID_br_en_o = br_en;

    // // hazard signals
    // ID_load_regfile_o = load_regfile;
    // ID_mem_read_o = mem_read;
    // ID_mem_write_o = mem_write;
    // ID_mem_byte_en_o = mem_byte_en;
end

endmodule : ID