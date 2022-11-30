module leapfrogging(
    input logic clk, rst, 
    input logic dcache_miss, 

); 
logic [4:0] LRU 
always_ff @(posedge clk or posedge rst)begin 

    if(rst)begin 

    end 



end 


// if opcode in mem stage is not reg_to_reg, then we should let it continue and finish committing
// if opcode in ex stage is a reg to reg then we should invole the stalling from leadfrogging
logic ex_op; 
assign ex_op = EX_MEM_ctrl_word_i.opcode;
logic ex_mem_instr;

always_comb begin 

    if(EX_MEM_ctrl_word_i.mem_read || EX_MEM_ctrl_word_i.mem_write)begin 
        ex_mem_instr = 1'b1; 
    end 

end 

ex_mem_instr = (ex_op == op_load || op_store || )

endmodule 

