module top(
    input  logic clk, reset,
    output logic [31:0] writedataM, aluresultM,
    output logic MemWriteM);

    logic [31:0] d_mrdaddress, d_mwraddress, i_mrdaddress;
    logic d_mrden, d_mwren, i_mrden;
    logic [63:0] d_mdout, d_mdin;
    logic [31:0] i_mdin;

    riscv_core rv(
    .clk(clk), .reset(reset),
    .d_mrdaddress(d_mrdaddress), .d_mwraddress(d_mwraddress), .i_mrdaddress(i_mrdaddress),
    .d_mrden(d_mrden), .d_mwren(d_mwren), .i_mrden(i_mrden),
    .d_mdout(d_mdout),
    .d_mdin(d_mdin),
    .i_mdin(i_mdin),
    .aluresultM(aluresultM), .writedataM(writedataM), .MemWriteM(MemWriteM));

    dcache_mem #(.FILE("")) dcm(
    .clk(clk),
    .mrdaddress(d_mrdaddress[14:3]),
    .mwraddress(d_mwraddress[14:3]),
    .mrden(d_mrden),
    .mwren(d_mwren),
    .d(d_mdout),
    .q(d_mdin));

    icache_mem #(.FILE("mem/test4b.txt")) icm(
    .clk(clk), 
    .mrdaddress(i_mrdaddress[13:2]),
    .mrden(i_mrden),
    .q(i_mdin));     
endmodule