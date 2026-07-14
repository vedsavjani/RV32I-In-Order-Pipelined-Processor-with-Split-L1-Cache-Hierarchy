module ID_EX_controlpipe(
    input clk, clr,
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
        RegWriteE <= clr? 0: RegWriteD;
        ResultSrcE <= clr? 3'b000: ResultSrcD;
        MemWriteE <= clr? 0: MemWriteD;
        JumpE <= clr? 0: JumpD;
        BranchE <= clr? 0: BranchD;
        alucontrolE <= clr? 4'b0000: alucontrolD;
        ALUSrcE <= clr? 0: ALUSrcD;
        jalrselE <= clr? 0: jalrselD;
    end    

endmodule


module EX_MEM_controlpipe(
    input clk,
    input logic RegWriteE,
    output logic RegWriteM,
    input logic [2:0] ResultSrcE,
    output logic [2:0] ResultSrcM,
    input logic MemWriteE,
    output logic MemWriteM);

    always_ff @(posedge clk) begin
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
    end
endmodule


module MEM_WB_controlpipe(
    input clk, 
    input logic RegWriteM,
    output logic RegWriteW,
    input logic [2:0] ResultSrcM,
    output logic [2:0] ResultSrcW);

    always_ff @(posedge clk) begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
    end

endmodule