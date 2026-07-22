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

    initial #100000000 begin
        $display("=== Dijkstra 3-node distances from node 0 ===");
        $display("dist[0]    = %0d (expected 0)", read_mem(32'h2024));
        $display("dist[1]    = %0d (expected 4)", read_mem(32'h2028));
        $display("dist[2]    = %0d (expected 6)", read_mem(32'h202c));

        if (read_mem(32'h2024) === 32'd0 &&
            read_mem(32'h2028) === 32'd4 &&
            read_mem(32'h202c) === 32'd6)
            $display("Simulation succeeded");
        else
            $display("Simulation failed");

        $stop;
    end

endmodule