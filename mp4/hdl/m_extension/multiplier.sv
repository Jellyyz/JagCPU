module array_multiplier(

    input logic clk, rst,
    input logic [31:0] a, b, 
    output logic [63:0] ans


); 

logic [63:0] c;
logic [63:0] mult_accum [32];

always_ff @(posedge clk or posedge rst)begin 

    if(rst)begin
        ans <= 0; 
    end 
    else begin 
        ans <= c; 
    end 
end 

integer i; 
always_comb begin : BASIC_MULT_LOGIC    
    for(i = 0; i < 32; i++)begin
        
        if(b[i])
            mult_accum[i] <= a[31:0] << i;
        else 
            mult_accum[i] <= 32'b0 << i; 

    end 
end 


integer j; 
logic carry_over [32]; 
always_comb begin : ADD_ACCUM 

    c = mult_accum[0] +
        mult_accum[1] +
        mult_accum[2] +
        mult_accum[3] +
        mult_accum[4] +
        mult_accum[5] +
        mult_accum[6] +
        mult_accum[7] +
        mult_accum[8] +
        mult_accum[9] +
        mult_accum[10] +
        mult_accum[11] +
        mult_accum[12] +
        mult_accum[13] +
        mult_accum[14] +
        mult_accum[15] +
        mult_accum[16] +
        mult_accum[17] +
        mult_accum[18] +
        mult_accum[19] +
        mult_accum[20] +
        mult_accum[21] +
        mult_accum[22] +
        mult_accum[23] +
        mult_accum[24] +
        mult_accum[25] +
        mult_accum[26] +
        mult_accum[27] +
        mult_accum[28] +
        mult_accum[29] +
        mult_accum[30] +
        mult_accum[31]; 
end 


endmodule 

