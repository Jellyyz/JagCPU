import rv32i_types::*;
module forwarder #(
    parameter width = 32
) (
    input clk,
    input rst, 

    input rv32i_reg ID_EX_rs1_i,
    input rv32i_reg ID_EX_rs2_i,
    input rv32i_reg EX_MEM_rd_i,
    input rv32i_reg MEM_WB_rd_i,
    input logic MEM_load_regfile_i,
    input logic WB_load_regfile_i,

    output forwardingmux::forwardingmux_sel_t forwardA_o,
    output forwardingmux::forwardingmux_sel_t forwardB_o
);

forwardingmux::forwardingmux_sel_t forwardA;
forwardingmux::forwardingmux_sel_t forwardB;
logic data_hazardA, data_hazardB;
logic mem_hazardA, mem_hazardB;

always_comb begin : set_output
    forwardA_o = forwardA;
    forwardB_o = forwardB;
end
    
always_comb begin : forwardingA
    data_hazardA = MEM_load_regfile_i & |EX_MEM_rd_i 
                    & (EX_MEM_rd_i == ID_EX_rs1_i);
    mem_hazardA = WB_load_regfile_i & |MEM_WB_rd_i 
                    & (MEM_WB_rd_i == ID_EX_rs1_i) & ~data_hazardA;
    
    if (mem_hazardA) begin
        forwardA = forwardingmux::mem_wb;
    end else if (data_hazardA) begin
        forwardA = forwardingmux::ex_mem;
    end else begin
        forwardA = forwardingmux::id_ex;
    end
end

always_comb begin : forwardingB
    data_hazardB = MEM_load_regfile_i 
                    & |EX_MEM_rd_i 
                    & (EX_MEM_rd_i == ID_EX_rs2_i);
    mem_hazardB = WB_load_regfile_i 
                    & |MEM_WB_rd_i 
                    & (MEM_WB_rd_i == ID_EX_rs2_i) 
                    & ~data_hazardA;
    
    if (mem_hazardB) begin
        forwardB = forwardingmux::mem_wb;
    end else if (data_hazardB) begin
        forwardB = forwardingmux::ex_mem;
    end else begin
        forwardB = forwardingmux::id_ex;
    end
end


endmodule