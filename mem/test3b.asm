# Test 3b: LW from preloaded data + dependent ADDI
# Checks: load-use hazard correctly handled during icache stall
# Preload 7 into dcache_mem at offset 0x2000>>3
# Expected: x3 = 7, x4 = 8
.text
main:
    lui  x1, 2
    lw   x3, 0(x1)
    addi x4, x3, 1
done:
    beq x0, x0, done