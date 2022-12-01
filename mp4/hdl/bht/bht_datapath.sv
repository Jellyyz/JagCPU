// module cache_datapath #( parameter
// 	size=256
// 	,width=1
// )(
// 	input clk,

// 	input logic  [31:0]  pc_address,
// 	input logic  [width-1:0] bht_wdata,
// 	output logic [width-1:0] bht_rdata,


// 	/* Control signals */
// 	// input logic tag_load,
// 	input logic valid_load,

// 	// output logic hit,
// 	input logic rw
// );

// logic [width-1:0] line_in, line_out;
// // logic [23:0] address_tag, tag_out;
// logic [$clog(size)-1:0]  index;
// logic valid_out;

// logic write_en;

// always_comb begin
// 	// address_tag = mem_address[31:$clog(size)+1];
// 	index = pc_address[$clog(size)+1:2];
// 	//   hit = valid_out && (tag_out == address_tag);

// 	case(rw)
// 		2'b10: begin // read from BHT
// 			write_en = 0'b1;
// 		end
// 		2'b01: begin // write to BHT
// 			write_en = 1'b1;
// 		end
// 		default: begin // don't change data
// 			write_en = 0'b1;
// 		end
// 	endcase
// end

// bht_data_array DM_bht (
//     .clk(clk),
//     .write_en(write_en),
//     .rindex(index),
//     .windex(index),
//     .datain(bht_wdata),
//     .dataout(bht_rdata)
// );

// // bht_array #(24) tag (clk, tag_load, index, index, address_tag, tag_out);
// // bht_array #(1) bht_valid (clk, valid_load, index, index,1'b1, valid_out);

// endmodule : cache_datapath