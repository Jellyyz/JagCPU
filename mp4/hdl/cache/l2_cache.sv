module l2_cache (
  input clk, rst,

  /* Physical memory signals */
  input logic pmem_resp,
  input logic [255:0] pmem_rdata,
  output logic [31:0] pmem_address,
  output logic [255:0] pmem_wdata,
  output logic pmem_read,
  output logic pmem_write,

  /* CPU memory signals */
  input logic mem_read,
  input logic mem_write,
  input logic [31:0] mem_byte_enable256,
  input logic [31:0] mem_address,
  input logic [255:0] mem_wdata_l1,
  output logic mem_resp,
  output logic [255:0] mem_rdata_l1
);

logic tag_load;
logic valid_load;
logic dirty_load;
logic dirty_in;
logic dirty_out;

logic hit;
logic [1:0] writing;

logic [255:0] mem_wdata;
logic [255:0] mem_rdata;
logic [31:0] mem_byte_enable;

cache_control control(.*);
cache_datapath datapath(.mem_wdata(mem_wdata_l1), .mem_rdata(mem_rdata_l1), .*);

//line_adapter bus (
//    .mem_wdata_line(mem_wdata),
//    .mem_rdata_line(mem_rdata),
//    .mem_wdata(mem_wdata_cpu),
//    .mem_rdata(mem_rdata_cpu),
//    .mem_byte_enable(mem_byte_enable_cpu),
//    .mem_byte_enable_line(mem_byte_enable),
//    .address(mem_address)
//);

endmodule : l2_cache