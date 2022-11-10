
module mp4
import rv32i_types::*;
(
    input clk,
    input rst,
	
    input pmem_resp,
    input [63:0] pmem_rdata,

    output logic pmem_read,
    output logic pmem_write,
    output rv32i_word pmem_address,
    output [63:0] pmem_wdata
);

logic [31:0] instr_mem_rdata, data_mem_rdata;
logic instr_mem_resp, data_mem_resp;

logic [31:0] instr_mem_address, data_mem_address;
logic instr_mem_read, data_mem_read;
logic instr_mem_write, data_mem_write;
logic [31:0] instr_mem_wdata, data_mem_wdata;
logic [3:0] i_mbe, d_mbe;

datapath d0(
    .clk(clk), .rst(rst),

    .instr_mem_rdata(instr_mem_rdata),
    .instr_mem_resp(instr_mem_resp),
    .instr_mem_address(instr_mem_address),
    .instr_mem_read(instr_mem_read),
    .instr_mem_write(instr_mem_write),
    .instr_mem_wdata(instr_mem_wdata),
    .i_mbe(i_mbe),

    .data_mem_rdata(data_mem_rdata),
    .data_mem_resp(data_mem_resp),
    .data_mem_address(data_mem_address),
    .data_mem_read(data_mem_read),
    .data_mem_write(data_mem_write),
    .data_mem_wdata(data_mem_wdata),
    .d_mbe(d_mbe)
); 

cache_interface cache(
    .clk(clk), .rst(rst),
    
    .instr_mem_address(instr_mem_address),
    .instr_mem_rdata(instr_mem_rdata),
    .instr_mem_wdata(instr_mem_wdata),
    .instr_mem_read(instr_mem_read),
    .instr_mem_write(instr_mem_write),
    .instr_mem_byte_enable(i_mbe),
    .instr_mem_resp(instr_mem_resp),

    .data_mem_address(data_mem_address),
    .data_mem_rdata(data_mem_rdata),
    .data_mem_wdata(data_mem_wdata),
    .data_mem_read(data_mem_read),
    .data_mem_write(data_mem_write),
    .data_mem_byte_enable(d_mbe),
    .data_mem_resp(data_mem_resp),

    .pmem_address(pmem_address),
    .pmem_rdata(pmem_rdata),
    .pmem_wdata(pmem_wdata),
    .pmem_read(pmem_read),
    .pmem_write(pmem_write),
    .pmem_resp(pmem_resp)
);

endmodule : mp4