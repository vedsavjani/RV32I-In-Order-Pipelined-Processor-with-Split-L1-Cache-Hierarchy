module icache_mem #(
    parameter WIDTH = 32,
    parameter DEPTH = 65536,  // 512KB
    parameter FILE = ""
)(
    input logic clk, 
    input logic [$clog2(DEPTH)-1: 0] mrdaddress,
    input logic mrden,
    output logic [WIDTH-1: 0] q);

    logic [WIDTH-1: 0] RAM [0: DEPTH-1];

    initial begin
    if (FILE != "")
        $readmemh(FILE, RAM);
    end

    always_ff @(posedge clk) begin
        if(mrden) q <= RAM[mrdaddress];
    end
endmodule