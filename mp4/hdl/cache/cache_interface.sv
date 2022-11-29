
module cache_interface
import rv32i_types::*;
(
    input   logic clk, rst,
    
    input   logic [31:0]    instr_mem_address,
    output  logic [31:0]    instr_mem_rdata,
    input   logic [31:0]    instr_mem_wdata,
    input   logic           instr_mem_read,
    input   logic           instr_mem_write,
    input   logic [3:0]     instr_mem_byte_enable,
    output  logic           instr_mem_resp,

    input   logic [31:0]    data_mem_address,
    output  logic [31:0]    data_mem_rdata,
    input   logic [31:0]    data_mem_wdata,
    input   logic           data_mem_read,
    input   logic           data_mem_write,
    input   logic [3:0]     data_mem_byte_enable,
    output  logic           data_mem_resp,

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
    
    .mem_read             (data_mem_read),          // from cpu
    .mem_write            (data_mem_write),         // from cpu
    .mem_byte_enable_cpu  (data_mem_byte_enable),   // from cpu
    .mem_address          (data_mem_address),       // from cpu
    .mem_wdata_cpu        (data_mem_wdata),         // from cpu
    .mem_resp             (data_mem_resp),          // to cpu
    .mem_rdata_cpu        (data_mem_rdata),         // to cpu

    .pmem_resp            (d_pmem_resp),    // from mem (from arb)
    .pmem_rdata           (d_pmem_rdata),   // from mem (from arb)
    .pmem_address         (d_pmem_address), // to mem (to arb)
    .pmem_wdata           (d_pmem_wdata),   // to mem (to arb)
    .pmem_read            (d_pmem_read),    // to mem (to arb)
    .pmem_write           (d_pmem_write)    // to mem (to arb)
);

cache instruction_cache
(
    .clk (clk),
    .rst (rst),
    
    .mem_read             (instr_mem_read),         // from cpu
    .mem_write            (instr_mem_write),        // from cpu
    .mem_byte_enable_cpu  (instr_mem_byte_enable),  // from cpu
    .mem_address          (instr_mem_address),      // from cpu
    .mem_wdata_cpu        (instr_mem_wdata),        // from cpu
    .mem_resp             (instr_mem_resp),         // to cpu
    .mem_rdata_cpu        (instr_mem_rdata),        // to cpu

    .pmem_resp            (i_pmem_resp),    // from mem (from arb)
    .pmem_rdata           (i_pmem_rdata),   // from mem (from arb)
    .pmem_address         (i_pmem_address), // to mem (to arb)
    .pmem_wdata           (i_pmem_wdata),   // to mem (to arb)
    .pmem_read            (i_pmem_read),    // to mem (to arb)
    .pmem_write           (i_pmem_write)    // to mem (to arb)
);

arbiter arbiter
(
    .clk (clk),
    .rst (rst),

    .instr_mem_write          (i_pmem_write),   // to mem (from icache)
    .instr_mem_read           (i_pmem_read),    // to mem (from icache)
    .instr_mem_address        (i_pmem_address), // to mem (from icache)
    .instr_mem_wdata          (i_pmem_wdata),   // to mem (from icache)
    .instr_mem_rdata          (i_pmem_rdata),   // from mem (to icache)
    .instr_mem_resp           (i_pmem_resp),    // from mem (to icache)

    .data_mem_write          (d_pmem_write),    // to mem (from dcache)
    .data_mem_read           (d_pmem_read),     // to mem (from dcache)
    .data_mem_address        (d_pmem_address),  // to mem (from dcache)
    .data_mem_wdata          (d_pmem_wdata),    // to mem (from dcache)
    .data_mem_rdata          (d_pmem_rdata),    // from mem (to dcache)
    .data_mem_resp           (d_pmem_resp),     // from mem (to dcache)

    .main_pmem_resp       (resp_o),     // from mem (to icache)
    .main_pmem_rdata      (line_o),     // from mem (to icache)
    .main_pmem_read       (read_i),     // to mem (to adaptor)
    .main_pmem_write      (write_i),    // to mem (to adaptor)
    .main_pmem_address    (address_i),  // to mem (to adaptor)
    .main_pmem_wdata      (line_i)      // to mem (to adaptor)
);

cacheline_adaptor cacheline_adaptor
(
    .clk                    (clk), 
    .reset_n                (~rst),

    .line_i                 (line_i),   // to mem (from arb)
    .line_o                 (line_o),   // from mem (to arb)
    .address_i              (address_i),// to mem (from arb)
    .read_i                 (read_i),   // to mem (from arb)
    .write_i                (write_i),  // to mem (from arb)
    .resp_o                 (resp_o),   // from mem (to arb)
    
    .burst_i                (pmem_rdata),   // from mem
    .burst_o                (pmem_wdata),   // to mem
    .address_o              (pmem_address), // to mem
    .read_o                 (pmem_read),    // to mem
    .write_o                (pmem_write),   // to mem
    .resp_i                 (pmem_resp)     // from mem
);


endmodule : cache_interface