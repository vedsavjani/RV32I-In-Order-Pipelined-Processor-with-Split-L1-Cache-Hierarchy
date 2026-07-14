module PCReg(
    input logic clk, enn, reset,
    input logic [31:0] pcnext,
    output logic [31:0] pcF);

    initial pcF = 32'h00000000;

    always_ff @(posedge clk) begin
        pcF <= reset ? 32'h0 : (enn ? pcF : pcnext);
    end

endmodule


module IF_ID_datapipe(
    input logic clk, enn, clr, reset,
    input logic [31:0] instrF,
    output logic [31:0] instrD,
    input logic [31:0] pcF,
    output logic [31:0] pcD,
    input logic [31:0] pcplus4F,
    output logic [31:0] pcplus4D);

    always_ff @(posedge clk) begin
        if (clr | reset) begin
            instrD <= 32'h00000000;
            pcD <= 32'h00000000;
            pcplus4D <= 32'h00000000;
        end 
        else if (~enn) begin
            instrD <= instrF;
            pcD <= pcF;
            pcplus4D <= pcplus4F;
        end
    end

endmodule


module ID_EX_datapipe(
    input logic clk, clr, reset,
    input logic [31:0] rd1D, rd2D, instrD, pcD,
    output logic [31:0] rd1E, rd2E, instrE, pcE,
    input logic [4:0] rs1D, rs2D, rdD,
    output logic [4:0] rs1E, rs2E, rdE,
    input [31:0] immextD, pcplus4D, 
    output [31:0] immextE, pcplus4E);

    always_ff @(posedge clk) begin
        rd1E <= (clr | reset) ? 32'h0 : rd1D;
        rd2E <= (clr | reset) ? 32'h0 : rd2D;
        instrE <= (clr | reset) ? 32'h0 : instrD;
        pcE <= (clr | reset) ? 32'h0 : pcD;
        rs1E <= (clr | reset) ? 5'h0 : rs1D;
        rs2E <= (clr | reset) ? 5'h0 : rs2D;
        rdE <= (clr | reset) ? 5'h0 : rdD;
        immextE <= (clr | reset) ? 32'h0 : immextD;
        pcplus4E <= (clr | reset) ? 32'h0 : pcplus4D;
    end
endmodule


module EX_MEM_datapipe(
    input logic clk, reset,
    input logic [31:0] aluresultE, writedataE, pcE,
    output logic [31:0] aluresultM, writedataM, pcM,
    input logic [4:0] rdE,
    output logic [4:0] rdM,
    input logic [31:0] instrE, pcplus4E,
    output logic [31:0] instrM, pcplus4M);

    always_ff @(posedge clk) begin
        aluresultM <= reset ? 32'h0 : aluresultE;
        writedataM <= reset ? 32'h0 : writedataE;
        pcM <= reset ? 32'h0 : pcE;
        instrM <= reset ? 32'h0 : instrE;
        pcplus4M <= reset ? 32'h0 : pcplus4E;
        rdM <= reset ? 5'h0  : rdE;
    end

endmodule


module MEM_WB_datapipe(
    input logic clk, reset,
    input logic [31:0] aluresultM, readdataM,
    output logic [31:0] aluresultW, readdataW,
    input logic [31:0] pcM, instrM, pcplus4M,
    output logic [31:0] pcW, instrW, pcplus4W,
    input logic [4:0] rdM,
    output logic [4:0] rdW);

    always_ff @(posedge clk) begin
        aluresultW <= reset ? 32'h0 : aluresultM;
        readdataW <= reset ? 32'h0 : readdataM;
        pcW <= reset ? 32'h0 : pcM;
        instrW <= reset ? 32'h0 : instrM;
        pcplus4W <= reset ? 32'h0 : pcplus4M;
        rdW <= reset ? 5'h0 : rdM;
    end
endmodule