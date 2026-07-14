module testbench();
    logic        clk, reset;
    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;

    top dut(clk, reset, WriteData, DataAdr, MemWrite);

    integer cycle_count = 0;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    always @(posedge clk) cycle_count <= cycle_count + 1;

    always @(negedge clk) begin
        if (cycle_count > 10 && cycle_count < 200)
            $display("cycle=%0d PC=%h instr=%h", cycle_count, dut.rv.dp.pcF, dut.instrF);
    end

    initial #5000000 $stop;
endmodule