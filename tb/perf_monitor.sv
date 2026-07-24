// Reusable performance/stats counter for the pipeline-integration testbenches.
// Instantiated once per testbench, wired to the DUT's internal hazard-unit
// and cache signals via hierarchical port connections at instantiation time
// (see any of test*_tb.sv / hh_tb.sv / quicksort_tb.sv for the wiring).
//
// Emits one machine-parseable "CSV," line at the end of each test, which
// run_tests.sh greps out to build the aggregate results table.
module perf_monitor(
    input logic clk, reset,
    input logic stallF, stallD, stallE, stallM,
    input logic flushD, flushE, flushW,
    input logic ic_rden, ic_state, ic_mrden,
    input logic dc_rden, dc_wren, dc_state, dc_mrden
);

    integer cycle_count;
    integer stallF_count, stallD_count, stallE_count, stallM_count;
    integer flushD_count, flushE_count, flushW_count;
    integer ic_access_count, ic_miss_count;
    integer dc_access_count, dc_miss_count;

    initial begin
        cycle_count      = 0;
        stallF_count = 0; stallD_count = 0; stallE_count = 0; stallM_count = 0;
        flushD_count = 0; flushE_count = 0; flushW_count = 0;
        ic_access_count = 0; ic_miss_count = 0;
        dc_access_count = 0; dc_miss_count = 0;
    end

    // state == 0 is always the idle/decision state in both i_cache and d_cache
    // (parameter idle = 0), so sampling on that cycle counts each access/miss
    // exactly once instead of double-counting across the miss-handling cycle.
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count <= cycle_count + 1;

            if (stallF) stallF_count <= stallF_count + 1;
            if (stallD) stallD_count <= stallD_count + 1;
            if (stallE) stallE_count <= stallE_count + 1;
            if (stallM) stallM_count <= stallM_count + 1;

            if (flushD) flushD_count <= flushD_count + 1;
            if (flushE) flushE_count <= flushE_count + 1;
            if (flushW) flushW_count <= flushW_count + 1;

            if (ic_state == 1'b0 && ic_rden) begin
                ic_access_count <= ic_access_count + 1;
                if (ic_mrden) ic_miss_count <= ic_miss_count + 1;
            end

            if (dc_state == 1'b0 && (dc_rden | dc_wren)) begin
                dc_access_count <= dc_access_count + 1;
                if (dc_mrden) dc_miss_count <= dc_miss_count + 1;
            end
        end
    end

    task automatic print_summary(input bit pass, input string test_name);
        integer ic_hits, dc_hits;
        real ic_hit_rate, dc_hit_rate;
        begin
            ic_hits = ic_access_count - ic_miss_count;
            dc_hits = dc_access_count - dc_miss_count;
            ic_hit_rate = (ic_access_count > 0) ? (100.0 * ic_hits) / ic_access_count : 0.0;
            dc_hit_rate = (dc_access_count > 0) ? (100.0 * dc_hits) / dc_access_count : 0.0;

            $display("========================================================");
            $display(" PERF SUMMARY: %s", test_name);
            $display("========================================================");
            $display(" Result                  : %s", pass ? "PASS" : "FAIL");
            $display(" Total cycles executed    : %0d", cycle_count);
            $display(" Stall cycles  F/D/E/M    : %0d / %0d / %0d / %0d",
                      stallF_count, stallD_count, stallE_count, stallM_count);
            $display(" Flush cycles  D/E/W      : %0d / %0d / %0d",
                      flushD_count, flushE_count, flushW_count);
            $display(" I-cache accesses/misses  : %0d / %0d  (%0.1f%% hit)",
                      ic_access_count, ic_miss_count, ic_hit_rate);
            $display(" D-cache accesses/misses  : %0d / %0d  (%0.1f%% hit)",
                      dc_access_count, dc_miss_count, dc_hit_rate);
            $display("========================================================");

            $display("CSV,%s,%s,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0.1f,%0d,%0d,%0.1f",
                      test_name, pass ? "PASS" : "FAIL", cycle_count,
                      stallF_count, stallD_count, stallE_count, stallM_count,
                      flushD_count, flushE_count, flushW_count,
                      ic_access_count, ic_miss_count, ic_hit_rate,
                      dc_access_count, dc_miss_count, dc_hit_rate);
        end
    endtask

endmodule
