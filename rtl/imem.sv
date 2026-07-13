module imem(
    input logic [31:0] a,
    output logic [31:0] rd);

    logic [31:0] RAM[0:4095]; // 16kB instruction memory

    initial $readmemh("mem/djikstras.txt", RAM);

    assign rd = RAM[a[31:2]]; // word aligned
endmodule
