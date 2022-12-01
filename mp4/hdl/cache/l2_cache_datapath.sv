/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

module l2_cache_datapath #(
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
    input   logic           clk, rst,
    input   logic [31:0]    mem_address,
    output  logic [31:0]    pmem_address,
    input   logic [255:0]   mem_wdata256, pmem_rdata,
    output  logic [255:0]   mem_rdata256, pmem_wdata,

    input   logic [num_ways-1:0] lru_in,
    output  logic [num_ways-1:0] lru_out,
    input   logic [31:0]         byte_enable[num_ways],
    
    input   logic        dirty_in[num_ways], valid_in[num_ways],
    input   logic        ld_dirty[num_ways], ld_valid[num_ways], ld_lru, ld_tag[num_ways],
    input   logic        rd_data[num_ways], rd_dirty[num_ways], rd_valid[num_ways], rd_lru, rd_tag[num_ways], 
    input   logic        datain_sel[num_ways],
    input   logic        mem_addr_sel, 
    output  logic        hit[num_ways], dirty_out[num_ways], valid_out[num_ways]
    
);

logic [s_tag - 1:0]   current_tag, tag_out[num_ways];
logic [255:0]  data_in[num_ways], data_out[num_ways], cache_out;

assign current_tag = mem_address[31:32 - s_tag];

genvar i;
for (i = 0; i < num_ways; i++) begin : check_hit
    assign hit[i] = valid_out[i] && (tag_out[i] == current_tag);
end

assign mem_rdata256 = cache_out;


l2_array #(.s_index(s_index), .width(num_ways)) lru (.clk (clk), .rst (rst), .read (rd_lru), .load (ld_lru), .rindex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .windex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .datain (lru_in), .dataout (lru_out));

generate;
    for (i = 0; i < num_ways; i++) begin : create_ways
        l2_array #(.s_index(s_index), .width(1)) dirty0 (.clk (clk), .rst (rst), .read (rd_dirty[i]), .load (ld_dirty[i]), .rindex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .windex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .datain (dirty_in[i]), .dataout (dirty_out[i]));
        l2_array #(.s_index(s_index), .width(1)) valid0 (.clk (clk), .rst (rst), .read (rd_valid[i]), .load (ld_valid[i]), .rindex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .windex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .datain (valid_in[i]), .dataout (valid_out[i]));
        l2_array #(.s_index(s_index), .width(s_tag)) tag0 (.clk (clk), .rst (rst), .read (rd_tag[i]), .load (ld_tag[i]),  .rindex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .windex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .datain (mem_address[31:32 - s_tag]), .dataout (tag_out[i]));
        l2_data_array #(.s_index(s_index)) data0 (.clk (clk), .read (rd_data[i]), .write_en (byte_enable[i]), .rindex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .windex (mem_address[32 - s_tag - 1: 32 - s_tag - s_index]), .datain (data_in[i]), .dataout (data_out[i]));
    end
endgenerate

always_comb begin : MUXES

    unique case (datain_sel[0])
        1'b0: data_in[0] = mem_wdata256;
        1'b1: data_in[0] = pmem_rdata;
        default: ;
    endcase  

    unique case (datain_sel[1])
        1'b0: data_in[1] = mem_wdata256;
        1'b1: data_in[1] = pmem_rdata;
        default: ;
    endcase

    unique case (datain_sel[2])
        1'b0: data_in[2] = mem_wdata256;
        1'b1: data_in[2] = pmem_rdata;
        default: ;
    endcase  

    unique case (datain_sel[3])
        1'b0: data_in[3] = mem_wdata256;
        1'b1: data_in[3] = pmem_rdata;
        default: ;
    endcase

    unique case (datain_sel[4])
        1'b0: data_in[4] = mem_wdata256;
        1'b1: data_in[4] = pmem_rdata;
        default: ;
    endcase  

    unique case (datain_sel[5])
        1'b0: data_in[5] = mem_wdata256;
        1'b1: data_in[5] = pmem_rdata;
        default: ;
    endcase

    unique case (datain_sel[6])
        1'b0: data_in[6] = mem_wdata256;
        1'b1: data_in[6] = pmem_rdata;
        default: ;
    endcase  

    unique case (datain_sel[7])
        1'b0: data_in[7] = mem_wdata256;
        1'b1: data_in[7] = pmem_rdata;
        default: ;
    endcase

    unique case ({hit[7], hit[6], hit[5], hit[4], hit[3], hit[2], hit[1], hit[0]})
        8'b00000001: cache_out = data_out[0];
        8'b00000010: cache_out = data_out[1];
        8'b00000100: cache_out = data_out[2];
        8'b00001000: cache_out = data_out[3];
        8'b00010000: cache_out = data_out[4];
        8'b00100000: cache_out = data_out[5];
        8'b01000000: cache_out = data_out[6];
        8'b10000000: cache_out = data_out[7];
        default: ;
    endcase

    unique case (mem_addr_sel)
        1'b0: pmem_address = {mem_address[31:5], 5'b0};
        1'b1: unique case ({lru_out[7], lru_out[6], lru_out[5], lru_out[4], lru_out[3], lru_out[2], lru_out[1], lru_out[0]})
            8'b00000001: pmem_address = {tag_out[0], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b00000010: pmem_address = {tag_out[1], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b00000100: pmem_address = {tag_out[2], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b00001000: pmem_address = {tag_out[3], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b00010000: pmem_address = {tag_out[4], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b00100000: pmem_address = {tag_out[5], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b01000000: pmem_address = {tag_out[6], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
            8'b10000000: pmem_address = {tag_out[7], mem_address[32 - s_tag - 1: 32 - s_tag - s_index], 5'b0};
        endcase
    endcase

    unique case ({lru_out[7], lru_out[6], lru_out[5], lru_out[4], lru_out[3], lru_out[2], lru_out[1], lru_out[0]})
        8'b00000001: pmem_wdata = data_out[0];
        8'b00000010: pmem_wdata = data_out[1];
        8'b00000100: pmem_wdata = data_out[2];
        8'b00001000: pmem_wdata = data_out[3];
        8'b00010000: pmem_wdata = data_out[4];
        8'b00100000: pmem_wdata = data_out[5];
        8'b01000000: pmem_wdata = data_out[6];
        8'b10000000: pmem_wdata = data_out[7];
        default: ;
    endcase  
end
endmodule : l2_cache_datapath
