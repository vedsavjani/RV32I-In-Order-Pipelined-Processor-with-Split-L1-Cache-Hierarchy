`timescale 1ns/1ps

module i_cache_tb();

    logic clk, reset;

    // cpu side
    logic [31:0] address;
    logic        rden;
    logic        hit_miss;
    logic [31:0] dout;

    // memory side
    logic [31:0] mrdaddress;
    logic        mrden;
    logic [31:0] mdin;

    // DUT instantiation
    i_cache dut_cache (
        .clk(clk), .reset(reset),
        .address(address),
        .rden(rden),
        .hit_miss(hit_miss),
        .dout(dout),
        .mrdaddress(mrdaddress),
        .mrden(mrden),
        .mdin(mdin));

    // memory instantiation
    icache_mem dut_mem (
        .clk(clk),
        .mrdaddress(mrdaddress[17:2]),
        .mrden(mrden),
        .q(mdin));

    // clock
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
        $monitor("time=%4d | addr=%h | hm=%b | dout=%h | way0=%h | way1=%h | lru0=%b | lru1=%b",
            $time, address, hit_miss, dout,
            dut_cache.mem0[1], dut_cache.mem1[1],
            dut_cache.lru0[1], dut_cache.lru1[1]);
    end

    // stimulus
    initial begin
        address = 0; rden = 0;
        @(negedge reset);

        // test 1: miss
        address = 32'h00000004; rden = 1;
        repeat(4) @(posedge clk);

        // test 2: miss
        address = 32'h10000008; rden = 1;
        repeat(4) @(posedge clk);

        // test 3: hit way0
        address = 32'h00000005; rden = 1;
        repeat(2) @(posedge clk);

        // test 4: hit way1
        address = 32'h10000009; rden = 1;  // same index as 0x10000008
        repeat(2) @(posedge clk);

        // test 5: hit way0
        address = 32'h00000007; rden = 1;
        repeat(2) @(posedge clk);

        $finish;
    end

endmodule