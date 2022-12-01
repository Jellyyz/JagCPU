
module clockgate 
import rv32i_types::*;
(
    input clk, 
    input rv32i_control_word MEM_ctrl_word_i,

    output logic clockgate_out
);

always_comb begin : decide_clock_gate
    clockgate_out = 1'b0;
    if (op_load == MEM_ctrl_word_i.opcode) clockgate_out=1'b1;
    if (op_store == MEM_ctrl_word_i.opcode) clockgate_out=1'b1;
end

endmodule : clockgate