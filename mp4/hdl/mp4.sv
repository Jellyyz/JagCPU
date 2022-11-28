
module mp4
import rv32i_types::*;
(
    input clk,
    input rst,
	
	// //Remove after CP1
    // input 					instr_mem_resp,
    // input rv32i_word 	instr_mem_rdata,
	// input 					data_mem_resp,
    // input rv32i_word 	data_mem_rdata, 
    // output logic 			instr_read,
	// output rv32i_word 	instr_mem_address,
    // output logic 			data_read,
    // output logic 			data_write,
    // output logic [3:0] 	data_mbe,
    // output rv32i_word 	data_mem_address,
    // output rv32i_word 	data_mem_wdata

	
	// For CP2

    input pmem_resp,
    input [63:0] pmem_rdata,

	// To physical memory
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


    // datapath d0(
    //     .clk(clk), .rst(rst),
    //     // inputs 
    //     .instr_mem_rdata(instr_mem_rdata), 
    //     .instr_mem_resp(instr_mem_resp),
    //     .data_mem_rdata(data_mem_rdata), 
    //     .data_mem_resp(data_mem_resp), 
    //     // outputs 
    //     .instr_read(instr_read), 
    //     .instr_mem_address(instr_mem_address), 
    //     .data_read(data_read), 
    //     .data_write(data_write), 
    //     .data_mbe(data_mbe), 
    //     .data_mem_address(data_mem_address),
    //     .data_mem_wdata(data_mem_wdata) 
        
    // ); 

endmodule : mp4