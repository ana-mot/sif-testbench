interface xw_if #(parameter int AW = 16, DW = 16) (input logic clk);
logic rst_b;
logic wr_s;
logic rd_s;
logic [AW-1:0] addr;
logic [DW-1:0] data_wr;
logic [DW-1:0] data_rd;

//--clocking block pentru Driver--
clocking cbd @(posedge clk);
    input  data_rd;
    input rst_b;
    output wr_s, rd_s, addr, data_wr;
endclocking : cbd

//--clocking block pentru Monitor--
clocking cbm @(posedge clk);
    input wr_s, rd_s, addr, data_wr, data_rd, rst_b;
endclocking : cbm

modport TB (clocking cbd);

modport DUT (
    input  clk,
    input  rst_b,
    input  wr_s,
    input  rd_s,
    input  addr,
    input  data_wr,
    output data_rd);

 modport MONITOR (clocking cbm);

 endinterface : xw_if

