module riscv_core(
    input  logic clk, reset,
    output logic [31:0] d_mrdaddress, d_mwraddress, i_mrdaddress,
    output logic d_mrden, d_mwren, i_mrden,
    output logic [63:0] d_mdout,
    input logic [63:0] d_mdin,
    input logic [31:0] i_mdin,
    output logic [31:0] aluresultM, writedataM,
    output logic MemWriteM);

    logic ALUSrcE, RegWriteE, RegWriteM, RegWriteW, zeroE, negativeE, pcsrcE, jalrselE;
    logic [1:0] immsrcD, forwardAE, forwardBE;
    logic [2:0] ResultSrcE, ResultSrcM, ResultSrcW;
    logic [3:0] alucontrolE;
    logic [31:0] instrF, instrD, instrE;
    logic stallF, stallD, stallE, stallM, flushD, flushE, flushW;
    logic [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW;
    logic [31:0] pcF, readdataM;
    logic dcache_hit, icache_hit;
    logic dcache_rden;
    assign dcache_rden = (ResultSrcM == 3'b001);

    controller c(
        .clk(clk), .reset(reset),
        .op(instrD[6:0]),
        .funct3(instrD[14:12]),
        .funct3E(instrE[14:12]),
        .funct7b5(instrD[30]),
        .zeroE(zeroE), .negativeE(negativeE),
        .ResultSrcW(ResultSrcW),
        .ResultSrcE(ResultSrcE),
        .MemWriteM(MemWriteM),
        .pcsrcE(pcsrcE), .ALUSrcE(ALUSrcE),
        .RegWriteW(RegWriteW),
        .RegWriteE(RegWriteE),
        .immsrcD(immsrcD),
        .alucontrolE(alucontrolE),
        .jalrselE(jalrselE),
        .RegWriteM(RegWriteM),
        .stallE(stallE),
        .stallM(stallM),
        .flushE(flushE),
        .flushW(flushW),
        .ResultSrcM(ResultSrcM));

    datapath dp(
        .clk(clk), .reset(reset),
        .ResultSrcW(ResultSrcW),
        .pcsrcE(pcsrcE), .ALUSrcE(ALUSrcE),
        .RegWriteW(RegWriteW),
        .jalrselE(jalrselE),
        .immsrcD(immsrcD),
        .alucontrolE(alucontrolE),
        .zeroE(zeroE), .negativeE(negativeE),
        .pcF(pcF),
        .instrF(instrF),
        .aluresultM(aluresultM), .writedataM(writedataM),
        .readdataM(readdataM),
        .stallF(stallF), .stallD(stallD), .stallE(stallE), .stallM(stallM), .flushD(flushD), .flushE(flushE), .flushW(flushW),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .rs1D(rs1D), .rs2D(rs2D), .rs1E(rs1E), .rs2E(rs2E), .rdE(rdE), .rdM(rdM), .rdW(rdW),
        .instrD(instrD), .instrE(instrE));

    hazard_unit hu(
        .rs1D(rs1D), .rs2D(rs2D), .rs1E(rs1E), .rs2E(rs2E), .rdE(rdE), .rdM(rdM), .rdW(rdW),
        .pcsrcE(pcsrcE), .ResultSrcE0(ResultSrcE[0]), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), .RegWriteE(RegWriteE),
        .stallF(stallF), .stallD(stallD), .stallE(stallE), .stallM(stallM), .flushD(flushD), .flushE(flushE), .flushW(flushW),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .ResultSrcM(ResultSrcM),
        .ResultSrcE(ResultSrcE),
        .icache_hit(icache_hit), .dcache_hit(dcache_hit));

    d_cache dc(
        .clk(clk), .reset(reset),
        .address(aluresultM), 
        .din(writedataM),
        .rden(dcache_rden),                 
        .wren(MemWriteM),                 
        .hit_miss(dcache_hit),           
        .dout(readdataM),    
        .mrdaddress(d_mrdaddress), 
        .mrden(d_mrden),                  
        .mwraddress(d_mwraddress),
        .mwren(d_mwren), 
        .mdout(d_mdout),     
        .mdin(d_mdin));

    i_cache ic(
        .clk(clk), .reset(reset),
        .address(pcF),    
        .rden(1'b1), // always reading
        .hit_miss(icache_hit),
        .dout(instrF),
        .mrdaddress(i_mrdaddress),
        .mrden(i_mrden),               
        .mdin(i_mdin));
endmodule