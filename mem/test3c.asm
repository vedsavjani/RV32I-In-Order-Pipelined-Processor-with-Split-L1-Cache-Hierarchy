# Test 3c: SW miss -> write-allocate -> LW hit -> dependent ADDI
# Checks: all of 3a and 3b together
# Expected: x2=7, x3=7, x4=8
.text
main:
    lui  x1, 2
    addi x2, x0, 7
    sw   x2, 0(x1)
    lw   x3, 0(x1)
    addi x4, x3, 1
done:
    beq x0, x0, done