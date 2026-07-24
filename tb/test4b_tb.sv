module testbench();
    logic clk, reset;
    logic [31:0] writedataM, aluresultM;
    logic MemWriteM;

    top dut(clk, reset, writedataM, aluresultM, MemWriteM);

    logic pass;

    perf_monitor perf(
        .clk(clk), .reset(reset),
        .stallF(dut.rv.stallF), .stallD(dut.rv.stallD), .stallE(dut.rv.stallE), .stallM(dut.rv.stallM),
        .flushD(dut.rv.flushD), .flushE(dut.rv.flushE), .flushW(dut.rv.flushW),
        .ic_rden(dut.rv.ic.rden), .ic_state(dut.rv.ic.state), .ic_mrden(dut.rv.ic.mrden),
        .dc_rden(dut.rv.dcache_rden), .dc_wren(dut.rv.MemWriteM), .dc_state(dut.rv.dc.state), .dc_mrden(dut.rv.dc.mrden));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    initial #4000 begin
        $display("--- Test 4b: LRU eviction ---");
        $display("x6=%0d x7=%0d",
            dut.rv.dp.rf.rf[6],
            dut.rv.dp.rf.rf[7]);
        pass = (dut.rv.dp.rf.rf[6] === 32'd42 &&
                dut.rv.dp.rf.rf[7] === 32'd42);
        if (pass) $display("Test 4b PASSED");
        else      $display("Test 4b FAILED");
        perf.print_summary(pass, "Test4b");
        $finish;
    end
endmodule