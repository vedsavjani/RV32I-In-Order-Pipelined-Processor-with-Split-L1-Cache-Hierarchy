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
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    initial #5000 begin
        $display("--- Test 4c: Dirty writeback ---");
        // check dcache_mem at index 0x2000>>3 = 1024
        // lower 32 bits should be 55 after writeback
        pass = (dut.dcm.RAM[1024][31:0] === 32'd55);
        if (pass) $display("Test 4c PASSED");
        else      $display("Test 4c FAILED - dcache_mem[1024]=%0d", dut.dcm.RAM[1024][31:0]);
        perf.print_summary(pass, "Test4c");
        $finish;
    end
endmodule