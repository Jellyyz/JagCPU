// module bht #( 
//     parameter size=256, 
//     parameter width=2
// )
// (
//     input clk,
//     input rst,

//     input logic bht_read,
// 	input logic bht_write,
// 	input logic [31:0] pc_address_read,

// 	// output logic bht_resp,
// 	output logic [width-1:0] bht_rdata,

// 	// input logic [width-1:0] bht_wdata,
//     input logic mispredict,
//     input logic [31:0] pc_address_write
// );

// logic write_en;
// logic [$clog2(size)-1:0] rindex, windex;
// logic [width-1:0] _bht_wdata;

// always_comb begin
//     // indices of width $clog2(size), just not using 2 LSBs
// 	rindex = pc_address_read[$clog2(size)+1:2];
//     windex = pc_address_write[$clog2(size)+1:2];

// 	case({bht_read, bht_write})
// 		2'b10: begin // read from BHT
// 			write_en = 1'b0;
// 		end
// 		2'b01: begin // write to BHT
// 			write_en = 1'b1;
// 		end
//         2'b11: begin // read from and write to BHT
//             write_en = 1'b1;
//         end
// 		default: begin // don't change data
// 			write_en = 1'b0;
// 		end
// 	endcase
// end

// enum int unsigned
// {
//   weakly_not_taken, strongly_taken, weakly_taken, strongly_not_taken
// } state, next_state;

// always_comb begin : state_actions
//     case (state)
//         strongly_taken : begin
//             _bht_wdata = mispredict ? 2'b10 : 2'b11;
//         end
//         weakly_taken : begin
//             _bht_wdata = mispredict ? 2'b01 : 2'b11;
//         end
//         weakly_not_taken : begin
//             _bht_wdata = mispredict ? 2'b00 : 2'b10;
//         end
//         strongly_not_taken : begin
//             _bht_wdata = mispredict ? 2'b00 : 2'b01;
//         end
//     endcase
// end

// /* Next State Logic */
// always_comb begin : next_state_logic
//     /* Default state transition */
// 	next_state = state;

//     if (mispredict && state == strongly_taken) next_state = weakly_taken;
//     if (mispredict && state == weakly_taken) next_state = weakly_not_taken;
//     if (mispredict && state == weakly_not_taken) next_state = strongly_not_taken;
//     if (mispredict && state == strongly_not_taken) next_state = strongly_not_taken;

//     if (~mispredict && state == strongly_taken) next_state = strongly_taken;
//     if (~mispredict && state == weakly_taken) next_state = strongly_taken;
//     if (~mispredict && state == weakly_not_taken) next_state = weakly_taken;
//     if (~mispredict && state == strongly_not_taken) next_state = weakly_not_taken;
// end

// /* Next State Assignment */
// always_ff @(posedge clk) begin: next_state_assignment
// 	 state <= next_state;
// end

// bht_data_array #(.size(size)) DM_BHT (
//     .clk(clk),
//     .write_en(write_en),
//     .rindex(rindex),
//     .windex(windex),
//     .datain(_bht_wdata),
//     .dataout(bht_rdata)
// );

// endmodule : bht