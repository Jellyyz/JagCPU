
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

        input ctrl_flow_preds IF_ID_br_pred_i,

        output logic [width-1:0] IF_ID_pc_out_o,
        output logic [width-1:0] IF_ID_instr_o,
        output ctrl_flow_preds IF_ID_br_pred_o
    );

    logic [width-1:0] pc_out;
    logic [width-1:0] instr;
    ctrl_flow_preds br_pred;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_out <= {width{1'b0}};
            instr <= {width{1'b0}};
            br_pred <= '0;
        end else if (flush_i) begin
            pc_out <= {width{1'b0}};
            instr <= {width{1'b0}};
            br_pred <= '0;            // this is potentially a huge issue 
        end else if (load_i) begin
            pc_out <= IF_ID_pc_out_i;
            instr <= IF_ID_instr_i;
            br_pred <= IF_ID_br_pred_i;
        end else begin
            pc_out <= pc_out;
            instr <= instr;
            br_pred <= br_pred;
        end
    end

    always_comb begin
        IF_ID_pc_out_o = pc_out;
        IF_ID_instr_o = instr;
        IF_ID_br_pred_o = br_pred;
    end

endmodule : IF_ID 
