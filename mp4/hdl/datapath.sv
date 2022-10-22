import rv32i_types::*;

module datapath(
    input logic clk, rst 
    
    input rv32i_word 	data_mem_rdata, 
    input rv32i_word 	instr_mem_rdata, 

); 

logic [6:0] opcode; 
logic [2:0] funct3; 
logic [6:0] funct7; 

// opcode of any instruction 
assign opcode = instr_mem_rdata[6:0]; 

// funct3 of any instruction 
assign funct3 = instr_mem_rdata[2:0]; 

// funct7 of any instruction 
assign funct7 = instr_mem_rdata[6:0]; 

// control signals from the control block ?

logic load_pc, pcmux_out, pc_out, pcmux_sel; 

pc_register pc_register(
    // inputs 
    .clk (clk), .rst (rst),
    .load(load_pc), .in(pcmux_out), 
    //ouputs 
    .out(pc_out) 

); 

register MAR(


); 


register MDR(


); 

always_comb begin : MUXES

unique case(pcmux_sel) 
    pcmux::pc_plus4: pcmux_out = pc_out + 4;
    pcmux::alu_out: pcmux_out = alu_out; 
    pcmux::alu_mod2: pcmux_out = alu_out & ~(32'b0000_0000_0000_0000_0000_0000_0000_0001);  
    
endcase  


endmodule 