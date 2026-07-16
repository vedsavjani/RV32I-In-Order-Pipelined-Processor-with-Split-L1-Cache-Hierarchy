module datapath(
    input logic clk, reset,
    input logic [2:0] ResultSrcW,
    input logic pcsrcE, ALUSrcE,
    input logic RegWriteW,
    input logic jalrselE,
    input logic [1:0]  immsrcD,
    input logic [3:0]  alucontrolE,
    output logic zeroE, negativeE,
    output logic [31:0] pcF,
    input logic [31:0] instrF,
    output logic [31:0] aluresultM, writedataM,
    input logic [31:0] readdataM,
    input logic stallF, stallD, flushD, flushE,
    input logic [1:0] forwardAE, forwardBE,
    output logic [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW,
    output logic [31:0] instrD, instrE);

    logic [31:0] instrM, instrW;
    logic [31:0] pcD, pcE, pcM, pcW;
    logic [31:0] pcnext, pcplus4F, pcplus4D, pcplus4E, pcplus4M, pcplus4W;
    logic [31:0] pctargetE, pcbaseE;
    logic [31:0] immextD, immextE;
    logic [31:0] srcaE, srcbE;
    logic [31:0] resultW;
    logic [31:0] auipcresW;
    logic [31:0] rd1D, rd2D, rd1E, rd2E;
    logic [31:0] writedataE, aluresultE, aluresultW, readdataW;
    logic [4:0] rdD;

    mux2 #(32) pcmux(
        .d0(pcplus4F),
        .d1(pctargetE),
        .s(pcsrcE),
        .y(pcnext));

    PCReg pcreg(
        .clk(clk), 
        .enn(stallF),
        .reset(reset),
        .pcnext(pcnext),
        .pcF(pcF));

    adder pcadd4(
        .a(pcF),
        .b(32'd4),
        .y(pcplus4F));

    // IF_ID pipeline
    IF_ID_datapipe if_id_dp(
        .clk(clk), 
        .enn(stallD), 
        .reset(reset),
        .clr(flushD),
        .instrF(instrF),
        .instrD(instrD),
        .pcF(pcF),
        .pcD(pcD),
        .pcplus4F(pcplus4F),
        .pcplus4D(pcplus4D));

    regfile rf(
        .clk(clk),
        .we3(RegWriteW),
        .ra1(instrD[19:15]),
        .ra2(instrD[24:20]),
        .wa3(rdW),
        .wd3(resultW),
        .rd1(rd1D),
        .rd2(rd2D));

    extend ext(
        .instr(instrD[31:0]),
        .immsrc(immsrcD),
        .immext(immextD));

    assign rs1D = instrD[19:15];
    assign rs2D = instrD[24:20];
    assign rdD = instrD[11:7];

    // ID_EX pipeline
    ID_EX_datapipe id_ex_dp(
    .clk(clk), 
    .clr(flushE),
    .reset(reset),
    .rd1D(rd1D), .rd2D(rd2D), .instrD(instrD), .pcD(pcD),
    .rd1E(rd1E), .rd2E(rd2E), .instrE(instrE), .pcE(pcE),
    .rs1D(rs1D), .rs2D(rs2D), .rdD(rdD),
    .rs1E(rs1E), .rs2E(rs2E), .rdE(rdE),
    .immextD(immextD), .pcplus4D(pcplus4D), 
    .immextE(immextE), .pcplus4E(pcplus4E));

    mux2 #(32) pctargetmux(
        .d0(pcE),
        .d1(srcaE),
        .s(jalrselE),
        .y(pcbaseE));

    adder pcaddbranch(
        .a(pcbaseE),
        .b(immextE),
        .y(pctargetE));

    mux3 #(32) forwardamux(
        .d0(rd1E),
        .d1(resultW),
        .d2(aluresultM),
        .s(forwardAE),
        .y(srcaE));

    mux3 #(32) forwardbmux(
        .d0(rd2E),
        .d1(resultW),
        .d2(aluresultM),
        .s(forwardBE),
        .y(writedataE));

    mux2 #(32) srcbmux(
        .d0(writedataE),
        .d1(immextE),
        .s(ALUSrcE),
        .y(srcbE));

    alu alu(
        .srca(srcaE),
        .srcb(srcbE),
        .alucontrol(alucontrolE),
        .aluresult(aluresultE),
        .zero(zeroE), 
        .negative(negativeE));

    // EX_MEM pipeline
    EX_MEM_datapipe ex_mem_dp(
        .clk(clk), .reset(reset),
        .aluresultE(aluresultE), .writedataE(writedataE), .pcE(pcE),
        .aluresultM(aluresultM), .writedataM(writedataM), .pcM(pcM),
        .rdE(rdE),
        .rdM(rdM),
        .instrE(instrE), .pcplus4E(pcplus4E),
        .instrM(instrM), .pcplus4M(pcplus4M));

    // MEM_WB pipeline
    MEM_WB_datapipe mem_wb_dp(
    .clk(clk), .reset(reset),
    .aluresultM(aluresultM), .readdataM(readdataM),
    .aluresultW(aluresultW), .readdataW(readdataW),
    .pcM(pcM), .instrM(instrM), .pcplus4M(pcplus4M),
    .pcW(pcW), .instrW(instrW), .pcplus4W(pcplus4W),
    .rdM(rdM),
    .rdW(rdW));

    adder auipcadd(
        .a({instrW[31:12], 12'b0}),
        .b(pcW),
        .y(auipcresW));

    mux5 #(32) resultmux(
        .d0(aluresultW),
        .d1(readdataW),
        .d2(pcplus4W),
        .d3({instrW[31:12], 12'b0}),
        .d4(auipcresW),
        .s(ResultSrcW),
        .y(resultW));

endmodule