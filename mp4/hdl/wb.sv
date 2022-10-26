import rv32i_types::*;

module WB #(parameter width = 32) (

    // input rv32i_word WB_imm_in(), 
    // input rv32i_word WB_mem_rdata_in(), 
    // input rv32i_word WB_pc_out_4_in(), 
    // input rv32i_word WB_alu_out_in(),
    // input logic WB_br_en_in(),
    // input rv32i_control_word WB_ctrl(ctrl), 

    // output rv32i_word WB_out(regfilemux_out) 
    input WB_mem_read_i,
    input WB_mem_write_i,
    input WB_br_en_i,
    input logic WB_pcmux_sel_i,
    input logic WB_alu_out_i,
    input logic [4:0] WB_rd_i,
    input rv32i_control_word WB_ctrl_word_i,
    input logic [width-1:0] WB_pc_out_i,
    input logic [width-1:0] WB_pc_plus4_i,
    input logic [width-1:0] WB_instr_i,
    input logic [width-1:0] WB_i_imm_i,
    input logic [width-1:0] WB_s_imm_i,
    input logic [width-1:0] WB_b_imm_i,
    input logic [width-1:0] WB_u_imm_i,
    input logic [width-1:0] WB_j_imm_i,
    input logic [width-1:0] WB_data_mem_address_i, // magic
    input logic [width-1:0] WB_data_mem_wdata_i, // magic
    input logic [width-1:0] WB_data_mem_rdata_i, // magic

    output logic WB_load_regfile_o,
    output logic [4:0] WB_rd_o,
    output logic [width-1:0] WB_regfilemux_out_o
); 

regfilemux::regfilemux_sel_t regfilemux_sel;
logic regfilemux_out; 

always_comb begin : ctrl_decode
    regfilemux_sel = WB_ctrl_word_i.regfilemux_sel
end

always_comb begin : set_output
    WB_load_regfile_o = rv32i_control_word.load_regfile;
    WB_regfilemux_out_o = regfilemux_out;
    WB_rd_o = WB_rd_i;
end

always_comb begin : wb_mux 
    unique case(regfilemux_sel)
        regfilemux::alu_out     : regfilemux_out = WB_alu_out_i;
        regfilemux::br_en       : regfilemux_out = {{31'b0000000000000000000000000000000}, WB_br_en_i};
        regfilemux::u_imm       : regfilemux_out = WB_u_imm_i;
        regfilemux::lw          : regfilemux_out = WB_data_mem_rdata_i;
        regfilemux::pc_plus4    : regfilemux_out = WB_pc_out_i + {32'h00000004};
        regfilemux::lh          : begin 
            unique case(mem_address_actual[1:0])
                2'b00 : regfilemux_out = {{16{WB_data_mem_rdata_i[15]}}, WB_data_mem_rdata_i[15:0]};
                // 2'b01 : regfilemux_out = {{16{WB_data_mem_rdata_i[23]}}, WB_data_mem_rdata_i[23:8]};
                2'b10 : regfilemux_out = {{16{WB_data_mem_rdata_i[31]}}, WB_data_mem_rdata_i[31:16]};
                // 2'b11 : regfilemux_out = '0;
                default:
                    $display("Found no possible placement for LH ALU_out[1:0] = %b at time " , WB_alu_out_i[1:0], $time);
            endcase 
        end 
        regfilemux::lhu         : begin 
            unique case(mem_address_actual[1:0])
                2'b00 : regfilemux_out = {16'h0, WB_data_mem_rdata_i[15:0]}; 
                // 2'b01 : regfilemux_out = {16'h0, WB_data_mem_rdata_i[23:8]}; 
                2'b10 : regfilemux_out = {16'h0, WB_data_mem_rdata_i[31:16]}; 
                // 2'b11 : regfilemux_out = 0; 
                default:
                    $display("Found no possible placement for LHU ALU_out[1:0] = %b at time " , WB_alu_out_i[1:0], $time);
            endcase 
        end 
        regfilemux::lb          : begin
            unique case(mem_address_actual[1:0])
                2'b00 : regfilemux_out = {{24{WB_data_mem_rdata_i[7]}}, WB_data_mem_rdata_i[7:0]}; 
                2'b01 : regfilemux_out = {{24{WB_data_mem_rdata_i[15]}}, WB_data_mem_rdata_i[15:8]}; 
                2'b10 : regfilemux_out = {{24{WB_data_mem_rdata_i[23]}}, WB_data_mem_rdata_i[23:16]}; 
                2'b11 : regfilemux_out = {{24{WB_data_mem_rdata_i[31]}}, WB_data_mem_rdata_i[31:24]}; 
                default:
                    $display("Found no possible placement for LB ALU_out[1:0] = %b at time " , WB_alu_out_i[1:0], $time);
            endcase 
        end 
        regfilemux::lbu         : begin 
            unique case(mem_address_actual[1:0])
                2'b00 : regfilemux_out = {24'h0, WB_data_mem_rdata_i[7:0]}; 
                2'b01 : regfilemux_out = {24'h0, WB_data_mem_rdata_i[15:8]}; 
                2'b10 : regfilemux_out = {24'h0, WB_data_mem_rdata_i[23:16]}; 
                2'b11 : regfilemux_out = {24'h0, WB_data_mem_rdata_i[31:24]}; 
                default:
                    $display("Found no possible placement for LBU ALU_out[1:0] = %b at time " , WB_alu_out_i[1:0], $time);
            endcase 
        end 
        default: $display("hit regfilemux error");
    endcase 
end 

endmodule : WB