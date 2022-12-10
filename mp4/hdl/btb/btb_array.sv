
// module btb_array #(parameter
//     width = 1
//     ,size = 256
// )
// (
//   input clk,
//   input logic load,
//   input logic [$clog(size)-1:0] rindex,
//   input logic [$clog(size)-1:0] windex,
//   input logic [width-1:0] datain,
//   output logic [width-1:0] dataout
// );

// logic [width-1:0] data [size] = '{default: '0};

// always_comb begin
// //   dataout = (load  & (rindex == windex)) ? datain : data[rindex];
//     dataout = load ? datain : data[rindex];
// end

// always_ff @(posedge clk)
// begin
//     if(load)
//         data[windex] <= datain;
// end

// endmodule : array