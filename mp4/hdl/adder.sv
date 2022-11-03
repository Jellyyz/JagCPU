module adder
import rv32i_types::*;
#(parameter width = 32) 
(
    input logic [width-1:0] a,
    input logic [width-1:0] b,

    output logic [width-1:0] f
);

always_comb begin : add
    f = a + b;
end
    
endmodule