
module IF
import rv32i_types::*;
    (
 
    input logic clk,
    input logic rst,
    input logic IF_PC_write_i,
    input pcmux::pcmux_sel_t IF_pcmux_sel_i,
    input rv32i_word IF_alu_out_i,
    output rv32i_word IF_pc_out_o,
    output rv32i_word IF_instr_out_o // undriven, for cp1 comes from magic memory
); 


rv32i_word pcmux_out;
// pcmux::pcmux_sel_t pcmux_sel;
// assign pcmux_sel = pcmux_sel_i;

always_comb begin : pc_mux
    unique case (IF_pcmux_sel_i)
        pcmux::pc_plus4 : pcmux_out = IF_pc_out_o + 4; 
        pcmux::alu_mod2 : pcmux_out = IF_alu_out_i & ~(32'b0000_0000_0000_0000_0000_0000_0000_0001);  
        pcmux::alu_out  : pcmux_out = IF_alu_out_i; 
        default:begin 
            $display("error no pcmux found"); 
            $finish; 
        end 
    endcase 
end 



pc_register pc_register( 

    // input of the PC register 
    .clk(clk), .rst(rst), 
    .load(IF_PC_write_i), 
    .in(pcmux_out), 
 
    // output of the PC register
    .out(IF_pc_out_o)
); 




endmodule 

