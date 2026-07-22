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

    initial #2000 begin
        $display("--- Test 4a: Spatial locality ---");
        $display("x3=%0d x4=%0d",
            dut.rv.dp.rf.rf[3],
            dut.rv.dp.rf.rf[4]);
        if (dut.rv.dp.rf.rf[3] === 32'd42 &&
            dut.rv.dp.rf.rf[4] === 32'd0)
            $display("Test 4a PASSED");
        else
            $display("Test 4a FAILED");
        $stop;
    end
endmodule