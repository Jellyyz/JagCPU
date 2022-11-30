module stride_prefetching(
    input logic clk, rst, 
    input logic MEM_ctrl_word_i, 
    input logic [31:0] load_mem_address, 
    
    output logic [31:0] stride_diff  
 
); 

logic load_counter; 
logic [31:0] prev_instr_address; 
logic [31:0] curr_instr_address; 

logic load_instr; 

assign load_instr = (MEM_ctrl_word_i.opcode == op_load); 

always_comb begin 
    // calculate the differences between the two addresses
    if(~load_counter) begin 
        stride_diff = prev_instr_address - curr_instr_address; 
    end 
    else begin 
        stride_diff = curr_instr_address - prev_instr_address; 
    end 

    if(load_instr)begin 
        for (int i=0; i<32; i=i+1) begin
            address_map[i] <= '0;
            address_map_valid[i] <= '0; 
            address_map_counter <= '0; 
        end
    end 
end 
// Allows for the system to remember the previous address in order to calculate striding. 
always_ff @ (posedge clk or posedge rst)begin 
    if(rst)begin 
        prev_instr_address <= '0; 
        curr_instr_address <= '0; 
    end 
    else begin 
        if(load_instr)begin
            if(~load_counter)begin 
                prev_instr_address <= load_mem_address; 
            end 
            else begin 
                curr_instr_address <= load_mem_address; 
            end 
        end 
    end 
end 

// Switches the load counter between 0 and 1 in order to figure out which one we should subtract from which 
always_ff @ (posedge clk or posedge rst)begin 
    if(rst)begin 
        load_counter <= '0; 
    end
    else begin 
        if(load_instr) begin 
            load_counter <= load_counter + 1'b1; 
        end 
    end 
end 


// prefetching valid table for i cache miss 
logic [31:0] address_map [31]; 
logic [4:0] address_map_counter; 
logic [31:0] address_map_valid [31]; 
always_ff @ (posedge clk or posedge rst)begin : ADDRESS_MAP 

    if(rst)begin 
        for (int i=0; i<32; i=i+1) begin
            address_map[i] <= '0;
            address_map_valid[i] <= '0; 
            address_map_counter <= '0; 

        end
    end 
    else begin 
        if(load_instr)begin 
            address_map[address_map_counter] <= load_mem_address;
            address_map_valid[address_map_counter] <= 1'b1;
            address_map_counter <= address_map_counter + 1'b1; 
        end 
    end 


end 
endmodule 

