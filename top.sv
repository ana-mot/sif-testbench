`timescale 1ps/1ps

module top;

  logic clk;

  //interfete
  xw_if #(16,16) x_if (.clk(clk));
  xw_if #(16,16) w_if (.clk(clk));


  //DUT
  sif dut (
    .rst_b(x_if.rst_b),
    .clk(clk),
    .xa_wr_s(x_if.wr_s),
    .xa_rd_s(x_if.rd_s),
    .xa_addr(x_if.addr),
    .xa_data_wr(x_if.data_wr),
    .xa_data_rd(x_if.data_rd),
    .wa_wr_s(w_if.wr_s),
    .wa_addr(w_if.addr),
    .wa_data_wr(w_if.data_wr)
  );

  //clock
  initial clk = 0;
  always #5 clk = ~clk;

endmodule