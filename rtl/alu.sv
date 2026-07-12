module alu(
    input  logic [31:0] srca, srcb,
    input  logic [2:0]  alucontrol,
    output logic [31:0] aluresult,
    output logic        zero);

    always_comb
        case(alucontrol)
            3'b000: aluresult = srca + srcb;
            3'b001: aluresult = srca - srcb;
            3'b010: aluresult = srca & srcb;
            3'b011: aluresult = srca | srcb;
            3'b100: aluresult = srca ^ srcb;
            3'b101: aluresult = {31'b0, $signed(srca) < $signed(srcb)};
            default: aluresult = 32'bx;
        endcase

    assign zero = (aluresult == 32'b0);

endmodule