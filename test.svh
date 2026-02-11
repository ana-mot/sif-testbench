`timescale 1ps/1ps

import environment_pkg::*;

class BaseTest;

  virtual xw_if.TB x;
  virtual xw_if.MONITOR xm;
  virtual xw_if.MONITOR wm;

  Monitor mon_x, mon_w;
  Driver drv;
  Transaction tr;
  Generator gen;
  Scoreboard scb;

  mailbox drv_mbx;
  event drv_done;

  mailbox x_msg_mbx, x_actual_mbx, w_actual_mbx;

  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm);
    this.x  = x;
    this.xm = xm;
    this.wm = wm;
  endfunction

  task run();
    drv_mbx = new();
    x_msg_mbx = new();
    x_actual_mbx = new();
    w_actual_mbx = new();

    mon_x = new(xm, "X_IF",x_msg_mbx, x_actual_mbx);
    mon_w = new(wm, "W_IF", null, w_actual_mbx);

    drv = new(x);
    gen = new();
    scb = new(x_msg_mbx, x_actual_mbx, w_actual_mbx);

    gen.drv_mbx = drv_mbx;
    drv.drv_mbx = drv_mbx;

    gen.drv_done = drv_done;
    drv.drv_done = drv_done;

    fork
      gen.run();
      drv.run();
      mon_x.run();
      mon_w.run();
      scb.run();
    join_none

    
    repeat (20) @(x.cbd);
    $finish;
  endtask

endclass
