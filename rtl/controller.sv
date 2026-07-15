module controller(
    input logic clk, reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zeroE, negativeE,
    output logic       MemWriteM,
    output logic       pcsrcE, ALUSrcE,
    output logic       RegWriteW, RegWriteE,
    output logic [1:0] immsrcD,
    output logic [3:0] alucontrolE,
    output logic jalrselE,
    output logic RegWriteM,
    input logic flushE,
    output logic [2:0] ResultSrcW, ResultSrcM, ResultSrcE);

    logic [1:0] aluop;
    logic branchtakenE, jalrselD;
    logic RegWriteD;
    logic [2:0] ResultSrcD;
    logic MemWriteD, MemWriteE;
    logic BranchD, BranchE;
    logic JumpD, JumpE;
    logic [3:0] alucontrolD;
    logic ALUSrcD;

    maindec md(
        .op(op),
        .ResultSrc(ResultSrcD),
        .MemWrite(MemWriteD),
        .Branch(BranchD),
        .ALUSrc(ALUSrcD),
        .RegWrite(RegWriteD),
        .Jump(JumpD),
        .ImmSrc(immsrcD),
        .aluop(aluop),
        .jalrsel(jalrselD));

    aludec ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .aluop(aluop),
        .alucontrol(alucontrolD));

    ID_EX_controlpipe cp1(
        .clk(clk), .clr(flushE), .reset(reset),
        .RegWriteD(RegWriteD),
        .RegWriteE(RegWriteE),
        .ResultSrcD(ResultSrcD),
        .ResultSrcE(ResultSrcE),
        .MemWriteD(MemWriteD),
        .MemWriteE(MemWriteE),
        .JumpD(JumpD),
        .JumpE(JumpE),
        .BranchD(BranchD),
        .BranchE(BranchE),
        .alucontrolD(alucontrolD),
        .alucontrolE(alucontrolE),
        .ALUSrcD(ALUSrcD),
        .ALUSrcE(ALUSrcE),
        .jalrselD(jalrselD), 
        .jalrselE(jalrselE));

    EX_MEM_controlpipe cp2(
        .clk(clk), .reset(reset),
        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .ResultSrcE(ResultSrcE),
        .ResultSrcM(ResultSrcM),
        .MemWriteE(MemWriteE),
        .MemWriteM(MemWriteM));

    MEM_WB_controlpipe cp3(
        .clk(clk), .reset(reset),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcM(ResultSrcM),
        .ResultSrcW(ResultSrcW));

    always_comb begin
        case (funct3) 
            3'b000: branchtakenE = zeroE;        // beq
            3'b001: branchtakenE = ~zeroE;       // bne
            3'b100: branchtakenE = negativeE;    // blt
            3'b101: branchtakenE = ~negativeE;   // bge
            default: branchtakenE = 1'b0;
        endcase
    end
    assign pcsrcE = BranchE & branchtakenE | JumpE | jalrselE;

endmodule