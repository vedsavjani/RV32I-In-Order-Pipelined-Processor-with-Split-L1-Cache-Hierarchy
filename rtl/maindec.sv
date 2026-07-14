module maindec(
    input  logic [6:0] op,
    output logic [2:0] ResultSrc,
    output logic       MemWrite,
    output logic       Branch, ALUSrc,
    output logic       RegWrite, Jump,
    output logic [1:0] ImmSrc,
    output logic [1:0] aluop,
    output logic jalrsel);

    logic [12:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
            ResultSrc, Branch, aluop, Jump, jalrsel} = controls;

    always_comb
        case(op)
            7'b0000011: controls = 13'b1_00_1_0_001_0_00_0_0; // lw
            7'b0100011: controls = 13'b0_01_1_1_000_0_00_0_0; // sw
            7'b0110011: controls = 13'b1_xx_0_0_000_0_10_0_0; // R-type
            7'b1100011: controls = 13'b0_10_0_0_000_1_01_0_0; // beq, bne, blt, bge
            7'b0010011: controls = 13'b1_00_1_0_000_0_10_0_0; // I-type ALU (addi, xori, slti, andi, ori, sltiu)
            7'b1101111: controls = 13'b1_11_0_0_010_0_00_1_0; // jal
            7'b1100111: controls = 13'b1_00_0_0_010_0_00_0_1; // jalr
            7'b0010111: controls = 13'b1_00_0_0_100_0_00_0_0; // auipc
            7'b0110111: controls = 13'b1_00_0_0_011_0_00_0_0; // lui
            default:    controls = 13'b0_00_0_0_000_0_00_0_0;
        endcase

endmodule
