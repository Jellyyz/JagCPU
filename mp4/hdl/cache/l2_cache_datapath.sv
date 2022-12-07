/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

module l2_cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input   logic           clk, rst,
    input   logic [31:0]    mem_address,
    output  logic [31:0]    pmem_address,
    input   logic [255:0]   mem_wdata256, pmem_rdata,
    output  logic [255:0]   mem_rdata256, pmem_wdata,

    input   logic [31:0] byte_enable0, byte_enable1,
    input   logic        lru_in, dirty0_in, dirty1_in, valid0_in, valid1_in,
    input   logic        ld_dirty0, ld_dirty1, ld_valid0, ld_valid1, ld_lru, ld_tag0, ld_tag1,
    input   logic        rd_data0, rd_data1, rd_dirty0, rd_dirty1, rd_valid0, rd_valid1, rd_lru, rd_tag0, rd_tag1, 
    input   logic        datain0_sel, datain1_sel,
    input   logic        mem_addr_sel, 
    output  logic        hit0, hit1, lru_out, dirty0_out, dirty1_out, valid0_out, valid1_out
);

logic [23:0]   current_tag, tag0_out, tag1_out;
logic [255:0]  data0_in, data1_in, data0_out, data1_out, cache_out;
logic [31:0]   address_mux1_out;

assign current_tag = mem_address[31:8];
assign hit0 = valid0_out && (tag0_out == current_tag);
assign hit1 = valid1_out && (tag1_out == current_tag);


l2_array #(.s_index(3), .width(1)) lru (
    .clk (clk), .rst (rst), .read (rd_lru), .load (ld_lru), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (lru_in), .dataout (lru_out)
);

l2_array #(.s_index(3), .width(1)) dirty0 (
    .clk (clk), .rst (rst), .read (rd_dirty0), .load (ld_dirty0), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (dirty0_in), .dataout (dirty0_out)
);

l2_array #(.s_index(3), .width(1)) dirty1 (
    .clk (clk), .rst (rst), .read (rd_dirty1), .load (ld_dirty1), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (dirty1_in), .dataout (dirty1_out)
);

l2_array #(.s_index(3), .width(1)) valid0 (
    .clk (clk), .rst (rst), .read (rd_valid0), .load (ld_valid0), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (valid0_in), .dataout (valid0_out)
);

l2_array #(.s_index(3), .width(1)) valid1 (
    .clk (clk), .rst (rst), .read (rd_valid1), .load (ld_valid1), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (valid1_in), .dataout (valid1_out)
);

l2_array #(.s_index(3), .width(24)) tag0(
    .clk (clk), .rst (rst), .read (rd_tag0), .load (ld_tag0),  
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (mem_address[31:8]), .dataout (tag0_out)
);

l2_array #(.s_index(3), .width(24)) tag1(
    .clk (clk), .rst (rst), .read (rd_tag1), .load (ld_tag1),  
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (mem_address[31:8]), .dataout (tag1_out)
);

assign mem_rdata256 = cache_out;
l2_data_array data0 (
    .clk (clk), .read (rd_data0), .write_en (byte_enable0), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (data0_in), .dataout (data0_out)
);

l2_data_array data1 (
    .clk (clk), .read (rd_data1), .write_en (byte_enable1), 
    .rindex (mem_address[7:5]), .windex (mem_address[7:5]), 
    .datain (data1_in), .dataout (data1_out)
);

always_comb begin : MUXES

    unique case (datain0_sel)
        1'b0: data0_in = mem_wdata256;
        1'b1: data0_in = pmem_rdata;
        default: ;
    endcase  

    unique case (datain1_sel)
        1'b0: data1_in = mem_wdata256;
        1'b1: data1_in = pmem_rdata;
        default: ;
    endcase

    unique case (hit1)
        1'b0: cache_out = data0_out;
        1'b1: cache_out = data1_out;
        default: ;
    endcase

    unique case (mem_addr_sel)
        1'b0: pmem_address = {mem_address[31:5], 5'b0};
        1'b1: unique case (lru_out)
            1'b0: pmem_address = {tag0_out, mem_address[7:5], 5'b0};
            1'b1: pmem_address = {tag1_out, mem_address[7:5], 5'b0};
        endcase
    endcase

    unique case (lru_out)
        1'b0: pmem_wdata = data0_out;
        1'b1: pmem_wdata = data1_out;
        default: ;
    endcase  
end
endmodule : l2_cache_datapath