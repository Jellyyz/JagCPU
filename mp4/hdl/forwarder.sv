
module forwarder
import rv32i_types::*; 
#(parameter width = 32) 
(
    input rv32i_reg ID_EX_rs1_i,
    input rv32i_reg ID_EX_rs2_i,
    input rv32i_reg EX_MEM_rs2_i,
    input rv32i_reg EX_MEM_rd_i,
    input rv32i_reg MEM_WB_rd_i,
    input logic MEM_load_regfile_i,
    input logic WB_load_regfile_i,

    input rv32i_control_word EX_MEM_ctrl_word_i, MEM_WB_ctrl_word_i, 

    input controlmux::controlmux_sel_t ID_HD_controlmux_sel_i,

    input rv32i_reg MEM_WB_data_mem_rdata,
    input rv32i_reg EX_MEM_rs2_out,

    output forwardingmux::forwardingmux1_sel_t forwardA_o,
    output forwardingmux::forwardingmux1_sel_t forwardB_o,
    output forwardingmux2::forwardingmux2_sel_t forwardC_o
);

forwardingmux::forwardingmux1_sel_t forwardA;
forwardingmux::forwardingmux1_sel_t forwardB;
forwardingmux2::forwardingmux2_sel_t forwardC;
logic data_hazardA, data_hazardB;
logic mem_hazardA, mem_hazardB;
logic load_hazard; 
always_comb begin : set_output
    forwardA_o = forwardA;
    forwardB_o = forwardB;
    forwardC_o = forwardC;
end
    
always_comb begin : forwardingA
    data_hazardA = MEM_load_regfile_i 
                    & |EX_MEM_rd_i 
                    & |ID_EX_rs1_i 
                    & (EX_MEM_rd_i == ID_EX_rs1_i);
                    // & (ID_HD_controlmux_sel_i != controlmux::zero);
    mem_hazardA = WB_load_regfile_i 
                    & |MEM_WB_rd_i 
                    & |ID_EX_rs1_i
                    & (MEM_WB_rd_i == ID_EX_rs1_i) 
                    // & (ID_HD_controlmux_sel_i != controlmux::zero)
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
                    & |EX_MEM_rd_i 
                    & |ID_EX_rs2_i
                    & (EX_MEM_rd_i == ID_EX_rs2_i);
                    // & (ID_HD_controlmux_sel_i != controlmux::zero);
    mem_hazardB = WB_load_regfile_i 
                    & |MEM_WB_rd_i 
                    & |ID_EX_rs2_i
                    & (MEM_WB_rd_i == ID_EX_rs2_i) 
                    // & (ID_HD_controlmux_sel_i != controlmux::zero)
                    & ~data_hazardB;

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

always_comb begin : forwardingC // WB -> MEM

    load_hazard = (MEM_WB_rd_i == EX_MEM_rs2_i) 
                   & (EX_MEM_ctrl_word_i.opcode == op_store) 
                   & (MEM_WB_ctrl_word_i.opcode == op_load);

     unique case (load_hazard)
        1'b0            : forwardC = forwardingmux2::mem;
        1'b1            : forwardC = forwardingmux2::wb;
        default         : begin 
            $display("Error on forwardmux_sel C @:", $time); 
        end 
     endcase
end 

endmodule