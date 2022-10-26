module IF
import rv32i_types::*;
(
 
    input logic clk, 
    input logic rst, 
    input logic instr_mem_rdata_i, 
    input rv32i_control_word ctrl_word_i, 
    input pcmux::pcmux_sel_t pcmux_sel_i,
    input rv32i_word EX_MEM_alu_out_i, 

    output rv32i_word IF_pc_out_o, 
    output rv32i_word IF_instr_out_o // undriven, for cp1 comes from magic memory
); 


rv32i_word pcmux_out;
// pcmux::pcmux_sel_t pcmux_sel;
// assign pcmux_sel = pcmux_sel_i;

always_comb begin : pc_mux
    unique case (pcmux_sel_i)
        pcmux::pc_plus4 : pcmux_out = IF_pc_out_o + 4; 
        pcmux::alu_out  : pcmux_out = EX_MEM_alu_out_i; 

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
    .in(pcmux_out), 
 
    // output of the PC register
    .out(IF_pc_out_o)
); 




endmodule 

