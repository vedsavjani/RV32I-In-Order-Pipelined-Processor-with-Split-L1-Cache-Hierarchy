// tb for dijkstras with 3 nodes 
module testbench();

    logic        clk, reset;
    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;

    top dut(clk, reset, WriteData, DataAdr, MemWrite);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    always @(negedge clk) begin
        if (MemWrite)
            $display("t=%0t WRITE: addr=0x%08h data=0x%08h", $time, DataAdr, WriteData);
    end

    initial #100000000 begin
        $display("=== Dijkstra 3-node distances from node 0 ===");
        $display("dist[0]    = %0d (expected 0)", dut.dmem.RAM[32'h2024>>2]);
        $display("dist[1]    = %0d (expected 4)", dut.dmem.RAM[32'h2028>>2]);
        $display("dist[2]    = %0d (expected 6)", dut.dmem.RAM[32'h202c>>2]);

        if (dut.dmem.RAM[32'h2024>>2] === 32'd0 &&
            dut.dmem.RAM[32'h2028>>2] === 32'd4 &&
            dut.dmem.RAM[32'h202c>>2] === 32'd6)
            $display("Simulation succeeded");
        else
            $display("Simulation failed");

        $stop;
    end

endmodule