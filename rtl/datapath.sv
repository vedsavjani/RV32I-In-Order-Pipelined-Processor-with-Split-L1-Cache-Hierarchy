module datapath(
    input logic clk, reset,
    input logic [2:0] ResultSrc,
    input logic PCSrc, ALUSrc,
    input logic RegWrite,
    input logic jalrsel,
    input logic [1:0]  ImmSrc,
    input logic [3:0]  alucontrol,
    output logic        zero, negative,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic [31:0] aluresult, WriteData,
    input logic [31:0] ReadData);

    logic [31:0] PCNext, PCPlus4, PCTarget, pcbase;
    logic [31:0] ImmExt;
    logic [31:0] srca, srcb;
    logic [31:0] Result;
    logic [31:0] auipcres;

    flopr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .d(PCNext),
        .q(PC));

    adder pcadd4(
        .a(PC),
        .b(32'd4),
        .y(PCPlus4));

    adder pcaddbranch(
        .a(pcbase),
        .b(ImmExt),
        .y(PCTarget));

    mux2 #(32) pcmux(
        .d0(PCPlus4),
        .d1(PCTarget),
        .s(PCSrc),
        .y(PCNext));

    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .ra1(Instr[19:15]),
        .ra2(Instr[24:20]),
        .wa3(Instr[11:7]),
        .wd3(Result),
        .rd1(srca),
        .rd2(WriteData));

    mux2 #(32) pctargetmux(
        .d0(PC),
        .d1(srca),
        .s(jalrsel),
        .y(pcbase));

    extend ext(
        .instr(Instr[31:0]),
        .immsrc(ImmSrc),
        .immext(ImmExt));

    mux2 #(32) srcbmux(
        .d0(WriteData),
        .d1(ImmExt),
        .s(ALUSrc),
        .y(srcb));

    alu alu(
        .srca(srca),
        .srcb(srcb),
        .alucontrol(alucontrol),
        .aluresult(aluresult),
        .zero(zero), 
        .negative(negative));

    adder auipcadd(
        .a({Instr[31:12], 12'b0}),
        .b(PC),
        .y(auipcres));

    mux5 #(32) resultmux(
        .d0(aluresult),
        .d1(ReadData),
        .d2(PCPlus4),
        .d3({Instr[31:12], 12'b0}),
        .d4(auipcres),
        .s(ResultSrc),
        .y(Result));

endmodule