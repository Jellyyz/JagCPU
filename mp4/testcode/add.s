
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
    beq x5, x5, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    andi x4, x4, 3
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

HALT:
    beq x0, x0, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop

DONEa:
pcrel_GOOD: auipc x16, %pcrel_hi(GOOD)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lw x1, %pcrel_lo(pcrel_GOOD)(x16)
DONEb:
    beq x0, x0, DONEb
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
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD
BYTES:  .word 0x04030201
HALF:   .word 0x0020FFFF

