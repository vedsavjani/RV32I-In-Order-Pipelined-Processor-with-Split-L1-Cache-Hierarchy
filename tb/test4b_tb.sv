module testbench();
    logic clk, reset;
    logic [31:0] writedataM, aluresultM;
    logic MemWriteM;

    top dut(clk, reset, writedataM, aluresultM, MemWriteM);

    initial begin
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
        if (dut.rv.dp.rf.rf[6] === 32'd42 &&
            dut.rv.dp.rf.rf[7] === 32'd42)
            $display("Test 4b PASSED");
        else
            $display("Test 4b FAILED");
        $stop;
    end
endmodule