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
    input logic clk, clr, reset, enn,
    input logic [31:0] rd1D, rd2D, instrD, pcD,
    output logic [31:0] rd1E, rd2E, instrE, pcE,
    input logic [4:0] rs1D, rs2D, rdD,
    output logic [4:0] rs1E, rs2E, rdE,
    input logic [31:0] immextD, pcplus4D, 
    output logic [31:0] immextE, pcplus4E);

    always_ff @(posedge clk) begin
        if (clr | reset) begin
            rd1E <= 32'h0; 
            rd2E <= 32'h0; 
            instrE <= 32'h0; 
            pcE <= 32'h0;
            rs1E <= 5'h0; 
            rs2E <= 5'h0; 
            rdE <= 5'h0;
            immextE <= 32'h0; 
            pcplus4E <= 32'h0;
        end
        else if (~enn) begin
            rd1E <= rd1D; 
            rd2E <= rd2D; 
            instrE <= instrD;
            pcE <= pcD;
            rs1E <= rs1D; 
            rs2E <= rs2D; 
            rdE <= rdD;
            immextE <= immextD; 
            pcplus4E <= pcplus4D;
        end
    end
endmodule


module EX_MEM_datapipe(
    input logic clk, reset, enn,
    input logic [31:0] aluresultE, writedataE, pcE,
    output logic [31:0] aluresultM, writedataM, pcM,
    input logic [4:0] rdE,
    output logic [4:0] rdM,
    input logic [31:0] instrE, pcplus4E,
    output logic [31:0] instrM, pcplus4M);

    always_ff @(posedge clk) begin
        if (reset) begin
            aluresultM <= 32'h0; 
            writedataM <= 32'h0; 
            pcM <= 32'h0;
            instrM <= 32'h0; 
            pcplus4M <= 32'h0; 
            rdM <= 5'h0;
        end
        else if (~enn) begin
            aluresultM <= aluresultE; 
            writedataM <= writedataE; 
            pcM <= pcE;
            instrM <= instrE; 
            pcplus4M <= pcplus4E; 
            rdM <= rdE;
        end
    end
endmodule


module MEM_WB_datapipe(
    input logic clk, reset, clr, enn,
    input logic [31:0] aluresultM, readdataM,
    output logic [31:0] aluresultW, readdataW,
    input logic [31:0] pcM, instrM, pcplus4M,
    output logic [31:0] pcW, instrW, pcplus4W,
    input logic [4:0] rdM,
    output logic [4:0] rdW);

    always_ff @(posedge clk) begin
        if (reset | clr) begin
            aluresultW <= 32'h0; 
            readdataW <= 32'h0;
            pcW <= 32'h0; 
            instrW <= 32'h0; 
            pcplus4W <= 32'h0; 
            rdW <= 5'h0;
        end
        else if (~enn) begin
            aluresultW <= aluresultM; 
            readdataW <= readdataM;
            pcW <= pcM; 
            instrW <= instrM; 
            pcplus4W <= pcplus4M; 
            rdW <= rdM;
        end
    end
endmodule