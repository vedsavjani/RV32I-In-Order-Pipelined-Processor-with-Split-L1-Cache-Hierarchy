module riscvsingle(
    input  logic        clk, reset,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic        MemWrite,
    output logic [31:0] aluresult, WriteData,
    input  logic [31:0] ReadData);

    logic       ALUSrc, RegWrite, Jump, zero, PCSrc;
    logic [1:0] ResultSrc, ImmSrc;
    logic [2:0] alucontrol;

    controller c(
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .zero(zero),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .alucontrol(alucontrol));

    datapath dp(
        .clk(clk),
        .reset(reset),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .alucontrol(alucontrol),
        .zero(zero),
        .PC(PC),
        .Instr(Instr),
        .aluresult(aluresult),
        .WriteData(WriteData),
        .ReadData(ReadData));

endmodule