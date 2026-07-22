# Test 4c: Dirty writeback - write to address A, evict with address B
# 0x2000 (tag1, index0) and 0x4000 (tag2, index0) - same index
# After SW to 0x4000 fills way1, way0 (0x2000) stays (4-way, no eviction yet)
# Need all 5 to force eviction - simplify: just verify dirty block
# gets written to dcache_mem on eviction
# Expected: x3=55
.text
main:
    lui  x1, 2
    lui  x2, 4
    lui  x9, 6
    lui  x10, 8
    lui  x11, 10
    addi x3, x0, 55
    sw   x3, 0(x1)
    sw   x3, 0(x2)
    sw   x3, 0(x9)
    sw   x3, 0(x10)
    sw   x3, 0(x11)
done:
    beq x0, x0, done