
module IF_ID 
import rv32i_types::*;
#(parameter width = 32) 
(
        input clk,
        input rst,
        input logic flush_i,
        input logic load_i,
        input logic [width-1:0] IF_ID_pc_out_i,
        input logic [width-1:0] IF_ID_instr_i,

        output logic [width-1:0] IF_ID_pc_out_o,
        output logic [width-1:0] IF_ID_instr_o
    );

    logic [width-1:0] pc_out;
    logic [width-1:0] instr;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_out <= {width{1'b0}};
            instr <= {width{1'b0}};
        end else if (flush_i) begin
            pc_out <= {width{1'b0}};
            instr <= {width{1'b0}};
        end else if (load_i) begin
            pc_out <= IF_ID_pc_out_i;
            instr <= IF_ID_instr_i;
        end else begin // practically, load is fixed high, so this will never execute
            pc_out <= pc_out;
            instr <= instr;
        end
    end

    always_comb begin
        IF_ID_pc_out_o = pc_out;
        IF_ID_instr_o = instr;
    end

endmodule : IF_ID 
