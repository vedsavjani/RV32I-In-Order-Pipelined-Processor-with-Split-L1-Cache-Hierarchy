module hazard_unit(
    input logic [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW,
    input logic pcsrcE, ResultSrcE0, RegWriteM, RegWriteW,
    output logic stallF, stallD, flushD, flushE,
    output logic [1:0] forwardAE, forwardBE,
    input logic [2:0] ResultSrcM);

    logic lwstall, memstall;

    always_comb begin
        if ((rs1E !=0) & (RegWriteM & (rs1E == rdM))) forwardAE = 2'b10;
        else if ((rs1E !=0) & (RegWriteW & (rs1E == rdW))) forwardAE = 2'b01;
        else forwardAE = 2'b00;
    end

    always_comb begin
        if ((rs2E !=0) & (RegWriteM & (rs2E == rdM))) forwardBE = 2'b10;
        else if ((rs2E !=0) & (RegWriteW & (rs2E == rdW))) forwardBE = 2'b01;
        else forwardBE = 2'b00;
    end

    always_comb begin
        lwstall = ResultSrcE0 & ((rs1D == rdE) | (rs2D == rdE));
        memstall = (ResultSrcM != 3'b000) & RegWriteM & ((rs1E == rdM & rs1E != 5'b0) | (rs2E == rdM & rs2E != 5'b0));
        stallF = lwstall | memstall;
        stallD = lwstall | memstall;
    end

    always_comb begin
        flushD = pcsrcE;
        flushE = lwstall | pcsrcE | memstall;
    end
endmodule
