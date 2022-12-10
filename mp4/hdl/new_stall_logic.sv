// module stall_for_mem
// import rv32i_types::*;
// (
//     input logic clk, rst, 
//     // triggers from pmem if data is ready to be read | written
//     input logic data_mem_resp_i,
//     input logic instr_mem_resp_i,
//     input rv32i_control_word EX_MEM_ctrl_word_i, 


//     output logic stall_IF_ID_ld_o,         
//     output logic stall_ID_EX_ld_o, 
//     output logic stall_EX_MEM_ld_o, 
//     output logic stall_MEM_WB_ld_o,

//     output logic IF_i_cache_read_stall_o,      // condition to read from physical memory during mem stall 
//     output logic stall_i_cache_pc_o            // condition to stall the PC          


// ); 
// logic mem_data_access; 
// logic EX_MEM_ld_flag; 
// always_ff @(posedge clk or posedge rst)begin : STALL_FLAG_FOR_EX_MEM
//     if(rst)begin 
//         EX_MEM_ld_flag <= 1'b0; 
//     end 
//     else begin 
//         if(~stall_IF_ID_ld_o)begin
//             EX_MEM_ld_flag <= 1'b0;
//         end
//         else if(data_mem_resp_i) begin 
//             EX_MEM_ld_flag <= 1'b1;
//         end     
//     end 
// end 


// // always_ff @(posedge clk or posedge rst ) begin : STALL_FLAG_FOR_IF_ID
// //     if(rst)begin 
// //         sdf <= 1'b0; 
// //     end 
// //     else begin 
// //         if(~stall_IF_ID_ld_o)begin
// //             sdf <= 1'b0;
// //         end
// //         else if(instr_mem_resp_i) begin 
// //             sdf <= 1'b1;
// //         end     
// //     end 
// // end 

// always_comb begin : stall_for_mem
    
//     mem_data_access = (EX_MEM_ctrl_word_i.opcode == op_store) | (EX_MEM_ctrl_word_i.opcode == op_load);


//     if(EX_MEM_ld_flag)begin 
//         if(instr_mem_resp_i)begin 
//             stall_IF_ID_ld_o = 1'b0;
//         end 
//     end 
//     else if(instr_mem_resp_i & ~mem_data_access)
//         stall_IF_ID_ld_o = 1'b0; 
//     else begin 
//         stall_IF_ID_ld_o = 1'b1; 
//     end 

//     // // if we are stalling the fetch register we should not read
//     // IF_i_cache_read_stall_o = ~stall_IF_ID_ld_o;
//     // // if we are stalling our fetch register we should stall pc
//     // stall_i_cache_pc_o = stall_IF_ID_ld_o;
//     // // stall_IF_ID_ld_o = ~instr_mem_resp_i & stall_ID_EX_ld_o;
//     // stall_ID_EX_ld_o = stall_EX_MEM_ld_o;
//     // stall_EX_MEM_ld_o = (~data_mem_resp_i & mem_data_access);
//     // stall_MEM_WB_ld_o = (~data_mem_resp_i & mem_data_access);

//     // if ((EX_MEM_ld_flag & instr_mem_resp_i) | (instr_mem_resp_i & ~mem_data_access)) begin
//     //     stall_IF_ID_ld_o = 1'b0; 
//     // end else begin
//     //     stall_IF_ID_ld_o = 1'b1; 
//     // end

//     // if we are stalling the fetch register we should not read
//     IF_i_cache_read_stall_o = ~stall_IF_ID_ld_o;
//     // if we are stalling our fetch register we should stall pc
//     stall_i_cache_pc_o = stall_IF_ID_ld_o;

// // backend 

//     if(~data_mem_resp_i & mem_data_access)begin
//         stall_MEM_WB_ld_o = 1'b1; 
//     end 
//     else if(stall_IF_ID_ld_o)begin
//         stall_MEM_WB_ld_o = 1'b1; 
//     end 
//     else begin 
//         stall_MEM_WB_ld_o = 1'b0; 
//     end 
//     // stall_MEM_WB_ld_o = (~data_mem_resp_i & mem_data_access) | stall_IF_ID_ld_o ;
//     stall_EX_MEM_ld_o = stall_MEM_WB_ld_o;
//     stall_ID_EX_ld_o = stall_MEM_WB_ld_o;

// end 


// // stall the backend if we are waiting for some pmem during memory access or the front end is stall_ID_EX_ld
// //  but also turn off the stalling if the front end has stopped 

// endmodule 


// // if waiting on data mem resp
// //  stall mem/wb, ex/mem, id/ex, if/id
// // if waiting on instr data mem resp
// //  stall mem/wb, ex/mem, id/ex, if/id


// // if not expecting data resp and not expecting instr resp
// //  no stalling
// // if not expecting data resp and expecting instr resp
// //  stall all stages
// // if expecting data resp and not expecting instr resp
// //  stall all stages
// // if expecting data resp and expecting instr resp
// //  stall all stages
// //  if get data resp first
// //      continue stalling all stages, until get instr resp. then, unstall all stages
// //  if get instr resp first
// //      



