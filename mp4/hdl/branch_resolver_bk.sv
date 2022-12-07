module branch_resolver 
import rv32i_types::*; #(
    parameter width = 32
) (
    input logic flush_and_stall, 
    input rv32i_opcode opcode_i,
    input logic [width-1:0] i_imm_i, b_imm_i, j_imm_i,
    input logic [width-1:0] rs1_out_i, rs2_out_i,
    input logic br_en_i,
    input logic [width-1:0] pc_addr_cur_i,

    output logic [width-1:0] addr_o, // new calculated address to set to pc
    output pcmux::pcmux_sel_t pcmux_sel_o
);
logic [width-1:0] trash;
assign trash = rs2_out_i;

logic [width-1:0] addr;
logic [width-1:0] addin1, addin2;
pcmux::pcmux_sel_t pcmux_sel;

always_comb begin : BRANCH_RESOLVE_MUX
    unique case (opcode_i) 
        op_br   : begin
            if (br_en_i) begin
                addin1 = pc_addr_cur_i;
                addin2 = b_imm_i;
                pcmux_sel = pcmux::alu_out;
            end
            else begin
                addin1 = {width{1'b0}};
                addin2 = {width{1'b0}};
                pcmux_sel = pcmux::pc_plus4;
            end
        end
        op_jal  : begin
            addin1 = pc_addr_cur_i;
            addin2 = j_imm_i;
            pcmux_sel = pcmux::alu_out;
        end
        op_jalr : begin
            addin1 = rs1_out_i;
            addin2 = i_imm_i;
            pcmux_sel = pcmux::alu_mod2;
        end
        default : begin
            addin1 = {width{1'b0}};
            addin2 = {width{1'b0}};
            pcmux_sel = pcmux::pc_plus4;
        end
    endcase
end

adder adder (
    .a(addin1),
    .b(addin2),

    .f(addr)
);

always_comb begin : setOutputs
    addr_o = addr;
    pcmux_sel_o = pcmux_sel;
end
    
endmodule