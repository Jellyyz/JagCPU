// module bht #( parameter
//     size=256
//     ,width=1
// )(
//   input clk,

//   /* Physical memory signals */
// //   input logic pmem_resp,
// //   input logic [255:0] pmem_rdata,
// //   output logic [31:0] pmem_address,
// //   output logic [255:0] pmem_wdata,
// //   output logic pmem_read,
// //   output logic pmem_write,

//   /* CPU memory signals */
// //   input logic mem_read,
// //   input logic mem_write,
// //   input logic [3:0] mem_byte_enable_cpu,
// //   input logic [31:0] mem_address,
// //   input logic [31:0] mem_wdata_cpu,
// //   output logic mem_resp,
// //   output logic [31:0] mem_rdata_cpu

// 	input bht_read,
// 	input bht_write,
// 	input [31:0] pc_address,

// 	output bht_resp,
// 	output [width-1:0] bht_rdata,

// 	input [width-1] bht_wdata
// );

// // logic tag_load;
// logic valid_load;

// logic hit;

// cache_control control(
// 	  /* CPU memory data signals */
// 	.mem_read(mem_read),
// 	.mem_write(mem_write),
// 	.mem_resp(mem_resp),

//   /* Physical memory data signals */
// 	.pmem_resp(pmem_resp),
// 	.pmem_read(pmem_read),
// 	.pmem_write(pmem_write),

//   /* Control signals */
// 	.tag_load(tag_load),
// 	.valid_load(valid_load),
// 	.dirty_load(dirty_load),
// 	.dirty_in(dirty_in),
// 	.dirty_out(dirty_out),

//   	.hit(hit),
//   	.writing(writing)
// );
// cache_datapath datapath(
// 	.mem_byte_enable(mem_byte_enable),
// 	.mem_address(mem_address),
// 	.mem_wdata(mem_wdata),
// 	.mem_rdata(mem_rdata),

//   /* Physical memory data signals */
// 	.pmem_rdata(pmem_rdata),
// 	.pmem_wdata(pmem_wdata),
// 	.pmem_address(pmem_address),

//   /* Control signals */
// 	// .tag_load(tag_load),
// 	// .valid_load(valid_load),
// 	// .dirty_load(dirty_load),
// 	// .dirty_in(dirty_in),
// 	// .dirty_out(dirty_out),

// 	.hit(hit),
// 	.writing(writing)
// );

// // line_adapter bus (
// //     .mem_wdata_line(mem_wdata),
// //     .mem_rdata_line(mem_rdata),
// //     .mem_wdata(mem_wdata_cpu),
// //     .mem_rdata(mem_rdata_cpu),
// //     .mem_byte_enable(mem_byte_enable_cpu),
// //     .mem_byte_enable_line(mem_byte_enable),
// //     .address(mem_address)
// // );

// endmodule : cache