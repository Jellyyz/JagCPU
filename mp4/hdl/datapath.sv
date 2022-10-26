
module datapath
import rv32i_types::*;
(
    input logic clk, rst, 
    
	//Remove after CP1
    input 					instr_mem_resp,
    input rv32i_word 	instr_mem_rdata,
	input 					data_mem_resp,
    input rv32i_word 	data_mem_rdata, 
    output logic 			instr_read,
	output rv32i_word 	instr_mem_address,
    output logic 			data_read,
    output logic 			data_write,
    output logic [3:0] 	data_mbe,
    output rv32i_word 	data_mem_address,
    output rv32i_word 	data_mem_wdata

); 

// master_ctrl word to be used for every sel/ld/control signal. 
rv32i_control_word ctrl; 

logic [6:0] opcode; 
logic [2:0] funct3; 
logic [6:0] funct7; 


// ~~~~~~~~~~~~~~~~~~~~~ ALL THE MODULES FOR THE MAIN PIPELINE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// contains the PC register and PC incrementation 
// @TODO: 
// load signal for PC : load_pc 
// pc mux is not implemented yet?? this is called : pc_mux_out btw in this module 
// need to think about how to parse control words through every stage 

rv32i_word IF_pc_out;
rv32i_word IF_ir_out; 

IF IF(
    // input 
    .clk(clk), .rst(rst), 
    .instr_mem_rdata(instr_mem_rdata), 
    .ctrl(), 
    .EX_MEM_alu_out(EX_MEM_alu_out),
    // output 
    .IF_pc_out(IF_pc_out), 
    .IF_ir_out(IF_ir_out)
); 

// contains the PC register and IR register
// @TODO: 
// unsure where IR comes from 
// also unsure how to load regs 
rv32i_word IF_ID_pc_out_o, IF_ID_instr_o; 

IF_ID IF_ID(
    // input 
    .clk(clk), 
    .rst(rst), 

    .flush_i(1'b0), 
    .load_i(1'b1), 
    .IF_ID_pc_out_i(IF_pc_out), 
    .IF_ID_instr_i(IF_ir_out), 
    .IF_ID_pc_out_o(IF_ID_pc_out_o), 
    .IF_ID_instr_o(IF_ID_instr_o)
); 

rv32i_control_word ID_ctrl_word_o; 
rv32i_word ID_instr_o, ID_pc_out_o; 

rv32i_word ID_rs1_out_o, ID_rs2_out_o; 
rv32i_word ID_i_imm_o, ID_s_imm_o, ID_b_imm_o, ID_u_imm_o, ID_j_imm_o;
logic [4:0] ID_rd_o;
logic ID_br_en_o; 
ID ID(
// @TODO: 
// unsure where IR comes from 
// we need a transparency regfile 
// we need to figure out where rs1, rs2, imm, etc comes from 
    // inputs
    .clk(clk), 
    .rst(rst), 
    
    .ID_instr_i(IF_ID_instr_o), 
    .ID_pc_out_i(IF_ID_pc_out_o), 
    
    .ID_load_regfile_i(WB_load_regfile_o), 
    .ID_rd_wr_i(WB_rd_o), 
    .ID_wr_data_i(WB_regfilemux_out_o), 

    // outputs
    .ID_ctrl_word_o(ID_ctrl_word_o), .ID_instr_o(ID_instr_o), 
    .ID_pc_out_o(ID_pc_out_o),
    .ID_rs1_out_o(ID_rs1_out_o), .ID_rs2_out_o(ID_rs2_out_o), 

    .ID_i_imm_o(ID_i_imm_o), .ID_s_imm_o(ID_s_imm_o), .ID_b_imm_o(ID_b_imm_o), 
    .ID_u_imm_o(ID_u_imm_o), .ID_j_imm_o(ID_j_imm_o), 
    
    .ID_rd_o(ID_rd_o), 
    .ID_br_en_o(ID_br_en_o) 


); 

rv32i_control_word ID_EX_ctrl_word_o; 
rv32i_word ID_EX_instr_o;
rv32i_word ID_EX_pc_out_o, ID_EX_rs1_out_o, ID_EX_rs2_out_o; 
rv32i_word ID_EX_i_imm_o, ID_EX_s_imm_o, ID_EX_b_imm_o; 
rv32i_word ID_EX_u_imm_o, ID_EX_j_imm_o; 
logic [4:0] ID_EX_rd_o;
logic ID_EX_br_en_o; 
ID_EX ID_EX(
    // inputs 
    .clk(clk), .rst(rst),
    .load_i(1'b1), 

    .ID_EX_ctrl_word_i(ID_ctrl_word_o), .ID_EX_instr_i(ID_instr_o), .ID_EX_pc_out_i(ID_pc_out_o),
    .ID_EX_rs1_out_i(ID_rs1_out_o), .ID_EX_rs2_out_i(ID_rs2_out_o), 

    .ID_EX_i_imm_i(ID_i_imm_o), .ID_EX_s_imm_i(ID_s_imm_o), .ID_EX_b_imm_i(ID_b_imm_o), 
    .ID_EX_u_imm_i(ID_u_imm_o), .ID_EX_j_imm_i(ID_j_imm_o), 
    .ID_EX_rd_i(ID_rd_o), 
    .ID_EX_br_en_i(ID_br_en_o), 

    // outputs 
    .ID_EX_ctrl_word_o(ID_EX_ctrl_word_o), .ID_EX_instr_o(ID_EX_instr_o), 
    .ID_EX_pc_out_o(ID_EX_pc_out_o), .ID_EX_rs1_out_o(ID_EX_rs1_out_o), .ID_EX_rs2_out_o(ID_EX_rs2_out_o), 

    .ID_EX_i_imm_o(ID_EX_i_imm_o), .ID_EX_s_imm_o(ID_EX_s_imm_o), .ID_EX_b_imm_o(ID_EX_b_imm_o), 
    .ID_EX_u_imm_o(ID_EX_u_imm_o), .ID_EX_j_imm_o(ID_EX_j_imm_o), 

    .ID_EX_rd_o(ID_EX_rd_o), .ID_EX_br_en_o(ID_EX_br_en_o)

); 

    rv32i_word EX_pc_out_o;  
    rv32i_word EX_pc_plus4_o; 
    rv32i_word EX_instr_o; 
    rv32i_word EX_i_imm_o, EX_s_imm_o; 
    rv32i_word EX_b_imm_o, EX_u_imm_o; 
    rv32i_word EX_j_imm_o; 
    rv32i_word EX_rs2_out_o; 
    rv32i_control_word EX_ctrl_word_o; 
    logic [4:0] EX_rd_o; 
    rv32i_word  EX_alu_out_o; 
    logic EX_br_en_o; 


EX EX(
// i think this one is the easiest once we have the other crap done. 
    // inputs 
    .clk(clk), .rst(rst), 
    .EX_pc_out_i(ID_EX_pc_out_o),     
    .EX_rs1_out_i(ID_EX_rs1_out_o), .EX_rs2_out_i(ID_EX_rs2_out_o), 
    .EX_rd_i(ID_EX_rd_o), .EX_instr_i(ID_EX_instr_o), 
    .EX_br_en_i(ID_EX_br_en_o), 

    .EX_i_imm_i(ID_EX_i_imm_o), .EX_u_imm_i(ID_EX_u_imm_o), 
    .EX_b_imm_i(ID_EX_b_imm_o), .EX_s_imm_i(ID_EX_s_imm_o),
    .EX_j_imm_i(ID_EX_j_imm_o),

    // outputs 
    .EX_pc_out(EX_pc_out_o), .EX_pc_plus4_o(EX_pc_plus4_o), 
    .EX_instr_o(EX_instr_o), 
    .EX_i_imm_out(EX_i_imm_o), .EX_u_imm_out(EX_u_imm_o), 
    .EX_b_imm_out(EX_b_imm_o), .EX_s_imm_out(EX_s_imm_o), .EX_j_imm_out(EX_j_imm_o),

    .EX_rs2_out_o(EX_rs2_out_o), 
    .EX_ctrl_word_o(EX_ctrl_word_o), 
    .EX_rd_o(EX_rd_o), 
    .EX_alu_out_o(EX_alu_out_o),
    .EX_br_en_o(EX_br_en_o) 

); 

rv32i_word EX_MEM_pc_out_o; 
rv32i_word EX_MEM_pc_plus4_o; 
rv32i_word EX_MEM_instr_o;
rv32i_word EX_MEM_i_imm_o;
rv32i_word EX_MEM_s_imm_o;
rv32i_word EX_MEM_b_imm_o;
rv32i_word EX_MEM_u_imm_o;
rv32i_word EX_MEM_j_imm_o;
rv32i_reg EX_MEM_rs2_out_o;
rv32i_control_word EX_MEM_ctrl_word_o;
logic [4:0] EX_MEM_rd_o;
rv32i_word  EX_MEM_alu_out_o;
logic EX_MEM_br_en_o;
EX_MEM EX_MEM(
    // inputs 
    .clk(clk), .rst(rst), 
    .load_i(1'b1),
    
    .EX_MEM_pc_out_i(EX_pc_out_o), .EX_MEM_pc_plus4_i(EX_pc_plus4_o), 
    .EX_MEM_instr_i(EX_instr_o),
    .EX_MEM_i_imm_i(EX_i_imm_o), .EX_MEM_s_imm_i(EX_s_imm_o),
    .EX_MEM_b_imm_i(EX_b_imm_o), .EX_MEM_u_imm_i(EX_u_imm_o),
    .EX_MEM_j_imm_i(EX_j_imm_o),
    .EX_MEM_rs2_out_i(EX_rs2_out_o),
    .EX_MEM_ctrl_word_i(EX_ctrl_word_o),
    .EX_MEM_rd_i(EX_rd_o),
    .EX_MEM_alu_out_i(EX_alu_out_o),
    .EX_MEM_br_en_i(EX_br_en_o),

    // outputs
    .EX_MEM_pc_out_o(EX_MEM_pc_out_o), .EX_MEM_pc_plus4_o(EX_MEM_pc_plus4_o), 
    .EX_MEM_instr_o(EX_MEM_instr_o),
    .EX_MEM_i_imm_o(EX_MEM_i_imm_o), .EX_MEM_s_imm_o(EX_MEM_s_imm_o),
    .EX_MEM_b_imm_o(EX_MEM_b_imm_o), .EX_MEM_u_imm_o(EX_MEM_u_imm_o),
    .EX_MEM_j_imm_o(EX_MEM_j_imm_o),
    .EX_MEM_rs2_out_o(EX_MEM_rs2_out_o),
    .EX_MEM_ctrl_word_o(EX_MEM_ctrl_word_o), 
    .EX_MEM_rd_o(EX_MEM_rd_o),
    .EX_MEM_alu_out_o(EX_MEM_alu_out_o),
    .EX_MEM_br_en_o(EX_MEM_br_en_o)


); 
logic MEM_pcmux_sel_o;
logic MEM_alu_out_o;
rv32i_control_word MEM_ctrl_word_o;
logic MEM_mem_read_o;
logic MEM_mem_write_o;
logic MEM_br_en_o;
logic [4:0] MEM_rd_o;
logic [width-1:0] MEM_pc_out_o;
logic [width-1:0] MEM_pc_plus4_o;

logic [width-1:0] MEM_instr_o;
rv32i_word MEM_data_mem_address_o;
rv32i_word MEM_data_mem_wdata_o;
logic [width-1:0] MEM_i_imm_o;
logic [width-1:0] MEM_s_imm_o;
logic [width-1:0] MEM_b_imm_o;
logic [width-1:0] MEM_u_imm_o;
logic [width-1:0] MEM_j_imm_o;

// output rv32i_word MEM_data_mem_rdata
MEM MEM(
    // inputs 
    .MEM_pc_out_i(EX_MEM_pc_out_o), .MEM_pc_plus4_i(EX_MEM_pc_plus4_o), 
    .MEM_instr_i(EX_MEM_instr_o), 
    
    .MEM_i_imm_i(EX_MEM_i_imm_o),
    .MEM_s_imm_i(EX_MEM_s_imm_o), .MEM_b_imm_i(EX_MEM_b_imm_o),
    .MEM_u_imm_i(EX_MEM_u_imm_o), .MEM_j_imm_i(EX_MEM_j_imm_o),
    .MEM_rs2_out_i(EX_MEM_rs2_out_o),
    .MEM_ctrl_word_i(EX_MEM_ctrl_word_o),
    .MEM_rd_i(EX_MEM_rd_o),
    .MEM_alu_out_i(EX_MEM_alu_out_o),
    .MEM_br_en_i(EX_MEM_br_en_o),

    // outputs 
    .MEM_pcmux_sel_o(MEM_pcmux_sel_o),
    .MEM_alu_out_o(MEM_alu_out_o),
    .MEM_rd_o(MEM_rd_o),
    .MEM_ctrl_word_o(MEM_ctrl_word_o),

    .MEM_mem_read_o(data_read), .MEM_mem_write_o(data_write),
    
    .MEM_br_en_o(MEM_br_en_o),
    .MEM_pc_out_o(MEM_pc_out_o), 
    .MEM_pc_plus4_o(MEM_pc_plus4_o), 

    .MEM_instr_o(MEM_instr_o),
    
    .MEM_data_mem_address_o(data_mem_address),
    .MEM_data_mem_wdata_o(data_mem_wdata),
    // output rv32i_word data_mem_rdata

    .MEM_i_imm_o(MEM_i_imm_o), .MEM_s_imm_o(MEM_s_imm_o),
    .MEM_b_imm_o(MEM_b_imm_o), .MEM_u_imm_o(MEM_u_imm_o),
    .MEM_j_imm_o(MEM_j_imm_o)

); 

logic MEM_WB_mem_read_o;
logic MEM_WB_mem_write_o;
logic MEM_WB_br_en_o;
logic MEM_WB_pcmux_sel_o;
logic MEM_WB_alu_out_o;
logic [4:0] MEM_WB_rd_o;
rv32i_control_word MEM_WB_ctrl_word_o;
logic [31:0] MEM_WB_pc_out_o;
logic [31:0] MEM_WB_pc_plus4_o;
logic [31:0] MEM_WB_instr_o;
logic [31:0] MEM_WB_i_imm_o;
logic [31:0] MEM_WB_s_imm_o;
logic [31:0] MEM_WB_b_imm_o;
logic [31:0] MEM_WB_u_imm_o;
logic [31:0] MEM_WB_j_imm_o;
logic [31:0] MEM_WB_data_mem_address_o; // magic
logic [31:0] MEM_WB_data_mem_wdata_o; // magic 
logic [31:0] MEM_WB_data_mem_rdata_o;// magic
MEM_WB MEM_WB(
    // inputs 
    .clk(clk), .rst(rst), 
    .load_i(1'b1), 

    // @ TODO FIX MEM_READ_O
    .MEM_WB_mem_read_i(MEM_mem_read_o), .MEM_WB_mem_write_i(MEM_mem_write_o),
    .MEM_WB_br_en_i(MEM_br_en_o),
    .MEM_WB_pcmux_sel_i(MEM_pcmux_sel_o),
    .MEM_WB_alu_out_i(MEM_alu_out_o),
    .MEM_WB_rd_i(MEM_rd_o),
    .MEM_WB_ctrl_word_i(MEM_ctrl_word_o),
    .MEM_WB_pc_out_i(MEM_pc_out_o),
    .MEM_WB_pc_plus4_i(MEM_pc_plus4_o),
    .MEM_WB_instr_i(MEM_instr_o),
    .MEM_WB_i_imm_i(MEM_i_imm_o), .MEM_WB_s_imm_i(MEM_s_imm_o),
    .MEM_WB_b_imm_i(MEM_b_imm_o), .MEM_WB_u_imm_i(MEM_u_imm_o),
    .MEM_WB_j_imm_i(MEM_j_imm_o),
    .MEM_WB_data_mem_address_i(MEM_data_mem_address_o),
    .MEM_WB_data_mem_wdata_i(MEM_data_mem_wdata_o),
    .MEM_WB_data_mem_rdata_i(data_mem_rdata), 

    // outputs 
    .MEM_WB_mem_read_o(data_read), 
    .MEM_WB_mem_write_o(data_write),
    .MEM_WB_br_en_o(MEM_WB_br_en_o), 
    .MEM_WB_pcmux_sel_o(MEM_WB_pcmux_sel_o),
    .MEM_WB_alu_out_o(MEM_WB_alu_out_o),
    .MEM_WB_rd_o(MEM_WB_rd_o),
    .MEM_WB_ctrl_word_o(MEM_WB_ctrl_word_o),
    .MEM_WB_pc_out_o(MEM_WB_pc_out_o),
    .MEM_WB_pc_plus4_o(MEM_WB_pc_plus4_o),
    .MEM_WB_instr_o(MEM_WB_instr_o),
    .MEM_WB_i_imm_o(MEM_WB_i_imm_o),
    .MEM_WB_s_imm_o(MEM_WB_s_imm_o),
    .MEM_WB_b_imm_o(MEM_WB_b_imm_o),
    .MEM_WB_u_imm_o(MEM_WB_u_imm_o),
    .MEM_WB_j_imm_o(MEM_WB_j_imm_o),
    .MEM_WB_data_mem_address_o(data_mem_address), // magic
    .MEM_WB_data_mem_wdata_o(data_mem_wdata), // magic 
    .MEM_WB_data_mem_rdata_o(MEM_WB_data_mem_rdata_o) // magic
); 


logic WB_load_regfile_o;
logic [4:0] WB_rd_o;
logic [width-1:0] WB_regfilemux_out_o;
WB WB (
    .WB_mem_read_i          (data_read),
    .WB_mem_write_i         (data_write),
    .WB_br_en_i             (MEM_WB_br_en_o),
    .WB_pcmux_sel_i         (MEM_WB_pcmux_sel_o),
    .WB_alu_out_i           (MEM_WB_alu_out_o),
    .WB_rd_i                (MEM_WB_rd_o),
    .WB_ctrl_word_i         (MEM_WB_ctrl_word_o),
    .WB_pc_out_i            (MEM_WB_pc_out_o),
    .WB_pc_plus4_i          (MEM_WB_pc_plus4_o),
    .WB_instr_i             (MEM_WB_instr_o),
    .WB_i_imm_i             (MEM_WB_i_imm_o),
    .WB_s_imm_i             (MEM_WB_s_imm_o),
    .WB_b_imm_i             (MEM_WB_b_imm_o),
    .WB_u_imm_i             (MEM_WB_u_imm_o),
    .WB_j_imm_i             (MEM_WB_j_imm_o),
    .WB_data_mem_address_i  (data_mem_address), 
    .WB_data_mem_wdata_i    (data_mem_wdata), 
    .WB_data_mem_rdata_i    (MEM_WB_data_mem_rdata_o),

    .WB_load_regfile_o      (WB_load_regfile_o),
    .WB_rd_o                (WB_rd_o),
    .WB_regfilemux_out_o    (WB_regfilemux_out_o)
);



always_comb begin : CONTROL_WORD

    // opcode of any instruction 
    opcode = instr_mem_rdata[6:0]; 

    // funct3 of any instruction 
    funct3 = instr_mem_rdata[2:0]; 

    // funct7 of any instruction 
    funct7 = instr_mem_rdata[6:0]; 

end 



always_comb begin : MUXES

    unique case(pcmux_sel) 
        pcmux::pc_plus4 : pcmux_out = pc_out + 4;
        pcmux::alu_out : pcmux_out = alu_out; 
        pcmux::alu_mod2 : pcmux_out = alu_out & ~(32'b0000_0000_0000_0000_0000_0000_0000_0001);  
        default: $display("hit pcmux error");
    endcase  
end
endmodule 