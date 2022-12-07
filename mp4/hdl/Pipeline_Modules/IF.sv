
module IF
import rv32i_types::*;
    (
 
    input logic clk,
    input logic rst,
    input logic IF_PC_write_i,
    input rv32i_word IF_instr_mem_rdata_i,
    input pcmux::pcmux_sel_t IF_pcmux_sel_i,
    input rv32i_word IF_alu_out_i,
    // input rv32i_word IF_adder_out_o_i, // come from IF/ID pipe reg, in case there is branch predicted, need to give PC
    output rv32i_word IF_pc_out_o,
    output rv32i_word IF_instr_out_o, // undriven, for cp1 comes from magic memory
    output rv32i_word IF_adder_out_o,
    output rv32i_word IF_pcmux_out_o,

    // output logic IF_br_pred_o
    output ctrl_flow_preds IF_br_pred_o,


    input logic IF_pc_load_i
); 


rv32i_word pcmux_out;
// pcmux::pcmux_sel_t pcmux_sel;
// assign pcmux_sel = pcmux_sel_i;
logic br_pred_static_NT;
logic br_pred_static_BTFNT;

assign br_pred_static_NT = 1'b0;
always_comb begin : setOutput
    IF_br_pred_o = '0;
    IF_br_pred_o.staticNT_pred = br_pred_static_NT;
    IF_br_pred_o.staticBTFNT_pred = op_br == rv32i_opcode'(IF_instr_mem_rdata_i[6:0]) ? IF_instr_mem_rdata_i[31] : 1'b0;
    // IF_br_pred_o.staticBTFNT_pred = IF_instr_mem_rdata_i[31];
end


always_comb begin : pc_mux
    unique case (IF_pcmux_sel_i)
        pcmux::pc_plus4 : pcmux_out = IF_pc_out_o + 4; 
        pcmux::alu_mod2 : pcmux_out = IF_alu_out_i & ~(32'b0000_0000_0000_0000_0000_0000_0000_0001);  
        pcmux::alu_out  : pcmux_out = IF_alu_out_i; // ADD TERNARY HERE? pcmux_out = if br predict taken ? IF_adder_out_o_i : IF_alu_out_i
        // pcmux::br_pred_add_out  : pcmux_out = IF_adder_out_o_i;
        default:begin 
            // $display("error no pcmux found @ time=",$time); 
            $finish; 
        end 
    endcase 
end 



pc_register pc_register( 

    // input of the PC register 
    .clk(clk), .rst(rst), 
    // .load(IF_PC_write_i | IF_pc_load_i), 
    .load(IF_PC_write_i),
    .in(pcmux_out), 
 
    // output of the PC register
    .out(IF_pc_out_o)
); 

// adder adder (
//     .a(addin1),
//     .b(addin2),

//     .f(addr)
// );

assign IF_pcmux_out_o = pcmux_out;


endmodule 

