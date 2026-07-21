//tb for harris and harris test program
module testbench();

    logic        clk, reset;
    logic [31:0] writedataM, aluresultM;
    logic        MemWriteM;

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
        if (MemWriteM)
            $display("t=%0t WRITE: addr=0x%08h data=0x%08h", $time, aluresultM, writedataM);
    end

    initial #50000 begin
        $display("=== HH Test Results ===");
        $display("mem[0x2000] = 0x%08h (expected 0x00000007)", dut.dcm.RAM[32'h2000>>3][31:0]);
        $display("mem[0x2004] = 0x%08h (expected 0x00000019)", dut.dcm.RAM[32'h2000>>3][63:32]);

        if (dut.dcm.RAM[32'h2000>>3][31:0]  === 32'd7 &&
            dut.dcm.RAM[32'h2000>>3][63:32] === 32'd25)
            $display("Simulation succeeded");
        else
            $display("Simulation failed");

        $stop;
    end

endmodule