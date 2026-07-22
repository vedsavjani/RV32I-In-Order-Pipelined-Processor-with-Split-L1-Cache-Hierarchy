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

    // Data files hold one 32-bit word per line, one per consecutive 4-byte
    // address (matching normal .word/array layout), but RAM is packed two
    // words per 64-bit entry (address bit 2 selects the half). Load into a
    // word-addressed staging array first, then pack pairs into RAM - a
    // straight $readmemh(FILE, RAM, ...) would instead drop each line into
    // its own 64-bit entry, leaving every odd word zero.
    logic [31:0] RAM32 [0: 2*DEPTH-1];

    initial begin
    for (int i = 0; i < DEPTH; i++) RAM[i] = '0;
    if (FILE != "") begin
        for (int i = 0; i < 2*DEPTH; i++) RAM32[i] = '0;
        $readmemh(FILE, RAM32, (32'h2000>>3)*2);
        for (int i = (32'h2000>>3); i < DEPTH; i++)
            RAM[i] = {RAM32[2*i+1], RAM32[2*i]};
    end
    end

    always_ff @(posedge clk) begin
        if(mwren) RAM[mwraddress] <= d;
        if(mrden) q <= RAM[mrdaddress];
    end

endmodule