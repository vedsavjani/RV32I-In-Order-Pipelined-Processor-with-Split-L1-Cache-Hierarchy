// tb for quicksort
module testbench();
    logic        clk, reset;
    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;

    top dut(clk, reset, WriteData, DataAdr, MemWrite);

    logic pass;

    perf_monitor perf(
        .clk(clk), .reset(reset),
        .stallF(dut.rv.stallF), .stallD(dut.rv.stallD), .stallE(dut.rv.stallE), .stallM(dut.rv.stallM),
        .flushD(dut.rv.flushD), .flushE(dut.rv.flushE), .flushW(dut.rv.flushW),
        .ic_rden(dut.rv.ic.rden), .ic_state(dut.rv.ic.state), .ic_mrden(dut.rv.ic.mrden),
        .dc_rden(dut.rv.dcache_rden), .dc_wren(dut.rv.MemWriteM), .dc_state(dut.rv.dc.state), .dc_mrden(dut.rv.dc.mrden));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    // d_cache is write-back: a location's current value may still be dirty
    // in the cache and never flushed to dcache_mem, so read through the
    // cache first (as a real load would) and only fall back to backing
    // memory when the line isn't resident.
    function automatic [31:0] read_mem(input [31:0] addr);
        logic [18:0] tag;
        logic [9:0]  idx;
        logic        half;
        begin
            tag  = addr[31:13];
            idx  = addr[12:3];
            half = addr[2];
            if (dut.rv.dc.valid0[idx] && dut.rv.dc.tag0[idx] == tag)
                read_mem = half ? dut.rv.dc.mem0[idx][63:32] : dut.rv.dc.mem0[idx][31:0];
            else if (dut.rv.dc.valid1[idx] && dut.rv.dc.tag1[idx] == tag)
                read_mem = half ? dut.rv.dc.mem1[idx][63:32] : dut.rv.dc.mem1[idx][31:0];
            else if (dut.rv.dc.valid2[idx] && dut.rv.dc.tag2[idx] == tag)
                read_mem = half ? dut.rv.dc.mem2[idx][63:32] : dut.rv.dc.mem2[idx][31:0];
            else if (dut.rv.dc.valid3[idx] && dut.rv.dc.tag3[idx] == tag)
                read_mem = half ? dut.rv.dc.mem3[idx][63:32] : dut.rv.dc.mem3[idx][31:0];
            else
                read_mem = half ? dut.dcm.RAM[addr[18:3]][63:32] : dut.dcm.RAM[addr[18:3]][31:0];
        end
    endfunction

    initial #5000000 begin
        int expected[0:9];
        int actual[0:9];
        expected[0] = 5;  expected[1] = 11; expected[2] = 12; expected[3] = 22; expected[4] = 25;
        expected[5] = 33; expected[6] = 45; expected[7] = 64; expected[8] = 78; expected[9] = 90;

        actual[0] = read_mem(32'h2064); actual[1] = read_mem(32'h2068);
        actual[2] = read_mem(32'h206c); actual[3] = read_mem(32'h2070);
        actual[4] = read_mem(32'h2074); actual[5] = read_mem(32'h2078);
        actual[6] = read_mem(32'h207c); actual[7] = read_mem(32'h2080);
        actual[8] = read_mem(32'h2084); actual[9] = read_mem(32'h2088);

        $display("=== Sorted Array ===");
        pass = 1;
        for (int i = 0; i < 10; i++) begin
            $display("mem[0x%04h] = %0d (expected %0d)", 32'h2064 + i*4, actual[i], expected[i]);
            if (actual[i] !== expected[i]) pass = 0;
        end
        if (pass) $display("Quicksort PASSED");
        else      $display("Quicksort FAILED");
        perf.print_summary(pass, "Quicksort");
        $finish;
    end
endmodule