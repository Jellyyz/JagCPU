/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module l2_cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input rst,

    /* CPU memory signals */
    input   logic [31:0]    mem_address,
    output  logic [255:0]    mem_rdata_l1,
    input   logic [255:0]    mem_wdata_l1,
    input   logic           mem_read,
    input   logic           mem_write,
    input   logic [31:0]     mem_byte_enable256,
    output  logic           mem_resp,

    /* Physical memory signals */
    output  logic [31:0]    pmem_address,
    input   logic [255:0]   pmem_rdata,
    output  logic [255:0]   pmem_wdata,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic           pmem_resp
);

logic [255:0] mem_rdata256, mem_wdata256;
logic [31:0]  mem_byte_enable256, byte_enable0, byte_enable1;
logic         hit0, hit1;
logic         datain0_sel, datain1_sel;
logic         ld_lru, lru_in, lru_out;
logic         ld_dirty0, ld_dirty1, dirty0_in, dirty1_in, dirty0_out, dirty1_out;
logic         ld_valid0, ld_valid1, valid0_in, valid1_in, valid0_out, valid1_out;
logic         ld_tag0, ld_tag1;
logic         rd_lru, rd_data0, rd_data1, rd_dirty0, rd_dirty1, rd_valid0, rd_valid1, rd_tag0, rd_tag1;
logic         mem_addr_sel;

l2_cache_control control(.*);

l2_cache_datapath datapath(.mem_wdata256(mem_wdata_l1), .mem_rdata256(mem_rdata_l1), .*);

//bus_adapter bus_adapter(.*, .address(mem_address));

endmodule : l2_cache