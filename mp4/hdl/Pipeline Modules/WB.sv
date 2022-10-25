import rv32i_types::*;

module WB(

    input rv32i_word WB_imm_in(), 
    input rv32i_word WB_mem_rdata_in(), 
    input rv32i_word WB_pc_out_4_in(), 
    input rv32i_word WB_alu_out_in(),
    input logic WB_br_en_in(),
    input rv32i_control_word WB_ctrl(ctrl), 

    output rv32i_word WB_out(regfilemux_out) 
); 

// @ TO DO: so far i just copied my mp2 here we need to probably fix the loads 

always_comb begin : WB_MUX 

    unique case(ctrl.regfilemux_sel)
        regfilemux::alu_out: regfilemux_out = alu_out;
        regfilemux::br_en: regfilemux_out = {31'h0, br_en};
        regfilemux::u_imm: regfilemux_out = u_imm; 
        regfilemux::lw: regfilemux_out = mdrreg_out;
        regfilemux::pc_plus4: regfilemux_out = pc_out + 4; 
        // process of deciding the loads needed... the rs1 + imm allows for the correct address to be calculated, 
        // should try and find which this is divisible by .. just like in lab 7 of ece 385 this uses the LSB of the ALU_out to be a 
        // easy modulo of 4, since 4 bytes in 32 and 2^2 is 4. since this is directly loaded into the alu, there needs to be some mux that 
        // does this logic after the alu _out 
        // add 8 to each new partition since 32/4 = 8 
        // don't need to account for LH and LHU apparently... for misaligned according to campuswire 
        // need to be careful here and make sure it is synthesized as combinational logic 
        regfilemux::lh: begin 
            unique case(mem_address_actual[1:0])
                2'b00:begin 
                    regfilemux_out = {{16{mdrreg_out[15]}}, mdrreg_out[15:0]};
                end 
                2'b01:begin
                    regfilemux_out = {{16{mdrreg_out[23]}}, mdrreg_out[23:8]};
                end
                2'b10:begin
                    regfilemux_out = {{16{mdrreg_out[31]}}, mdrreg_out[31:16]};
                end
                2'b11:begin
                    regfilemux_out = 0;
                end
                default:
                    $display("Found no possible placement for LH ALU_out[1:0] = %b at time " , alu_out[1:0], $time);
            endcase 
        end 
        regfilemux::lhu: begin 
            unique case(mem_address_actual[1:0])
                2'b00:begin 
                    regfilemux_out = {16'h0, mdrreg_out[15:0]}; 
                end 
                2'b01:begin
                    regfilemux_out = {16'h0, mdrreg_out[23:8]}; 
                end
                2'b10:begin
                    regfilemux_out = {16'h0, mdrreg_out[31:16]}; 
                end
                2'b11:begin
                    regfilemux_out = 0; 
                end
                default:
                    $display("Found no possible placement for LHU ALU_out[1:0] = %b at time " , alu_out[1:0], $time);
            endcase 
        end 
        regfilemux::lb: begin
            unique case(mem_address_actual[1:0])
                2'b00:begin 
                    regfilemux_out = {{24{mdrreg_out[7]}}, mdrreg_out[7:0]}; 
                end 
                2'b01:begin
                    regfilemux_out = {{24{mdrreg_out[15]}}, mdrreg_out[15:8]}; 
                end
                2'b10:begin
                    regfilemux_out = {{24{mdrreg_out[23]}}, mdrreg_out[23:16]}; 
                end
                2'b11:begin
                    regfilemux_out = {{24{mdrreg_out[31]}}, mdrreg_out[31:24]}; 
                end
                default:
                    $display("Found no possible placement for LB ALU_out[1:0] = %b at time " , alu_out[1:0], $time);
            endcase 
        end 
        regfilemux::lbu: begin 
            unique case(mem_address_actual[1:0])
                2'b00:begin 
                    regfilemux_out = {24'h0, mdrreg_out[7:0]}; 
                end 
                2'b01:begin
                    regfilemux_out = {24'h0, mdrreg_out[15:8]}; 
                end
                2'b10:begin
                    regfilemux_out = {24'h0, mdrreg_out[23:16]}; 
                end
                2'b11:begin
                    regfilemux_out = {24'h0, mdrreg_out[31:24]}; 
                end
                default:
                    $display("Found no possible placement for LBU ALU_out[1:0] = %b at time " , alu_out[1:0], $time);
            endcase 
        end 
        default: $display("hit regfilemux error");
    endcase 
end 

endmodule 