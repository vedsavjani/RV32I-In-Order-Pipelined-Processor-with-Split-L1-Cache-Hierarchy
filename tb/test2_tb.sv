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

    always @(negedge clk) begin
        $display("t=%0t pcF=%08h instrF=%08h stallF=%b stallE=%b stallM=%b dcache_hit=%b",
            $time, dut.rv.pcF, dut.rv.instrF,
            dut.rv.stallF, dut.rv.stallE, dut.rv.stallM,
            dut.rv.dcache_hit);
    end

    initial #2000 begin
        $display("--- register check ---");
        $display("x1=0x%08h x2=%0d x3=%0d",
            dut.rv.dp.rf.rf[1],
            dut.rv.dp.rf.rf[2],
            dut.rv.dp.rf.rf[3]);
        pass = (dut.rv.dp.rf.rf[2] === 32'd5 &&
                dut.rv.dp.rf.rf[3] === 32'd6);
        if (pass) $display("Step 2 PASSED");
        else      $display("Step 2 FAILED");
        perf.print_summary(pass, "Test2");
        $finish;
    end

endmodule