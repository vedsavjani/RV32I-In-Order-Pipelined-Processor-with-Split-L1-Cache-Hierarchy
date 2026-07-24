#!/usr/bin/env bash
# Runs every testbench in this repo (pipeline-integration + cache isolation)
# one at a time, printing each test's full result before moving to the next.
# Per-test compile/sim logs (including full per-cycle debug trace) still land
# in sim_logs/ for anyone who wants to dig deeper than the console summary.
#
# Usage: ./run_tests.sh
# Exits non-zero if any test failed or failed to compile/run.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

LOGDIR="sim_logs"
mkdir -p "$LOGDIR"
rm -f "$LOGDIR"/*.log "$LOGDIR"/*.vcd

TOP="rtl/top.sv"
TOP_BACKUP="$(mktemp)"
cp "$TOP" "$TOP_BACKUP"
restore_top() { [ -f "$TOP_BACKUP" ] && cp "$TOP_BACKUP" "$TOP" && rm -f "$TOP_BACKUP"; }
trap restore_top EXIT

SIM="$(mktemp -u /tmp/rv32i_sim.XXXXXX).vvp"

TOTAL_TESTS=12
TEST_NUM=0
SUMMARY_NAMES=()
SUMMARY_STATUS=()

banner() {
    TEST_NUM=$((TEST_NUM+1))
    echo "================================================================================"
    echo " TEST $TEST_NUM/$TOTAL_TESTS : $1  —  $2"
    echo "================================================================================"
}

# args: display_name  description  testbench_file  icache_hex  dcache_hex ("" if none)
run_pipeline_test() {
    local name="$1" desc="$2" tb="$3" ifile="$4" dfile="$5"
    local log="$LOGDIR/${name}.log"
    banner "$name" "$desc"

    cp "$TOP_BACKUP" "$TOP"
    sed -i "s|icache_mem #(.FILE(\"[^\"]*\")) icm|icache_mem #(.FILE(\"$ifile\")) icm|" "$TOP"
    sed -i "s|dcache_mem #(.FILE(\"[^\"]*\")) dcm|dcache_mem #(.FILE(\"$dfile\")) dcm|" "$TOP"
    if ! grep -q "\"$ifile\"" "$TOP"; then
        echo "  !! sed substitution failed -- aborting this test"
        SUMMARY_NAMES+=("$name"); SUMMARY_STATUS+=("SCRIPT_ERROR")
        echo
        return
    fi

    if iverilog -g2012 -o "$SIM" rtl/*.sv tb/perf_monitor.sv "$tb" > "$log" 2>&1; then
        vvp "$SIM" < /dev/null >> "$log" 2>&1
        rm -f "$SIM"
        [ -f dump.vcd ] && mv dump.vcd "$LOGDIR/${name}.vcd"
    else
        echo "COMPILE FAILED" >> "$log"
    fi

    if grep -q '@@@PERF_BLOCK_START@@@' "$log"; then
        sed -n '/@@@PERF_BLOCK_START@@@/,/@@@PERF_BLOCK_END@@@/p' "$log" \
            | sed '1d;$d'
    else
        echo "  !! test did not complete (compile error or crash) -- see $log"
    fi

    local status
    status="$(grep '^CSV,' "$log" | tail -1 | cut -d',' -f3)"
    [ -z "$status" ] && status="FAIL"
    SUMMARY_NAMES+=("$name"); SUMMARY_STATUS+=("$status")
    echo
}

# args: display_name  description  rtl_and_tb_files...
run_isolation_test() {
    local name="$1" desc="$2"; shift 2
    local log="$LOGDIR/${name}.log"
    banner "$name" "$desc"

    if iverilog -g2012 -o "$SIM" "$@" > "$log" 2>&1; then
        vvp "$SIM" < /dev/null >> "$log" 2>&1
        rm -f "$SIM"
    else
        echo "COMPILE FAILED" >> "$log"
    fi

    grep -E '^(PASS|FAIL) \||Results:|ALL TESTS|SOME TESTS' "$log"

    local status
    status="$(grep '^CSV,' "$log" | tail -1 | cut -d',' -f3)"
    [ -z "$status" ] && status="FAIL"
    SUMMARY_NAMES+=("$name"); SUMMARY_STATUS+=("$status")
    echo
}

run_pipeline_test Test1     "5 sequential ADDIs, cold-start icache stall"              tb/test1_tb.sv     mem/test1.txt     ""
run_pipeline_test Test2     "LW then dependent ADDI - load-use hazard + icache stall"  tb/test2_tb.sv     mem/test2.txt     mem/test2_data.txt
run_pipeline_test Test3a    "SW miss then LW hit - write-allocate"                     tb/test3a_tb.sv    mem/test3a.txt    ""
run_pipeline_test Test3b    "LW + dependent ADDI with icache miss in flight"           tb/test3b_tb.sv    mem/test3b.txt    mem/test3b_data.txt
run_pipeline_test Test3c    "SW miss + LW hit + dependent ADDI"                        tb/test3c_tb.sv    mem/test3c.txt    ""
run_pipeline_test Test4a    "LW word1 then word2 of block - spatial locality"          tb/test4a_tb.sv    mem/test4a.txt    ""
run_pipeline_test Test4b    "Fill all 4 ways, access 5th - LRU eviction"               tb/test4b_tb.sv    mem/test4b.txt    ""
run_pipeline_test Test4c    "Write to cached block, evict, reload - dirty writeback"   tb/test4c_tb.sv    mem/test4c.txt    ""
run_pipeline_test HH_Test   "Harris & Harris reference test program"                   tb/hh_tb.sv        mem/hh_test.txt   ""
run_pipeline_test Quicksort "10-element recursive quicksort"                           tb/quicksort_tb.sv mem/quicksort.txt mem/quicksort_data.txt

restore_top

run_isolation_test D-Cache-Isolation "Direct D-cache correctness, 17 cases" rtl/d_cache.sv rtl/dcache_mem.sv tb/d_cache_tb.sv
run_isolation_test I-Cache-Isolation "Direct I-cache correctness, 7 cases"  rtl/i_cache.sv rtl/icache_mem.sv tb/i_cache_tb.sv

# ------------------------------------------------------------------ summary --
FAIL_COUNT=0
echo "================================================================================"
echo " SUMMARY"
echo "================================================================================"
for i in "${!SUMMARY_NAMES[@]}"; do
    printf "  %-24s %s\n" "${SUMMARY_NAMES[$i]}" "${SUMMARY_STATUS[$i]}"
    [ "${SUMMARY_STATUS[$i]}" != "PASS" ] && FAIL_COUNT=$((FAIL_COUNT+1))
done
PASSED=$(( ${#SUMMARY_NAMES[@]} - FAIL_COUNT ))
echo "--------------------------------------------------------------------------------"
echo " $PASSED/${#SUMMARY_NAMES[@]} test suites passed"
echo " Per-test logs + waveforms: $LOGDIR/"
echo "================================================================================"

[ "$FAIL_COUNT" -eq 0 ]
