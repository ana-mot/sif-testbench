`timescale 1ps/1ps

`include "test.svh"

module tb_sif;

reg clk; 

//interfata pt reset
reset_if r_if(.clk(clk));

//2 instante de interfata: X si W
xw_if #(16,16) x_if (.clk(clk));
xw_if #(16,16) w_if (.clk(clk));

BaseTest t;

assign x_if.rst_b = r_if.rst_b;
assign w_if.rst_b = r_if.rst_b;

  // DUT
  sif dut (
    .rst_b(r_if.rst_b),
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

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    //init
    r_if.rst_b = 1'b0;
    x_if.wr_s = 1'b0;
    x_if.rd_s = 1'b0;
    x_if.addr = '0;
    x_if.data_wr = '0;

    //reset
    repeat (2) @(posedge clk);
    r_if.rst_b = 1'b1;

    wait (r_if.rst_b == 1'b1);
    t = new(x_if, x_if, w_if, r_if);
    t.enable_rst = 1'b1;
    t.run();
  end

  /*initial begin
    wait (r_if.rst_b == 1'b1);

    repeat ($urandom_range(5,10)) @(posedge clk);
    r_if.rst_b = 1'b0;
    repeat ($urandom_range(1,3)) @(posedge clk);
    r_if.rst_b = 1'b1;

  end*/

endmodule

