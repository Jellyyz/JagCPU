package pcmux;
typedef enum bit [1:0] {
    pc_plus4  = 2'b00
    ,alu_out  = 2'b01
    ,alu_mod2 = 2'b10
    ,br_pred_add_out = 2'b11
} pcmux_sel_t;
endpackage

package marmux;
typedef enum bit {
    pc_out = 1'b0
    ,alu_out = 1'b1
} marmux_sel_t;
endpackage

package cmpmux;
typedef enum bit {
    rs2_out = 1'b0
    ,i_imm = 1'b1
} cmpmux_sel_t;
endpackage

package alumux;
typedef enum bit {
    rs1_out = 1'b0
    ,pc_out = 1'b1
} alumux1_sel_t;

typedef enum bit [2:0] {
    i_imm    = 3'b000
    ,u_imm   = 3'b001
    ,b_imm   = 3'b010
    ,s_imm   = 3'b011
    ,j_imm   = 3'b100
    ,rs2_out = 3'b101
} alumux2_sel_t;
endpackage

package regfilemux;
typedef enum bit [3:0] {
    alu_out   = 4'b0000
    ,br_en    = 4'b0001
    ,u_imm    = 4'b0010
    ,lw       = 4'b0011
    ,pc_plus4 = 4'b0100
    ,lb        = 4'b0101
    ,lbu       = 4'b0110  // unsigned byte
    ,lh        = 4'b0111
    ,lhu       = 4'b1000  // unsigned halfword
} regfilemux_sel_t;
endpackage 

package forwardingmux;
typedef enum bit [2:0] {
    id_ex           = 3'b000 // ALU operand comes from the register file
    ,ex_mem         = 3'b010 // ALU operand forwarded from prior ALU result
    ,mem_wb         = 3'b001 // ALU operand forwarded from data memory or earlier ALU result
    ,u_imm_ex_mem   = 3'b110 // handle forwarding when ALU unused
    ,u_imm_mem_wb   = 3'b101 // handle forwarding when ALU unused
    ,br_en_ex_mem   = 3'b011 // handle forwarding when ALU unused
    ,br_en_mem_wb   = 3'b111 // handle forwarding when ALU unused
} forwardingmux1_sel_t;
endpackage 

package forwardingmux2; 
typedef enum bit {
    mem         = 1'b0 
    ,wb         = 1'b1
} forwardingmux2_sel_t;
endpackage

package forwardingmux3; 
typedef enum bit [2:0] {
    // id          = 2'b00
    // ,ex         = 2'b01 
    // ,mem_ld     = 2'b10   
    // ,mem_alu    = 2'b11
    id          = 3'b000
    ,ex         = 3'b001 
    ,mem_ld     = 3'b010   
    ,mem_alu    = 3'b011
    ,wb_ld      = 3'b100
    ,wb_alu     = 3'b110
} forwardingmux3_sel_t;
endpackage 

package forwardingmux4; 
typedef enum bit [2:0] {
    id          = 3'b000
    ,ex         = 3'b001 
    ,mem_ld     = 3'b010   
    ,mem_alu    = 3'b011
    ,wb_ld      = 3'b100
    ,wb_alu     = 3'b110
} forwardingmux4_sel_t;
endpackage 

package controlmux;
typedef enum bit {
    zero = 1'b0
    ,norm = 1'b1 // no stall, execute as normal
} controlmux_sel_t;
endpackage

