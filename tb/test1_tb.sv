module testbench();
    logic clk, reset;
    logic [31:0] writedataM, aluresultM;
    logic MemWriteM;

    top dut(clk, reset, writedataM, aluresultM, MemWriteM);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    always @(negedge clk) begin
        $display("t=%0t pcF=%08h instrF=%08h icache_hit=%b stallF=%b stallD=%b",
            $time, dut.rv.pcF, dut.rv.instrF,
            dut.rv.icache_hit, dut.rv.stallF, dut.rv.stallD);
    end

    initial #500 begin
        $display("--- register check ---");
        $display("x1=%0d x2=%0d x3=%0d x4=%0d",
            dut.rv.dp.rf.rf[1], dut.rv.dp.rf.rf[2],
            dut.rv.dp.rf.rf[3], dut.rv.dp.rf.rf[4]);
        if (dut.rv.dp.rf.rf[1] === 32'd1 &&
            dut.rv.dp.rf.rf[2] === 32'd2 &&
            dut.rv.dp.rf.rf[3] === 32'd3 &&
            dut.rv.dp.rf.rf[4] === 32'd4)
            $display("Step 1 PASSED");
        else
            $display("Step 1 FAILED");
        $stop;
    end

endmodule