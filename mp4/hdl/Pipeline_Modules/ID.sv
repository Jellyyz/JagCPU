
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
    
    input logic [width-1:0] MEM_data_mem_rdata, 
    input logic [width-1:0] EX_MEM_alu_out, 
    input logic [width-1:0] MEM_WB_alu_out,
    input logic [width-1:0] WB_data_mem_rdata,
    input logic [width-1:0] EX_alu_out, 

    input controlmux::controlmux_sel_t ID_HD_controlmux_sel_i, // from hazard detector

    input logic ID_br_pred_i,

    input forwardingmux3::forwardingmux3_sel_t ID_forwardD_i,
    input forwardingmux4::forwardingmux4_sel_t ID_forwardE_i,

    // input logic [width-1:0] ID_EX_rs2_out_i, 
    // input logic [width-1:0] EX_MEM_rs1_out_i,
    // input logic [width-1:0] EX_MEM_rs2_out_i,
    
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

    output logic ID_br_en_o,

    output logic [width-1:0] ID_branch_pc_o,
    output pcmux::pcmux_sel_t ID_pcmux_sel_o,

    output logic ID_br_pred_o,
    output logic ID_if_id_flush_o,

    output logic ID_halt_en_o

    // specific wires for control
    // output logic ID_load_regfile_o;
    // output logic ID_mem_read_o;
    // output logic ID_mem_write_o;
    // output logic [3:0] ID_mem_byte_en_o;
);

rv32i_word br_in1, br_in2;
rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;

logic [4:0] rs1, rs2, rd;
logic [width-1:0] rs1_out, rs2_out;

rv32i_control_word ctrl_word;
branch_funct3_t cmpop;
cmpmux::cmpmux_sel_t cmpmux_sel;
pcmux::pcmux_sel_t pcmux_sel;
logic [width-1:0] branch_pc;

logic br_en;
logic [31:0] cmp_mux_out; 

logic br_equal;
logic halt_en;


/****************************************/
/* Start Hazard stuff *******************/
/****************************************/

control_rom ctrl_rom (
    .opcode (opcode),
    .funct3 (funct3),
    .funct7 (funct7),

    .ctrl   (ctrl_word)
);

rv32i_control_word ctrl_word_hd;

always_comb begin : NOP_generator
    ctrl_word_hd = ctrl_word;

    if (ID_HD_controlmux_sel_i == controlmux::zero) begin
        $display("pls stuff @", $time);
        // ctrl_word_hd.opcode = rv32i_opcode'();
        ctrl_word_hd.opcode = op_csr;


        ctrl_word_hd.pcmux_sel = pcmux::pc_plus4;

        ctrl_word_hd.load_regfile = 1'b0;

        // ctrl_word_hd.aluop = alu_xor;
        ctrl_word_hd.alumux1_sel = alumux::rs1_out;
        ctrl_word_hd.alumux2_sel = alumux::rs2_out;
        
        ctrl_word_hd.mem_read = 1'b0;
        ctrl_word_hd.mem_write = 1'b0;
        ctrl_word_hd.mem_byte_en = 1'b0;

        ctrl_word_hd.regfilemux_sel = regfilemux::alu_out;
        
        
        
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
        1'b0 : cmp_mux_out = br_in2;
        1'b1 : cmp_mux_out = i_imm;
        default :
            cmp_mux_out = br_in2;
    endcase
end


cmp cmp_id(
    .cmpop(cmpop),
    .rs1_out(br_in1),
    .cmp_mux_out(cmp_mux_out),
    
    .br_en(br_en)
);

always_comb begin : PREDICTION_COMPARATOR
    //if we have a correct prediction then we don't flush 
    ID_if_id_flush_o = ~(br_en == ID_br_pred_i) 
                        & ((ctrl_word_hd.opcode == op_br) 
                            | (ctrl_word_hd.opcode == op_jal) 
                            | (ctrl_word_hd.opcode == op_jalr)
                        );
                        
end

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

always_comb begin : branchMuxes
    unique case (ID_forwardD_i)
        forwardingmux3::id      : br_in1 = rs1_out;
        forwardingmux3::ex      : br_in1 = EX_alu_out;
        forwardingmux3::mem_alu : br_in1 = EX_MEM_alu_out; // EX_MEM_rs1_out_i
        forwardingmux3::mem_ld  : br_in1 = MEM_data_mem_rdata; 
        forwardingmux3::wb_alu  : br_in1 = MEM_WB_alu_out;
        forwardingmux3::wb_ld   : br_in1 = WB_data_mem_rdata;
        default : begin
            br_in1 = rs1_out;
            $display("shsdf");
        end
    endcase



    unique case (ID_forwardE_i)
        forwardingmux4::id      : br_in2 = rs2_out;
        forwardingmux4::ex      : br_in2 = EX_alu_out;
        forwardingmux4::mem_alu : br_in2 = EX_MEM_alu_out; // EX_MEM_rs2_out_i
        forwardingmux4::mem_ld  : br_in2 = MEM_data_mem_rdata;
        forwardingmux4::wb_alu  : br_in2 = MEM_WB_alu_out;
        forwardingmux4::wb_ld   : br_in2 = WB_data_mem_rdata;
        default : begin
            br_in2 = rs2_out;
            $display("plplplp");
        end
    endcase 
end

branch_resolver branch_resolver (
    .opcode_i(opcode),
    .i_imm_i(i_imm), .b_imm_i(b_imm), .j_imm_i(j_imm),
    .rs1_out_i(br_in1), .rs2_out_i(br_in2),
    .br_en_i(br_en),
    .pc_addr_cur_i(ID_pc_out_i),

    .addr_o(branch_pc),
    .pcmux_sel_o(pcmux_sel)
);

always_comb begin : HALT_CHECK
    br_equal = branch_pc == ID_pc_out_i;
    halt_en = br_en & br_equal & ~rst ? 1'b1 : 1'b0;
end

always_comb begin : set_output
    ID_ctrl_word_o = ctrl_word_hd;
    ID_instr_o = ID_instr_i;
    ID_pc_out_o = ID_pc_out_i;

    ID_branch_pc_o = branch_pc;
    ID_pcmux_sel_o = pcmux_sel;

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

    ID_br_pred_o = ID_br_pred_i;

    ID_halt_en_o = halt_en;
end

endmodule : ID