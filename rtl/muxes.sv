module mux2 #(parameter WIDTH = 8)(
    input  logic [WIDTH-1:0] d0, d1,
    input  logic s,
    output logic [WIDTH-1:0] y);

    assign y = s ? d1 : d0;

endmodule

module mux3 #(parameter WIDTH = 8)(
    input logic [WIDTH-1:0] d0, d1, d2,
    input logic [1:0] s,
    output logic [WIDTH-1:0] y);

    always_comb begin
        case(s) 
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = d0;
        endcase
    end
endmodule


module mux5 #(parameter WIDTH = 8)(
    input  logic [WIDTH-1:0] d0, d1, d2, d3, d4,
    input  logic [2:0] s,
    output logic [WIDTH-1:0] y);

    always_comb begin
        case (s)
            3'b000: y = d0;
            3'b001: y = d1;
            3'b010: y = d2;
            3'b011: y = d3;
            3'b100: y = d4;
            default: y = 32'b0;
        endcase
    end
endmodule
