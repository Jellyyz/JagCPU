import rv32i_types::*;

module datapath(
    input logic clk, rst 
    
    input rv32i_word 	data_mem_rdata, 
    input rv32i_word 	instr_mem_rdata, 

); 

logic [6:0] opcode; 
logic [2:0] funct3; 
logic [6:0] funct7; 

// ~~~~~~~~~~~~~~~~~~~~~ PIPELINE GLUE LOGIC TYPES DECLARATION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// we should try to follow a convention. I propose we do STAGE_COMBBLOCKNAME_INPUT/OUTPUT 
// @TODO: 
// maybe make a struct for the imm's as well? 

rv32i_word IF_pc_out; 
rv32i_word IF_ID_pc_out; 
rv32i_word wb_output; 





// ~~~~~~~~~~~~~~~~~~~~~ ALL THE MODULES FOR THE MAIN PIPELINE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// contains the PC register and PC incrementation 
// @TODO: 
// load signal for PC : load_pc 
// pc mux is not implemented yet?? this is called : pc_mux_out btw in this module 
// need to think about how to parse control words through every stage 
// 

IF IF(
    // input 
    .clk(clk), .rst(rst), 
    .instr_mem_rdata(instr_mem_rdata), 
    .ctrl(ctrl), 
    
    // output 
    .IF_pc_out(IF_pc_out)
); 
// contains the PC register and IR register
// @TODO: 
// unsure where IR comes from 
// also unsure how to load regs 

IF_ID IF_ID(
    // input 
    .clk(clk), .rst(rst), 
    .IF_ID_pc_in(IF_pc_out),
    .IF_ID_pc_ld(), 

    .IF_ID_ir_in(),
    .IF_ID_ir_ld(), 

    // output  
    .IF_ID_pc_out(IF_ID_pc_out)
    .IF_ID_ir_out(),


); 

ID ID(
// @TODO: 
// unsure where IR comes from 
// we need a transparency regfile 
// we need to figure out where rs1, rs2, imm, etc comes from 
    // inputs
    .clk(), .rst(), 
    .ID_pc_in(),
    .ID_imm_in(), 
    .ID_rs1_in(), .ID_rs2_in(), 
    .ID_IR_in(), 
    
    .ID_wb_in(wb_output), 


    // outputs 
    .ID_pc_out(), 
    .ID_imm_out(), 
    .ID_rs1_out(), .ID_rs2_out(), 
    .ID_IR_out() 

);


ID_EX ID_EX(
    // inputs 
    .ID_EX_pc_in(), 

    // outputs 
    .ID_EX_pc_out() 


); 

EX EX(
// i think this one is the easiest once we have the other crap done. 
    // inputs 
    .EX_pc_in(),     

    .EX_wb_in(wb_output), 

    // outputs 
    .EX_pc_out() 

); 


EX_MEM EX_MEM(
    // inputs 
    .EX_MEM_pc_in(), 

    // outputs 
    .EX_MEM_pc_out() 


); 


MEM MEM(
// @TODO: 
// unsure where IR comes from 
// how to interact with memory?? so much signals? 
    // inputs 
    .MEM_pc_in(), 

    // outputs 
    .MEM_pc_out() 

); 

MEM_WB MEM_WB(
    // inputs 
    .MEM_WB_pc_in(), 
    
    // outputs 
    .MEM_WB_pc_out() 
); 


WB WB(
    // inputs 
    .WB_pc_in(), 
    .WB_imm_in(), 
    .WB_mem_rdata_in(), 
    .WB_pc_out_4_in(), 
    .WB_alu_out_in(),
    .WB_br_en_in(),
     

    // outputs 
    .WB_pc_out() 
    .WB_output(wb_output)

); 

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



always_comb begin : CONTROL_WORD
    // opcode of any instruction 
    opcode = instr_mem_rdata[6:0]; 
    // funct3 of any instruction 
    funct3 = instr_mem_rdata[2:0]; 
    // funct7 of any instruction 
    funct7 = instr_mem_rdata[6:0]; 
end 

// master_ctrl word to be used for every sel/ld/control signal. 
rv32i_control_word ctrl; 
control_rom(
    // inputs 
    .opcode(opcode), 
    .funct3(funct3), .funct7(funct7), 
    
    // outputs 
    .ctrl(ctrl) 
);  

endmodule 