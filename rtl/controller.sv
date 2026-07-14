module controller(
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zeroE, negativeE,
    output logic [2:0] ResultSrcW,
    output logic       MemWriteM,
    output logic       pcsrcE, ALUSrcE,
    output logic       RegWriteW,
    output logic [1:0] immsrcD,
    output logic [3:0] alucontrolE,
    output logic jalrselE);

    logic [1:0] aluop;
    logic branchtakenE;
    logic RegWriteD, RegWriteE, RegWriteM, RegWriteW;
    logic [2:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW;
    logic MemWriteD, MemWriteE, MemWriteM;
    logic BranchD, BranchE;
    logic JumpD, JumpE;
    logic [3:0] alucontrolD, alucontrolE;
    logic ALUSrcD, ALUSrcE;

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
        .clk(clk), .clr(flushE),
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
        .clk(clk),
        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .ResultSrcE(ResultSrcE),
        .ResultSrcM(ResultSrcM),
        .MemWriteE(MemWriteE),
        .MemWriteM(MemWriteM));

    MEM_WB_controlpipe cp3(
        .clk(clk), 
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