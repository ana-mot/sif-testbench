`timescale 1ps/1ps


program automatic test_sif (xw_if.TB x, xw_if.MONITOR xm);
import environment_pkg::*;
    Monitor mon;
    Driver drv;
    Transaction tr;


  initial begin
    mon = new(xm);
    drv = new(x);
    fork
      mon.run();
      drv.run();
    join_none

    

    wait (x.cbd.rst_b == 1'b1);

    //---WRITE TEST---
    @(x.cbd);
    x.cbd.wr_s <= 1'b1;
    x.cbd.rd_s <= 1'b0;
    x.cbd.addr <= 16'h1234;
    x.cbd.data_wr <= 16'hABCD;

    @(x.cbd);
    x.cbd.wr_s <= 1'b0;

    //---READ TEST---
    @(x.cbd);
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b0;
    x.cbd.addr <= 16'h05DE;

    @(x.cbd);
    x.cbd.rd_s <= 1'b0;

    repeat (5) @(x.cbd);
    $finish;
  end

endprogram

/*task automatic do_write(input logic [15:0] a, input logic [15:0] d);
    @(x.cbd);
    x.cbd.wr_s <= 1'b1;
    x.cbd.rd_s <= 1'b0;
    x.cbd.addr <= a;
    x.cbd.data_wr <= d;

    @(x.cbd);
    x.cbd.wr_s <= 1'b0;
  endtask

  task automatic do_read(input logic [15:0] a);
    @(x.cbd);
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b0;
    x.cbd.addr <= a;

    @(x.cbd);
    x.cbd.rd_s <= 1'b0;
  endtask

  initial begin
   
    mon = new(xm);
    fork
      mon.run;
    join_none

    wait (x.cbd.rst_b == 1'b1);

    //---WRITE TES---
    do_write(16'h1234, 16'hABCD);

    //---READ TEST---
    do_read(16'h05DE);

    repeat (5) @(x.cbd);
    $finish;
  end*/