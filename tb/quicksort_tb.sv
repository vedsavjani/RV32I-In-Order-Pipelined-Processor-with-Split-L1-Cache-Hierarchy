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

    // d_cache is write-back: a location's current value may still be dirty
    // in the cache and never flushed to dcache_mem, so read through the
    // cache first (as a real load would) and only fall back to backing
    // memory when the line isn't resident.
    function automatic [31:0] read_mem(input [31:0] addr);
        logic [18:0] tag;
        logic [9:0]  idx;
        logic        half;
        begin
            tag  = addr[31:13];
            idx  = addr[12:3];
            half = addr[2];
            if (dut.rv.dc.valid0[idx] && dut.rv.dc.tag0[idx] == tag)
                read_mem = half ? dut.rv.dc.mem0[idx][63:32] : dut.rv.dc.mem0[idx][31:0];
            else if (dut.rv.dc.valid1[idx] && dut.rv.dc.tag1[idx] == tag)
                read_mem = half ? dut.rv.dc.mem1[idx][63:32] : dut.rv.dc.mem1[idx][31:0];
            else if (dut.rv.dc.valid2[idx] && dut.rv.dc.tag2[idx] == tag)
                read_mem = half ? dut.rv.dc.mem2[idx][63:32] : dut.rv.dc.mem2[idx][31:0];
            else if (dut.rv.dc.valid3[idx] && dut.rv.dc.tag3[idx] == tag)
                read_mem = half ? dut.rv.dc.mem3[idx][63:32] : dut.rv.dc.mem3[idx][31:0];
            else
                read_mem = half ? dut.dcm.RAM[addr[18:3]][63:32] : dut.dcm.RAM[addr[18:3]][31:0];
        end
    endfunction

    initial #5000000 begin
        $display("=== Sorted Array ===");
        $display("mem[0x2064] = %0d", read_mem(32'h2064));
        $display("mem[0x2068] = %0d", read_mem(32'h2068));
        $display("mem[0x206c] = %0d", read_mem(32'h206c));
        $display("mem[0x2070] = %0d", read_mem(32'h2070));
        $display("mem[0x2074] = %0d", read_mem(32'h2074));
        $display("mem[0x2078] = %0d", read_mem(32'h2078));
        $display("mem[0x207c] = %0d", read_mem(32'h207c));
        $display("mem[0x2080] = %0d", read_mem(32'h2080));
        $display("mem[0x2084] = %0d", read_mem(32'h2084));
        $display("mem[0x2088] = %0d", read_mem(32'h2088));
        $stop;
    end
endmodule