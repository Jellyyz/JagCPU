
.align 4
.section .text
.globl _start
_start:
pcrel_NEGTWO: auipc x10, %pcrel_hi(NEGTWO)
pcrel_TWO: auipc x11, %pcrel_hi(TWO)
pcrel_ONE: auipc x12, %pcrel_hi(ONE)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lw x2, %pcrel_lo(pcrel_TWO)(x11)
    lw x1, %pcrel_lo(pcrel_ONE)(x12)
    nop
    nop
    nop
    nop
    nop
    lw x4, ONE
    lw x3, THREE
    lw x2, CHEESE
    nop
    nop
    nop
    lw x4, BYTES
    add x2, x4, x1
    nop
    nop
    nop
    nop
    nop
    nop    
    nop    
    nop    
    nop    
    nop    
    nop
    nop
    nop
    nop
    nop

.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
THREE:  .word 0x00000003
CHEESE: .word 0xC8335E00
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD
BYTES:  .word 0x04030201
HALF:   .word 0x0020FFFF

HALT:
    beq x0, x0, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop
