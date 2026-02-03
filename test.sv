`timescale 1ps/1ps


program automatic test_sif (xw_if.TB x, xw_if.MONITOR xm, xw_if.MONITOR wm);
import environment_pkg::*;
    Monitor mon_x, mon_w;
    Driver drv;
    Transaction tr;


  initial begin
    mon_x = new(xm);
    mon_w = new(wm);
    drv = new(x);
    fork
      mon_x.run();
      mon_w.run();
      drv.run();
    join_none

    
    repeat (10) @(x.cbd);
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