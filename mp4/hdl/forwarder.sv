
module forwarder
import rv32i_types::*; 
#(parameter width = 32) 
(
    /*******************************************************/
    /* InputsOutputs for Data Hazard Fwds*******************/
    /*******************************************************/
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
    input rv32i_reg EX_MEM_rs2,

    output forwardingmux::forwardingmux1_sel_t forwardA_o,
    output forwardingmux::forwardingmux1_sel_t forwardB_o,
    output forwardingmux2::forwardingmux2_sel_t forwardC_o, 
    
    
    /*******************************************************/
    /* Inputs / Outputs for branch Hazard Fwds****************/
    /*******************************************************/

    input logic EX_load_regfile_i,
    // input logic MEM_load_regfile_i // already input for data hazard portion
    input rv32i_reg REGFILE_rs1_i,
    input rv32i_reg REGFILE_rs2_i,
    input rv32i_reg ID_EX_rd_i,
    // input rv32i_reg EX_MEM_rd_i, // already input for data hazard portion

    output forwardingmux3::forwardingmux3_sel_t forwardD_o,
    output forwardingmux4::forwardingmux4_sel_t forwardE_o
    
);

forwardingmux::forwardingmux1_sel_t forwardA;
forwardingmux::forwardingmux1_sel_t forwardB;
forwardingmux2::forwardingmux2_sel_t forwardC;
forwardingmux3::forwardingmux3_sel_t forwardD;
forwardingmux4::forwardingmux4_sel_t forwardE; 

logic data_hazardA, data_hazardB;
logic mem_hazardA, mem_hazardB;
logic control_hazard_EX_D, control_hazard_MEM_D, control_hazard_WB_D;
logic control_hazard_EX_E, control_hazard_MEM_E, control_hazard_WB_E;

logic load_hazard; 


always_comb begin : set_output
    forwardA_o = forwardA;
    forwardB_o = forwardB;
    forwardC_o = forwardC;
    forwardD_o = forwardD; 
    forwardE_o = forwardE; 
end
    
always_comb begin : forwardingA
    data_hazardA = MEM_load_regfile_i 
                    & |EX_MEM_rd_i 
                    & |ID_EX_rs1_i                  // is this good????
                    & (EX_MEM_rd_i == ID_EX_rs1_i);
                    // & (ID_HD_controlmux_sel_i != controlmux::zero);
    mem_hazardA = WB_load_regfile_i 
                    & |MEM_WB_rd_i 
                    & |ID_EX_rs1_i                  // is this good????
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
                    & |ID_EX_rs2_i                  // is this good????
                    & (EX_MEM_rd_i == ID_EX_rs2_i);
                    // & (ID_HD_controlmux_sel_i != controlmux::zero);
    mem_hazardB = WB_load_regfile_i 
                    & |MEM_WB_rd_i 
                    & |ID_EX_rs2_i                  // is this good????
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
// **********************************************************************************************************
// ************************** Divider between branch and data hazard ***************************************
// **********************************************************************************************************

always_comb begin : forwardingD // forwarding for branches to input 1 of adder in decode stage

    control_hazard_EX_D = EX_load_regfile_i
                            & |ID_EX_rd_i
                            & |REGFILE_rs1_i
                            & (REGFILE_rs1_i == ID_EX_rd_i); 

    control_hazard_MEM_D = MEM_load_regfile_i
                            & |EX_MEM_rd_i
                            & |REGFILE_rs1_i
                            & (REGFILE_rs1_i == EX_MEM_rd_i)
                            & ~control_hazard_EX_D;

    control_hazard_WB_D = WB_load_regfile_i
                            & |MEM_WB_rd_i
                            & |REGFILE_rs1_i
                            & (REGFILE_rs1_i == MEM_WB_rd_i)
                            & ~control_hazard_EX_D
                            & ~control_hazard_MEM_D;

    // if ex load regfile and 
    //  rs1 out of regfile == ID_EX_rd 
    // |rs1_out of regfile & |ID_EX_rd 
    
    // ex_mem_rd == rs1 out of regfile 
    // if load regfile mem 
    // | ex_mem_rd & | rs1 out of regfile 


    // unique case ({control_hazard_MEM_D, control_hazard_EX_D})
    //     2'b00           : forwardD = forwardingmux3::id;
    //     2'b01, 2'b11    : forwardD = forwardingmux3::ex;
    //     2'b10           : begin 
    //         if(EX_MEM_ctrl_word_i.opcode == op_load) 
    //             forwardD = forwardingmux3::mem_ld;
    //         // else if(EX_MEM_ctrl_word_i.opcode == op_alu)
    //         //     forwardD = forwardingmux3::mem_alu; 
    //         else 
    //             // $display("fck shit @", $time ); 
    //             forwardD = forwardingmux3::mem_alu; 
    //     end 
    //     default : forwardD = forwardingmux3::id;
    // endcase

    unique case ({control_hazard_WB_D, control_hazard_MEM_D, control_hazard_EX_D})
        3'b000                  : forwardD = forwardingmux3::id;
        3'b001, 3'b011, 3'b111  : forwardD = forwardingmux3::ex;
        3'b010, 3'b110          : begin
            if (EX_MEM_ctrl_word_i.opcode == op_load)
                forwardD = forwardingmux3::mem_ld;
            else
                forwardD = forwardingmux3::mem_alu;
        end
        3'b100                  : begin
            if (MEM_WB_ctrl_word_i.opcode == op_load)
                forwardD = forwardingmux3::wb_ld;
            else 
                forwardD = forwardingmux3::wb_alu;
        end
        default : forwardD = forwardingmux3::id;
    endcase
end

always_comb begin : forwardingE // forwarding for branches 
    
    control_hazard_EX_E = EX_load_regfile_i
                            & |ID_EX_rd_i
                            & |REGFILE_rs2_i
                            & (REGFILE_rs2_i == ID_EX_rd_i); 

    control_hazard_MEM_E = MEM_load_regfile_i
                            & |EX_MEM_rd_i
                            & |REGFILE_rs2_i
                            & (REGFILE_rs2_i == EX_MEM_rd_i)
                            & ~control_hazard_EX_E;

    control_hazard_WB_E = WB_load_regfile_i
                            & |MEM_WB_rd_i
                            & |REGFILE_rs2_i
                            & (REGFILE_rs2_i == MEM_WB_rd_i)
                            & ~control_hazard_EX_E
                            & ~control_hazard_MEM_E;
    // if ex load regfile and 
    //  rs1 out of regfile == ID_EX_rd 
    // |rs1_out of regfile & |ID_EX_rd 
    
    // ex_mem_rd == rs1 out of regfile 
    // if load regfile mem 
    // | ex_mem_rd & | rs1 out of regfile 
    
    
    // unique case ({control_hazard_MEM_E, control_hazard_EX_E})
    //     2'b00           : forwardE = forwardingmux4::id;
    //     2'b01, 2'b11    : forwardE = forwardingmux4::ex;
    //     2'b10           : begin
    //         if (EX_MEM_ctrl_word_i.opcode == op_load)
    //             forwardE = forwardingmux4::mem_ld;
    //         // else if (EX_MEM_ctrl_word_i.opcode == op_alu)
    //         //     forwardE = forwardingmux4::mem_alu;
    //         else begin
    //             // $display("forwardE mega broken")
    //             forwardE = forwardingmux4::mem_alu;
    //         end
    //     end
    //     default : forwardE = forwardingmux4::id;
    // endcase

    unique case ({control_hazard_WB_E, control_hazard_MEM_E, control_hazard_EX_E})
        3'b000                  : forwardE = forwardingmux4::id;
        3'b001, 3'b011, 3'b111  : forwardE = forwardingmux4::ex;
        3'b010, 3'b110          : begin
            if (EX_MEM_ctrl_word_i.opcode == op_load)
                forwardE = forwardingmux4::mem_ld;
            else
                forwardE = forwardingmux4::mem_alu;
        end
        3'b100                  : begin
            if (MEM_WB_ctrl_word_i.opcode == op_load)
                forwardE = forwardingmux4::wb_ld;
            else 
                forwardE = forwardingmux4::wb_alu;
        end
        default : forwardE = forwardingmux4::id;
    endcase
end 

endmodule