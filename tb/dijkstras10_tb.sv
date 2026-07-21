// testbench for dijkstras with 10 nodes 
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

    initial #500000000 begin
        $display("=== Dijkstra 10-node distances from node 0 ===");
        $display("dist[0] = %0d (expected 0)",     dut.dmem.RAM[32'h2190>>2]);
        $display("dist[1] = %0d (expected 4)",     dut.dmem.RAM[32'h2194>>2]);
        $display("dist[2] = %0d (expected 12)",    dut.dmem.RAM[32'h2198>>2]);
        $display("dist[3] = %0d (expected 19)",    dut.dmem.RAM[32'h219c>>2]);
        $display("dist[4] = %0d (expected 21)",    dut.dmem.RAM[32'h21a0>>2]);
        $display("dist[5] = %0d (expected 11)",    dut.dmem.RAM[32'h21a4>>2]);
        $display("dist[6] = %0d (expected 9)",     dut.dmem.RAM[32'h21a8>>2]);
        $display("dist[7] = %0d (expected 8)",     dut.dmem.RAM[32'h21ac>>2]);
        $display("dist[8] = %0d (expected 14)",    dut.dmem.RAM[32'h21b0>>2]);
        $display("dist[9] = %0d (expected 99999)", dut.dmem.RAM[32'h21b4>>2]);

        if (dut.dmem.RAM[32'h2190>>2] === 32'd0  &&
            dut.dmem.RAM[32'h2194>>2] === 32'd4  &&
            dut.dmem.RAM[32'h2198>>2] === 32'd12 &&
            dut.dmem.RAM[32'h219c>>2] === 32'd19 &&
            dut.dmem.RAM[32'h21a0>>2] === 32'd21 &&
            dut.dmem.RAM[32'h21a4>>2] === 32'd11 &&
            dut.dmem.RAM[32'h21a8>>2] === 32'd9  &&
            dut.dmem.RAM[32'h21ac>>2] === 32'd8  &&
            dut.dmem.RAM[32'h21b0>>2] === 32'd14 &&
            dut.dmem.RAM[32'h21b4>>2] === 32'd99999)
            $display("Simulation succeeded");
        else
            $display("Simulation failed");

        $stop;
    end

endmodule