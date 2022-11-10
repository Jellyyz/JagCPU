
.align 4
.section .text
.globl _start
_start:
    lw x1, ONE
    lw x2, ONE
    add x2, x1, x1 
    bne x2, x1, LOOP1 
    lw x2, POG # won't happen

LOOP1:
    lw x5, FIVE
    lw x6, ONE 
    bne x5, x6, LOOP2 
    lw x3, POG # won't happen
LOOP2:
    lw x4, GOOD
    bne x1, x0, HALT
    lw x4, POG # won't happen




# LABEL:
#     nop
#     nop
#     nop
#     nop
#     nop
#     nop
#     beq x2, x10, HALT
#     #add x3, x2, x1
#     #add x4, x1, x1
#     #add x3, x2, x4
#     add x4, x3, x1
#     add x6, x3, x4
#     lw x20, POG
#     #la x7, TWO
#     #sw x6, 0(x7)
#     addi x10, x10, -1
#     beq x0, x0, LABEL

.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
THREE:  .word 0x00000003
LOOP:   .word 0x00000002
FIVE:  .word 0x00000005
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD
BYTES:  .word 0x04030201
HALF:   .word 0x0020FFFF
POG:    .word 0xDEADBEEF


HALT:
    beq x0, x0, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop
