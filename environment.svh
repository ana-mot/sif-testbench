`timescale 1ps/1ps

import environment_pkg::*;

class Environment;

virtual xw_if.TB x;
virtual xw_if.MONITOR xm;
virtual xw_if.MONITOR wm;
virtual reset_if r_if;

Monitor mon_x, mon_w;
Driver drv;
Transaction tr;
Generator gen;
Scoreboard scb;
Configuration cfg;
Coverage cov;

mailbox drv_mbx;
mailbox x_msg_mbx, x_actual_mbx, w_actual_mbx;

event drv_done;
event gen_done;

bit enable_rst;
bit enable_gen;

function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    this.x  = x;
    this.xm = xm;
    this.wm = wm;
    this.r_if = r_if;
endfunction

task initial_reset();

    r_if.rst_b <= 0;

    x.cbd.wr_s <= 0;
    x.cbd.rd_s <= 0;
    x.cbd.addr <= 0;
    x.cbd.data_wr <= 0;

    repeat(2) @(x.cbd);

    r_if.rst_b <= 1;
    wait (r_if.rst_b == 1'b1);

    @(x.cbd);

endtask

task reset_run();
    wait (r_if.rst_b == 1'b1);

    repeat (cfg.n_resets) begin
      repeat ($urandom_range(5, 10)) @(x.cbd);

      r_if.rst_b = 1'b0;
      repeat ($urandom_range(1, 3)) @(x.cbd);
      r_if.rst_b = 1'b1;
      -> scb.rst_active;
      $display("%t evenimentul de reset", $time);
    end

endtask

task build();

    drv_mbx = new();
    x_msg_mbx = new();
    x_actual_mbx = new();
    w_actual_mbx = new();

    cfg = new();

    gen = new(cfg, x, drv_mbx, drv_done, gen_done);

    drv = new(x, drv_mbx, drv_done);

    mon_x = new(xm, "X_IF", x_msg_mbx, x_actual_mbx);
    mon_w = new(wm, "W_IF", null, w_actual_mbx);

    scb = new(x_msg_mbx, x_actual_mbx, w_actual_mbx);

    cov = new(xm);

    
endtask

task run();

    initial_reset();

    fork
      if(enable_gen) gen.run();
      if(enable_gen) drv.run();
      mon_x.run();
      mon_w.run();
      scb.run();
      cov.run();
      if(enable_rst) reset_run();
    join_none

endtask

endclass