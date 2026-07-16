module dmem(
    input logic clk, we,
    input logic  [31:0] a, wd,
    output logic [31:0] rd);

    logic [31:0] RAM [0:4095]; // 16kB data memory

    // initializing dmem for quicksort
    // initial $readmemh("mem/quicksort_data.txt", RAM, 32'h2000>>2);

    // initializing dmem for dijkstras with 3 nodes
    // initial $readmemh("mem/dijkstras3_data.txt", RAM, 32'h2000 >> 2);

    // initializing dmem for dijkstras with 10 nodes
    initial $readmemh("mem/dijkstras10_data.txt", RAM, 32'h2000 >> 2);

    assign rd = RAM[a[13:2]];

    always_ff @(posedge clk) begin
        if (we) RAM[a[13:2]] <= wd;
    end
endmodule
