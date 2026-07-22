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
        $display("--- Test 3b: Load-use hazard + icache stall ---");
        $display("x1=0x%08h x3=%0d x4=%0d",
            dut.rv.dp.rf.rf[1],
            dut.rv.dp.rf.rf[3],
            dut.rv.dp.rf.rf[4]);
        if (dut.rv.dp.rf.rf[1] === 32'h00002000 &&
            dut.rv.dp.rf.rf[3] === 32'd7 &&
            dut.rv.dp.rf.rf[4] === 32'd8)
            $display("Test 3b PASSED");
        else
            $display("Test 3b FAILED");
        $stop;
    end
endmodule