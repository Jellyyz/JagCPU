module datapath 
import rv32i_types::*;
#(parameter width = 32) (
    input logic clk, rst, 
    

    
	
	// // For CP2
    // input pmem_resp,
    // input [63:0] pmem_rdata,

	// // To physical memory
    // output logic pmem_read,
    // output logic pmem_write,
    // output rv32i_word pmem_address,
    // output [63:0] pmem_wdata

	//Remove after CP1
    input rv32i_word 	instr_mem_rdata,
    input rv32i_word 	data_mem_rdata, 
    output rv32i_word 	data_mem_address,
    output rv32i_word 	data_mem_wdata,

    // undriven or unused 
	output rv32i_word 	instr_mem_address,
    input 					instr_mem_resp,
	input 					data_mem_resp,
    output logic 			instr_read,
    output logic 			data_read,
    output logic 			data_write,
    output logic [3:0] 	data_mbe

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

/****************************************/
/* Declarations for IF ******************/
/****************************************/
rv32i_word IF_pc_out;
rv32i_word IF_instr_out; 
logic IF_br_pred;

/****************************************/
/* Declarations for IF/ID ***************/
/****************************************/
rv32i_word IF_ID_pc_out;
rv32i_word IF_ID_instr; 
logic IF_ID_br_pred;

/****************************************/
/* Declarations for ID ******************/
/****************************************/
rv32i_control_word ID_ctrl_word; 
rv32i_word ID_instr;
rv32i_word ID_pc_out;  
rv32i_word ID_rs1_out;
rv32i_word ID_rs2_out; 
rv32i_word ID_i_imm, ID_s_imm, ID_b_imm, ID_u_imm, ID_j_imm;
logic [4:0] ID_rs1, ID_rs2, ID_rd;
logic ID_br_en;
logic [width-1:0] ID_branch_pc;
pcmux::pcmux_sel_t ID_pcmux_sel;
logic ID_br_pred;
logic IF_ID_flush;
lgoic ID_halt_en;

/****************************************/
/* Declarations for ID/EX ***************/
/****************************************/
rv32i_control_word ID_EX_ctrl_word; 
rv32i_word ID_EX_instr;
rv32i_word ID_EX_pc_out, ID_EX_rs1_out, ID_EX_rs2_out; 
rv32i_word ID_EX_i_imm, ID_EX_s_imm, ID_EX_b_imm, ID_EX_u_imm, ID_EX_j_imm; 
logic [4:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
logic ID_EX_br_en; 
logic ID_EX_br_pred;

logic ID_EX_halt_en;

/****************************************/
/* Declarations for EX ******************/
/****************************************/
rv32i_word EX_pc_out;  
rv32i_word EX_pc_plus4; 
rv32i_word EX_instr; 
rv32i_word EX_i_imm, EX_s_imm, EX_b_imm, EX_u_imm, EX_j_imm; 
rv32i_word EX_rs1_out, EX_rs2_out; 
rv32i_control_word EX_ctrl_word; 
logic [4:0] EX_rs1, EX_rs2, EX_rd; 
rv32i_word  EX_alu_out; 
logic EX_br_en; 
logic EX_br_pred;
logic EX_load_regfile; 

logic ID_EX_halt_en;

/****************************************/
/* Declarations for EX/MEM **************/
/****************************************/
rv32i_word EX_MEM_pc_out, EX_MEM_pc_plus4; 
rv32i_word EX_MEM_instr;
rv32i_word EX_MEM_i_imm, EX_MEM_s_imm, EX_MEM_b_imm, EX_MEM_u_imm, EX_MEM_j_imm;
rv32i_word EX_MEM_rs1_out, EX_MEM_rs2_out;
rv32i_control_word EX_MEM_ctrl_word;
logic [4:0] EX_MEM_rs1, EX_MEM_rs2, EX_MEM_rd;
rv32i_word  EX_MEM_alu_out;
logic EX_MEM_br_en;

logic EX_MEM_halt_en;

/****************************************/
/* Declarations for MEM *****************/
/****************************************/
pcmux::pcmux_sel_t MEM_pcmux_sel;
logic [width-1:0] MEM_alu_out;
rv32i_control_word MEM_ctrl_word;
logic MEM_mem_read;
logic MEM_mem_write;
logic MEM_br_en;
logic [4:0] MEM_rd;
logic [width-1:0] MEM_pc_out;
logic [width-1:0] MEM_pc_plus4;

logic [width-1:0] MEM_instr;
logic [width-1:0] MEM_i_imm;
logic [width-1:0] MEM_s_imm;
logic [width-1:0] MEM_b_imm;
logic [width-1:0] MEM_u_imm;
logic [width-1:0] MEM_j_imm;

rv32i_word MEM_data_mem_address;
rv32i_word MEM_data_mem_wdata;
rv32i_word MEM_data_mem_rdata;
logic MEM_load_regfile;

logic MEM_halt_en;
// [3:0] MEM_mem_byte_en;

/****************************************/
/* Declarations for MEM/WB **************/
/****************************************/
logic MEM_WB_mem_read;
logic MEM_WB_mem_write;
logic MEM_WB_br_en;
pcmux::pcmux_sel_t MEM_WB_pcmux_sel;
logic [width-1:0] MEM_WB_alu_out;
logic [4:0] MEM_WB_rd;
rv32i_control_word MEM_WB_ctrl_word;
logic [width-1:0] MEM_WB_pc_out;
logic [width-1:0] MEM_WB_pc_plus4;
logic [width-1:0] MEM_WB_instr;
logic [width-1:0] MEM_WB_i_imm;
logic [width-1:0] MEM_WB_s_imm;
logic [width-1:0] MEM_WB_b_imm;
logic [width-1:0] MEM_WB_u_imm;
logic [width-1:0] MEM_WB_j_imm;
logic [width-1:0] MEM_WB_data_mem_address; // magic
logic [width-1:0] MEM_WB_data_mem_wdata; // magic 
logic [width-1:0] MEM_WB_data_mem_rdata;// magic

logic MEM_WB_halt_en;

/****************************************/
/* Declarations for WB ******************/
/****************************************/
logic WB_load_regfile;
logic [4:0] WB_rd;
logic [width-1:0] WB_regfilemux_out;

logic WB_halt_en;

/****************************************/
/* Declarations for forwarding unit *****/
/****************************************/
forwardingmux::forwardingmux1_sel_t forwardA;
forwardingmux::forwardingmux1_sel_t forwardB;
forwardingmux2::forwardingmux2_sel_t forwardC;
forwardingmux3::forwardingmux3_sel_t forwardD; 
forwardingmux4::forwardingmux4_sel_t forwardE; 

/****************************************/
/* Declarations for forwarding unit *****/
/****************************************/
controlmux::controlmux_sel_t ID_HD_controlmux_sel;
logic IF_HD_PC_write;
logic IF_ID_HD_write;


/****************************************/
/* Begin instantiation ******************/
/****************************************/

always_comb begin : MEM_PORTS

    instr_read = 1'b1; 
    instr_mem_address = IF_pc_out; 

end 



IF IF(
    // input 
    .clk(clk),
    .rst(rst), 
    .IF_PC_write_i(IF_HD_PC_write),
    .IF_instr_mem_rdata_i(instr_mem_rdata), 
    // .IF_pcmux_sel_i(MEM_pcmux_sel), // branch resolution in mem
    // .IF_alu_out_i(EX_MEM_alu_out), // branch resolution in mem
    .IF_pcmux_sel_i(ID_pcmux_sel), // branch resolution in decode
    .IF_alu_out_i(ID_branch_pc), // branch resolution in decode

    .IF_br_pred_o(IF_br_pred),

    // output 
    .IF_pc_out_o(IF_pc_out), 
    .IF_instr_out_o(IF_instr_out) // needs to come from magic memory for cp1 this is unused in cp2
);

IF_ID IF_ID(
    // input 
    .clk(clk), 
    .rst(rst), 
    .flush_i(IF_ID_flush), // this flush signal is calcualted in ID stage, looepd back
    // .load_i(1'b1), 
    .load_i(IF_ID_HD_write),

    .IF_ID_pc_out_i(IF_pc_out), 
    .IF_ID_instr_i(instr_mem_rdata), 

    .IF_ID_br_pred_i(IF_br_pred),

    // output
    .IF_ID_pc_out_o(IF_ID_pc_out), 
    .IF_ID_instr_o(IF_ID_instr),

    .IF_ID_br_pred_o(IF_ID_br_pred) 
); 

ID ID(
    // inputs
    .clk(clk), 
    .rst(rst), 
    
    .ID_instr_i(IF_ID_instr), 
    .ID_pc_out_i(IF_ID_pc_out), 
    
    .ID_load_regfile_i(WB_load_regfile), 
    .ID_rd_wr_i(WB_rd), 
    .ID_wr_data_i(WB_regfilemux_out), 

    .ID_HD_controlmux_sel_i(ID_HD_controlmux_sel),
    .ID_forwardD_i(forwardD), 
    .ID_forwardE_i(forwardE), 

    .ID_br_pred_i(IF_ID_br_pred),

    // outputs
    .ID_ctrl_word_o(ID_ctrl_word),
    .ID_instr_o(ID_instr), 
    .ID_pc_out_o(ID_pc_out),
    .ID_rs1_out_o(ID_rs1_out), .ID_rs2_out_o(ID_rs2_out), 

    .ID_i_imm_o(ID_i_imm), .ID_s_imm_o(ID_s_imm), .ID_b_imm_o(ID_b_imm), 
    .ID_u_imm_o(ID_u_imm), .ID_j_imm_o(ID_j_imm), 
    
    .ID_rs1_o(ID_rs1),             // 5 bit output 
    .ID_rs2_o(ID_rs2),              
    .ID_rd_o(ID_rd), 
    .ID_br_en_o(ID_br_en),

    .ID_branch_pc_o(ID_branch_pc), // sent to IF
    .ID_pcmux_sel_o(ID_pcmux_sel), // sent to IF

    .ID_br_pred_o(ID_br_pred),
    .ID_if_id_flush_o(IF_ID_flush),

    // more inputs, for fwding
    .EX_alu_out(EX_alu_out),
    .EX_MEM_alu_out(EX_MEM_alu_out),
    .MEM_data_mem_rdata(MEM_data_mem_rdata), 
    .WB_data_mem_rdata(MEM_WB_data_mem_rdata),
    .MEM_WB_alu_out(MEM_WB_alu_out),
    // .ID_EX_rs1_out_i(EX_alu_out),
    // .ID_EX_rs2_out_i(EX_alu_out), 
    // .EX_MEM_rs1_out_i(EX_MEM_alu_out), 
    // .EX_MEM_rs2_out_i(EX_MEM_alu_out),

    // .MEM_WB_data_mem_rdata_i(MEM_data_mem_rdata)

    .ID_halt_en_o(ID_halt_en)
); 

ID_EX ID_EX(
    // inputs 
    .clk(clk), .rst(rst),
    .load_i(1'b1), 

    .ID_EX_ctrl_word_i(ID_ctrl_word), 
    .ID_EX_instr_i(ID_instr), 
    .ID_EX_pc_out_i(ID_pc_out),
    .ID_EX_rs1_out_i(ID_rs1_out), 
    .ID_EX_rs2_out_i(ID_rs2_out), 

    .ID_EX_i_imm_i(ID_i_imm),
    .ID_EX_s_imm_i(ID_s_imm),
    .ID_EX_b_imm_i(ID_b_imm),
    .ID_EX_u_imm_i(ID_u_imm),
    .ID_EX_j_imm_i(ID_j_imm),

    .ID_EX_rs1_i(ID_rs1),
    .ID_EX_rs2_i(ID_rs2),
    .ID_EX_rd_i(ID_rd),
    .ID_EX_br_en_i(ID_br_en),

    .ID_EX_br_pred_i(ID_br_pred),

    .ID_EX_halt_en_i(ID_halt_en)

    // outputs 
    .ID_EX_ctrl_word_o(ID_EX_ctrl_word),
    .ID_EX_instr_o(ID_EX_instr),
    .ID_EX_pc_out_o(ID_EX_pc_out),
    .ID_EX_rs1_out_o(ID_EX_rs1_out),
    .ID_EX_rs2_out_o(ID_EX_rs2_out),

    .ID_EX_i_imm_o(ID_EX_i_imm),
    .ID_EX_s_imm_o(ID_EX_s_imm),
    .ID_EX_b_imm_o(ID_EX_b_imm),
    .ID_EX_u_imm_o(ID_EX_u_imm),
    .ID_EX_j_imm_o(ID_EX_j_imm), 

    .ID_EX_rs1_o(ID_EX_rs1),
    .ID_EX_rs2_o(ID_EX_rs2),
    .ID_EX_rd_o(ID_EX_rd),
    .ID_EX_br_en_o(ID_EX_br_en),

    .ID_EX_br_pred_o(ID_EX_br_pred),

    .ID_EX_halt_en_o(ID_EX_halt_en)

); 

EX EX(
    // inputs 
    .EX_rs1_i(ID_EX_rs1), 
    .EX_rs2_i(ID_EX_rs2), 
    .EX_rd_i(ID_EX_rd), 
    .EX_pc_out_i(ID_EX_pc_out),     
    .EX_rs1_out_i(ID_EX_rs1_out),
    .EX_rs2_out_i(ID_EX_rs2_out), 
    // .EX_rs1_i(),
    .EX_instr_i(ID_EX_instr), 
    .EX_br_en_i(ID_EX_br_en),   
    .EX_ctrl_word_i(ID_EX_ctrl_word),
    .EX_i_imm_i(ID_EX_i_imm), .EX_u_imm_i(ID_EX_u_imm), 
    .EX_b_imm_i(ID_EX_b_imm), .EX_s_imm_i(ID_EX_s_imm),
    .EX_j_imm_i(ID_EX_j_imm),
    .EX_forwardA_i(forwardA),
    .EX_forwardB_i(forwardB),
    // .EX_forwardA_i(forwardingmux::id_ex),
    // .EX_forwardB_i(forwardingmux::id_ex),
    // .EX_from_WB_regfilemux_out_i(MEM_WB_alu_out), // from MEM/WB pipe reg output
    .EX_from_WB_regfilemux_out_i(WB_regfilemux_out), // from WB regfile mux select output
    .EX_from_MEM_alu_out_i(EX_MEM_alu_out), // from EX/MEM pipe reg output

    .EX_br_pred_i(ID_EX_br_pred),

    .EX_halt_en_i(ID_EX_halt_en),


    // outputs 
    .EX_rs1_o(EX_rs1), 
    .EX_rs2_o(EX_rs2), 
    .EX_rd_o(EX_rd), 
    .EX_pc_out_o(EX_pc_out),
    .EX_pc_plus4_o(EX_pc_plus4), 
    .EX_instr_o(EX_instr), 
    .EX_i_imm_o(EX_i_imm),
    .EX_u_imm_o(EX_u_imm), 
    .EX_b_imm_o(EX_b_imm),
    .EX_s_imm_o(EX_s_imm),
    .EX_j_imm_o(EX_j_imm),
    .EX_rs1_out_o(EX_rs1_out),
    .EX_rs2_out_o(EX_rs2_out), 
    .EX_ctrl_word_o(EX_ctrl_word), 
    .EX_alu_out_o(EX_alu_out),
    .EX_br_en_o(EX_br_en),

    .EX_br_pred_o(EX_br_pred),               // branch prediction not carried past this point,

    .EX_load_regfile_o(EX_load_regfile),

    .EX_halt_en_o(EX_halt_en)
); 

EX_MEM EX_MEM(
    // inputs 
    .clk(clk), 
    .rst(rst), 
    .load_i(1'b1),
    .EX_MEM_rs1_i(EX_rs1),
    .EX_MEM_rs2_i(EX_rs2), 
    .EX_MEM_rd_i(EX_rd), 
    .EX_MEM_pc_out_i(EX_pc_out),
    .EX_MEM_pc_plus4_i(EX_pc_plus4), 
    .EX_MEM_instr_i(EX_instr),
    .EX_MEM_i_imm_i(EX_i_imm),
    .EX_MEM_s_imm_i(EX_s_imm),  
    .EX_MEM_b_imm_i(EX_b_imm),
    .EX_MEM_u_imm_i(EX_u_imm),
    .EX_MEM_j_imm_i(EX_j_imm),
    .EX_MEM_rs1_out_i(EX_rs1_out),
    .EX_MEM_rs2_out_i(EX_rs2_out),
    .EX_MEM_ctrl_word_i(EX_ctrl_word),
    .EX_MEM_alu_out_i(EX_alu_out),
    .EX_MEM_br_en_i(EX_br_en),

    .EX_MEM_halt_en_i(EX_halt_en),

    // outputs
    .EX_MEM_rs1_o(EX_MEM_rs1), 
    .EX_MEM_rs2_o(EX_MEM_rs2), 
    .EX_MEM_rd_o(EX_MEM_rd), 
    .EX_MEM_pc_out_o(EX_MEM_pc_out),
    .EX_MEM_pc_plus4_o(EX_MEM_pc_plus4), 
    .EX_MEM_instr_o(EX_MEM_instr),
    .EX_MEM_i_imm_o(EX_MEM_i_imm),
    .EX_MEM_s_imm_o(EX_MEM_s_imm),
    .EX_MEM_b_imm_o(EX_MEM_b_imm),
    .EX_MEM_u_imm_o(EX_MEM_u_imm),
    .EX_MEM_j_imm_o(EX_MEM_j_imm),
    .EX_MEM_rs1_out_o(EX_MEM_rs1_out),
    .EX_MEM_rs2_out_o(EX_MEM_rs2_out),
    .EX_MEM_ctrl_word_o(EX_MEM_ctrl_word), 
    .EX_MEM_alu_out_o(EX_MEM_alu_out),
    .EX_MEM_br_en_o(EX_MEM_br_en),

    .EX_MEM_halt_en_o(EX_MEM_halt_en)
); 


MEM MEM(
    // inputs 
    .MEM_pc_out_i(EX_MEM_pc_out),
    .MEM_pc_plus4_i(EX_MEM_pc_plus4), 
    .MEM_instr_i(EX_MEM_instr),
    
    .MEM_i_imm_i(EX_MEM_i_imm),
    .MEM_s_imm_i(EX_MEM_s_imm),
    .MEM_b_imm_i(EX_MEM_b_imm),
    .MEM_u_imm_i(EX_MEM_u_imm),
    .MEM_j_imm_i(EX_MEM_j_imm),

    .MEM_rs2_out_i(EX_MEM_rs2_out),
    // .MEM_mem_wb_rdata_i(MEM_WB_data_mem_rdata), // from MEM_WB register, rdata from data memory
    .MEM_forwardC_i(forwardC),
    .MEM_from_WB_rd_i(MEM_WB_data_mem_rdata), 
    .MEM_ctrl_word_i(EX_MEM_ctrl_word),
    .MEM_rd_i(EX_MEM_rd),
    .MEM_alu_out_i(EX_MEM_alu_out),
    .MEM_br_en_i(EX_MEM_br_en),

    .MEM_halt_en_i(EX_MEM_halt_en),

    // outputs 
    .MEM_pcmux_sel_o(MEM_pcmux_sel),
    .MEM_alu_out_o(MEM_alu_out),
    .MEM_rd_o(MEM_rd),
    .MEM_ctrl_word_o(MEM_ctrl_word),

    .MEM_mem_read_o(data_read), 
    .MEM_mem_write_o(data_write),
    
    .MEM_br_en_o(MEM_br_en),
    .MEM_pc_out_o(MEM_pc_out), 
    .MEM_pc_plus4_o(MEM_pc_plus4), 

    .MEM_instr_o(MEM_instr),
    
    .MEM_data_mem_address_o(data_mem_address),
    .MEM_data_mem_wdata_o(data_mem_wdata),
    //.MEM_data_mem_rdata(),

    .MEM_i_imm_o(MEM_i_imm), .MEM_s_imm_o(MEM_s_imm),
    .MEM_b_imm_o(MEM_b_imm), .MEM_u_imm_o(MEM_u_imm),
    .MEM_j_imm_o(MEM_j_imm),

    .MEM_mem_byte_en_o(data_mbe),

    .MEM_load_regfile_o(MEM_load_regfile),

    .MEM_halt_en_o(MEM_halt_en)
); 

assign MEM_data_mem_rdata = data_mem_rdata; // MUST BE CHANGED WHEN INTEGRATING CACHE

MEM_WB MEM_WB(
    // inputs 
    .clk(clk), .rst(rst), 
    .load_i(1'b1), 

    // @ TODO FIX MEM_READ_O
    // .MEM_WB_mem_read_i          (MEM_mem_read),
    // .MEM_WB_mem_write_i         (MEM_mem_write),
    .MEM_WB_br_en_i             (MEM_br_en),
    .MEM_WB_pcmux_sel_i         (MEM_pcmux_sel),
    .MEM_WB_alu_out_i           (MEM_alu_out),
    .MEM_WB_rd_i                (MEM_rd),
    .MEM_WB_ctrl_word_i         (MEM_ctrl_word),
    .MEM_WB_pc_out_i            (MEM_pc_out),
    .MEM_WB_pc_plus4_i          (MEM_pc_plus4),
    .MEM_WB_instr_i             (MEM_instr),
    .MEM_WB_i_imm_i             (MEM_i_imm),
    .MEM_WB_s_imm_i             (MEM_s_imm),
    .MEM_WB_b_imm_i             (MEM_b_imm),
    .MEM_WB_u_imm_i             (MEM_u_imm),
    .MEM_WB_j_imm_i             (MEM_j_imm),
    .MEM_WB_data_mem_address_i  (data_mem_address), // only for rvfi
    .MEM_WB_data_mem_wdata_i    (data_mem_wdata),   // only for rvfi
    .MEM_WB_data_mem_rdata_i    (MEM_data_mem_rdata), // MUST BE CHANGED WHEN INTEGRATING CACHE

    .MEM_WB_halt_en_i(MEM_halt_en),

    // outputs
    // .MEM_WB_mem_read_o(MEM_WB_mem_read),
    // .MEM_WB_mem_write_o(MEM_WB_mem_write),
    .MEM_WB_br_en_o(MEM_WB_br_en),
    .MEM_WB_pcmux_sel_o(MEM_WB_pcmux_sel),
    .MEM_WB_alu_out_o(MEM_WB_alu_out),
    .MEM_WB_rd_o(MEM_WB_rd),
    .MEM_WB_ctrl_word_o(MEM_WB_ctrl_word),
    .MEM_WB_pc_out_o(MEM_WB_pc_out),
    .MEM_WB_pc_plus4_o(MEM_WB_pc_plus4),
    .MEM_WB_instr_o(MEM_WB_instr),
    .MEM_WB_i_imm_o(MEM_WB_i_imm),
    .MEM_WB_s_imm_o(MEM_WB_s_imm),
    .MEM_WB_b_imm_o(MEM_WB_b_imm),
    .MEM_WB_u_imm_o(MEM_WB_u_imm),
    .MEM_WB_j_imm_o(MEM_WB_j_imm),
    .MEM_WB_data_mem_address_o(data_mem_address), // magic // only for rvfi
    .MEM_WB_data_mem_wdata_o(data_mem_wdata), // magic // only for rvfi
    .MEM_WB_data_mem_rdata_o(MEM_WB_data_mem_rdata), // magic

    .MEM_WB_halt_en_o(MEM_WB_halt_en)
); 


WB WB (
    // inputs 
    // .WB_mem_read_i          (MEM_WB_mem_write),
    // .WB_mem_write_i         (MEM_WB_mem_write),
    .WB_br_en_i             (MEM_WB_br_en),
    .WB_pcmux_sel_i         (MEM_WB_pcmux_sel),
    .WB_alu_out_i           (MEM_WB_alu_out),
    .WB_rd_i                (MEM_WB_rd),
    .WB_ctrl_word_i         (MEM_WB_ctrl_word),
    .WB_pc_out_i            (MEM_WB_pc_out),
    .WB_pc_plus4_i          (MEM_WB_pc_plus4),
    .WB_instr_i             (MEM_WB_instr),
    .WB_i_imm_i             (MEM_WB_i_imm),
    .WB_s_imm_i             (MEM_WB_s_imm),
    .WB_b_imm_i             (MEM_WB_b_imm),
    .WB_u_imm_i             (MEM_WB_u_imm),
    .WB_j_imm_i             (MEM_WB_j_imm),
    .WB_data_mem_address_i  (data_mem_address), // only for rvfi
    .WB_data_mem_wdata_i    (data_mem_wdata), // only for rvfi 
    .WB_data_mem_rdata_i    (MEM_WB_data_mem_rdata),

    .WB_halt_en_i(MEM_WB_halt_en),

    // outputs 
    .WB_load_regfile_o      (WB_load_regfile),
    .WB_rd_o                (WB_rd),
    .WB_regfilemux_out_o    (WB_regfilemux_out),

    // .WB_halt_en_o           (WB_halt_en)
);

forwarder forwarding(
    .ID_EX_rs1_i        (ID_EX_rs1),
    .ID_EX_rs2_i        (ID_EX_rs2),
    .EX_MEM_rs2_i       (EX_MEM_rs2),
    .EX_MEM_rd_i        (EX_MEM_rd),
    .MEM_WB_rd_i        (MEM_WB_rd),
    .MEM_load_regfile_i (MEM_load_regfile),
    .WB_load_regfile_i  (WB_load_regfile),
    .EX_load_regfile_i  (EX_load_regfile), 
    .REGFILE_rs1_i      (ID_rs1), 
    .REGFILE_rs2_i      (ID_rs2), 
    .ID_EX_rd_i         (ID_EX_rd),


    .EX_MEM_ctrl_word_i(EX_MEM_ctrl_word),
    .MEM_WB_ctrl_word_i(MEM_WB_ctrl_word),

    .ID_HD_controlmux_sel_i(ID_HD_controlmux_sel),
    
    .forwardA_o         (forwardA),
    .forwardB_o         (forwardB),
    .forwardC_o         (forwardC), 
    .forwardD_o         (forwardD), 
    .forwardE_o         (forwardE) 
);


hazard_detector hazard_detector (
    .EX_mem_read_i(EX_ctrl_word.mem_read),
    .MEM_mem_read_i(MEM_ctrl_word.mem_read), 
    .ID_rs1_i(ID_rs1),
    .ID_rs2_i(ID_rs2),
    .EX_rd_i(EX_rd),
    .MEM_rd_i(MEM_rd), 
    .ID_HD_controlmux_sel_o(ID_HD_controlmux_sel),
    .IF_HD_PC_write_o(IF_HD_PC_write),
    .IF_ID_HD_write_o(IF_ID_HD_write)
);



always_comb begin : CONTROL_WORD

    // opcode of any instruction 
    opcode = instr_mem_rdata[6:0]; 

    // funct3 of any instruction 
    funct3 = instr_mem_rdata[2:0]; 

    // funct7 of any instruction 
    funct7 = instr_mem_rdata[6:0]; 

end 


endmodule 