
module MEM 
import rv32i_types::*;
#(parameter width = 32) 
(

    input logic [width-1:0] MEM_pc_out_i, 
    input logic [width-1:0] MEM_pc_plus4_i, 
    input logic [width-1:0] MEM_instr_i,
    input logic [width-1:0] MEM_i_imm_i,
    input logic [width-1:0] MEM_s_imm_i,
    input logic [width-1:0] MEM_b_imm_i,
    input logic [width-1:0] MEM_u_imm_i,
    input logic [width-1:0] MEM_j_imm_i,
    input logic [width-1:0] MEM_rs2_out_i,
    input rv32i_control_word MEM_ctrl_word_i,
    input logic [4:0] MEM_rd_i,
    input logic [width-1:0] MEM_alu_out_i,
    input logic MEM_br_en_i,

    output pcmux::pcmux_sel_t MEM_pcmux_sel_o,
    output logic [width-1:0] MEM_alu_out_o,
    output logic [4:0] MEM_rd_o,
    output rv32i_control_word MEM_ctrl_word_o,
    output logic MEM_mem_read_o,
    output logic MEM_mem_write_o,
    output logic MEM_br_en_o,
    output logic [width-1:0] MEM_pc_out_o, 
    output logic [width-1:0] MEM_pc_plus4_o, 

    output logic [width-1:0] MEM_instr_o,

    output rv32i_word MEM_data_mem_address_o,
    output rv32i_word MEM_data_mem_wdata_o,
    // output rv32i_word MEM_data_mem_rdata_o // this is an output after cp1

    output logic [width-1:0] MEM_i_imm_o,
    output logic [width-1:0] MEM_s_imm_o,
    output logic [width-1:0] MEM_b_imm_o,
    output logic [width-1:0] MEM_u_imm_o,
    output logic [width-1:0] MEM_j_imm_o,

    output logic [3:0] MEM_mem_byte_en_o
);

logic [4:0] rs1, rs2, rd;
logic [width-1:0] rs1_out, rs2_out;
logic mem_read, mem_write;
rv32i_word data_mem_address, data_mem_wdata;
logic [3:0] mem_byte_en;

always_comb begin : ctrl_decode
    mem_read = MEM_ctrl_word_i.mem_read;
    mem_write = MEM_ctrl_word_i.mem_write;
    mem_byte_en = MEM_ctrl_word_i.mem_byte_en << data_mem_address[1:0];
end

always_comb begin : set_output
    MEM_pc_out_o = MEM_pc_out_i;
    MEM_pc_plus4_o = MEM_pc_plus4_i; 

    MEM_alu_out_o = MEM_alu_out_i;
    MEM_pcmux_sel_o = {1'b0, MEM_br_en_i & (op_br == MEM_ctrl_word_i.opcode)};

    MEM_ctrl_word_o = MEM_ctrl_word_i;

    MEM_i_imm_o = MEM_i_imm_i;
    MEM_s_imm_o = MEM_s_imm_i;
    MEM_b_imm_o = MEM_b_imm_i;
    MEM_u_imm_o = MEM_u_imm_i;
    MEM_j_imm_o = MEM_j_imm_i;

    MEM_rd_o = MEM_rd_i;
    MEM_instr_o = MEM_instr_i;
    MEM_br_en_o = MEM_br_en_i;

    MEM_mem_read_o = mem_read;
    MEM_mem_write_o = mem_write;
    MEM_data_mem_address_o = data_mem_address;
    MEM_data_mem_wdata_o = data_mem_wdata;

    MEM_mem_byte_en_o = mem_byte_en;
end

assign data_mem_wdata = MEM_rs2_out_i;

always_comb begin : muxes
    unique case (MEM_ctrl_word_i.marmux_sel) 
        1'b0 : 
            data_mem_address = MEM_pc_out_i;
        1'b1 : 
            data_mem_address = MEM_alu_out_i;
        default : begin
            data_mem_address = MEM_pc_out_i;
        end
    endcase 
end


endmodule : MEM