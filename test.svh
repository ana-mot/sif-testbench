`timescale 1ps/1ps

import environment_pkg::*;

class BaseTest;

  virtual xw_if.TB x;
  virtual xw_if.MONITOR xm;
  virtual xw_if.MONITOR wm;
  virtual reset_if r_if;

  bit enable_rst = 1'b0;

  Monitor mon_x, mon_w;
  Driver drv;
  Transaction tr;
  Generator gen;
  Scoreboard scb;
  Configuration cfg;

  mailbox drv_mbx;
  event drv_done;
  event gen_done;

  mailbox x_msg_mbx, x_actual_mbx, w_actual_mbx;

  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    this.x  = x;
    this.xm = xm;
    this.wm = wm;
    this.r_if = r_if;
  endfunction

  task init();
    x.cbd.wr_s <= 1'b0;
    x.cbd.rd_s <= 1'b0;
    x.cbd.addr <= '0;
    x.cbd.data_wr <= '0;
  endtask

  task initial_reset();
    r_if.rst_b <= 1'b0;
    init();

    repeat (2) @(posedge x.cbd);

    r_if.rst_b <= 1'b1;
    wait (r_if.rst_b == 1'b1);

    @(posedge x.cbd);
  endtask

  task reset_run();
     wait (r_if.rst_b == 1'b1);

    repeat ($urandom_range(5,10))@(posedge x.cbd);
    r_if.rst_b = 1'b0;
    repeat ($urandom_range(1,3)) @(posedge x.cbd);
    r_if.rst_b = 1'b1; 
  endtask

  virtual function void configure();
    cfg.max_delay  = 5;
    cfg.delay_mode = MAX_DELAY;
    enable_rst = 1'b0;
  endfunction

  task run();
    drv_mbx = new();
    x_msg_mbx = new();
    x_actual_mbx = new();
    w_actual_mbx = new();

    mon_x = new(xm, "X_IF",x_msg_mbx, x_actual_mbx);
    mon_w = new(wm, "W_IF", null, w_actual_mbx);

    cfg = new();
    drv = new(x);
    gen = new(cfg, x);
    gen.gen_done = gen_done;

    scb = new(x_msg_mbx, x_actual_mbx, w_actual_mbx);

    configure();

    initial_reset();

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

      if(enable_rst) reset_run();
    join_none

    
    @gen_done;
    repeat (5) @(x.cbd);
    -> scb.done_p;
    repeat (5) @(x.cbd);
    $finish;
  endtask

endclass

// ------------------------------------------------------------

class SanityTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    cfg.delay_mode = MAX_DELAY;
    enable_rst = 1'b0;
  endfunction
endclass

// ------------------------------------------------------------
class StresTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    cfg.delay_mode = NO_DELAY;
    cfg.max_delay = 0;
    enable_rst = 1'b0;
  endfunction
endclass


// ------------------------------------------------------------
class ResetTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    cfg.delay_mode = MAX_DELAY;
    cfg.max_delay = 5;
    enable_rst = 1'b1;
  endfunction
endclass


