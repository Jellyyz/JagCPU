module btb import rv32i_types::*; #( 
    parameter size=256
)

(
    input clk,
    input rst,

    input clockgate,

    // input logic btb_read,
	input logic btb_write_bp,
	input logic [31:0] pc_address_read,
    input logic [31:0] pc_address_write,

	output logic btb_br_pred,
    output logic [31:0] btb_pred_target_addr, // feed in to PC if BTB_br_pred is taken
    output logic [1:0] btb_pred_rdata, // solely for return for updating if necessary

    input logic btb_mispredict, // if high, means need to update the predicted target array @ windex
    input logic btb_wrong_pc,
    input logic [31:0] branch_target_address_real,
    // input logic br_en,
    input logic [1:0] btb_rdata_ret,   // this was output as bht_rdata in IF stage
                                // use to update sat counter
    input rv32i_control_word ID_ctrl,

    output logic BTB_jump_the_gun_and_load_pc
    
);

localparam bp_width=2;
localparam target_width=32;
localparam idx_offset=2;

logic [bp_width-1:0] _btb_pred_wdata;
logic [$clog2(size)-1:0] rindex, windex;

always_comb begin : set_pred_output
    // 11 - strongly taken, 10 - weakly taken
    // 01 - weakly NOT taken, 00 - strongly NOT taken
    btb_br_pred = btb_pred_rdata[1];

    BTB_jump_the_gun_and_load_pc = (btb_pred_target_addr > 32'h00000060) & btb_br_pred & ((ID_ctrl.opcode == op_br) /*| (ID_ctrl.opcode == op_jal) | (ID_ctrl.opcode == op_jalr))*/ & ~btb_wrong_pc;
    // include btb_wrong_pc since if already tried wrong pc, just want to use standard pc+4 mux output to get next instruction
end

initial begin
    $display("btb size is ", size);
    $display("$clog2 size is",$clog2(size));
end

assign rindex = pc_address_read[$clog2(size)-1+idx_offset:0+idx_offset];
assign windex = pc_address_write[$clog2(size)-1+idx_offset:0+idx_offset];


saturate_coutnter saturate_counter_btb (
    .clk(clk & clockgate),
    .rst(rst),
    .bht_rdata_ret(btb_rdata_ret),
    .mispredict(btb_mispredict), // update counter up/down based on if prediction right/wrong
    .wdata(_btb_pred_wdata)
);


btb_data_array #(.size(size), .width(bp_width)) direct_mapped_BP (
    .clk(clk & clockgate),
    .write_en(btb_write_bp), // update counter after every exec of branch (diff from update target), but not decrement if predict write, but wrong address
    .rindex(rindex),
    .windex(windex),
    .datain(_btb_pred_wdata),
    .dataout(btb_pred_rdata)
);


btb_data_array #(.size(size), .width(target_width)) direct_mapped_targets (
    .clk(clk & clockgate),
    .write_en(btb_wrong_pc && |pc_address_write), // only update target address if mispredicted target previously (no need if )
    .rindex(rindex),
    .windex(windex),
    .datain(branch_target_address_real),
    .dataout(btb_pred_target_addr)
);

// btb_data_array #(.size(size), .width(width)) dm_btb (
//     .clk(clk),
//     .write_en(btb_write),
//     .rindex(rindex),
//     .windex(windex),
//     .datain(_btb_wdata),
//     .dataout(btb_rdata)
// );

// btb_array #(.size(size), .width(24)) tag (
//     .clk(clk),
//     .load(btb_write),
//     .rindex(rindex),
//     .windex(windex),
//     .datain(),
//     .dataout(tag_rdata)
// )

endmodule : btb