// tb for quicksort
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

    initial #5000000 begin
        $display("=== Sorted Array ===");
        $display("mem[0x2064] = %0d", dut.dmem.RAM[32'h2064>>2]);
        $display("mem[0x2068] = %0d", dut.dmem.RAM[32'h2068>>2]);
        $display("mem[0x206c] = %0d", dut.dmem.RAM[32'h206c>>2]);
        $display("mem[0x2070] = %0d", dut.dmem.RAM[32'h2070>>2]);
        $display("mem[0x2074] = %0d", dut.dmem.RAM[32'h2074>>2]);
        $display("mem[0x2078] = %0d", dut.dmem.RAM[32'h2078>>2]);
        $display("mem[0x207c] = %0d", dut.dmem.RAM[32'h207c>>2]);
        $display("mem[0x2080] = %0d", dut.dmem.RAM[32'h2080>>2]);
        $display("mem[0x2084] = %0d", dut.dmem.RAM[32'h2084>>2]);
        $display("mem[0x2088] = %0d", dut.dmem.RAM[32'h2088>>2]);
        $stop;
    end
endmodule

// tb for dijkstras with 3 nodes 
// module testbench();

//     logic        clk, reset;
//     logic [31:0] WriteData, DataAdr;
//     logic        MemWrite;

//     top dut(clk, reset, WriteData, DataAdr, MemWrite);

//     initial begin
//         $dumpfile("dump.vcd");
//         $dumpvars(0, dut);
//         reset <= 1; #22; reset <= 0;
//     end

//     always begin
//         clk <= 1; #5; clk <= 0; #5;
//     end

//     always @(negedge clk) begin
//         if (MemWrite)
//             $display("t=%0t WRITE: addr=0x%08h data=0x%08h", $time, DataAdr, WriteData);
//     end

//     initial #100000000 begin
//         $display("=== Dijkstra 3-node distances from node 0 ===");
//         $display("dist[0]    = %0d (expected 0)", dut.dmem.RAM[32'h2024>>2]);
//         $display("dist[1]    = %0d (expected 4)", dut.dmem.RAM[32'h2028>>2]);
//         $display("dist[2]    = %0d (expected 6)", dut.dmem.RAM[32'h202c>>2]);

//         if (dut.dmem.RAM[32'h2024>>2] === 32'd0 &&
//             dut.dmem.RAM[32'h2028>>2] === 32'd4 &&
//             dut.dmem.RAM[32'h202c>>2] === 32'd6)
//             $display("Simulation succeeded");
//         else
//             $display("Simulation failed");

//         $stop;
//     end

// endmodule