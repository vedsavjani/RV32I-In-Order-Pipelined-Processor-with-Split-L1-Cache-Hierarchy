module testbench();

    logic        clk, reset;
    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;

    top dut(clk, reset, WriteData, DataAdr, MemWrite);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    initial #10000000 begin
        $display("=== Dijkstra Distances from node 0 ===");
        $display("dist[0] = %0d", dut.dmem.RAM[32'h2100>>2]);
        $display("dist[1] = %0d", dut.dmem.RAM[32'h2104>>2]);
        $display("dist[2] = %0d", dut.dmem.RAM[32'h2108>>2]);
        $display("dist[3] = %0d", dut.dmem.RAM[32'h210c>>2]);
        $display("dist[4] = %0d", dut.dmem.RAM[32'h2110>>2]);
        $display("dist[5] = %0d", dut.dmem.RAM[32'h2114>>2]);
        $display("dist[6] = %0d", dut.dmem.RAM[32'h2118>>2]);
        $display("dist[7] = %0d", dut.dmem.RAM[32'h211c>>2]);
        $display("dist[8] = %0d", dut.dmem.RAM[32'h2120>>2]);
        $stop;
    end

    initial #5000000 $stop;
endmodule