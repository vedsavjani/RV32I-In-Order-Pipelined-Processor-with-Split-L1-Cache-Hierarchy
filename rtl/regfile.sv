module regfile(
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2);

    logic [31:0] rf[31:0];

    initial begin
        for (int i = 0; i < 32; i++) rf[i] = 0;
        rf[2] = 32'h00003ffc;
    end

    always_ff @(posedge clk)
        if (we3) rf[wa3] <= wd3;

    assign rd1 = (ra1 != 0) ? rf[ra1] : 32'b0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 32'b0;

endmodule