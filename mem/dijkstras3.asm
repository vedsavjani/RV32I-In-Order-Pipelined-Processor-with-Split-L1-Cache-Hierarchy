.data
graph:  .word 0, 4, 8
        .word 4, 0, 2
        .word 8, 2, 0
dist:   .word 0, 0, 0
visited: .word 0, 0, 0

.text
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16
        li      a0,0
        jal     ra,dijkstra
        li      a5,0
        mv      a0,a5
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
done:   j       done

min_dist_node:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,98304
        addi    a5,a5,1695
        sw      a5,-20(s0)
        li      a5,-1
        sw      a5,-24(s0)
        sw      zero,-28(s0)
        j       .L2
.L4:
        lui     a5,%hi(visited)
        addi    a4,a5,%lo(visited)
        lw      a5,-28(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a5,0(a5)
        bne     a5,zero,.L3
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-28(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a5,0(a5)
        lw      a4,-20(s0)
        ble     a4,a5,.L3
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-28(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a5,0(a5)
        sw      a5,-20(s0)
        lw      a5,-28(s0)
        sw      a5,-24(s0)
.L3:
        lw      a5,-28(s0)
        addi    a5,a5,1
        sw      a5,-28(s0)
.L2:
        lw      a4,-28(s0)
        li      a5,2
        ble     a4,a5,.L4
        lw      a5,-24(s0)
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jalr    x0,ra,0

dijkstra:
        addi    sp,sp,-64
        sw      ra,60(sp)
        sw      s0,56(sp)
        addi    s0,sp,64
        sw      a0,-52(s0)
        sw      zero,-20(s0)
        j       .L7
.L8:
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-20(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        li      a4,98304
        addi    a4,a4,1695
        sw      a4,0(a5)
        lui     a5,%hi(visited)
        addi    a4,a5,%lo(visited)
        lw      a5,-20(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        sw      zero,0(a5)
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L7:
        lw      a4,-20(s0)
        li      a5,2
        ble     a4,a5,.L8
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-52(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        sw      zero,0(a5)
        sw      zero,-24(s0)
        j       .L9
.L15:
        jal     ra,min_dist_node
        sw      a0,-32(s0)
        lw      a4,-32(s0)
        li      a5,-1
        beq     a4,a5,.L16
        lui     a5,%hi(visited)
        addi    a4,a5,%lo(visited)
        lw      a5,-32(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        li      a4,1
        sw      a4,0(a5)
        sw      zero,-28(s0)
        j       .L12
.L14:
        lui     a5,%hi(visited)
        addi    a4,a5,%lo(visited)
        lw      a5,-28(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a5,0(a5)
        bne     a5,zero,.L13
        lui     a5,%hi(graph)
        addi    a3,a5,%lo(graph)
        lw      a4,-32(s0)
        mv      a5,a4
        slli    a5,a5,1
        add     a5,a5,a4
        lw      a4,-28(s0)
        add     a5,a5,a4
        slli    a5,a5,2
        add     a5,a3,a5
        lw      a5,0(a5)
        beq     a5,zero,.L13
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-32(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a3,0(a5)
        lui     a5,%hi(graph)
        addi    a2,a5,%lo(graph)
        lw      a4,-32(s0)
        mv      a5,a4
        slli    a5,a5,1
        add     a5,a5,a4
        lw      a4,-28(s0)
        add     a5,a5,a4
        slli    a5,a5,2
        add     a5,a2,a5
        lw      a5,0(a5)
        add     a5,a3,a5
        sw      a5,-36(s0)
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-28(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a5,0(a5)
        lw      a4,-36(s0)
        bge     a4,a5,.L13
        lui     a5,%hi(dist)
        addi    a4,a5,%lo(dist)
        lw      a5,-28(s0)
        slli    a5,a5,2
        add     a5,a4,a5
        lw      a4,-36(s0)
        sw      a4,0(a5)
.L13:
        lw      a5,-28(s0)
        addi    a5,a5,1
        sw      a5,-28(s0)
.L12:
        lw      a4,-28(s0)
        li      a5,2
        ble     a4,a5,.L14
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L9:
        lw      a4,-24(s0)
        li      a5,2
        ble     a4,a5,.L15
        j       .L17
.L16:
        nop
.L17:
        nop
        lw      ra,60(sp)
        lw      s0,56(sp)
        addi    sp,sp,64
        jalr    x0,ra,0