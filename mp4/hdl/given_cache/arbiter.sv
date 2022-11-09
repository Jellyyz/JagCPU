
module arbiter
import rv32i_types::*;
(
    input clk,
    input rst,

    input  logic instr_mem_write,
    input  logic instr_mem_read,
    input  logic [31:0] instr_mem_address,
    input  logic [255:0] instr_mem_wdata,
    output logic [255:0] instr_mem_rdata,
    output logic instr_mem_resp,

    input  logic data_mem_write,
    input  logic data_mem_read,
    input  logic [31:0] data_mem_address,
    input  logic [255:0] data_mem_wdata,
    output logic [255:0] data_mem_rdata,
    output logic data_mem_resp,

    input  logic main_pmem_resp,
    input  logic [255:0] main_pmem_rdata,
    output logic main_pmem_read,
    output logic main_pmem_write,
    output logic [31:0] main_pmem_address,
    output logic [255:00] main_pmem_wdata
);

logic i_request, d_request;
assign i_request = instr_mem_write || instr_mem_read;
assign d_request = data_mem_write || data_mem_read;

enum int unsigned {
    idle, instruction_access, data_access
} state, next_states;

function void set_defaults();
    instr_mem_resp = 1'b0;
    data_mem_resp = 1'b0;

    instr_mem_rdata = 256'b0;
    data_mem_rdata = 256'b0;
    main_pmem_wdata = 256'b0;

    main_pmem_read = 1'b0;
    main_pmem_write = 1'b0;
    main_pmem_address = 32'b0;
endfunction


always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)
        idle: ;

        instruction_access: begin
            main_pmem_read = instr_mem_read;
            main_pmem_write = instr_mem_write;
            main_pmem_address = instr_mem_address;
            main_pmem_wdata = instr_mem_wdata;
            instr_mem_rdata = main_pmem_rdata;
            instr_mem_resp = main_pmem_resp;
        end

        data_access: begin
            main_pmem_read = data_mem_read;
            main_pmem_write = data_mem_write;
            main_pmem_address = data_mem_address;
            main_pmem_wdata = data_mem_wdata;
            data_mem_rdata = main_pmem_rdata;
            data_mem_resp = main_pmem_resp;
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
            if (main_pmem_resp && d_request) next_states = data_access;
            else if (main_pmem_resp) next_states = idle;
            else next_states = instruction_access;
        end

        data_access: begin
            if (main_pmem_resp && i_request) next_states = instruction_access;
            else if (main_pmem_resp) next_states = idle;
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