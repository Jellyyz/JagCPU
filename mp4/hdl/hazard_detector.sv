module hazard_detector
import rv32i_types::*;
 #(
    parameter width = 32
) (
    input logic EX_mem_read_i,
    input rv32i_reg EX_rd_i,
    input rv32i_reg ID_rs1_i,
    input rv32i_reg ID_rs2_i,
    input logic instr_mem_resp,
    input logic instr_mem_read,
    input logic data_mem_resp,
    input logic data_mem_read,
    input logic data_mem_write,
    input rv32i_control_word MEM_ctrl_word,

    output controlmux::controlmux_sel_t ID_HD_controlmux_sel_o,

    output logic stall_ex_mem_o, 
    output logic stall_id_ex_o, 
    output logic stall_if_id_o, 
    output logic stall_pc_o 

    // output logic IF_HD_PC_write_o,
    // output logic IF_ID_HD_write_o,
);

logic stall_instr_cache, stall_data_cache, stall_load_use, mem_instr;

assign mem_instr = (MEM_ctrl_word.opcode == op_load) | (MEM_ctrl_word.opcode == op_store);

always_comb begin : stall_flags
    stall_ex_mem_o = stall_data_cache & mem_instr; 
    stall_id_ex_o = stall_data_cache & mem_instr;
    stall_if_id_o = stall_instr_cache || stall_load_use;
    stall_pc_o = (stall_instr_cache || stall_load_use || (stall_data_cache & mem_instr)) & ~data_mem_resp; 

    ID_HD_controlmux_sel_o = stall_load_use ? controlmux::zero : controlmux::norm;
end

always_comb begin : stall_conditions
    stall_instr_cache = (!instr_mem_resp & instr_mem_read);
    stall_data_cache =  (!data_mem_resp & (data_mem_read | data_mem_write));
    stall_load_use =  (EX_mem_read_i & ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i)) & |EX_rd_i);
    
    // if (stall_inst || stall_load_use) begin
    // ID_HD_controlmux_sel_o = controlmux::zero;
    //     IF_HD_PC_write_o = 1'b0;
    //   IF_ID_HD_write_o = 1'b0;
    // end else begin
    //     ID_HD_controlmux_sel_o = controlmux::norm;
    //     IF_HD_PC_write_o = 1'b1;
    //     IF_ID_HD_write_o = 1'b1;
    // end
end
    
endmodule