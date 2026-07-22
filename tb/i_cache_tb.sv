`timescale 1ns/1ps

module i_cache_tb();

    logic clk, reset;

    logic [31:0] address;
    logic        rden;
    logic        hit_miss;
    logic [31:0] dout;

    logic [31:0] mrdaddress;
    logic        mrden;
    logic [31:0] mdin;

    int pass_count, fail_count;

    i_cache dut_cache (
        .clk(clk), .reset(reset),
        .address(address),
        .rden(rden),
        .hit_miss(hit_miss),
        .dout(dout),
        .mrdaddress(mrdaddress),
        .mrden(mrden),
        .mdin(mdin));

    icache_mem dut_mem (
        .clk(clk),
        .mrdaddress(mrdaddress[17:2]),
        .mrden(mrden),
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
        $monitor("time=%4d | addr=%h | hm=%b | dout=%h | way0=%h | way1=%h | lru0=%b | lru1=%b",
            $time, address, hit_miss, dout,
            dut_cache.mem0[1], dut_cache.mem1[1],
            dut_cache.lru0[1], dut_cache.lru1[1]);
    end

    task check_miss(input string name);
        if (hit_miss === 1'b0) begin
            $display("PASS | %s | miss detected correctly (hit_miss=0)", name);
            pass_count++;
        end else begin
            $display("FAIL | %s | expected miss (hit_miss=0), got hit_miss=%b", name, hit_miss);
            fail_count++;
        end
    endtask

    task check_resolved(input string name);
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
        address = 0; rden = 0;
        @(negedge reset);

        // test 1: miss
        address = 32'h00000004; rden = 1;
        @(negedge clk); check_miss("Test 1: Miss 0x00000004");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 1: Miss resolved 0x00000004");

        // test 2: miss
        address = 32'h10000008; rden = 1;
        @(negedge clk); check_miss("Test 2: Miss 0x10000008");
        repeat(3) @(posedge clk);
        @(negedge clk); check_resolved("Test 2: Miss resolved 0x10000008");

        // test 3: hit way0
        address = 32'h00000005; rden = 1;
        @(posedge clk);
        @(negedge clk); check_hit("Test 3: Hit way0 0x00000005");
        @(posedge clk);

        // test 4: hit way1
        address = 32'h10000009; rden = 1;
        @(posedge clk);
        @(negedge clk); check_hit("Test 4: Hit way1 0x10000009");
        @(posedge clk);

        // test 5: hit way0
        address = 32'h00000007; rden = 1;
        @(posedge clk);
        @(negedge clk); check_hit("Test 5: Hit way0 0x00000007");
        @(posedge clk);

        $display("----------------------------------------");
        $display("I-Cache Results: %0d/%0d PASSED, %0d/%0d FAILED", pass_count, pass_count+fail_count, fail_count, pass_count+fail_count);
        if (fail_count == 0)
            $display("I-Cache: ALL TESTS PASSED");
        else
            $display("I-Cache: SOME TESTS FAILED");
        $finish;
    end

endmodule