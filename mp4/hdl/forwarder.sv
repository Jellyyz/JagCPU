
module forwarder
import rv32i_types::*; 
#(parameter width = 32) 
(
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
    data_hazardA = MEM_load_regfile_i 
                    // & |EX_MEM_rd_i 
                    & (EX_MEM_rd_i == ID_EX_rs1_i);
    mem_hazardA = WB_load_regfile_i 
                    // & |MEM_WB_rd_i 
                    & (MEM_WB_rd_i == ID_EX_rs1_i) 
                    & ~data_hazardA;
    
    // if (data_hazardA) begin
    //     forwardA = forwardingmux::ex_mem;
    // end else if (mem_hazardA) begin
    //     forwardA = forwardingmux::mem_wb;
    // end else begin
    //     forwardA = forwardingmux::id_ex;
    // end

    unique case ({mem_hazardA, data_hazardA})
        2'b10           : forwardA = forwardingmux::mem_wb;
        2'b01, 2'b11    : forwardA = forwardingmux::ex_mem;
        2'b00           : forwardA = forwardingmux::id_ex;
        default         : begin
            forwardA = forwardingmux::id_ex;
            $display("Error on forwardmux_sel A @:", $time); 
        end
    endcase
end

always_comb begin : forwardingB
    data_hazardB = MEM_load_regfile_i 
                    // & |EX_MEM_rd_i 
                    & (EX_MEM_rd_i == ID_EX_rs2_i);
    mem_hazardB = WB_load_regfile_i 
                    // & |MEM_WB_rd_i 
                    & (MEM_WB_rd_i == ID_EX_rs2_i) 
                    & ~data_hazardB;
    
    // if (data_hazardB) begin
    //     forwardB = forwardingmux::ex_mem;
    // end else if (mem_hazardB) begin
    //     forwardB = forwardingmux::mem_wb;
    // end else begin
    //     forwardB = forwardingmux::id_ex;
    // end

    unique case ({mem_hazardB, data_hazardB})
        2'b10           : forwardB = forwardingmux::mem_wb;
        2'b01, 2'b11    : forwardB = forwardingmux::ex_mem;
        2'b00           : forwardB = forwardingmux::id_ex;
        default         : begin
            forwardB = forwardingmux::id_ex;
            $display("Error on forwardmux_sel B @:", $time); 
        end
    endcase

end


endmodule