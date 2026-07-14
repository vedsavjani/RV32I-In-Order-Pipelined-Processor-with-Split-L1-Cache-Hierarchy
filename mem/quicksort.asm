# RARS settings -> memory configurations -> text at address 0 

.data
arr:
        .word   64
        .word   25
        .word   12
        .word   22
        .word   11
        .word   90
        .word   45
        .word   33
        .word   78
        .word   5

.globl main
.text
main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a2,9
        li      a1,0
        lui     a5,%hi(arr)
        addi    a0,a5,%lo(arr)
        call    quicksort
        li      a5,8192
        addi    a5,a5,100
        sw      a5,-24(s0)
        sw      zero,-20(s0)
        j       .L11
.L12:
        lw      a5,-20(s0)
        slli    a5,a5,2
        lw      a4,-24(s0)
        add     a5,a4,a5
        lui     a4,%hi(arr)
        addi    a3,a4,%lo(arr)
        lw      a4,-20(s0)
        slli    a4,a4,2
        add     a4,a3,a4
        lw      a4,0(a4)
        sw      a4,0(a5)
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L11:
        lw      a4,-20(s0)
        li      a5,9
        ble     a4,a5,.L12
        li      a5,0
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        j       halt
halt:
        j       halt

swap:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        sw      a1,-40(s0)
        lw      a5,-36(s0)
        lw      a5,0(a5)
        sw      a5,-20(s0)
        lw      a5,-40(s0)
        lw      a4,0(a5)
        lw      a5,-36(s0)
        sw      a4,0(a5)
        lw      a5,-40(s0)
        lw      a4,-20(s0)
        sw      a4,0(a5)
        nop
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra

partition:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        sw      a1,-40(s0)
        sw      a2,-44(s0)
        lw      a5,-44(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a5,a4,a5
        lw      a5,0(a5)
        sw      a5,-28(s0)
        lw      a5,-40(s0)
        addi    a5,a5,-1
        sw      a5,-20(s0)
        lw      a5,-40(s0)
        sw      a5,-24(s0)
        j       .L3
.L5:
        lw      a5,-24(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a5,a4,a5
        lw      a5,0(a5)
        lw      a4,-28(s0)
        blt     a4,a5,.L4
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
        lw      a5,-20(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a3,a4,a5
        lw      a5,-24(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a5,a4,a5
        mv      a1,a5
        mv      a0,a3
        call    swap
.L4:
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L3:
        lw      a4,-24(s0)
        lw      a5,-44(s0)
        blt     a4,a5,.L5
        lw      a5,-20(s0)
        addi    a5,a5,1
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a3,a4,a5
        lw      a5,-44(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a5,a4,a5
        mv      a1,a5
        mv      a0,a3
        call    swap
        lw      a5,-20(s0)
        addi    a5,a5,1
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra

quicksort:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        sw      a1,-40(s0)
        sw      a2,-44(s0)
        lw      a4,-40(s0)
        lw      a5,-44(s0)
        bge     a4,a5,.L9
        lw      a2,-44(s0)
        lw      a1,-40(s0)
        lw      a0,-36(s0)
        call    partition
        sw      a0,-20(s0)
        lw      a5,-20(s0)
        addi    a5,a5,-1
        mv      a2,a5
        lw      a1,-40(s0)
        lw      a0,-36(s0)
        call    quicksort
        lw      a5,-20(s0)
        addi    a5,a5,1
        lw      a2,-44(s0)
        mv      a1,a5
        lw      a0,-36(s0)
        call    quicksort
.L9:
        nop
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra