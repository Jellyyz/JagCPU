
module MEM_WB 
import rv32i_types::*;
#(parameter width = 32)
(
    input logic clk,
    input logic rst,
    input logic load_i,

    // input logic MEM_WB_mem_read_i,
    // input logic MEM_WB_mem_write_i,
    input logic MEM_WB_br_en_i,
    input pcmux::pcmux_sel_t MEM_WB_pcmux_sel_i,
    input logic [width-1:0] MEM_WB_alu_out_i,
    input logic [4:0] MEM_WB_rd_i,
    input rv32i_control_word MEM_WB_ctrl_word_i,
    input logic [width-1:0] MEM_WB_pc_out_i,
    input logic [width-1:0] MEM_WB_pc_plus4_i,
    input logic [width-1:0] MEM_WB_instr_i,
    input logic [width-1:0] MEM_WB_i_imm_i,
    input logic [width-1:0] MEM_WB_s_imm_i,
    input logic [width-1:0] MEM_WB_b_imm_i,
    input logic [width-1:0] MEM_WB_u_imm_i,
    input logic [width-1:0] MEM_WB_j_imm_i,
    // input logic [width-1:0] MEM_WB_data_mem_address_i, // magic
    // input logic [width-1:0] MEM_WB_data_mem_wdata_i, // magic
    input logic [width-1:0] MEM_WB_data_mem_rdata_i, // magic

    // output logic MEM_WB_mem_read_o,
    // output logic MEM_WB_mem_write_o,
    output logic MEM_WB_br_en_o,
    output pcmux::pcmux_sel_t MEM_WB_pcmux_sel_o,
    output logic [width-1:0] MEM_WB_alu_out_o,
    output logic [4:0] MEM_WB_rd_o,
    output rv32i_control_word MEM_WB_ctrl_word_o,
    output logic [width-1:0] MEM_WB_pc_out_o,
    output logic [width-1:0] MEM_WB_pc_plus4_o,
    output logic [width-1:0] MEM_WB_instr_o,
    output logic [width-1:0] MEM_WB_i_imm_o,
    output logic [width-1:0] MEM_WB_s_imm_o,
    output logic [width-1:0] MEM_WB_b_imm_o,
    output logic [width-1:0] MEM_WB_u_imm_o,
    output logic [width-1:0] MEM_WB_j_imm_o,
    // output logic [width-1:0] MEM_WB_data_mem_address_o, // magic
    // output logic [width-1:0] MEM_WB_data_mem_wdata_o, // magic 
    output logic [width-1:0] MEM_WB_data_mem_rdata_o // magic
);

// logic MEM_WB_mem_read;
// logic MEM_WB_mem_write;
logic MEM_WB_br_en;
pcmux::pcmux_sel_t MEM_WB_pcmux_sel;
logic [width-1:0] MEM_WB_alu_out;
logic [4:0] MEM_WB_rd;
rv32i_control_word MEM_WB_ctrl_word;
logic [width-1:0] MEM_WB_pc_out;
logic [width-1:0] MEM_WB_pc_plus4;
logic [width-1:0] MEM_WB_instr;
logic [width-1:0] MEM_WB_i_imm;
logic [width-1:0] MEM_WB_s_imm;
logic [width-1:0] MEM_WB_b_imm;
logic [width-1:0] MEM_WB_u_imm;
logic [width-1:0] MEM_WB_j_imm;
// logic [width-1:0] MEM_WB_data_mem_address;
// logic [width-1:0] MEM_WB_data_mem_wdata;
logic [width-1:0] MEM_WB_data_mem_rdata;

always_ff @(posedge clk) begin
    if (rst) begin
        // MEM_WB_mem_write <= '0;
        // MEM_WB_mem_read <= '0;
        MEM_WB_br_en <= '0;
        MEM_WB_pcmux_sel <= {2'b00};
        MEM_WB_alu_out <= '0;
        MEM_WB_rd <= '0;
        MEM_WB_ctrl_word <= '0;
        MEM_WB_pc_out <= '0;
        MEM_WB_pc_plus4 <= '0;
        MEM_WB_instr <= '0;
        MEM_WB_i_imm <= '0;
        MEM_WB_s_imm <= '0;
        MEM_WB_b_imm <= '0;
        MEM_WB_u_imm <= '0;
        MEM_WB_j_imm <= '0;
        // MEM_WB_data_mem_address <= '0;
        // MEM_WB_data_mem_wdata <= '0;
        MEM_WB_data_mem_rdata <= '0;
    end else if (load_i) begin
        // MEM_WB_mem_write <= MEM_WB_mem_write_i;
        // MEM_WB_mem_read <= MEM_WB_mem_read_i;
        MEM_WB_br_en <= MEM_WB_br_en_i;
        MEM_WB_pcmux_sel <= MEM_WB_pcmux_sel_i;
        MEM_WB_alu_out <= MEM_WB_alu_out_i;
        MEM_WB_rd <= MEM_WB_rd_i;
        MEM_WB_ctrl_word <= MEM_WB_ctrl_word_i;
        MEM_WB_pc_out <= MEM_WB_pc_out_i;
        MEM_WB_pc_plus4 <= MEM_WB_pc_plus4_i;
        MEM_WB_instr <= MEM_WB_instr_i;
        MEM_WB_i_imm <= MEM_WB_i_imm_i;
        MEM_WB_s_imm <= MEM_WB_s_imm_i;
        MEM_WB_b_imm <= MEM_WB_b_imm_i;
        MEM_WB_u_imm <= MEM_WB_u_imm_i;
        MEM_WB_j_imm <= MEM_WB_j_imm_i;
        // MEM_WB_data_mem_address <= MEM_WB_data_mem_address_i;
        // MEM_WB_data_mem_wdata <= MEM_WB_data_mem_wdata_i;
        MEM_WB_data_mem_rdata <= MEM_WB_data_mem_rdata_i;
    end else begin // practically, load is fixed high, so this will never execute
        // MEM_WB_mem_write <= MEM_WB_mem_write;
        // MEM_WB_mem_read <= MEM_WB_mem_read;
        MEM_WB_br_en <= MEM_WB_br_en;
        MEM_WB_pcmux_sel <= MEM_WB_pcmux_sel;
        MEM_WB_alu_out <= MEM_WB_alu_out;
        MEM_WB_rd <= MEM_WB_rd;
        MEM_WB_ctrl_word <= MEM_WB_ctrl_word;
        MEM_WB_pc_out <= MEM_WB_pc_out;
        MEM_WB_pc_plus4 <= MEM_WB_pc_plus4;
        MEM_WB_instr <= MEM_WB_instr;
        MEM_WB_i_imm <= MEM_WB_i_imm;
        MEM_WB_s_imm <= MEM_WB_s_imm;
        MEM_WB_b_imm <= MEM_WB_b_imm;
        MEM_WB_u_imm <= MEM_WB_u_imm;
        MEM_WB_j_imm <= MEM_WB_j_imm;
        // MEM_WB_data_mem_address <= MEM_WB_data_mem_address;
        // MEM_WB_data_mem_wdata <= MEM_WB_data_mem_wdata;
        MEM_WB_data_mem_rdata <= MEM_WB_data_mem_rdata;
    end 
end

always_comb begin
    // MEM_WB_mem_write_o = MEM_WB_mem_write;
    // MEM_WB_mem_read_o = MEM_WB_mem_read;
    MEM_WB_br_en_o = MEM_WB_br_en;
    MEM_WB_pcmux_sel_o = MEM_WB_pcmux_sel;
    MEM_WB_alu_out_o = MEM_WB_alu_out;
    MEM_WB_rd_o = MEM_WB_rd;
    MEM_WB_ctrl_word_o = MEM_WB_ctrl_word;
    MEM_WB_pc_out_o = MEM_WB_pc_out;
    MEM_WB_pc_plus4_o = MEM_WB_pc_plus4;
    MEM_WB_instr_o = MEM_WB_instr;
    MEM_WB_i_imm_o = MEM_WB_i_imm;
    MEM_WB_s_imm_o = MEM_WB_s_imm;
    MEM_WB_b_imm_o = MEM_WB_b_imm;
    MEM_WB_u_imm_o = MEM_WB_u_imm;
    MEM_WB_j_imm_o = MEM_WB_j_imm;
    // MEM_WB_data_mem_address_o = MEM_WB_data_mem_address;
    // MEM_WB_data_mem_wdata_o = MEM_WB_data_mem_wdata;
    MEM_WB_data_mem_rdata_o = MEM_WB_data_mem_rdata;
end

endmodule : MEM_WB 