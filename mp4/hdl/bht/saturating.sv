module saturate_coutnter (
    input clk,
    input rst,
    input logic [1:0] bht_rdata_ret,
    input logic mispredict,

    output logic [1:0] wdata
);

logic [1:0] _wdata, wdsat;

always_comb begin : sat_ctr
    if (bht_rdata_ret[1]) begin // strongly or weakly taken
        if (bht_rdata_ret[0]) begin // strongly taken - 11
            _wdata = mispredict ? 2'b10 : 2'b11;
        end else begin // weakly taken - 10
            _wdata = mispredict ? 2'b01 : 2'b11;
        end
    end else begin // strongly or weakly NOT taken
        if (bht_rdata_ret[0]) begin // weakly NOT taken - 01
            _wdata = mispredict ? 2'b10 : 2'b00;
        end else begin // strongly NOT taken - 00
            _wdata = mispredict ? 2'b01 : 2'b00;
        end
    end

    wdata = _wdata;
end

always_ff @( posedge clk or posedge rst) begin
    if (rst) wdsat <= '0;
    else wdsat <= _wdata;
end

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


endmodule : saturate_coutnter