module ID_EX_controlpipe(
    input clk, clr, reset,
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
        RegWriteE <= (clr | reset)? 0: RegWriteD;
        ResultSrcE <= (clr | reset)? 3'b000: ResultSrcD;
        MemWriteE <= (clr | reset)? 0: MemWriteD;
        JumpE <= (clr | reset)? 0: JumpD;
        BranchE <= (clr | reset)? 0: BranchD;
        alucontrolE <= (clr | reset)? 4'b0000: alucontrolD;
        ALUSrcE <= (clr | reset)? 0: ALUSrcD;
        jalrselE <= (clr | reset)? 0: jalrselD;
    end    

endmodule


module EX_MEM_controlpipe(
    input clk, reset,
    input logic RegWriteE,
    output logic RegWriteM,
    input logic [2:0] ResultSrcE,
    output logic [2:0] ResultSrcM,
    input logic MemWriteE,
    output logic MemWriteM);

    always_ff @(posedge clk) begin
        RegWriteM <= reset? 0: RegWriteE;
        ResultSrcM <= reset? 3'b000: ResultSrcE;
        MemWriteM <= reset? 0: MemWriteE;
    end
endmodule


module MEM_WB_controlpipe(
    input clk, reset,
    input logic RegWriteM,
    output logic RegWriteW,
    input logic [2:0] ResultSrcM,
    output logic [2:0] ResultSrcW);

    always_ff @(posedge clk) begin
        RegWriteW <= reset? 0: RegWriteM;
        ResultSrcW <= reset? 3'b000: ResultSrcM;
    end

endmodule