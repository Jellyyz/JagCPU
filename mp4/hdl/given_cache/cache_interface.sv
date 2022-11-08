
module cache_interface
import rv32i_types::*;
(
    input   logic clk, rst,
    
    input   logic [31:0]    i_mem_address,
    output  logic [31:0]    i_mem_rdata,
    input   logic [31:0]    i_mem_wdata,
    input   logic           i_mem_read,
    input   logic           i_mem_write,
    input   logic [3:0]     i_mem_byte_enable,
    output  logic           i_mem_resp,

    input   logic [31:0]    d_mem_address,
    output  logic [31:0]    d_mem_rdata,
    input   logic [31:0]    d_mem_wdata,
    input   logic           d_mem_read,
    input   logic           d_mem_write,
    input   logic [3:0]     d_mem_byte_enable,
    output  logic           d_mem_resp,

    output  logic [31:0]    pmem_address,
    input   logic [63:0]   pmem_rdata,
    output  logic [63:0]   pmem_wdata,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic           pmem_resp  
);

// Data Cache Signals
logic           d_pmem_resp;
logic [255:0]   d_pmem_rdata;
logic [31:0]    d_pmem_address;
logic [255:0]   d_pmem_wdata;
logic           d_pmem_read;
logic           d_pmem_write;

// Instruction Cache Signals
logic           i_pmem_resp;
logic [255:0]   i_pmem_rdata;
logic [31:0]    i_pmem_address;
logic [255:0]   i_pmem_wdata;
logic           i_pmem_read;
logic           i_pmem_write;

// Memory Signals
logic           resp_o;
logic [255:0]   line_o;
logic           read_i;
logic           write_i;
logic [31:0]    address_i;
logic [255:0]   line_i;

cache data_cache
(
    .clk (clk),
    .rst (rst),
    
    .mem_read             (d_mem_read),
    .mem_write            (d_mem_write),
    .mem_byte_enable_cpu  (d_mem_byte_enable),
    .mem_address          (d_mem_address),
    .mem_wdata_cpu        (d_mem_wdata),
    .mem_resp             (d_mem_resp),
    .mem_rdata_cpu        (d_mem_rdata),

    .pmem_resp            (d_pmem_resp),
    .pmem_rdata           (d_pmem_rdata),
    .pmem_address         (d_pmem_address),
    .pmem_wdata           (d_pmem_wdata),
    .pmem_read            (d_pmem_read),
    .pmem_write           (d_pmem_write)
);

cache instruction_cache
(
    .clk (clk),
    .rst (rst),
    
    .mem_read             (i_mem_read),
    .mem_write            (i_mem_write),
    .mem_byte_enable_cpu  (i_mem_byte_enable),
    .mem_address          (i_mem_address),
    .mem_wdata_cpu        (i_mem_wdata),
    .mem_resp             (i_mem_resp),
    .mem_rdata_cpu        (i_mem_rdata),

    .pmem_resp            (i_pmem_resp),
    .pmem_rdata           (i_pmem_rdata),
    .pmem_address         (i_pmem_address),
    .pmem_wdata           (i_pmem_wdata),
    .pmem_read            (i_pmem_read),
    .pmem_write           (i_pmem_write)
);

arbiter arbiter
(
    .clk (clk),
    .rst (rst),

    .i_mem_write          (i_pmem_write),
    .i_mem_read           (i_pmem_read),
    .i_mem_address        (i_pmem_address),
    .i_mem_wdata          (i_pmem_wdata),
    .i_mem_rdata          (i_pmem_rdata),
    .i_mem_resp           (i_pmem_resp),

    .d_mem_write          (d_pmem_write),
    .d_mem_read           (d_pmem_read),
    .d_mem_address        (d_pmem_address),
    .d_mem_wdata          (d_pmem_wdata),
    .d_mem_rdata          (d_pmem_rdata),
    .d_mem_resp           (d_pmem_resp),

    .main_pmem_resp       (resp_o),
    .main_pmem_rdata      (line_o),
    .main_pmem_read       (read_i),
    .main_pmem_write      (write_i),
    .main_pmem_address    (address_i),
    .main_pmem_wdata      (line_i)
);

cacheline_adaptor cacheline_adaptor
(
    .clk                    (clk), 
    .reset_n                (~rst),

    .line_i                 (line_i), 
    .line_o                 (line_o),
    .address_i              (address_i), 
    .read_i                 (read_i), 
    .write_i                (write_i), 
    .resp_o                 (resp_o), 
    
    .burst_i                (pmem_rdata), 
    .burst_o                (pmem_wdata), 
    .address_o              (pmem_address), 
    .read_o                 (pmem_read), 
    .write_o                (pmem_write), 
    .resp_i                 (pmem_resp) 
);


endmodule : cache_interface