module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// Dump signals
initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, mp4_tb, "+all");
end
/****************************** End do not touch *****************************/


/************************ Signals necessary for monitor **********************/
// This section not required until CP2

assign rvfi.commit = 0; // Set high when a valid instruction is modifying regfile or PC
                    // = |dut.d0.WB.WB_ctrl_word_i.opcode && ~not stall
                    // grab signal to define stall
assign rvfi.halt = 0;//dut.d0.WB.WB_halt_en_i; // Set high when target PC == Current PC for a branch
                    // probably = rvfi.pc_rdata == rvfi.pc_wdata && rvfi.commit
                    // i also have wire called halt, computed in ID stage
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

/*
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_add
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.load_regfile
    rvfi.rd_addr
    rvfi.rd_wdata

PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

Please refer to rvfi_itf.sv for more information.
*/

// // Instruction and trap:
// assign rvfi.inst = dut.d0.WB.WB_instr_i;
// assign rvfi.trap = 1'b0; // idk what this is ???

// // Regfile:
// assign rvfi.rs1_addr = ; // need to be proporgated to WB // 5 bit
// assign rvfi.rs2_addr = ; // ditto // 5 bit
// assign rvfi.rs1_rdata = ; // dit (keep in mind forwarding) // 32bit
// assign rvfi.rs2_rdata = ; // di // 32 bit
// assign rvfi.load_regfile = dut.d0.WB.WB_load_regfile_o;
// assign rvfi.rd_addr = dut.d0.WB.WB_rd_o;
// assign rvfi.rd_wdata = dut.d0.WB.WB_regfilemux_out_o;

// // PC:
// assign rvfi.pc_rdata = ; // output of PC?
// assign rvfi.pc_wdata = ; // input to PC to update for next clock edge?

// // Memory:
// assign rvfi.mem_addr = dut.d0.MEM_WB.MEM_WB_data_mem_address_o;
// assign rvfi.mem_rmask = ; // ????
// assign rvfi.mem_wmask = ; // ????
// assign rvfi.mem_rdata = dut.d0.MEM_WB.MEM_WB_data_mem_rdata_o;
// assign rvfi.mem_wdata = dut.d0.MEM_WB.MEM_WB_data_mem_wdata_o;

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/
// // icache signals:
// assign itf.inst_read = ; // depends on cache integration
// assign itf.inst_addr = dut.d0.IF.IF_pc_out_o;
// assign itf.inst_resp = ; // depends on cache integration
// assign itf.inst_rdata = dut.d0.IF_ID.IF_ID_instr_i;

// // dcache signals:
// assign itf.data_read = dut.d0.MEM.MEM_mem_read_o;
// assign itf.data_write = dut.d0.MEM.MEM_mem_write_o;
// assign itf.data_mbe = dut.d0.MEM.MEM_mem_byte_en_o;
// assign itf.data_addr = dut.d0.MEM.MEM_data_mem_address_o;
// assign itf.data_wdata = dut.d0.MEM.MEM_data_mem_wdata_o;
// assign itf.data_resp = ; // depends on cache integration
// assign itf.data_rdata = dut.d0.MEM_WB.MEM_WB_data_mem_rdata_i;

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
// assign itf.registers = '{default: '0};
assign itf.registers = dut.d0.ID.regfile.data;

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level for CP2:
Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),
    
     // Remove after CP1
    .instr_mem_resp(itf.inst_resp),
    .instr_mem_rdata(itf.inst_rdata),
	.data_mem_resp(itf.data_resp),
    .data_mem_rdata(itf.data_rdata),
    .instr_read(itf.inst_read),
	.instr_mem_address(itf.inst_addr),
    .data_read(itf.data_read),
    .data_write(itf.data_write),
    .data_mbe(itf.data_mbe),
    .data_mem_address(itf.data_addr),
    .data_mem_wdata(itf.data_wdata)


    /* Use for CP2 onwards
    .pmem_read(itf.mem_read),
    .pmem_write(itf.mem_write),
    .pmem_wdata(itf.mem_wdata),
    .pmem_rdata(itf.mem_rdata),
    .pmem_address(itf.mem_addr),
    .pmem_resp(itf.mem_resp)
    */
);
/***************************** End Instantiation *****************************/

endmodule
