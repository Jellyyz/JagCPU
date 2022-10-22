import rv32i_types::*;

module datapath(
    input logic clk, rst 
    

); 

// control signals from the control block 

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