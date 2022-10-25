import rv32i_types::*;
module IF(
 
    input logic clk, rst, 
    input logic instr_mem_rdata, 
    input rv32i_control_word ctrl, 
    output rv32i_word IF_pc_out; 
 
); 


pc_register pc_register( 

    // input of the PC register 
    .clk(clk), .rst(rst), 
    .load(load_pc), 
    .in(pc_mux_out), 
 
    // output of the PC register
    .output(pc_out)
); 




endmodule 
