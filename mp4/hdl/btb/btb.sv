module btb #( 
    parameter size=256
)
(
    input clk,
    input rst,

    input logic btb_read,
	input logic btb_write_bp,
	input logic [31:0] pc_address_read,
    input logic [31:0] pc_address_write,

	output logic btb_br_pred,
    output logic btb_pred_target_addr, // feed in to PC if BTB_br_pred is taken
    output logic [1:0] btb_rdata,

    input logic btb_mispredict,
    input logic [31:0] branch_target_address_real
    // input logic br_en,
    input logic [1:0] btb_rdata_ret   // this was output as bht_rdata in IF stage
                                // use to update sat counter

    
);

localparam bp_width=2;
localparam target_width=32;
localparam idx_offset=2;

logic [width-1:0] _btb_wdata;
logic [$clog2(size)-1+idx_offset:0+idx_offset] rindex, windex;

logic 

always_comb begin : set_pred_output
    // 11 - strongly taken, 10 - weakly taken
    // 01 - weakly NOT taken, 00 - strongly NOT taken
    br_pred = btb_rdata[1];
end

initial begin
    $display("btb size is ", size);
    $display("$clog2 size is",$clog2(size));
end

assign rindex = pc_address_read[$clog2(size)-1:0];
assign windex = pc_address_write[$clog2(size)-1:0];


saturate_coutnter saturate_counter_btb (
    .clk(clk),
    .rst(rst),
    .bht_rdata_ret(btb_rdata_ret),
    .mispredict(btb_mispredict),
    .wdata(_btb_wdata)
);


btb_data_array #(.size(size), .width(bp_width)) direct_mapped_BP (
    .clk(clk),
    .write_en(btb_write_bp),
    .rindex(rindex),
    .windex(windex),
    .datain(_btb_wdata),
    .dataout(btb_rdata)
);


btb_data_array #(.size(size), .width(target_width)) direct_mapped_targets (
    .clk(clk),
    .write_en(btb_mispredict),
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