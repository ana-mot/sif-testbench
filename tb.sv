`timescale 1ps/1ps

module tb_sif;


reg rst;
reg clk; 

//2 instante de interfata: X si W
xw_if #(16,16) x_if (.clk(clk));
xw_if #(16,16) w_if (.clk(clk));

//legam testul de interfata
test_sif t0 (x_if, x_if);


assign x_if.rst_b = rst;
assign w_if.rst_b = rst;

  // DUT
  sif dut (
    .rst_b(rst),
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
    rst = 1'b0;
    x_if.wr_s = 1'b0;
    x_if.rd_s = 1'b0;
    x_if.addr = '0;
    x_if.data_wr = '0;


    //reset
    repeat (2) @(posedge clk);
    rst = 1;
  end

endmodule

