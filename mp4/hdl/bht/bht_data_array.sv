
module bht_data_array
#(
  parameter size=256,
  parameter width=2
)
(
  input clk,
  input logic write_en,
  input logic [$clog2(size)-1:0] rindex,
  input logic [$clog2(size)-1:0] windex,
  input logic [1:0] datain,
  output logic [1:0] dataout
);

logic [1:0] data [size] = '{default: 10};

always_comb begin
  // for (int i = 0; i < 1; i++) begin
      // dataout[1*i +: 0] = (write_en & (rindex == windex)) ? datain[size*i +: size] : data[rindex][size*i +: size];
  // end
  dataout[1:0] = (write_en) ? datain[1:0] : data[rindex][1:0];
end

always_ff @(posedge clk) begin
    // for (int i = 0; i < 1; i++) begin
		//   data[windex][size*i +: size] <= write_en ? datain[size*i +: size] : data[windex][size*i +: size];
    // end
    data[windex][1:0] <= write_en ? datain[1:0] : data[windex][1:0];
end

endmodule : bht_data_array

// module data_array (
//   input clk,
//   input logic [31:0] write_en,
//   input logic [2:0] rindex,
//   input logic [2:0] windex,
//   input logic [255:0] datain,
//   output logic [255:0] dataout
// );

// logic [255:0] data [8] = '{default: '0};

// always_comb begin
//   for (int i = 0; i < 32; i++) begin
//       dataout[8*i +: 8] = (write_en[i] & (rindex == windex)) ? datain[8*i +: 8] : data[rindex][8*i +: 8];
//   end
// end

// always_ff @(posedge clk) begin
//     for (int i = 0; i < 32; i++) begin
// 		  data[windex][8*i +: 8] <= write_en[i] ? datain[8*i +: 8] : data[windex][8*i +: 8];
//     end
// end

// endmodule : data_array