import rv32i_types::*;
module IF(
 
    input logic clk, rst, 
    input logic instr_mem_rdata, 
    input rv32i_control_word ctrl, 
    input rv32i_word EX_MEM_alu_out, 

    output rv32i_word IF_pc_out, 
    output rv32i_word IF_ir_out
); 


rv32i_word IF_pcmux_out; 
always_comb begin : PC_MUX

    unique case (ctrl.pcmux_sel)
    
        pcmux::pc_plus4 : IF_pcmux_out = IF_pc_out + 4; 
        pcmux::alu_out : IF_pcmux_out = EX_MEM_alu_out; 

        default:begin 
            $display("error no pcmux found"); 
            $finish; 
        end 

    endcase 


end 



pc_register pc_register( 

    // input of the PC register 
    .clk(clk), .rst(rst), 
    .load(1'b1), 
    .in(IF_pcmux_out), 
 
    // output of the PC register
    .out(IF_pc_out)
); 




endmodule 

