module bht #( 
    parameter size=256
)
(
    input clk,
    input rst,

    input logic bht_read,
	input logic bht_write,
	input logic [31:0] pc_address_read,
    input logic [31:0] pc_address_write,

	output logic br_pred,
    output logic [1:0] bht_rdata,

    input logic mispredict,
    // input logic br_en,
    input logic [1:0] bht_rdata_ret   // this was output as bht_rdata in IF stage
                                // use to update sat counter

    
);

localparam width=2;
localparam idx_offset=2;

logic [width-1:0] _bht_wdata;
logic [$clog2(size)-1+idx_offset:0+idx_offset] rindex, windex;

always_comb begin : set_pred_output
    // 11 - strongly taken, 10 - weakly taken
    // 01 - weakly NOT taken, 00 - strongly NOT taken
    br_pred = bht_rdata[1];
end

initial begin
    $display("bht size is ", size);
    $display("$clog2 size is",$clog2(size));
end

assign rindex = pc_address_read[$clog2(size)-1:0];
assign windex = pc_address_write[$clog2(size)-1:0];


saturate_coutnter saturate_coutnter (
    .clk(clk),
    .rst(rst),
    .bht_rdata_ret(bht_rdata_ret),
    .mispredict(mispredict),
    .wdata(_bht_wdata)
);


bht_data_array #(.size(size), .width(width)) DM_BHT (
    .clk(clk),
    .write_en(bht_write),
    .rindex(rindex),
    .windex(windex),
    .datain(_bht_wdata),
    .dataout(bht_rdata)
);

endmodule : bht