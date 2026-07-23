# Test 1: Sequential ADDIs
# Tests basic pipeline flow and icache cold-start miss
# Expected: x1=1, x2=2, x3=3, x4=4

.text
main:
    addi x1, x0, 1    # x1 = 1
    addi x2, x0, 2    # x2 = 2
    addi x3, x0, 3    # x3 = 3
    addi x4, x0, 4    # x4 = 4
done:
    j done             # halt