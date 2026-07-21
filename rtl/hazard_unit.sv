module hazard_unit(
    input logic [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW,
    input logic pcsrcE, RegWriteM, RegWriteW, RegWriteE,
    input logic icache_hit, dcache_hit,
    output logic stallF, stallD, stallE, stallM, 
    output logic flushD, flushE,flushW,
    output logic [1:0] forwardAE, forwardBE,
    input logic [2:0] ResultSrcM, ResultSrcE);

    logic lwstall, memstall, exstall, icache_stall, dcache_stall;

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
        icache_stall = ~icache_hit;
        dcache_stall =  ~dcache_hit;

        lwstall = (ResultSrcE == 3'b001) & ((rs1D == rdE) | (rs2D == rdE));

        memstall = (ResultSrcM != 3'b000) & RegWriteM & ((rs1E == rdM & rs1E != 5'b0) | (rs2E == rdM & rs2E != 5'b0));
        exstall = (ResultSrcE != 3'b001) & RegWriteE & ((rs1D == rdE & rs1D != 5'b0) | (rs2D == rdE & rs2D != 5'b0));

        stallF = lwstall | memstall | exstall | icache_stall | dcache_stall;
        stallD = lwstall | memstall | exstall | icache_stall | dcache_stall;
        stallE = dcache_stall;
        stallM = dcache_stall;
    end

    always_comb begin
        flushD = pcsrcE & ~(icache_stall | dcache_stall);
        flushE = (lwstall | pcsrcE | memstall | exstall) & ~dcache_stall;
        flushW = dcache_stall;
    end
endmodule
