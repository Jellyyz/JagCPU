#  mp4-cp2.s version 1.3
.align 4
.section .text
.globl _start
_start:

#   Your pipeline should be able to do hazard detection and forwarding.
#   Note that you should not stall or forward for dependencies on register x0 or when an
#   instruction does not use one of the source registers (such as rs2 for immediate instructions).

# Mispredict taken branch flushing tests
taken_branches:
    beq x0, x0, forward_br # taken always 1
    # lw x31, BTB 
    lw x7, BAD

backward_br:
    beq x0, x0, not_taken_branches # taken always 3
    # lw x30, BRB
    beq x0, x0, oof                    # Also, test back-to-back branches

forward_br:
    beq x0, x0, backward_br # taken always 2
    # lw x29, BRF
    lw x7, BAD

# Mispredict not-taken branch flushing tests
not_taken_branches: 
    add x1, x0, 1                      # Also, test branching on forwarded value :)
    # lw x28, BNT
    beq x0, x1, oof                    # Don't take
    # lw x23, BPR2
    beq x0, x0, backward_br_nt         # Take


forwarding_tests:
    # Forwarding x0 test
    add x3, x3, 1
    add x0, x1, 0
    add x2, x0, 0
    # lw x25, STA
    beq x2, x3, oof
    # lw x24, BPR2              

    # Forwarding sr2 imm test
    # x0 = 0
    # x1 = 1
    # x2 = 0
    # x3 = 1
    # x4 = 0
    add x2, x1, 0       
    add x3, x1, 2                      # 2 immediate makes sr2 bits point to x2
    add x4, x0, 3
    # lw x24, STB
    bne x3, x4, oof                    # Also, test branching on 2 forwarded values :)

    # MEM -> EX forwarding with stall
    lw x1, NOPE
    lw x1, A
    add x5, x1, x0                     # Necessary forwarding stall
    # lw x18, STC
    bne x5, x1, oof

    # WB -> MEM forwarding test
    add x3, x1, 1 #2
    la x8, TEST
    sw  x3, 0(x8)
    lw  x4, TEST

    bne x4, x3, oof

    #lw x22, STD
    #lw x21, BPR2
    #lw x20, STD
    #lw x19, BPR
    #lw x18, STF


    # Half word forwarding test
    lh  x2, FULL             # FULL = FFFFFFFF
    add x3, x0, -1
    # lw x21, STE
    bne x3, x2, oof

    # Cache miss control test
    add x4, x0, 3
    lw  x2, B                          # Cache miss
    add x3, x2, 1                      # Try to forward from cache miss load
    lw x20, STF
    bne x4, x3, oof

    # Forwarding contention test
    add x2, x0, 1
    add x2, x0, 2
    add x3, x2, 1
    lw x19, STG
    beq x3, x2, oof

    lw x7, GOOD

halt:
    beq x0, x0, halt
    lw x7, BAD

oof:
    lw x7, BAD
    lw x2, PAY_RESPECTS
    beq x0, x0, halt

backward_br_nt:
    beq x0, x1, oof                    # Don't take
    #lw x27, BPR
    beq x0, x0, forwarding_tests       # Take always
    # lw x26, BPR2



.section .rodata
.balign 256
DataSeg:
    nop
    nop
    nop
    nop
    nop
    nop
BAD:            .word 0x00BADBAD
PAY_RESPECTS:   .word 0xAAAAAAAA
BRB:            .word 0x12345678
BRF:            .word 0x32323232
BTB:            .word 0x98765432
BNT:            .word 0x50710390
BPR:            .word 0xDEADBEEF
BPR2:           .word 0x0C0FFEE0
STA:            .word 0xC0DC0DC0
STB:            .word 0x55555555
STC:            .word 0x44444444
STD:            .word 0x33333333
STE:            .word 0x22222222
STF:            .word 0x11111111
STG:            .word 0xDDDDDDDD
# cache line boundary - this cache line should never be loaded

A:      .word 0x00000001
GOOD:   .word 0x600D600D
NOPE:   .word 0x00BADBAD
TEST:   .word 0x00000000
FULL:   .word 0xFFFFFFFF
        nop
        nop
        nop
# cache line boundary

B:      .word 0x00000002
        nop
        nop
        nop
        nop
        nop
        nop
        nop
# cache line boundary

C:      .word 0x00000003
        nop
        nop
        nop
        nop
        nop
        nop
        nop
# cache line boundary

D:      .word 0x00000004
        nop
        nop
        nop
        nop
        nop
        nop
        nop
