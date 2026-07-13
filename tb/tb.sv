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

    always @(negedge clk) begin
        if (MemWrite) begin
            $display("MemWrite: DataAdr=%0d WriteData=%0d", DataAdr, WriteData);
            if (DataAdr === 8 & WriteData === 32'hABCD127) begin
                $display("Simulation succeeded");
                $stop;
            end else if (DataAdr !== 8) begin
                $display("Simulation failed");
                $stop;
            end
        end
    end

endmodule