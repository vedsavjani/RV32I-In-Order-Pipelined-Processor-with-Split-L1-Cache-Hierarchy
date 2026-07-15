module dmem(
    input logic clk, we,
    input logic  [31:0] a, wd,
    output logic [31:0] rd);

    logic [31:0] RAM [0:4095]; // 16kB data memory

    initial $readmemh("mem/quicksort_data.txt", RAM, 0, 4095);

    assign rd = RAM[a[13:2]];

    always_ff @(posedge clk) begin
        if (we) RAM[a[13:2]] <= wd;
    end
endmodule
