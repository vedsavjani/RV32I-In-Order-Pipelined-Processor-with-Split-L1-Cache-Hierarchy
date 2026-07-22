# Test 4b: LRU eviction - fill 4 ways at same index, force 5th miss
# All addresses map to index 0 (bits [12:3] = 0), different tags
# 0x2000=tag1, 0x4000=tag2, 0x6000=tag3, 0x8000=tag4, 0xA000=tag5
# Expected: x7=0 (evicted, fetched from dcache_mem which has 0)
.text
main:
    lui  x1, 2
    lui  x2, 4
    lui  x3, 6
    lui  x4, 8
    lui  x5, 10
    addi x6, x0, 42
    sw   x6, 0(x1)
    sw   x6, 0(x2)
    sw   x6, 0(x3)
    sw   x6, 0(x4)
    sw   x6, 0(x5)
    lw   x7, 0(x1)
done:
    beq x0, x0, done