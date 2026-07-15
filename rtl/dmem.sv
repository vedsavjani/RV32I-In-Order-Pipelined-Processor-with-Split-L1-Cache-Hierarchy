module dmem(
    input logic clk, we,
    input logic  [31:0] a, wd,
    output logic [31:0] rd);

    logic [31:0] RAM [0:4095]; // 16kB data memory

    // uncomment the below line to check for quicksort and comment out the initialization of dmem to zero for dijkstras
    // initial $readmemh("mem/quicksort_data.txt", RAM, 32'h2000>>2);

    // initializing dmem to zero for dijkstras 
    initial begin
        integer i;
        for (i=0; i<4096; i++) RAM[i] = 32'b0;
    end

    assign rd = RAM[a[13:2]];

    always_ff @(posedge clk) begin
        if (we) RAM[a[13:2]] <= wd;
    end
endmodule
