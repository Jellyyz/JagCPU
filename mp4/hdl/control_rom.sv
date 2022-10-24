import rv32i_types::*;

module control_rom
(
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output rv32i_control_word ctrl
);

branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;
arith_funct3_t arith_funct3;

assign arith_funct3 = arith_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);

function void set_defaults();
    ctrl.opcode = opcode;

    ctrl.mem_read = 1'b0;
    ctrl.mem_write = 1'b0;

    ctrl.load_regfile = 1'b0;

    ctrl.funct3 = funct3;
    ctrl.funct7 = funct7;

    ctrl.pcmux_sel = pcmux::pc_plus4;
    ctrl.alumux1_sel = alumux::rs1_out;
    ctrl.alumux2_sel = alumux::imm;
    ctrl.regfilemux_sel = regfilemux::alu_out;
    //Idk yet
    //ctrl.cmpmux_sel = 

    ctrl.aluop = alu_add;
    ctrl.cmpop = beq;
endfunction


always_comb
begin
    set_defaults();
    case(opcode)
        op_lui: begin
            ctrl.load_regfile = 1'b1;
            ctrl.regfilemux_sel = regfilemux::u_imm;
        end
        op_auipc: begin
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux::u_imm;
            ctrl.aluop = alu_add;
            ctrl.load_regfile = 1'b1;
            ctrl.regfilemux_sel = regfilemux::alu_out;
        end
        op_jal: begin
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = aliumux::j_imm;
            ctrl.aluop = alu_add;
            ctrl.load_regfile = 1'b1;
            ctrl.regfilemux_sel = regfilemux::pc_plus4;
        end
        op_jalr: begin
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::i_imm;
            ctrl.aluop = alu_add;
            ctrl.load_regfile = 1'b1;
            ctrl.regfilemux_sel = regfilemux::pc_plus4;
        end
        op_br: begin
            ctrl.cmpop = branch_funct3;
            ctrl.cmpmux_sel = cmpmux::rs2_out;
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = a;umux::b_imm;
            ctr.aluop = alu_add;
        end
        op_load: begin
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::i_imm;
            ctrl.aluop = alu_add;
            ctrl.load_regfile = 1'b1;
            ctrl.mem_read = 1'b1;
            unique case (load_funct3)
                lb:  ctrl.regfilemux_sel = regfilemux::lb;
                lbu: ctrl.regfilemux_sel = regfilemux::lbu;
                lh:  ctrl.regfilemux_sel = regfilemux::lh;
                lhu: ctrl.regfilemux_sel = regfilemux::lhu;
                lw:  ctrl.regfilemux_sel = regfilemux::lw;
            endcase
        end
        op_store: begin
        end
        op_imm: begin
        end
        op_reg: begin
        end
        default: ;
    endcase
end
endmodule : control_rom