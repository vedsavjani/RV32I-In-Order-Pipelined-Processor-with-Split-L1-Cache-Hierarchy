module riscvsingle(
    input  logic        clk, reset,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic        MemWrite,
    output logic [31:0] aluresult, WriteData,
    input  logic [31:0] ReadData);

    logic       ALUSrc, RegWrite, Jump, zero, negative, PCSrc, jalrsel;
    logic [1:0] ImmSrc;
    logic [2:0] ResultSrc;
    logic [3:0] alucontrol;

    controller c(
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .zero(zero),
        .negative(negative),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .alucontrol(alucontrol),
        .jalrsel(jalrsel));

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
        .negative(negative),
        .PC(PC),
        .Instr(Instr),
        .aluresult(aluresult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .jalrsel(jalrsel));

endmodule