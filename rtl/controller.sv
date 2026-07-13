module controller(
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zero, negative,
    output logic [2:0] ResultSrc,
    output logic       MemWrite,
    output logic       PCSrc, ALUSrc,
    output logic       RegWrite, Jump,
    output logic [1:0] ImmSrc,
    output logic [3:0] alucontrol,
    output logic jalrsel);

    logic [1:0] aluop;
    logic branchtaken, Branch;

    maindec md(
        .op(op),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .aluop(aluop),
        .jalrsel(jalrsel));

    aludec ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .aluop(aluop),
        .alucontrol(alucontrol));

    always_comb begin
        case (funct3) 
            3'b000: branchtaken = zero;        // beq
            3'b001: branchtaken = ~zero;       // bne
            3'b100: branchtaken = negative;    // blt
            3'b101: branchtaken = ~negative;   // bge
            default: branchtaken = 1'b0;
        endcase
    end
    assign PCSrc = Branch & branchtaken | Jump | jalrsel;

endmodule