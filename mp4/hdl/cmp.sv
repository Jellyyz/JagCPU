
//comparison module for branch instructions
module cmp
import rv32i_types::*;
(
    input branch_funct3_t cmpop,
    input rv32i_word rs1_out,
    input rv32i_word cmp_mux_out,
    output logic br_en
);

always_comb
begin
    unique case (cmpop)
        beq: br_en = rs1_out == cmp_mux_out;                   // check equality
        bne: br_en = rs1_out != cmp_mux_out;                   // check inequality
        blt: br_en = $signed(rs1_out) < $signed(cmp_mux_out);  // check signed less than
        bge: br_en = $signed(rs1_out) >= $signed(cmp_mux_out); // check signed greater-or-equal
        bltu: br_en = rs1_out < cmp_mux_out;                   // check unsigned less than
        bgeu: br_en = rs1_out >= cmp_mux_out;                  // check unsigned greater-or-equal
        default: br_en = 1'b0;                                 // default to br_en low
    endcase
end

endmodule : cmp
