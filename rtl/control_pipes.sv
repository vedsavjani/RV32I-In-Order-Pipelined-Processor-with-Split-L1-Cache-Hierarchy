module ID_EX_controlpipe(
    input clk, clr, reset, enn,
    input logic RegWriteD,
    output logic RegWriteE,
    input logic [2:0] ResultSrcD,
    output logic [2:0] ResultSrcE,
    input logic MemWriteD,
    output logic MemWriteE,
    input logic JumpD,
    output logic JumpE,
    input logic BranchD,
    output logic BranchE,
    input logic [3:0] alucontrolD,
    output logic [3:0] alucontrolE,
    input logic ALUSrcD,
    output logic ALUSrcE,
    input logic jalrselD, 
    output logic jalrselE);

    always_ff @(posedge clk) begin
        if (clr | reset) begin
            RegWriteE <= 0; ResultSrcE <= 3'b000; MemWriteE <= 0;
            JumpE <= 0; BranchE <= 0; alucontrolE <= 4'b0000;
            ALUSrcE <= 0; jalrselE <= 0;
        end
        else if (~enn) begin
            RegWriteE <= RegWriteD; ResultSrcE <= ResultSrcD; MemWriteE <= MemWriteD;
            JumpE <= JumpD; BranchE <= BranchD; alucontrolE <= alucontrolD;
            ALUSrcE <= ALUSrcD; jalrselE <= jalrselD;
        end
    end   

endmodule


module EX_MEM_controlpipe(
    input clk, reset, enn,
    input logic RegWriteE,
    output logic RegWriteM,
    input logic [2:0] ResultSrcE,
    output logic [2:0] ResultSrcM,
    input logic MemWriteE,
    output logic MemWriteM);

    always_ff @(posedge clk) begin
        if (reset) begin
            RegWriteM <= 0; ResultSrcM <= 3'b000; MemWriteM <= 0;
        end
        else if (~enn) begin
            RegWriteM <= RegWriteE; ResultSrcM <= ResultSrcE; MemWriteM <= MemWriteE;
        end
    end
endmodule


module MEM_WB_controlpipe(
    input logic clk, reset, clr, enn,
    input logic RegWriteM,
    output logic RegWriteW,
    input logic [2:0] ResultSrcM,
    output logic [2:0] ResultSrcW);

    always_ff @(posedge clk) begin
        if (reset | clr) begin
            RegWriteW <= 1'b0; 
            ResultSrcW <= 3'b000;
        end
        else if (~enn) begin
            RegWriteW <= RegWriteM; 
            ResultSrcW <= ResultSrcM;
        end
    end
endmodule