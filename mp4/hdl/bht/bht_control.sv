// module bht_control (
//   input clk,

//   /* BHT data signals */
//   input  logic bht_read,
// 	input  logic bht_write,
// 	output logic bht_resp,

//   /* Control signals */
//   // output logic tag_load,
//   // output logic valid_load,

//   input logic hit,
//   output logic [1:0] rw
// );

// /* State Enumeration */
// enum int unsigned
// {
//   check_hit,
// 	read_mem
// } state, next_state;

// /* State Control Signals */
// always_comb begin : state_actions

// 	/* Defaults */
//   // tag_load = 1'b0;
//   // valid_load = 1'b0;
//   // dirty_load = 1'b0;
//   // dirty_in = 1'b0;
//   rw = 2'b00;

// 	bht_resp = 1'b0;
// 	bht_write = 1'b0;
// 	bht_read = 1'b0;

// 	case(state)
//     check_hit: begin
//       if (bht_read || bht_write) begin
//         if (hit) begin
//           bht_resp = 1'b1;
//           if (bht_write) begin
//             dirty_load = 1'b1;
//             dirty_in = 1'b1;
//             writing = 2'b01;
//           end
//         end else begin
//           if (dirty_out)
//             bht_write = 1'b1;
//         end
//       end
//     end

//     // read_mem: begin
//     //   bht_read = 1'b1;
//     //   writing = 2'b00;
//     //   if (bht_resp) begin
//     //     // tag_load = 1'b1;
//     //     valid_load = 1'b1;
//     //   end
//     //     dirty_load = 1'b1;
//     //     dirty_in = 1'b0;
//     // end

// 	endcase
// end

// /* Next State Logic */
// always_comb begin : next_state_logic

// 	/* Default state transition */
// 	next_state = state;

// 	case(state)
//     check_hit: begin
//       if ((bht_read || bht_write) && !hit) begin
//         if (dirty_out) begin
//           if (pbht_resp)
//             next_state = read_mem;
//         end else begin
//           next_state = read_mem;
// 		  end
//       end
//     end

//     // read_mem: begin
//     //   if (pbht_resp)
//     //     next_state = check_hit;
//     // end

// 	endcase
// end

// /* Next State Assignment */
// always_ff @(posedge clk) begin: next_state_assignment
// 	 state <= next_state;
// end

// endmodule : cache_control