module hazard_unit(
    input logic [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW,
    input logic pcsrcE, ResultSrcE0, RegWriteM, RegWriteW,
    output logic stallF, stallD, flushD, flushE,
    output logic [1:0] forwardAE, forwardBE);

    logic lwstall;

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
        stallF = lwstall;
        stallD = lwstall;
    end

    always_comb begin
        flushD = pcsrcE;
        flushE = lwstall | pcsrcE;
    end
endmodule
