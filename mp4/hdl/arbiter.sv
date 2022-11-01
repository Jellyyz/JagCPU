module arbiter
import rv32i_types::*;
(
    input clk,
    input rst,

    input  logic i_mem_write,
    input  logic i_mem_read,
    input  logic [31:0] i_mem_address,
    input  logic [255:0] i_mem_wdata,
    output logic [255:0] i_mem_rdata,
    output logic i_mem_resp,

    input  logic d_mem_write,
    input  logic d_mem_read,
    input  logic [31:0] d_mem_address,
    input  logic [255:0] d_mem_wdata,
    output logic [255:0] d_mem_rdata,
    output logic d_mem_resp,

    input  logic mem_resp,
    input  logic [255:0] mem_rdata,
    output logic mem_read,
    output logic mem_write,
    output logic [31:0] mem_address,
    output logic [255:00] mem_wdata
);

logic i_request, d_request;
assign i_request = i_mem_write || i_mem_read;
assign d_request = d_mem_write || d_mem_read;

enum int unsigned {
    idle, instruction_access, data_access
} state, next_states;

function void set_defaults();
    i_mem_resp = 1'b0;
    d_mem_resp = 1'b0;

    i_mem_rdata = 256'b0;
    d_mem_rdata = 256'b0;
    mem_wdata = 256'b0;

    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_address = 32'b0;
endfunction


always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)
        idle: ;

        instruction_access: begin
            mem_read = i_mem_read;
            mem_write = i_mem_write;
            mem_address = i_mem_address;
            mem_wdata = i_mem_wdata;
            i_mem_rdata = mem_rdata;
            i_mem_resp = mem_resp;
        end

        data_access: begin
            mem_read = d_mem_read;
            mem_write = d_mem_write;
            mem_address = d_mem_address;
            mem_wdata = d_mem_wdata;
            d_mem_rdata = mem_rdata;
            d_mem_resp = mem_resp;
        end
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */

    unique case (state)
        idle: begin
            if (i_request) next_states = instruction_access;
            else if (d_request) next_states = data_access;
            else next_states = idle;
        end

        instruction_access: begin
            if (mem_resp && d_request) next_states = data_access;
            else if (mem_resp) next_states = idle;
            else next_states = instruction_access;
        end

        data_access: begin
            if (mem_resp && i_request) next_states = instruction_access;
            else if (mem_resp) next_states = idle;
            else next_states = data_access;
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst)
        state <= idle;
    else state <= next_states;
end
endmodule: arbiter