// module branch_prediction #(
//     parameter width = 32
// ) (

//     input logic [width-1:0] ID_pc_addr,
//     input logic [width-1:0] IF_pc_addr,
//     input logic br_en, 

//     output logic IF_ID_flush,
//     output logic branch_taken, 
// );



// logic branch_actual_prediction; // comes from magic for now 
// logic branch_correctness;       // is the branch correct 
// assign branch_actual_prediction = 1'b0;     // branch not taken 
// assign branch_correctness = (ID_pc_addr == IF_pc_addr);     
// always_comb begin: CHECK_FOR_BR

//     IF_ID_flush = 1'b0;
//     if(~branch_actual_prediction)begin 

//         if (branch_correctness) begin
//             // do nothing?, pc <- pc + 4 as normal
//             pcmux_sel = pcmux::pc_plus4;
//         end
//         else begin
//             IF_ID_flush = 1'b1;
//             pcmux_sel = pcmux::alu_out;
//         end


//     end 
//     else begin 
//             // do later 

//     end 

// end 

// // // actual branch prediction of what we think we should take 
// // branch_actual_prediction = 0; 
// //     // 1 - branch taken
// //     // 0 - branch not taken 
// // // is the prediction that we have chosen correct?
// // branch_correctness = pc_addr_calculated_in_ID == IF_pc_addr_fetching_with
// //     // = 1, good
// //     // = 0, bad -> flush


// // // does the instruction itself require a branch? 
// // br_en = comes from cmp 

// // for branch not taken 
// // // correctness checking 
// //     if br_en :
// //         if branch_correctness : // branch prediction was correct 
// //             pc <- pc + 4 
// //         else : // branch correctness was incorrect 
// //             if branch_actual_prediction:
                
// //             else: 
            

// endmodule