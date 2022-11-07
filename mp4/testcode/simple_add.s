
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
    add x3, x2, x1 # 3 = 2 + 1
    add x4, x1, x1 # 2 = 1 + 1
    nop
    nop
    nop
    add x2, x2, x1 # 3 = 2 + 1
    nop
    nop
    add x3, x2, x4 # 5 = 3 + 2
    nop
    nop
    nop
    nop
    nop
    nop
    # add x4, x3, x1
    nop
    nop
    nop
    nop
    nop
    # addi x6, x6, 1
    nop
    nop
    nop
    nop
    nop

.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
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
