module divider_control #(parameter WIDTH = 31)(

    input logic clk, rst, 
    input logic start,
    input logic subtract_trigger, 

    output logic shift_en,
    output logic done, 
    output logic div_cpy_trigger

); 


enum logic [7:0] {
    IDLE, 
    RST,
    SHIFTING, 
    SUBTRACT,
    HALT
    

}curr_state, next_state; 

logic [5:0] counter; 

always_ff @(posedge clk or posedge rst)begin : STATE_MACHINE
    if(rst)begin 
        curr_state <= RST; 
    end 
    else begin 
        curr_state <= next_state; 
    end 
end 
always_ff @(posedge clk or posedge rst)begin: COUNTER_LOGIC  
    if(rst)begin
        counter <= 6'd0; 
    end 
    else if(curr_state == SHIFTING && !subtract_trigger)begin 
        counter <= counter + 1'b1; 
    end
end 





always_comb begin: CONDITION_FOR_NEXT_STATE 
    next_state = curr_state; 
    unique case(curr_state)
        RST:begin
            next_state = IDLE; 
        end 
        IDLE:begin 
            if(start)begin 
                next_state = SHIFTING; 
            end 
        end 
        SHIFTING:begin 
            if(subtract_trigger)begin 
                next_state = SUBTRACT;
            end  
            else if(counter >= WIDTH)begin 
                next_state = HALT;
            end 
        end 
        SUBTRACT:begin 
            if(counter > WIDTH)begin 
                next_state = HALT; 
            end 
            else begin 
                next_state = SHIFTING; 
            end 
        end
        HALT:begin 
            if(subtract_trigger)begin 
                next_state = SUBTRACT;
            end 
        end 
    endcase 
    

end 

always_comb begin: CONTROL_SIGNAL
    
    // default signals 
    shift_en = 1'b0; 
    div_cpy_trigger = 1'b0; 
    done_en = 1'b0;

    unique case(curr_state)
        RST:begin 
            // reset all signals 
            div_cpy_trigger = 1'b1; 
        end 
        IDLE:begin  
            // wait for a start operation 
        end 
        SHIFTING:begin 
            if(!subtract_trigger)begin 
                shift_en = 1'b1; 
            end 
        end 
        SUBTRACT:begin 
            // placeholder 
        end 
        HALT:begin 
            done_en = 1'b1;// do nothing 
        end 
    endcase 
end 

logic [1:0] done_delay;
always_ff @(posedge clk or posedge rst)begin 
    if(rst || ~done_en)begin 
        done_delay <= '0; 
    end 
    else if(done_en)begin 
        done_delay <= done_delay + 1; 
    end 

end 

always_comb begin : CHECK_FOR_DONE
    done = (done_delay == 2'b11) ? 1 : 0;
end 

endmodule 


