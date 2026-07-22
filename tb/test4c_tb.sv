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

    initial #5000 begin
        $display("--- Test 4c: Dirty writeback ---");
        // check dcache_mem at index 0x2000>>3 = 1024
        // lower 32 bits should be 55 after writeback
        if (dut.dcm.RAM[1024][31:0] === 32'd55)
            $display("Test 4c PASSED");
        else
            $display("Test 4c FAILED - dcache_mem[1024]=%0d", dut.dcm.RAM[1024][31:0]);
        $stop;
    end
endmodule