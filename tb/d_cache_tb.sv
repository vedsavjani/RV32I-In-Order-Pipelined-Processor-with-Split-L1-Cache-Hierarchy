`timescale 1ns/1ps

module d_cache_tb();

    logic clk, reset;

    logic [31:0] address;
    logic [31:0] din, dout;
    logic rden, wren;
    logic hit_miss;

    logic [31:0] mrdaddress, mwraddress;
    logic mrden, mwren;
    logic [63:0] mdin, mdout;

    int pass_count, fail_count;

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

    dcache_mem dut_mem (
        .clk(clk),
        .mrdaddress(mrdaddress[18:3]),
        .mwraddress(mwraddress[18:3]),
        .mrden(mrden),
        .mwren(mwren),
        .d(mdout),
        .q(mdin));

    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    initial begin
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
    end

    // detailed monitor trace
    initial begin
        $monitor("time=%4d | addr=%h | hm=%b | dout=%h | way0=%h | way1=%h | way2=%h | way3=%h | lru0=%d | lru1=%d | lru2=%d | lru3=%d",
            $time, address, hit_miss, dout,
            dut_cache.mem0[1], dut_cache.mem1[1],
            dut_cache.mem2[1], dut_cache.mem3[1],
            dut_cache.lru0[1], dut_cache.lru1[1],
            dut_cache.lru2[1], dut_cache.lru3[1]);
    end

    task check_miss(input string name);
        // check hit_miss=0 at start of miss
        if (hit_miss === 1'b0) begin
            $display("PASS | %s | miss detected correctly (hit_miss=0)", name);
            pass_count++;
        end else begin
            $display("FAIL | %s | expected miss (hit_miss=0), got hit_miss=%b", name, hit_miss);
            fail_count++;
        end
    endtask

    task check_resolved(input string name);
        // check hit_miss=1 after miss resolves
        if (hit_miss === 1'b1) begin
            $display("PASS | %s | miss resolved correctly (hit_miss=1)", name);
            pass_count++;
        end else begin
            $display("FAIL | %s | expected resolved (hit_miss=1), got hit_miss=%b", name, hit_miss);
            fail_count++;
        end
    endtask

    task check_hit(input string name);
        if (hit_miss === 1'b1) begin
            $display("PASS | %s | hit detected correctly (hit_miss=1)", name);
            pass_count++;
        end else begin
            $display("FAIL | %s | expected hit (hit_miss=1), got hit_miss=%b", name, hit_miss);
            fail_count++;
        end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;
        address = 0; din = 0; rden = 0; wren = 0;
        @(negedge reset);

        // test 1: miss - 0x00000008
        address = 32'h00000008; rden = 1; wren = 0;
        @(negedge clk); check_miss("Test 1: Miss 0x00000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 1: Miss resolved 0x00000008");

        // test 2: write hit - 0x00000008
        address = 32'h00000008; din = 32'hBADDBEEF; rden = 0; wren = 1;
        @(posedge clk);
        @(negedge clk); check_hit("Test 2: Write hit 0x00000008");
        @(posedge clk);

        // test 3: write hit - 0x0000000B
        address = 32'h0000000B; din = 32'h00000000; rden = 0; wren = 1;
        @(posedge clk);
        @(negedge clk); check_hit("Test 3: Write hit 0x0000000B");
        @(posedge clk);

        // test 4: write hit - 0x0000000C
        address = 32'h0000000C; din = 32'hAAAAAAAA; rden = 0; wren = 1;
        @(posedge clk);
        @(negedge clk); check_hit("Test 4: Write hit 0x0000000C");
        @(posedge clk);

        // test 5: miss - 0x10000008
        address = 32'h10000008; rden = 1; wren = 0;
        @(negedge clk); check_miss("Test 5: Miss 0x10000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 5: Miss resolved 0x10000008");

        // test 6: miss - 0x20000008
        address = 32'h20000008; rden = 1; wren = 0;
        @(negedge clk); check_miss("Test 6: Miss 0x20000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 6: Miss resolved 0x20000008");

        // test 7: miss - 0x30000008
        address = 32'h30000008; rden = 1; wren = 0;
        @(negedge clk); check_miss("Test 7: Miss 0x30000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 7: Miss resolved 0x30000008");

        // test 8: miss + eviction - 0x40000008
        address = 32'h40000008; rden = 1; wren = 0;
        @(negedge clk); check_miss("Test 8: Miss+eviction 0x40000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 8: Miss+eviction resolved 0x40000008");

        // test 9: miss (evicted) - 0x00000008
        address = 32'h00000008; rden = 1; wren = 0;
        @(negedge clk); check_miss("Test 9: Miss evicted 0x00000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 9: Miss evicted resolved 0x00000008");

        // test 10: miss + write allocate - 0x10000008
        address = 32'h10000008; din = 32'hBADDBEEF; rden = 0; wren = 1;
        @(negedge clk); check_miss("Test 10: Write-allocate miss 0x10000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 10: Write-allocate resolved 0x10000008");

        $display("----------------------------------------");
        $display("D-Cache Results: %0d/%0d PASSED, %0d/%0d FAILED", pass_count, pass_count+fail_count, fail_count, pass_count+fail_count);
        if (fail_count == 0)
            $display("D-Cache: ALL TESTS PASSED");
        else
            $display("D-Cache: SOME TESTS FAILED");
        $finish;
    end

endmodule