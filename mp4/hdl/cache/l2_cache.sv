/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module l2_cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter num_ways = 8,
    parameter num_bits = 1
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
    //input   logic [3:0]     mem_byte_enable,
    output  logic           mem_resp,

    /* Physical memory signals */
    output  logic [31:0]    pmem_address,
    input   logic [255:0]   pmem_rdata,
    output  logic [255:0]   pmem_wdata,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic           pmem_resp
);

logic [255:0]           mem_rdata256, mem_wdata256;
logic [31:0]            mem_byte_enable256, byte_enable[num_ways];
logic [num_ways-1:0]    lru_in, lru_out;
logic                   hit[num_ways];
logic                   datain_sel[num_ways];
logic                   ld_lru;
logic                   ld_dirty[num_ways], dirty_in[num_ways], dirty_out[num_ways];
logic                   ld_valid[num_ways], valid_in[num_ways], valid_out[num_ways];
logic                   ld_tag[num_ways];
logic                   rd_lru, rd_data[num_ways], rd_dirty[num_ways], rd_valid[num_ways], rd_tag[num_ways];
logic                   mem_addr_sel;

l2_cache_control control(.*);

l2_cache_datapath #(.s_offset(5), .s_index(1)) datapath(.mem_wdata256(mem_wdata_l1), .mem_rdata256(mem_rdata_l1), .*);

//l2_bus_adapter bus_adapter(.*, .address(mem_address));

endmodule : l2_cache
