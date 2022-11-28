
module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

logic [2:0] burst_counter, burst_counter_next;

enum int unsigned { 
    idle, read, write, done
} state, next_state;

always_comb begin
    address_o = address_i;
    burst_o = line_i[64*burst_counter +: 64];
    line_o [64*burst_counter +: 64] = burst_i;

    unique case (state)
        idle: begin
            read_o = 1'b0;
            write_o = 1'b0;
            resp_o = 1'b0;
        end

        read: begin
            read_o = 1'b1;
            write_o = 1'b0;
            resp_o = 1'b0;
        end
        
        write: begin
            read_o = 1'b0;
            write_o = 1'b1;
            resp_o = 1'b0;
        end

        done: begin 
            read_o = 1'b0; 
            write_o = 1'b0;
            resp_o = 1'b1; 
        end
    endcase
end

always_comb begin
    unique case (state)
        idle: begin
            if (read_i) begin 
                next_state = read; 
                burst_counter_next = 3'b000; 
            end

            else if (write_i) begin 
                next_state = write; 
                burst_counter_next = 3'b000; 

            end

            else begin 
                next_state = idle; 
                burst_counter_next = 3'b000; 
            end
        end

        read: begin 
            if (burst_counter == 3'b011) begin 
                burst_counter_next = 3'b100; 
                next_state = done; 
            end

            else begin
                burst_counter_next = 3'b000;
                next_state = read;
            end 
            
            if (resp_i) begin
                burst_counter_next = burst_counter + 1'b1;
            end
        end

        write: begin 
            if (burst_counter == 3'b011) begin 
                burst_counter_next = 3'b100; 
                next_state = done; 
            end

            else begin
                burst_counter_next = 3'b000;
                next_state = write;
            end 
            
            if (resp_i) begin 
                burst_counter_next = burst_counter + 1'b1;
            end
        end

        done: begin 
            burst_counter_next = 3'b000; 
            next_state = idle; 
        end
    endcase
end


always_ff @(posedge clk) begin
    if(~reset_n) begin 
        state <= idle; 
        burst_counter <= 3'b000; 
    end
    else begin 
        state <= next_state; 
        burst_counter <= burst_counter_next; 
    end
end
endmodule : cacheline_adaptor