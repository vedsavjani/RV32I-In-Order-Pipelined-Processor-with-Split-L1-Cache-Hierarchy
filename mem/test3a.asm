# Test 3a: SW miss -> write-allocate -> LW hit
# Checks: store miss correctly allocates block with din spliced in
# Expected: x3 = 42
.text
main:
    lui  x1, 2
    addi x2, x0, 42
    sw   x2, 0(x1)
    lw   x3, 0(x1)
done:
    beq x0, x0, done