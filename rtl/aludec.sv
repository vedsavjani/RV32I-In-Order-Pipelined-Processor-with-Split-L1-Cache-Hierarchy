module aludec(
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] aluop,
    output logic [2:0] alucontrol);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;

    always_comb
        case(aluop)
            2'b00: alucontrol = 3'b000; // addition
            2'b01: alucontrol = 3'b001; // subtraction
            default: case(funct3)
                3'b000: if (RtypeSub) alucontrol = 3'b001; // sub
                        else          alucontrol = 3'b000; // add, addi
                3'b010: alucontrol = 3'b101; // slt, slti
                3'b100: alucontrol = 3'b100; // xor, xori 
                3'b110: alucontrol = 3'b011; // or, ori
                3'b111: alucontrol = 3'b010; // and, andi
                default: alucontrol = 3'bxxx;
            endcase
        endcase
endmodule
