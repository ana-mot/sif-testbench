`timescale 1ps/1ps

import environment_pkg::*;

class BaseTest;

  virtual xw_if.TB x;
  virtual xw_if.MONITOR xm;
  virtual xw_if.MONITOR wm;
  virtual reset_if r_if;

  bit enable_rst = 1'b0;
  bit enable_gen = 1'b1;

  Monitor mon_x, mon_w;
  Driver drv;
  Transaction tr;
  Generator gen;
  Scoreboard scb;
  Configuration cfg;
  Coverage cov;

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

    repeat (2) @(x.cbd);

    r_if.rst_b <= 1'b1;
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

  virtual function void configure();
    //cfg.randomize();
    if (!cfg.randomize()) $fatal(1, "Randomize failed");
    enable_rst = 1'b0;
    enable_gen = 1'b1;
  endfunction

  virtual task run();
    drv_mbx = new();
    x_msg_mbx = new();
    x_actual_mbx = new();
    w_actual_mbx = new();

    mon_x = new(xm, "X_IF",x_msg_mbx, x_actual_mbx);
    mon_w = new(wm, "W_IF", null, w_actual_mbx);

    cov = new(xm);
    
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
      if (enable_gen) gen.run();
      if (enable_gen) drv.run();
      mon_x.run();
      mon_w.run();
      scb.run();
      cov.run();
      if(enable_rst) reset_run();
    join_none

    
    if (enable_gen) begin
      @gen_done;
      repeat (20) @(x.cbd);
      -> scb.done_p;
      repeat (5) @(x.cbd);
      $finish;
    end 
  endtask

endclass

// ------------------------------------------------------------

class SanityTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!cfg.randomize() with { delay_mode == MAX_DELAY;
                           nr_frames > 50; }) $fatal(1, "Randomize failed");
    enable_rst = 1'b0;
    enable_gen = 1'b1;
  endfunction
endclass

// ------------------------------------------------------------
class StresTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!cfg.randomize() with { delay_mode == NO_DELAY;
                           max_delay == 0; }) $fatal(1, "Randomize failed");
    enable_rst = 1'b0;
    enable_gen = 1'b1;
  endfunction
endclass


// ------------------------------------------------------------
class ResetTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!cfg.randomize() with { delay_mode == MAX_DELAY;
                           max_delay == 5;
                           nr_frames > 50; }) $fatal(1, "Randomize failed");
    enable_rst = 1'b1;
    enable_gen = 1'b1;
  endfunction
endclass

// ------------------------------------------------------------
class TrafficMixtTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!cfg.randomize() with { delay_mode == MIXT;
                           max_delay == 4;
                           nr_frames > 50;}) $fatal(1, "Randomize failed");
    enable_rst = 1'b1;
    enable_gen = 1'b1;
  endfunction
endclass



// ------------------------------------------------------------
class ManualTest extends BaseTest;

  rand logic [15:0] rand_addr;
  rand logic [15:0] rand_data;

  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  task consecutive_reads();
    if (!randomize()) $fatal(1, "Randomize failed");
    $display("Citiri consecutive");
    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b0;
    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b0;
    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b0;
    @(x.cbd);
    x.cbd.rd_s <= 1'b0;
  endtask //consecutive reads

  task rd_wr_simultan();
    if (!randomize()) $fatal(1, "Randomize failed");
    $display("O citire si o scriere in acelasi timp");
    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.data_wr <= rand_data;
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b1;
    @(x.cbd);
    x.cbd.rd_s <= 1'b0;
    x.cbd.wr_s <= 1'b0;
  endtask //rd_wr_simultan

  task reset_read();
    if (!randomize()) $fatal(1, "Randomize failed");
    $display("Reset simultan cu o citire");
    r_if.rst_b <= 1'b0;

    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b0;
    @(x.cbd);
    x.cbd.rd_s <= 1'b0;

    @(x.cbd);
    r_if.rst_b <= 1'b1;
    @(x.cbd);
  endtask

  task reset_write();
    if (!randomize()) $fatal(1, "Randomize failed");
    $display("Reset simultan cu o scriere");
    r_if.rst_b <= 1'b0;

    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.data_wr <= rand_data;
    x.cbd.rd_s <= 1'b0;
    x.cbd.wr_s <= 1'b1;
    @(x.cbd);
    x.cbd.wr_s <= 1'b0;

    @(x.cbd);
    r_if.rst_b <= 1'b1;
    @(x.cbd);
  endtask
  
  task reset_with_rd_wr();
    if (!randomize()) $fatal(1, "Randomize failed");
    $display("Reset simultan cu o scriere si o citire");
    r_if.rst_b <= 1'b0;

    @(x.cbd);
    x.cbd.addr <= rand_addr;
    x.cbd.data_wr <= rand_data;
    x.cbd.rd_s <= 1'b1;
    x.cbd.wr_s <= 1'b1;
    @(x.cbd);
    x.cbd.wr_s <= 1'b0;
    x.cbd.rd_s <= 1'b0;

    @(x.cbd);
    r_if.rst_b <= 1'b1;
    @(x.cbd);
  endtask

  virtual function void configure();
    super.configure();
    enable_gen = 1'b0;
    enable_rst = 1'b0;
  endfunction

  task run();
    super.run(); 
      
    wait (r_if.rst_b == 1'b1);
    repeat (2) @(x.cbd);

    consecutive_reads();
    repeat (3) @(x.cbd);

    rd_wr_simultan();
    repeat (5) @(x.cbd);

    reset_read();
    repeat (3) @(x.cbd);

    reset_write();
    repeat (3) @(x.cbd);

    reset_with_rd_wr();
    repeat (10) @(x.cbd);

    -> scb.done_p;
    repeat (5) @(x.cbd);
    $finish;
  endtask
endclass

