`timescale 1ns/1ps

module d_cache_tb();

    logic clk, reset;

    // cpu side signals
    logic [31:0] address;
    logic [31:0] din, dout;
    logic rden, wren;
    logic hit_miss;

    // memory side signals
    logic [31:0] mrdaddress, mwraddress;
    logic mrden, mwren;
    logic [63:0] mdin, mdout;

    // DUT instantiation
    d_cache dut_cache (
        .clk(clk), .reset(reset),
        .address(address),
        .din(din),
        .rden(rden),
        .wren(wren),
        .hit_miss(hit_miss),
        .dout(dout),
        .mrdaddress(mrdaddress),
        .mrden(mrden),
        .mwraddress(mwraddress),
        .mwren(mwren),
        .mdout(mdout),
        .mdin(mdin));


    // memory instantiation
    dcache_mem dut_mem (
        .clk(clk),
        .mrdaddress(mrdaddress[18:3]),
        .mwraddress(mwraddress[18:3]),
        .rden(mrden),
        .wren(mwren),
        .d(mdout),
        .q(mdin));


    // clock generator
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // reset
    initial begin
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
    end

    // monitor
    initial begin
        $monitor("time=%4d | addr=%h | hm=%b | dout=%h | way0=%h | way1=%h | way2=%h | way3=%h | lru0=%d | lru1=%d | lru2=%d | lru3=%d | mwren=%b | mwraddr=%h",
            $time, address, hit_miss, dout,
            dut_cache.mem0[1], dut_cache.mem1[1],
            dut_cache.mem2[1], dut_cache.mem3[1],
            dut_cache.lru0[1], dut_cache.lru1[1],
            dut_cache.lru2[1], dut_cache.lru3[1],
            mwren, mwraddress);
    end

    // stimulus
    // stimulus
    initial begin
        address = 0; din = 0; rden = 0; wren = 0;
        @(negedge reset);

        // setup — fill all 4 ways
        address = 32'h00000008; rden = 1; wren = 0;
        repeat(4) @(posedge clk);
        address = 32'h00000008; din = 32'hBADDBEEF; rden = 0; wren = 1;
        repeat(2) @(posedge clk);
        address = 32'h0000000B; din = 32'h00000000; rden = 0; wren = 1;
        repeat(2) @(posedge clk);
        address = 32'h0000000C; din = 32'hAAAAAAAA; rden = 0; wren = 1;
        repeat(2) @(posedge clk);
        address = 32'h10000008; rden = 1; wren = 0;
        repeat(4) @(posedge clk);
        address = 32'h20000008; rden = 1; wren = 0;
        repeat(4) @(posedge clk);
        address = 32'h30000008; rden = 1; wren = 0;
        repeat(4) @(posedge clk);

        // test 8
        $display("=== test 8: eviction ===");
        address = 32'h40000008; rden = 1; wren = 0;
        repeat(4) @(posedge clk);

        // test 9
        $display("=== test 9: should be miss ===");
        address = 32'h00000008; rden = 1; wren = 0;
        repeat(4) @(posedge clk);

        $finish;
    end
    
endmodule