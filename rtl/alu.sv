module alu(
    input  logic [31:0] srca, srcb,
    input  logic [3:0]  alucontrol,
    output logic [31:0] aluresult,
    output logic zero, negative);

    always_comb
        case(alucontrol)
            4'b0000: aluresult = srca + srcb;
            4'b0001: aluresult = srca - srcb;
            4'b0010: aluresult = srca & srcb;
            4'b0011: aluresult = srca | srcb;
            4'b0100: aluresult = srca ^ srcb;
            4'b0101: aluresult = {31'b0, $signed(srca) < $signed(srcb)};
            4'b0110: aluresult = {31'b0, srca < srcb};
            4'b0111: aluresult = srca << srcb;
            4'b1000: aluresult = srca >> srcb;
            4'b1001: aluresult = $signed(srca) >>> srcb;
            default: aluresult = 32'bx;
        endcase

    assign zero = (aluresult == 32'b0);
    assign negative = aluresult[31];

endmodule