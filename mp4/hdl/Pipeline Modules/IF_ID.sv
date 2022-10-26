import rv32i_types::*;

module IF_ID(
    input clk, rst, 
    input rv32i_word IF_ID_pc_in, IF_ID_pc_ld,
    input rv32i_word IF_ID_ir_in, IF_ID_ir_ld, 

    output rv32i_word IF_ID_pc_out, IF_ID_ir_out 
); 



always_ff @(posedge clk or posedge rst) begin 

    if(rst)begin 
        IF_ID_pc_out <= '0; 
        IF_ID_ir_out <= '0; 
    end 
    else begin 
        if(IF_ID_pc_ld)
            IF_ID_pc_out <= IF_ID_pc_in; 
        else 
            ; 
        if(IF_ID_ir_ld)
            IF_ID_ir_out <= IF_ID_ir_in; 
        else 
            ; 
    end 

end 

endmodule 
