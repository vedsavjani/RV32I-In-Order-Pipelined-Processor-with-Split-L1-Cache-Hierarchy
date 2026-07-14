module top(
    input  logic clk, reset,
    output logic [31:0] writedataM, aluresultM,
    output logic MemWriteM);

    logic [31:0] pcF, instrF, readdataM;

    
    riscvsingle(
        .clk(clk), .reset(reset),
        .pcF(pcF),
        .instrF(instrF),
        .MemWriteM(MemWriteM),
        .aluresultM(aluresultM), .writedataM(writedataM),
        .readdataM(readdataM));

    imem(
        .a(pcF),
        .rd(instrF));

    dmem(
        .clk(clk), .we(MemWriteM),
        .a(aluresultM), .wd(writedataM),
        .rd(readdataM));
endmodule