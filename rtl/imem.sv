module imem(
    input logic [31:0] a,
    output logic [31:0] rd);

    logic [31:0] RAM[0:4095]; // 16kB instruction memory

    // instructions for quicksort
    // initial $readmemh("mem/quicksort.txt", RAM);

    // instructions for dijkstras with 3 nodes
    // initial $readmemh("mem/dijkstras3.txt", RAM);

    // instructions for dijkstras with 10 nodes
    initial $readmemh("mem/dijkstras10.txt", RAM);

    assign rd = RAM[a[31:2]]; // word aligned
endmodule
