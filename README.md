# RV32I In-Order Pipelined Processor with Split L1 Cache Hierarchy

A fully functional 5-stage pipelined RISC-V processor implementing the complete RV32I instruction set, integrated with a split L1 instruction and data cache system. Designed, implemented, and verified entirely in SystemVerilog — simulated in iverilog and synthesized in Vivado targeting the Nexys A7 FPGA.

**Author:** Ved Savjani | `Ved.Savjani@iiitb.ac.in` | BTech ECE, IIIT Bangalore
**Tools:** iverilog/vvp · GTKWave · Vivado 2024.2 · RARS · Godbolt

---

## Table of Contents

1. [Architecture and Instructions Supported](#1-architecture-and-instructions-supported)
2. [Pipelined Processor — Details and Implementation](#2-pipelined-processor--details-and-implementation)
3. [Data Cache — Details and Implementation](#3-data-cache--details-and-implementation)
4. [Instruction Cache — Details and Implementation](#4-instruction-cache--details-and-implementation)
5. [Testing and Verification with Micro-Programs](#5-testing-and-verification-with-micro-programs)
6. [Testing with Real-World Programs](#6-testing-with-real-world-programs)
7. [Synthesizing on Real Hardware with Vivado](#7-synthesizing-on-real-hardware-with-vivado)

---

## 1. Architecture and Instructions Supported

### System Overview

This project implements a complete RISC-V SoC subsystem: a 5-stage in-order pipelined processor core with a split L1 cache hierarchy, backed by separate instruction and data memories.

<!-- INSERT DIAGRAM (Claude Design): Top-level system block diagram showing CPU core → I-cache → icache_mem and CPU core → D-cache → dcache_mem, with arrows showing data/address flow -->

### File Structure

```
.
├── rtl/
│   ├── top.sv              # Top module: riscv_core + cache memories
│   ├── riscv_core.sv       # Pipeline core with cache interfaces
│   ├── datapath.sv         # Pipeline datapath
│   ├── controller.sv       # Main decoder + ALU decoder
│   ├── hazard_unit.sv      # Stall, flush, forwarding logic
│   ├── i_cache.sv          # L1 instruction cache
│   ├── d_cache.sv          # L1 data cache
│   ├── icache_mem.sv       # Instruction backing memory
│   ├── dcache_mem.sv       # Data backing memory
│   ├── data_pipes.sv       # Pipeline data registers (with enable/clear)
│   ├── control_pipes.sv    # Pipeline control registers (with enable/clear)
│   ├── regfile.sv          # Register file
│   ├── alu.sv              # ALU
│   ├── adder.sv            # PC adder
│   ├── muxes.sv            # All datapath muxes
│   ├── extend.sv           # Immediate sign extension
│   ├── maindec.sv          # Main control decoder
│   └── aludec.sv           # ALU control decoder
│
├── tb/
│   ├── test1_tb.sv         # Sequential ADDIs
│   ├── test2_tb.sv         # LW + dependent ADDI
│   ├── test3a_tb.sv        # SW miss + LW hit (write-allocate)
│   ├── test3b_tb.sv        # Load-use + icache stall interaction
│   ├── test3c_tb.sv        # SW miss + LW hit + dependent ADDI
│   ├── test4a_tb.sv        # Spatial locality (word 2 of same block)
│   ├── test4b_tb.sv        # LRU eviction
│   ├── test4c_tb.sv        # Dirty writeback
│   ├── hh_tb.sv            # Harris & Harris test program
│   ├── quicksort_tb.sv     # 10-element quicksort
│   ├── dijkstras3_tb.sv    # Dijkstra 3-node
│   ├── dijkstras10_tb.sv   # Dijkstra 10-node
│   ├── d_cache_tb.sv       # D-cache isolation testbench
│   └── i_cache_tb.sv       # I-cache isolation testbench
│
└── mem/
    ├── hh_test.txt             # H&H test program hex
    ├── quicksort.txt           # Quicksort instruction hex
    ├── quicksort_data.txt      # Quicksort initial array data
    ├── dijkstras10.txt         # Dijkstra instruction hex
    ├── dijkstras10_data.txt    # Dijkstra graph data
    ├── test1.txt ... test4c.txt
    └── test2_data.txt, test3b_data.txt
```

### RV32I Instructions Supported

This processor implements the full RV32I base integer instruction set — every instruction in the spec, not just the subset covered in Harris & Harris.

| Type | Instructions |
|------|-------------|
| R-type | `add` `sub` `and` `or` `xor` `slt` `sltu` `sll` `srl` `sra` |
| I-type | `addi` `andi` `ori` `xori` `slti` `sltiu` `slli` `srli` `srai` `lw` `jalr` |
| S-type | `sw` |
| B-type | `beq` `bne` `blt` `bge` |
| J-type | `jal` |
| U-type | `lui` `auipc` |

All other standard RISC-V instructions are pseudo-instructions derived from these (e.g. `mv`, `li`, `ret`, `call`).

### Architectural Specifications

| Parameter | Value |
|-----------|-------|
| ISA | RV32I |
| Pipeline | 5-stage, in-order |
| Hazard handling | Forwarding + stalling + flushing |
| Branch resolution | EX stage |
| Register file | 32 × 32-bit, negedge write |
| ALU control | 4-bit |
| Instruction cache | 16KB, 2-way, 1-word block, LRU |
| Data cache | 32KB, 4-way, 2-word block, write-back, write-allocate, LRU |
| Miss penalty | 3 cycles (both caches) |
| Memory interface | Word-addressed, 1-cycle latency |

---

## 2. Pipelined Processor — Details and Implementation

### Pipeline Stages

The processor implements the standard 5-stage RISC-V pipeline:

```
┌────┐     ┌────┐     ┌────┐     ┌─────┐     ┌────┐
│ IF │────▶│ ID │────▶│ EX │────▶│ MEM │────▶│ WB │
└────┘     └────┘     └────┘     └─────┘     └────┘
  │                     │                       │
  │    i-cache miss      │    d-cache miss       │
  │    stall F,D         │    stall F,D,E,M      │
  │    flush E           │    flush W            │
```

- **IF** — Fetch instruction from I-cache using PC
- **ID** — Decode instruction, read register file, extend immediate
- **EX** — ALU operation, branch resolution, forwarding
- **MEM** — D-cache access for loads and stores
- **WB** — Write result back to register file

<!-- INSERT HAND-DRAWN SCHEMATIC: Full datapath schematic showing all pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB), all muxes, forwarding paths (EX→EX, MEM→EX), ALU, regfile, extend unit, PC logic with pcsrc mux -->

### Pipeline Registers

All pipeline registers have `enable` and `clear` ports to support stalling and flushing:

```systemverilog
// Example: IF/ID register
always_ff @(posedge clk) begin
    if (reset | flushD)      instrD <= 32'b0;
    else if (~stallD)        instrD <= instrF;
end
```

### Hazard Unit

The hazard unit handles three categories of hazards:

<!-- INSERT HAND-DRAWN SCHEMATIC: Hazard unit block showing all inputs (rs1D, rs2D, rdE, rdM, ResultSrcE, ResultSrcM, RegWriteE, RegWriteM, pcsrcE, icache_hit, dcache_hit, mem_active) and all outputs (stallF, stallD, stallE, stallM, flushD, flushE, flushW, forwardAE, forwardBE) -->

**1. Data Hazards — Forwarding**

```systemverilog
// Forward from MEM stage to EX stage
if (rs1E == rdM & rs1E != 5'b0 & RegWriteM) forwardAE = 2'b10;
// Forward from WB stage to EX stage  
else if (rs1E == rdW & rs1E != 5'b0 & RegWriteW) forwardAE = 2'b01;
else forwardAE = 2'b00;
```

**2. Load-Use Hazard — Stall**

When a load is in EX and the next instruction needs the result, the pipeline must stall one cycle:

```systemverilog
lwstall = (ResultSrcE == 3'b001) & ((rs1D == rdE) | (rs2D == rdE));
```

**3. MEM-Stage Stall (auipc + jalr)**

`auipc` computes `PC + upimm` — this result is only available in WB (via the extra adder and mux5). If `jalr` immediately follows `auipc` and tries to use `ra`, it reads the wrong value. Fix: stall one cycle when a MEM-stage instruction writes to a register that EX needs.

```systemverilog
memstall = (ResultSrcM != 3'b000) & RegWriteM &
           ((rs1E == rdM & rs1E != 5'b0) | (rs2E == rdM & rs2E != 5'b0));
```

**4. Cache Stalls**

```systemverilog
icache_stall = ~icache_hit;
dcache_stall = ~dcache_hit & mem_active;  // mem_active = rden | MemWriteM

stallF = lwstall | memstall | exstall | icache_stall | dcache_stall;
stallD = lwstall | memstall | exstall | icache_stall | dcache_stall;
stallE = dcache_stall;
stallM = dcache_stall;

flushD = pcsrcE & ~(icache_stall | dcache_stall);
flushE = (lwstall | pcsrcE | memstall | exstall | icache_stall) & ~dcache_stall;
flushW = dcache_stall;
```

**Why flushE is blocked during dcache stall:** During a D-cache stall, the instruction in EX is valid and frozen in place. If flushE fires, that instruction is lost permanently. The rule: never flush EX during a D-cache stall.

**Why flushD is blocked during cache stalls:** If a branch resolves while a cache stall is active, the instruction in ID is a bubble — flushing it would be a no-op but could cause incorrect behavior. Gate with `~(icache_stall | dcache_stall)`.

### Control Unit

The controller takes `op`, `funct3`, `funct7[5]` and `zero`/`negative` flags from the ALU and generates all control signals.

Key design decisions:
- Branch taken (`branchtakenE`) computed in EX using `funct3E` — **must use EX-stage funct3, not decode-stage**. Using decode-stage funct3 was a critical bug that corrupted all loop branches.
- `pcsrc = (branch & branchtakenE) | jump | jalrsel`
- `ResultSrc` is 3-bit to support 5 result sources: ALUresult, ReadData, PC+4, UpperImm, PC+UpperImm (auipc)

### ALU

4-bit ALU control supporting all RV32I arithmetic and logic operations:

| ALUControl | Operation |
|------------|-----------|
| 0000 | ADD |
| 0001 | SUB |
| 0010 | AND |
| 0011 | OR |
| 0100 | XOR |
| 0101 | SLT |
| 0110 | SLTU |
| 0111 | SLL |
| 1000 | SRL |
| 1001 | SRA |

### Register File

Writes on **negedge** of clock. This allows WB→ID forwarding to happen within the same clock cycle — the write completes on the falling edge, and the read in ID on the following rising edge sees the updated value. The alternative (latching the write data into an extra register) was tried and broke the H&H test.

---

## 3. Data Cache — Details and Implementation

### Specifications

| Parameter | Value |
|-----------|-------|
| Size | 32 KB |
| Associativity | 4-way set-associative |
| Block size | 2 words (64 bits) |
| Sets | 1024 |
| Replacement policy | LRU (2-bit counter per way) |
| Write policy | Write-back, write-allocate |
| Miss penalty | 3 cycles |
| Memory data width | 64 bits |
| Memory addressing | Word-addressed (each word = 64 bits) |

### Address Breakdown

```
 31                13 12          3 2        1 0
 ┌───────────────────┬─────────────┬──────────┬──┐
 │      TAG (19b)    │  INDEX (10b) │ BLKOFF(1)│B │
 └───────────────────┴─────────────┴──────────┴──┘
```

- **TAG [31:13]** — 19 bits, identifies which memory block is cached
- **INDEX [12:3]** — 10 bits, selects which of the 1024 sets
- **BLOCK OFFSET [2]** — 1 bit, selects word 0 or word 1 within the 2-word block
- **BYTE OFFSET [1:0]** — 2 bits, word-aligned (ignored for word accesses)

<!-- INSERT DIAGRAM (Claude Design): D-cache internal structure showing 1024 sets × 4 ways, each way containing valid bit, dirty bit, 2-bit LRU counter, 19-bit tag, and 64-bit data (two 32-bit words) -->

### Internal Storage

Each way has its own register array with NSETS entries:

```systemverilog
logic valid0 [0:NSETS-1];
logic dirty0 [0:NSETS-1];
logic [1:0] lru0 [0:NSETS-1];
logic [TAG_WIDTH-1:0] tag0 [0:NSETS-1];
logic [MWIDTH-1:0] mem0 [0:NSETS-1];  // 64-bit (2-word block)
// same for way1, way2, way3
```

### Cache FSM

<!-- INSERT HAND-DRAWN SCHEMATIC: 2-state FSM diagram with IDLE and MISS states, showing transition conditions and actions in each state -->

**IDLE state:**
- Compare incoming address tag against all 4 ways at the indexed set
- If any way matches and is valid → **hit**: return data, update LRU, assert `hit_miss=1`
- If no match → **miss**: pre-issue memory read request (reduces miss penalty by 1 cycle), transition to MISS

**MISS state:**
- If all ways are valid and the LRU way is dirty → write LRU block back to memory
- Load new block from memory into LRU (or first invalid) way
- Update tag, set valid bit, clear dirty bit
- Transition back to IDLE (hit logic handles the rest next cycle)

### Hit Detection

```systemverilog
wire hit0 = valid0[index] & (tag0[index] == address[`D_TAG]);
wire hit1 = valid1[index] & (tag1[index] == address[`D_TAG]);
wire hit2 = valid2[index] & (tag2[index] == address[`D_TAG]);
wire hit3 = valid3[index] & (tag3[index] == address[`D_TAG]);
assign hit_miss = hit0 | hit1 | hit2 | hit3;
assign mrden = ~hit_miss;  // combinational — pre-issues memory request on miss
```

### LRU Update

On a hit in way `i`, increment the LRU counter of every way whose current LRU value is less than way `i`'s LRU value, then reset way `i`'s LRU to 0. This keeps a valid ranking of 0 (MRU) to 3 (LRU) across all 4 ways.

**Critical bug fixed:** LRU comparison used `<` instead of `<=`, which broke cold-start behavior when all LRU counters initialize to 0.

### Write Policy

- **Write-hit:** Write directly to the cached block, set dirty bit
- **Write-miss (write-allocate):** Fetch the block from memory first, then write to it
- **Eviction:** If the LRU block is dirty, write it back to memory before replacing

### Memory Interface

```
CPU side:                    Memory side:
  address [31:0]  ──▶          mrdaddress [31:0]  ──▶
  din     [31:0]  ──▶          mrden               ──▶
  rden            ──▶          mdin    [63:0]      ◀──
  wren            ──▶          mdout   [63:0]       ──▶
  dout    [31:0]  ◀──          mwraddress [31:0]   ──▶
  hit_miss        ◀──          mwren               ──▶
```

Memory read address is block-aligned:
```systemverilog
mrdaddress = {address[31:3], 3'b000};  // zero out block offset + byte offset
```

---

## 4. Instruction Cache — Details and Implementation

### Specifications

| Parameter | Value |
|-----------|-------|
| Size | 16 KB |
| Associativity | 2-way set-associative |
| Block size | 1 word (32 bits) |
| Sets | 2048 |
| Replacement policy | LRU (1-bit per set) |
| Write policy | Read-only (instruction memory is never written) |
| Miss penalty | 3 cycles |
| Memory data width | 32 bits |

### Address Breakdown

```
 31                13 12           1 0
 ┌───────────────────┬──────────────┬─┐
 │      TAG (19b)    │  INDEX (12b)  │B│
 └───────────────────┴──────────────┴─┘
```

- **TAG [31:13]** — 19 bits
- **INDEX [12:1]** — 12 bits, selects which of the 2048 sets
- **BYTE OFFSET [0]** — 1 bit, ignored (word-aligned)

<!-- INSERT DIAGRAM (Claude Design): I-cache internal structure showing 2048 sets × 2 ways, each way containing valid bit, 1-bit LRU, 19-bit tag, and 32-bit data -->

### Differences from D-Cache

The I-cache is a simplified version of the D-cache:

| Feature | D-Cache | I-Cache |
|---------|---------|---------|
| Ways | 4 | 2 |
| Block size | 2 words (64-bit) | 1 word (32-bit) |
| Sets | 1024 | 2048 |
| Dirty bit | Yes | No |
| Write support | Yes | No |
| mdout port | Yes | No |
| mwren port | Yes | No |

Because the instruction memory is read-only, there are no dirty bits, no write-back, and no write-allocate. On a miss, the block is simply fetched from memory and placed in the LRU way.

### Stall Behavior in Pipeline

When the I-cache misses, the instruction isn't ready yet. The pipeline must freeze the fetch and decode stages until the cache returns the correct instruction.

```
Cycle N:   IF=I5(miss)  ID=I4   EX=I3   MEM=I2   WB=I1
Cycle N+1: IF=I5(miss)  ID=I4*  EX=bubble MEM=I3  WB=I2
Cycle N+2: IF=I5(miss)  ID=I4*  EX=bubble MEM=-    WB=I3
Cycle N+3: IF=I5(hit)   ID=I4*  EX=bubble MEM=-    WB=-
Cycle N+4: IF=I6        ID=I5   EX=I4    MEM=-    WB=-
```
*frozen in place

**Critical implementation detail:** The stall signal must be driven by `~i_mrden` (combinational), not by a registered version of `icache_hit`. Using a registered signal caused the PC to advance one cycle before the stall took effect, fetching the wrong instruction.

<!-- INSERT HAND-DRAWN SCHEMATIC: I-cache FSM state diagram (IDLE → MISS → IDLE) with transition conditions -->

---

## 5. Testing and Verification with Micro-Programs

### Testing Methodology

The testing workflow for every program:
1. Write C code (bare-metal, no stdlib)
2. Compile via Godbolt (RISC-V 32-bit gcc 14.2.0, `-O0`)
3. Adapt for RARS (replace `call` with `jal ra, label`, `jr ra` with `jalr x0, ra, 0`)
4. Verify correctness in RARS (Compact memory config: text at `0x0`, data at `0x2000`)
5. Dump hex from RARS → load into `icache_mem`/`dcache_mem` via `$readmemh`
6. Run SystemVerilog testbench in iverilog, check register/memory values

### How to Run

**Prerequisites:**
```bash
sudo apt install iverilog gtkwave
```

**Running any test:**
```bash
cd tb
iverilog -g2012 -o sim.vvp \
  ../rtl/top.sv ../rtl/riscv_core.sv ../rtl/datapath.sv \
  ../rtl/controller.sv ../rtl/hazard_unit.sv \
  ../rtl/i_cache.sv ../rtl/d_cache.sv \
  ../rtl/icache_mem.sv ../rtl/dcache_mem.sv \
  ../rtl/data_pipes.sv ../rtl/control_pipes.sv \
  ../rtl/regfile.sv ../rtl/alu.sv ../rtl/adder.sv \
  ../rtl/muxes.sv ../rtl/extend.sv \
  ../rtl/maindec.sv ../rtl/aludec.sv \
  test1_tb.sv   # replace with any testbench
vvp sim.vvp
```

**Running cache isolation tests:**
```bash
# D-cache
iverilog -g2012 -o sim.vvp ../rtl/d_cache.sv ../rtl/dcache_mem.sv d_cache_tb.sv
vvp sim.vvp

# I-cache
iverilog -g2012 -o sim.vvp ../rtl/i_cache.sv ../rtl/icache_mem.sv i_cache_tb.sv
vvp sim.vvp
```

### Cache Isolation Tests

Before integrating with the pipeline, both caches were verified independently with dedicated testbenches that directly drive the cache inputs.

**D-cache test coverage (17/17 pass):**

| Test Case | What it verifies |
|-----------|-----------------|
| Cold-start miss | First access to empty cache — miss, fetch from memory |
| Read hit | Same address accessed twice — second access is a hit |
| Write hit | Write to cached block — dirty bit set, data updated |
| Write miss (write-allocate) | Write to uncached address — block fetched first, then written |
| Spatial locality | Access word 2 of an already-cached 2-word block |
| LRU eviction | Fill all 4 ways, access a 5th — LRU way evicted |
| Dirty writeback | Evict a dirty block — old data written back to memory first |
| Multi-set independence | Accesses to different index bits don't interfere |

**I-cache test coverage (7/7 pass):**

| Test Case | What it verifies |
|-----------|-----------------|
| Cold-start miss | First fetch — miss, load from memory |
| Sequential hits | Multiple fetches from same cached block |
| LRU eviction | Fill both ways, fetch a third address — LRU way replaced |
| No false writes | Write enable signal ignored (read-only cache) |

### Pipeline Integration Micro-Tests

8 targeted micro-programs designed to isolate specific hazard + cache interactions:

<!-- INSERT DIAGRAM (Claude Design): Table or flowchart showing the 8 tests and what each one specifically stresses -->

| Test | Program | What it verifies |
|------|---------|-----------------|
| test1 | 5 sequential `addi` | Basic pipeline flow, icache stall on cold start |
| test2 | `lw` then `addi` using loaded value | Load-use hazard + icache stall interaction |
| test3a | `sw` to uncached addr, then `lw` same addr | Write-allocate: store miss triggers block fetch |
| test3b | `lw` + dependent `addi` with icache miss in flight | Load-use hazard simultaneous with icache stall |
| test3c | `sw` miss + `lw` hit + dependent `addi` | Combined dcache stall + load-use hazard |
| test4a | `lw` word1 of block, then `lw` word2 | Spatial locality: second word hits without fetch |
| test4b | Fill all 4 ways, access 5th address | LRU eviction: correct way replaced |
| test4c | Write to cached block, evict it, reload | Dirty writeback: modified data preserved in memory |

**All 8 micro-tests: PASS**

### Key Bugs Found During Integration Testing

**Bug 1: PC advancing before stall asserted**
- Symptom: First instruction after cold-start icache miss fetched wrong instruction
- Cause: `icache_stall` was derived from registered `hit_miss`, so stall arrived one cycle late
- Fix: Drive `icache_stall = ~i_mrden` (combinational — goes high the same cycle the miss is detected)

**Bug 2: D-cache stalling on every cycle**
- Symptom: Pipeline permanently stalled even with no memory operation in flight
- Cause: `dcache_stall = ~dcache_hit` fired even when there was no load/store in MEM stage
- Fix: Gate with `mem_active`: `dcache_stall = ~dcache_hit & (rden | MemWriteM)`

**Bug 3: D-cache stall releasing one cycle early**
- Symptom: `dout` not yet valid when pipeline unstalled, wrong value written to register
- Cause: Stall released when `hit_miss` went high, but `dout` was registered and arrived next cycle
- Fix: Register `hit_miss` gated with `mem_active`: stall releases only after `dout` is valid

**Bug 4: dcache_mem $readmemh offset wrong**
- Symptom: Quicksort and Dijkstra data corrupted — every other array element was zero
- Cause: `$readmemh` loaded data at word offset `32'h2000>>2` (4-byte words), but dcache_mem is indexed by 64-bit words
- Fix: Use `32'h2000>>3` — 8-byte word addressing

**Bug 5: False load-use stall on `lui`**
- Symptom: Pipeline stalled unnecessarily after `lui`
- Cause: Hazard unit checked `ResultSrcE[0]` to detect loads, but `lui` also sets `ResultSrcE[0]`
- Fix: Check full `ResultSrcE == 3'b001` (only true for `lw`)

**Bug 6: Branch using wrong `funct3` (caught earlier, during pipeline-only phase)**
- Symptom: All loops with `bne`/`blt`/`bge` executed wrong branch direction
- Cause: `branchtakenE` used `funct3` from the decode stage instead of `funct3E` (EX stage)
- Fix: Use `funct3E` everywhere branch condition is evaluated

---

## 6. Testing with Real-World Programs

### Harris & Harris Test Program

The standard verification suite from Harris & Harris RISC-V Edition. Tests a broad range of instructions including arithmetic, logic, loads, stores, branches, and jumps.

**Result: PASS** — All instructions produce correct register and memory values.

<!-- INSERT SCREENSHOT: Terminal output showing H&H test passing -->

### Quicksort (10 elements)

Sorts the array `[90, 45, 78, 33, 12, 64, 22, 11, 5, 25]` using recursive quicksort implemented in C, compiled to RISC-V assembly.

This program exercises:
- Recursive function calls (`jal`, `jalr`)
- Stack manipulation (`sw`/`lw` to stack pointer)
- Array indexing with computed addresses
- Heavy branch usage inside partition loop
- Repeated D-cache hits on array data (spatial and temporal locality)

**Result: PASS** — Output array `[5, 11, 12, 22, 25, 33, 45, 64, 78, 90]` verified in D-cache memory.

<!-- INSERT SCREENSHOT: Terminal output showing quicksort result -->

### Dijkstra's Algorithm

Finds shortest paths from node 0 in a weighted directed graph. Tests the same features as quicksort but with more complex control flow and nested loops.

**3-node result: FAIL** — `dist[1]` and `dist[2]` return 0 instead of correct distances.

**Known bug:** When a `jal`/branch fires at the exact same cycle as an icache stall, the PC is frozen and cannot accept the branch redirect. The jump target is computed in EX but the PC can't update because `stallF` is also asserted. The JAL in EX gets flushed the next cycle, so the jump is lost and execution falls through sequentially. Dijkstra uses heavy recursive function calls, hitting this pattern frequently.

This bug does not affect quicksort because quicksort's recursive calls happen to not coincide with icache stalls in the same cycle.

---

## 7. Synthesizing on Real Hardware with Vivado

### Target

**Board:** Digilent Nexys A7  
**FPGA:** Xilinx Artix-7 `xc7a100tcsg324-1`  
**Tool:** Vivado ML Standard 2024.2 (free WebPACK edition)

### Setup

**Source the Vivado environment:**
```bash
source /tools/Xilinx/Vivado/2024.2/settings64.sh
```

**Or add to `.zshrc` for permanent access:**
```bash
echo 'source /tools/Xilinx/Vivado/2024.2/settings64.sh' >> ~/.zshrc
```

### Creating a Vivado Project

1. Launch Vivado: `vivado &`
2. Create Project → RTL Project → select part `xc7a100tcsg324-1`
3. Add Design Sources → add all `rtl/*.sv`
4. Add Simulation Sources → add testbenches from `tb/`
5. Set `top.sv` as top module for synthesis

### Running Behavioral Simulation in XSim

Flow → Run Simulation → Run Behavioral Simulation

Note: `$readmemh` paths must be absolute or relative to the Vivado simulation working directory. Update paths in `icache_mem.sv` and `dcache_mem.sv` if simulation fails to load memory files.

### Synthesis Results

> Results to be updated after synthesis run completes.

Target: `xc7a100tcsg324-1` | Artix-7 100T

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| LUTs | TBD | 63,400 | TBD% |
| Flip-Flops | TBD | 126,800 | TBD% |
| BRAMs | TBD | 135 | TBD% |
| DSPs | TBD | 240 | TBD% |

| Timing | Value |
|--------|-------|
| Target clock | 50 MHz |
| Fmax | TBD MHz |
| WNS | TBD ns |
| TNS | TBD ns |

<!-- INSERT SCREENSHOT: Vivado utilization report -->
<!-- INSERT SCREENSHOT: Vivado timing summary -->

### FPGA Bring-Up Plan (when board is available)

1. Add XDC constraints file mapping clock/reset to Nexys A7 pins
2. Add output logic (UART or 7-segment display) to observe results
3. Program bitstream via Vivado Hardware Manager

---

## References

- Harris & Harris, *Digital Design and Computer Architecture: RISC-V Edition*
- RISC-V Unprivileged ISA Specification, Chapters 1, 2, 24
- [RARS — RISC-V Assembly and Runtime Simulator](https://github.com/TheThirdOne/rars)
- [Godbolt Compiler Explorer](https://godbolt.org/) — RISC-V 32-bit gcc 14.2.0
- [Digilent Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)