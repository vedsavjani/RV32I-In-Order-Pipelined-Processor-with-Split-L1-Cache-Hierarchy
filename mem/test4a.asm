# Test 4a: Spatial locality - read word 2 of same cache block
# Checks: block offset correctly selects upper vs lower word
# SW writes to word 1 (0x2000), LW reads word 2 (0x2004) -> should be 0
# Expected: x3=42, x4=0
.text
main:
    lui  x1, 2
    addi x2, x0, 42
    sw   x2, 0(x1)
    lw   x3, 0(x1)
    lw   x4, 4(x1)
done:
    beq x0, x0, done