module hazard_detector
import rv32i_types::*;
 #(
    parameter width = 32
) (
    /*******************************************************/
    /* InputsOutputs for Data Hazard Fwds*******************/
    /*******************************************************/
    input logic EX_mem_read_i,
    input rv32i_reg EX_rd_i,
    input rv32i_reg ID_rs1_i,
    input rv32i_reg ID_rs2_i,

    output controlmux::controlmux_sel_t ID_HD_controlmux_sel_o,
    output logic IF_HD_PC_write_o,
    output logic IF_ID_HD_write_o,

    output logic stall_br1_o,
    output logic stall_br2_o,

    /*******************************************************/
    /* InputsOutputs for branch Hazard Fwds****************/
    /*******************************************************/

    input logic MEM_mem_read_i,
    input rv32i_reg MEM_rd_i

    // ADD THIS IN WHEN MOVING CALC FOR TAKEN PREDICTION INTO FETCH
    // input logic ID_mem_read_i,
    // input rv32i_reg ID_rd_i,
    // input rv32i_reg IF_rs1_i,
    // input rv32i_reg IF_rs2_i,
);

// logic stall;
logic stall_br1, stall_br2;

// always_comb begin : hazard_detection
//     stall = EX_mem_read_i & ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i)) & |EX_rd_i;
//     if (stall) begin
//         ID_HD_controlmux_sel_o = controlmux::zero;
//         IF_HD_PC_write_o = 1'b0;
//         IF_ID_HD_write_o = 1'b0;
//     end else begin
//         ID_HD_controlmux_sel_o = controlmux::norm;
//         IF_HD_PC_write_o = 1'b1;
//         IF_ID_HD_write_o = 1'b1;
//     end
// end

always_comb begin : branch_hazard_detection
    stall_br1 = EX_mem_read_i & ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i)) & |EX_rd_i;
    stall_br2 = MEM_mem_read_i & ((MEM_rd_i == ID_rs1_i) | (MEM_rd_i == ID_rs2_i)) & |MEM_rd_i;

    if (stall_br1 | stall_br2) begin
        ID_HD_controlmux_sel_o = controlmux::zero;
        IF_HD_PC_write_o = 1'b0;
        IF_ID_HD_write_o = 1'b0;
    end else begin
        ID_HD_controlmux_sel_o = controlmux::norm;
        IF_HD_PC_write_o = 1'b1;
        IF_ID_HD_write_o = 1'b1;
    end

    stall_br1_o = stall_br1;
    stall_br2_o = stall_br2;
end

// ADD THIS IN WHEN MOVING CALC FOR TAKEN PREDICTION INTO FETCH
// always_comb begin : branch_hazard_detection_predicted_taken
//     stall_br1_IF = ID_mem_read_i & ((ID_rd_i == IF_rs1_i) | (ID_rd_i == IF_rs2_i)) & |ID_rd_i;
//     stall_br2_IF = EX_mem_read_i & ((EX_rd_i == IF_rs1_i) | (EX_rd_i == IF_rs2_i)) & |EX_rd_i;
//     stall_br2_IF = MEM_mem_read_i & ((MEM_rd_i == IF_rs1_i) | (MEM_rd_i == IF_rs2_i)) & |MEM_rd_i;

//     if (stall_br1_IF | stall_br1_IF) begin
//         ID_HD_controlmux_sel_o = controlmux::zero;
//         IF_HD_PC_write_o = 1'b0;
//         IF_ID_HD_write_o = 1'b0;
//     end else begin
//         ID_HD_controlmux_sel_o = controlmux::norm;
//         IF_HD_PC_write_o = 1'b1;
//         IF_ID_HD_write_o = 1'b1;
//     end

//     stall_brA_IF_o = stall_brA_IF;
//     stall_brB_IF_o = stall_brB_IF;
//     stall_brC_IF_o = stall_brC_IF;
// end
    
endmodule