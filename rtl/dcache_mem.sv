module dcache_mem #(
    parameter WIDTH = 64,
    parameter DEPTH = 65536,  // 512KB
    parameter FILE = ""
)(
    input logic clk,
    input logic [$clog2(DEPTH)-1: 0] mrdaddress,
    input logic [$clog2(DEPTH)-1: 0] mwraddress,
    input logic mrden,
    input logic mwren,
    input logic [WIDTH-1: 0] d,
    output logic [WIDTH-1: 0] q);

    logic [WIDTH-1: 0] RAM [0: DEPTH-1];

    initial begin
    for (int i = 0; i < DEPTH; i++) RAM[i] = '0;
    if (FILE != "")
        $readmemh(FILE, RAM, 32'h2000>>3);
    end

    always_ff @(posedge clk) begin
        if(mwren) RAM[mwraddress] <= d;
        if(mrden) q <= RAM[mrdaddress];
    end

endmodule