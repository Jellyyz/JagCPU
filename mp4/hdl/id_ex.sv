module id_ex #(parameter width = 32)
(
    input clk,
    input rst,
    input logic flush_i,
    input logic load_i,
    input logic [width-1:0] pc_out_i,
    input logic [width-1:0] reg_a_i,
    input logic [width-1:0] reg_b_i,
    input logic [width-1:0] imm_i,

    output logic [width-1:0] pc_out_o,
    output logic [width-1:0] reg_a_o,
    output logic [width-1:0] reg_b_o,
    output logic [width-1:0] imm_o,
);

logic [width-1:0] pc_out;
logic [width-1:0] reg_a;
logic [width-1:0] reg_b;
logic [width-1:0] imm;


always_ff @(posedge clk) begin
    if (rst) begin
        pc_out <= {width{1'b0}};
        reg_a <= {width{1'b0}};
        reg_b <= {width{1'b0}};
        imm <= {width{1'b0}};
    end else if (flush_i) begin
        pc_out <= {width{1'b0}};
        reg_a <= {width{1'b0}};
        reg_b <= {width{1'b0}};
        imm <= {width{1'b0}};
    end else if (load_i) begin
        pc_out <= pc_out_i;
        reg_a <= reg_a_i;
        reg_b <= reg_b_i;
        imm <= imm_i;
    end else begin // practically, load is fixed high, so this will never execute
        pc_out <= pc_out;
        reg_a <= reg_a;
        reg_b <= reg_b;
        imm <= imm;
    end
end

always_comb begin
    pc_out_o = pc_out;
    reg_a_o = reg_a;
    reg_b_o = reg_b;
    imm_o = imm;
end

endmodule : id_ex 
