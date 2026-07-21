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

    always @(negedge clk) begin
        if ($time >= 150 && $time <= 400) begin
            $display("t=%0t | pcF=%0d | rdE=%0d rdM=%0d rdW=%0d | RegWriteW=%0b | resultW=%0d | stallF=%0b stallD=%0b stallE=%0b stallM=%0b | flushD=%0b flushE=%0b flushW=%0b | icache_stall=%0b dcache_stall=%0b | pcsrcE=%0b pctargetE=%0d",
                $time,
                dut.rv.dp.pcF,
                dut.rv.dp.rdE,
                dut.rv.dp.rdM,
                dut.rv.dp.rdW,
                dut.rv.dp.RegWriteW,
                dut.rv.dp.resultW,
                dut.rv.hu.stallF,
                dut.rv.hu.stallD,
                dut.rv.hu.stallE,
                dut.rv.hu.stallM,
                dut.rv.hu.flushD,
                dut.rv.hu.flushE,
                dut.rv.hu.flushW,
                dut.rv.hu.icache_stall,
                dut.rv.hu.dcache_stall,
                dut.rv.dp.pcsrcE,
                dut.rv.dp.pctargetE);
        end
    end

    initial #2000 begin
        $display("--- register check ---");
        $display("x1=0x%08h x2=%0d x3=%0d x4=%0d",
            dut.rv.dp.rf.rf[1],
            dut.rv.dp.rf.rf[2],
            dut.rv.dp.rf.rf[3],
            dut.rv.dp.rf.rf[4]);
        if (dut.rv.dp.rf.rf[1] === 32'h00002000 &&
            dut.rv.dp.rf.rf[2] === 32'd7 &&
            dut.rv.dp.rf.rf[3] === 32'd7 &&
            dut.rv.dp.rf.rf[4] === 32'd8)
            $display("Step 3 PASSED");
        else
            $display("Step 3 FAILED");
        $stop;
    end

endmodule