
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
    nop
    nop
    lw x4, ONE      # 1
    lw x4, BYTES    # 04030201
    add x2, x4, x1  # 04030202 = 04030201 + 1
    add x3, x2, x1  # 04030203 = 04030202 + 1
    add x4, x1, x1  # 2 = 1 + 1
    add x2, x2, x1  # 04030203 = 04030202 + 1`
    add x3, x2, x4  # 04030205 = 04030203 + 2 
    add x5, x1, x4 # 3 = 1 + 2
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
