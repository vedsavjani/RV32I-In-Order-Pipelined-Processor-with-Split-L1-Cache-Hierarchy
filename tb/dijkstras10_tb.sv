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

    initial #500000000 begin
        $display("=== Dijkstra 10-node distances from node 0 ===");
        $display("dist[0] = %0d (expected 0)",     read_mem(32'h2190));
        $display("dist[1] = %0d (expected 4)",     read_mem(32'h2194));
        $display("dist[2] = %0d (expected 12)",    read_mem(32'h2198));
        $display("dist[3] = %0d (expected 19)",    read_mem(32'h219c));
        $display("dist[4] = %0d (expected 21)",    read_mem(32'h21a0));
        $display("dist[5] = %0d (expected 11)",    read_mem(32'h21a4));
        $display("dist[6] = %0d (expected 9)",     read_mem(32'h21a8));
        $display("dist[7] = %0d (expected 8)",     read_mem(32'h21ac));
        $display("dist[8] = %0d (expected 14)",    read_mem(32'h21b0));
        $display("dist[9] = %0d (expected 99999)", read_mem(32'h21b4));

        if (read_mem(32'h2190) === 32'd0  &&
            read_mem(32'h2194) === 32'd4  &&
            read_mem(32'h2198) === 32'd12 &&
            read_mem(32'h219c) === 32'd19 &&
            read_mem(32'h21a0) === 32'd21 &&
            read_mem(32'h21a4) === 32'd11 &&
            read_mem(32'h21a8) === 32'd9  &&
            read_mem(32'h21ac) === 32'd8  &&
            read_mem(32'h21b0) === 32'd14 &&
            read_mem(32'h21b4) === 32'd99999)
            $display("Simulation succeeded");
        else
            $display("Simulation failed");

        $stop;
    end

endmodule