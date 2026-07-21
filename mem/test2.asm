.data
    .word 5
.text
main:
    lui  x1, 2
    lw   x2, 0(x1)
    addi x3, x2, 1
done:
    beq x0, x0, done