
module alu
import rv32i_types::*;
(
    input alu_ops aluop,
    input logic [6:0] funct7, 
    input [31:0] a, b,
    input logic start_div, 
    output logic done_div, 
    output logic [31:0] f
);

// temp logic variables 
logic [63:0] ans; //used for mult 

logic a_mod, b_mod; // choose between signed and unsigned, 1 is signed, 0 is unsigned (default)
logic a_in, b_in;   // inputs into the mult and div 
always_comb begin :SIGNEDvUNSIGNED
    a_in = a_mod ? $signed(a) : $unsigned(a); 
    b_in = b_mod ? $signed(b) : $unsigned(b); 
end 
always_comb begin
    // defaults to unsigned 
    a_mod = 1'b0; 
    b_mod = 1'b0; 
    unique case (aluop)
        if(funct7 == 7'b0000001)begin 
            alu_add: begin  
                f = ans[31:0];  // MUL
                a_mod = 1'b1; 
                b_mod = 1'b1; 
            end 
            alu_sll: begin  
                f = ans[63:32]; // MULH
                a_mod = 1'b1; 
                b_mod = 1'b1; 
            end 
            alu_sra: begin 
                f = ans[63:32]; // MULHSU
                a_mod = 1'b1; 
                b_mod = 1'b0;  
            end 
            alu_sub: begin 
                f = ans[63:32]; // MULHU
                a_mod = 1'b0; 
                b_mod = 1'b0; 
            end 
            alu_xor: begin 
                f = q; // DIV
                a_mod = 1'b1; 
                b_mod = 1'b1; 
            end 
            alu_srl: begin 
                f = q; // DIVU
                a_mod = 1'b0; 
                b_mod = 1'b0; 
            end 
            alu_or:  begin 
                f = r; // REM
                a_mod = 1'b1; 
                b_mod = 1'b1; 
            end 
            alu_and: begin 
                f = r; // REMU
                a_mod = 1'b0; 
                b_mod = 1'b0; 
            end 
        end 
        else begin 
            alu_add:  f = a + b;
            alu_sll:  f = a << b[4:0];
            alu_sra:  f = $signed(a) >>> b[4:0];
            alu_sub:  f = a - b;
            alu_xor:  f = a ^ b;
            alu_srl:  f = a >> b[4:0];
            alu_or:   f = a | b;
            alu_and:  f = a & b;
        end 
    endcase
end


array_multiplier m0(
    .clk(clk), .rst(rst),
    .a(a_in), .b(b_in),
    .ans(ans)

); 
logic [31:0] dividend, divisor; 


logic [31:0] q, r; 
// glue logic for dividing unit 
logic div_cpy_trigger, shift_en, subtract_trigger;

divider div0(

    .clk(clk), .rst(rst), 
    .dividend(a_in), .divisor(b_in), 
    .div_cpy_trigger(div_cpy_trigger), 
    .shift_en(shift_en),
    
    .subtract_trigger(subtract_trigger), 
    .q(q), .r(r) 

);


divider_control div_ctrl0(
    .clk(clk), .rst(rst),
    .start(start_div), .done(done_div),
    .subtract_trigger(subtract_trigger), 
    .shift_en(shift_en),
    .div_cpy_trigger(div_cpy_trigger) 

);
endmodule : alu
