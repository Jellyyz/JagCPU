
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

logic [31:0] i_mem_rdata, d_mem_rdata;
logic i_mem_resp, d_mem_resp;

logic [31:0] i_mem_address, d_mem_address;
logic i_mem_read, d_mem_read;
logic i_mem_write, d_mem_write;
logic [31:0] i_mem_wdata, d_mem_wdata;
logic [3:0] i_mbe, d_mbe;

datapath d0(
    .clk(clk), .rst(rst),

    .i_mem_rdata(i_mem_rdata),
    .i_mem_resp(i_mem_resp),
    .i_mem_address(i_mem_address),
    .i_mem_read(i_mem_read),
    .i_mem_write(i_mem_write),
    .i_mem_wdata(i_mem_wdata),
    .i_mbe(i_mbe),

    .d_mem_rdata(d_mem_rdata),
    .d_mem_resp(d_mem_resp),
    .d_mem_address(d_mem_address),
    .d_mem_read(d_mem_read),
    .d_mem_write(d_mem_write),
    .d_mem_wdata(d_mem_wdata),
    .d_mbe(d_mbe)
); 

cache_interface cache(
    .clk(clk), .rst(rst),
    
    .i_mem_address(i_mem_address),
    .i_mem_rdata(i_mem_rdata),
    .i_mem_wdata(i_mem_wdata),
    .i_mem_read(i_mem_read),
    .i_mem_write(i_mem_write),
    .i_mem_byte_enable(i_mbe),
    .i_mem_resp(i_mem_resp),

    .d_mem_address(d_mem_address),
    .d_mem_rdata(d_mem_rdata),
    .d_mem_wdata(d_mem_wdata),
    .d_mem_read(d_mem_read),
    .d_mem_write(d_mem_write),
    .d_mem_byte_enable(d_mbe),
    .d_mem_resp(d_mem_resp),

    .pmem_address(pmem_address),
    .pmem_rdata(pmem_rdata),
    .pmem_wdata(pmem_wdata),
    .pmem_read(pmem_read),
    .pmem_write(pmem_write),
    .pmem_resp(pmem_resp)
);

endmodule : mp4