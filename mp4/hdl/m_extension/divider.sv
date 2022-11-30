module divider #(parameter WIDTH = 31)(

    input logic clk, rst,
    input logic [WIDTH:0] dividend, divisor, 
    input logic div_cpy_trigger, 
    input logic shift_en, 

    output logic subtract_trigger, 
    output logic [WIDTH:0] q, r

); 

    logic subtract_flag; 
    logic [WIDTH+1:0] accumulator;
    logic [WIDTH:0] dividend_cpy;  

    logic [WIDTH:0] quotient_reg; 
    logic [WIDTH+WIDTH+WIDTH+1:0] testing; 

    
always_comb begin 
    // defualts 
    q = quotient_reg; 
    r = accumulator[WIDTH:0]; 
    subtract_trigger = 1'b0; 
    testing = {accumulator, dividend_cpy, quotient_reg}; 
    if(accumulator >= {1'b0, divisor})begin 
        subtract_trigger = 1'b1; 
    end
end 
always_comb begin 
    if(accumulator >= {1'b0, divisor})begin 
        subtract_flag = 1'b1; 
    end 
    else begin 
        subtract_flag = 1'b0; 
    end 
end 
always_ff @(posedge clk or posedge rst)begin 

    // rst & triggers 
    if(div_cpy_trigger || rst)begin 
        dividend_cpy <= dividend; 
        quotient_reg <= '0; 
        accumulator <= '0; 
    end 

    else begin 
        if(shift_en)begin 
            {accumulator, dividend_cpy} <= {accumulator, dividend_cpy} << 1; 
            quotient_reg <= quotient_reg << 1; 
        end             
        else if(subtract_trigger)begin 
            accumulator <= accumulator - divisor; 
            quotient_reg[0] <= 1'b1; 
        end 
        
    end

end 
endmodule 