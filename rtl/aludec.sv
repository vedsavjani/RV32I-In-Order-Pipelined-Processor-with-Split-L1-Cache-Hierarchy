module aludec(
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] aluop,
    output logic [3:0] alucontrol);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;

    always_comb
        case(aluop)
            2'b00: alucontrol = 4'b0000; // addition
            2'b01: alucontrol = 4'b0001; // subtraction
            default: case(funct3)
                3'b000: if (RtypeSub) alucontrol = 4'b0001; // sub
                        else          alucontrol = 4'b0000; // add, addi
                3'b001: alucontrol = 4'b0111; // sll, slli
                3'b010: alucontrol = 4'b0101; // slt, slti
                3'b011: alucontrol = 4'b0110; // sltu, sltiu
                3'b100: alucontrol = 4'b0100; // xor, xori
                3'b101: if (funct7b5) alucontrol = 4'b1001; // sra, srai
                        else          alucontrol = 4'b1000; // srl, srli
                3'b110: alucontrol = 4'b0011; // or, ori
                3'b111: alucontrol = 4'b0010; // and, andi
                default: alucontrol = 4'bxxxx;
            endcase
        endcase
endmodule
