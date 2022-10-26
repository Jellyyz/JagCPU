
module control_rom
import rv32i_types::*;
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
    ctrl.alumux2_sel = alumux::i_imm;
    ctrl.regfilemux_sel = regfilemux::alu_out;
    ctrl.cmpmux_sel = cmpmux::rs2_out; 

    ctrl.marmux_sel = marmux::pc_out; 
    ctrl.aluop = alu_add;
    ctrl.cmpop = beq;

    ctrl.mem_byte_en = 4'b1111;
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
            ctrl.alumux2_sel = alumux::j_imm;
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
            ctrl.alumux2_sel = alumux::b_imm;
            ctrl.aluop = alu_add;
        end
        op_load: begin
            ctrl.marmux_sel = marmux::alu_out; // @TODO
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::i_imm;
            ctrl.aluop = alu_add;
            ctrl.load_regfile = 1'b1;
            ctrl.mem_read = 1'b1;
            unique case (load_funct3)
                lb  :  ctrl.regfilemux_sel = regfilemux::lb;
                lbu : ctrl.regfilemux_sel = regfilemux::lbu;
                lh  :  ctrl.regfilemux_sel = regfilemux::lh;
                lhu : ctrl.regfilemux_sel = regfilemux::lhu;
                lw  :  ctrl.regfilemux_sel = regfilemux::lw;
            endcase
        end
        op_store: begin
            ctrl.marmux_sel = marmux::alu_out; // @TODO
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::s_imm;
            ctrl.aluop = alu_add;
            ctrl.mem_write = 1'b1;
            unique case (store_funct3)
                sb : ctrl.mem_byte_en = 4'b0001;// << mem_addr_byte_sel[1:0];
                sh : ctrl.mem_byte_en = 4'b0011;// << mem_addr_byte_sel[1:0];
                sw : ctrl.mem_byte_en = 4'b1111;// << mem_addr_byte_sel[1:0];
                default : ;
            endcase
        end
        op_imm: begin
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::i_imm;
            ctrl.load_regfile = 1'b1;
            unique case (arith_funct3)
                sr: begin
                    ctrl.regfilemux_sel = regfilemux::alu_out;
                    unique case (funct7[5])
                        1'b0: ctrl.aluop = alu_srl;
                        1'b1: ctrl.aluop = alu_sra;
                    endcase
                end
                slt: begin
                    ctrl.cmpmux_sel = cmpmux::i_imm;
                    ctrl.cmpop = blt;
                    ctrl.regfilemux_sel = regfilemux::br_en;
                end
                sltu: begin
                    ctrl.cmpmux_sel = cmpmux:: i_imm;
                    ctrl.cmpop = bltu;
                    ctrl.regfilemux_sel = regfilemux::br_en;
                end
                default: begin
                    ctrl.aluop = alu_ops'(funct3);
                    ctrl.regfilemux_sel = regfilemux::alu_out;
                end
            endcase
        end
        op_reg: begin
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::rs2_out;
            ctrl.load_regfile = 1'b1;
            unique case (arith_funct3)
                sr: begin
                    ctrl.regfilemux_sel = regfilemux::alu_out;
                    unique case (funct7[5])
                        1'b0: ctrl.aluop = alu_srl;
                        1'b1: ctrl.aluop = alu_sra;
                    endcase
                end
                slt: begin
                    ctrl.cmpmux_sel = cmpmux::rs2_out;
                    ctrl.cmpop = blt;
                    ctrl.regfilemux_sel = regfilemux::br_en;
                end
                sltu: begin
                    ctrl.cmpmux_sel = cmpmux::rs2_out;
                    ctrl.cmpop = bltu;
                    ctrl.regfilemux_sel = regfilemux::br_en;
                end
                default: begin
                    ctrl.aluop = alu_ops'(funct3);
                    ctrl.regfilemux_sel = regfilemux::alu_out;
                end
            endcase
        end
        default: ;
    endcase
end
endmodule : control_rom