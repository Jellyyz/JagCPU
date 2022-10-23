import rv32i_types::*;

module datapath(
    input logic clk, rst 
    
    input rv32i_word 	data_mem_rdata, 
    input rv32i_word 	instr_mem_rdata, 

); 

logic [6:0] opcode; 
logic [2:0] funct3; 
logic [6:0] funct7; 
alu_ops aluop;

// control signals from the control block ?

logic load_pc, pcmux_out, pc_out, pcmux_sel; 
logic alu_op; 

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

alu alu (
    // inputs 
    .aluop(aluop),
    .a(alumux1_out), .b(alumux2_out), 
    // outputs 
    .f(alu_out)
    
);


always_comb begin : CONTROL_WORD

    // opcode of any instruction 
    opcode = instr_mem_rdata[6:0]; 

    // funct3 of any instruction 
    funct3 = instr_mem_rdata[2:0]; 

    // funct7 of any instruction 
    funct7 = instr_mem_rdata[6:0]; 

    // alu_op calculation 
    unique case(funct3)
        sll, axor, aor, aand:begin
            alu_op = funct3; 
        end 

        slt:begin 
            alu_op = blt;
        end 

        sltu:begin 
            alu_op = bltu; 
        end 

        sr:begin 
            if(funct7 == 7'h0)begin 
                alu_op = alu_srl;
            end 
            else begin 
                alu_op = alu_sra; 
            end 
        end 
        
        add:begin 
            if(funct7 == 7'h0)begin 
                alu_op = alu_add; 
            end 
            else begin 
                alu_op = alu_sub; 
            end 
        end     

    endcase 

    // aluMUX sel 
end 
always_comb begin : MUXES

    unique case(pcmux_sel) 
        pcmux::pc_plus4: pcmux_out = pc_out + 4;
        pcmux::alu_out: pcmux_out = alu_out; 
        pcmux::alu_mod2: pcmux_out = alu_out & ~(32'b0000_0000_0000_0000_0000_0000_0000_0001);  
        default: $display("hit pcmux error");
    endcase  

    unique case (alumux1_sel)
        // alumux1
        alumux::rs1_out: alumux1_out = rs1_out; 
        alumux::pc_out: alumux1_out = pc_out; 
        default: $display("hit alumux1 error");
    endcase 
    unique case (alumux2_sel)    
        //alumux2 
        alumux::i_imm: alumux2_out = i_imm; 
        alumux::u_imm: alumux2_out = u_imm; 
        alumux::b_imm: alumux2_out = b_imm; 
        alumux::s_imm: alumux2_out = s_imm; 
        alumux::j_imm: alumux2_out = j_imm; 
        alumux::rs2_out: alumux2_out = rs2_out;
        default: $display("hit alumux2 error");
    endcase 


endmodule 