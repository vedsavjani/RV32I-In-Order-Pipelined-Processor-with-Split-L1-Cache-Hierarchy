module riscvsingle(
    input  logic clk, reset,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic        MemWriteM,
    output logic [31:0] aluresultM, writedataM,
    input  logic [31:0] readdataM);

    logic ALUSrcE, RegWriteM, RegWriteW, zeroE, negativeE, pcsrcE, jalrselE;
    logic [1:0] immsrcD, forwardAE, forwardBE;
    logic [2:0] ResultSrcE, ResultSrcW;
    logic [3:0] alucontrolE;
    logic [31:0] instrD;
    logic stallF, stallD, flushD, flushE;
    logic [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW;

    controller c(
        .op(instrD[6:0]),
        .funct3(instrD[14:12]),
        .funct7b5(instrD[30]),
        .zeroE(zeroE), .negativeE(negativeE),
        .ResultSrcW(ResultSrcW),
        .MemWriteM(MemWriteM),
        .pcsrcE(pcsrcE), ,ALUSrcE(ALUSrcE),
        .RegWriteW(RegWriteW),
        .immsrcD(immsrcD),
        .alucontrolE(alucontrolE),
        .jalrselE(jalrselE));

    datapath dp(
        .clk(clk), .reset(reset),
        .ResultSrcW(ResultSrcW),
        .pcsrcE(pcsrcE), .ALUSrcE(ALUSrcE),
        .RegWriteW(RegWriteW),
        .jalrselE(jalrselE),
        .immsrcD(immsrcD),
        .alucontrolE(alucontrolE),
        .zeroE(zeroE), .negativeE(negativeE),
        .pcF(pcF),
        .instrF(instrF),
        .aluresultM(aluresultM), .writedataM(writedataM),
        .readdataM(readdataM),
        .stallF(stallF), .stallD(stallD), .flushD(flushD), .flushE(flushE),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .rs1D(rs1D), .rs2D(rs2D), .rs1E(rs1E), .rs2E(rs2E), .rdE(rdE), .rdM(rdM), .rdW(rdW),
        .instrD(instrD));

    hazard_unit hu(
        .rs1D(rs1D), .rs2D(rs2D), .rs1E(rs1E), .rs2E(rs2E), .rdE(rdE), .rdM(rdM), .rdW(rdW),
        .pcsrcE(pcsrcE), .ResultSrcE0(ResultSrcE[0]), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .stallF(stallF), .stallD(stallD), .flushD(flushD), .flushE(flushE),
        .forwardAE(forwardAE), .forwardBE(forwardBE));
endmodule