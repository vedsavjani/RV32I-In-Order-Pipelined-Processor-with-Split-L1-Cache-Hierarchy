#!/usr/bin/env bash
# Runs every testbench in this repo (pipeline-integration + cache isolation),
# collects PASS/FAIL plus perf stats (cycles, stalls, flushes, cache hit
# rates) from each run, and prints one aggregate report at the end.
#
# Usage: ./run_tests.sh
# Per-test compile/sim logs (and any waveform dumps) land in sim_logs/.
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

PIPE_RESULTS=()
ISO_RESULTS=()

# args: display_name  testbench_file  icache_hex  dcache_hex ("" if none)
run_pipeline_test() {
    local name="$1" tb="$2" ifile="$3" dfile="$4"
    local log="$LOGDIR/${name}.log"

    cp "$TOP_BACKUP" "$TOP"
    sed -i "s|icache_mem #(.FILE(\"[^\"]*\")) icm|icache_mem #(.FILE(\"$ifile\")) icm|" "$TOP"
    sed -i "s|dcache_mem #(.FILE(\"[^\"]*\")) dcm|dcache_mem #(.FILE(\"$dfile\")) dcm|" "$TOP"
    if ! grep -q "\"$ifile\"" "$TOP"; then
        echo "!! sed substitution failed for $name (icache FILE) -- aborting this test" | tee "$log"
        PIPE_RESULTS+=("CSV,$name,SCRIPT_ERROR,0,0,0,0,0,0,0,0,0,0,0.0,0,0,0.0")
        return
    fi

    if iverilog -g2012 -o "$SIM" rtl/*.sv tb/perf_monitor.sv "$tb" > "$log" 2>&1; then
        vvp "$SIM" < /dev/null >> "$log" 2>&1
        rm -f "$SIM"
        [ -f dump.vcd ] && mv dump.vcd "$LOGDIR/${name}.vcd"
    else
        echo "COMPILE FAILED" >> "$log"
    fi

    local csv
    csv="$(grep '^CSV,' "$log" | tail -1)"
    if [ -z "$csv" ]; then
        PIPE_RESULTS+=("CSV,$name,COMPILE/RUNTIME ERROR,0,0,0,0,0,0,0,0,0,0,0.0,0,0,0.0")
    else
        PIPE_RESULTS+=("$csv")
    fi
}

# args: display_name  rtl_and_tb_files...
run_isolation_test() {
    local name="$1"; shift
    local log="$LOGDIR/${name}.log"

    if iverilog -g2012 -o "$SIM" "$@" > "$log" 2>&1; then
        vvp "$SIM" < /dev/null >> "$log" 2>&1
        rm -f "$SIM"
    else
        echo "COMPILE FAILED" >> "$log"
    fi

    local csv
    csv="$(grep '^CSV,' "$log" | tail -1)"
    if [ -z "$csv" ]; then
        ISO_RESULTS+=("CSV,$name,COMPILE/RUNTIME ERROR,0,0")
    else
        ISO_RESULTS+=("$csv")
    fi
}

echo "Running pipeline-integration tests..."
run_pipeline_test Test1     tb/test1_tb.sv     mem/test1.txt     ""
run_pipeline_test Test2     tb/test2_tb.sv     mem/test2.txt     mem/test2_data.txt
run_pipeline_test Test3a    tb/test3a_tb.sv    mem/test3a.txt    ""
run_pipeline_test Test3b    tb/test3b_tb.sv    mem/test3b.txt    mem/test3b_data.txt
run_pipeline_test Test3c    tb/test3c_tb.sv    mem/test3c.txt    ""
run_pipeline_test Test4a    tb/test4a_tb.sv    mem/test4a.txt    ""
run_pipeline_test Test4b    tb/test4b_tb.sv    mem/test4b.txt    ""
run_pipeline_test Test4c    tb/test4c_tb.sv    mem/test4c.txt    ""
run_pipeline_test HH_Test   tb/hh_tb.sv        mem/hh_test.txt   ""
run_pipeline_test Quicksort tb/quicksort_tb.sv mem/quicksort.txt mem/quicksort_data.txt

restore_top

echo "Running cache isolation tests..."
run_isolation_test D-Cache-Isolation rtl/d_cache.sv rtl/dcache_mem.sv tb/d_cache_tb.sv
run_isolation_test I-Cache-Isolation rtl/i_cache.sv rtl/icache_mem.sv tb/i_cache_tb.sv

# ---------------------------------------------------------------- report ---
FAIL_COUNT=0

echo
echo "================================================================================================"
echo " PIPELINE INTEGRATION TESTS"
echo "================================================================================================"
printf "%-10s %-6s %8s %-16s %-12s %-22s %-22s\n" \
    "Test" "Result" "Cycles" "Stalls F/D/E/M" "Flush D/E/W" "I-cache acc/miss/hit%" "D-cache acc/miss/hit%"
echo "------------------------------------------------------------------------------------------------"
for row in "${PIPE_RESULTS[@]}"; do
    IFS=',' read -r _ name status cycles sf sd se sm fd fe fw ica icm ich dca dcm dch <<< "$row"
    [ "$status" != "PASS" ] && FAIL_COUNT=$((FAIL_COUNT+1))
    printf "%-10s %-6s %8s %-16s %-12s %-22s %-22s\n" \
        "$name" "$status" "$cycles" "$sf/$sd/$se/$sm" "$fd/$fe/$fw" \
        "$ica/$icm/${ich}%" "$dca/$dcm/${dch}%"
done

echo
echo "================================================================================================"
echo " CACHE ISOLATION TESTS"
echo "================================================================================================"
printf "%-22s %-6s %-14s\n" "Test" "Result" "Cases Passed"
echo "------------------------------------------------------------------------------------------------"
for row in "${ISO_RESULTS[@]}"; do
    IFS=',' read -r _ name status passed total <<< "$row"
    [ "$status" != "PASS" ] && FAIL_COUNT=$((FAIL_COUNT+1))
    printf "%-22s %-6s %-14s\n" "$name" "$status" "$passed/$total"
done

TOTAL=$(( ${#PIPE_RESULTS[@]} + ${#ISO_RESULTS[@]} ))
PASSED=$(( TOTAL - FAIL_COUNT ))
echo
echo "================================================================================================"
echo " OVERALL: $PASSED/$TOTAL test suites passed"
echo " Per-test logs + waveforms: $LOGDIR/"
echo "================================================================================================"

[ "$FAIL_COUNT" -eq 0 ]
