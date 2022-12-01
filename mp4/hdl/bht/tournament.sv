// module tournament_predictor 
// import rv32i_types::*; 
// (
//     input int always_nt_br_mispred,
//     input int btfnt_br_mispred, 
//     input int local_br_mispred,
//     input ctrl_flow_preds br_preds,

//     output logic tournament_br_pred
// );
// int min1, min2;
// int min1_pred, min2_pred;
// always_comb begin : blockName
//     if (always_nt_br_mispred < btfnt_br_mispred) begin
//         min1 = always_nt_br_mispred;
//         min1_pred = br_preds.staticNT_pred;
//     end else begin
//         min1 = btfnt_br_mispred;
//         min1_pred = br_preds.staticBTFNT_pred;
//     end
//     // if 
//     min2 = local_br_mispred;
//     min2_pred = br_preds.dynamicLocalBHT_pred;


//     tournament_br_pred = (min1 < min2) ? min1_pred : min2_pred;


// end

// endmodule : tournament_predictor