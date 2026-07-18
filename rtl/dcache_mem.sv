module dcache_mem #(
    parameter WIDTH = 64,
    parameter DEPTH = 65536,  // 512KB
    parameter FILE = ""
)(
    input logic clk,
    input logic [$clog2(DEPTH)-1: 0] mrdaddress,
    input logic [$clog2(DEPTH)-1: 0] mwraddress,
    input logic rden,
    input logic wren,
    input logic [WIDTH-1: 0] d,
    output logic [WIDTH-1: 0] q);

    logic [WIDTH-1: 0] RAM [0: DEPTH-1];

    initial begin
    if (FILE != "")
        $readmemh(FILE, RAM);
    end

    always_ff @(posedge clk) begin
        if(wren) RAM[mwraddress] <= d;
        if(rden) q <= RAM[mrdaddress];
    end

endmodule