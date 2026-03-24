`timescale 1ps/1ps

`include "environment.svh"
import environment_pkg::*;

class BaseTest;

  virtual xw_if.TB x;
  virtual xw_if.MONITOR xm;
  virtual xw_if.MONITOR wm;
  virtual reset_if r_if;

  Environment env;

  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    this.x  = x;
    this.xm = xm;
    this.wm = wm;
    this.r_if = r_if;
  endfunction


  virtual function void configure();

  int frames, delay, resets;

  if (!env.cfg.randomize())
    $fatal(1, "Randomize failed");

  if ($value$plusargs("FRAMES=%d", frames))
    env.cfg.nr_frames = frames;

  if ($value$plusargs("DELAY=%d", delay))
    env.cfg.max_delay = delay;

  if ($value$plusargs("RESETS=%d", resets))
    env.cfg.n_resets = resets;

  env.enable_rst = 1'b0;
  env.enable_gen = 1'b1;

  $display("CONFIG: frames=%0d delay=%0d resets=%0d", env.cfg.nr_frames, env.cfg.max_delay, env.cfg.n_resets);

endfunction

  virtual task run();

    env = new(x,xm,wm,r_if);
    env.build();

    configure();

    env.run();

  if(env.enable_gen) begin
    @env.gen_done;
    repeat(20) @(x.cbd);
    -> env.scb.done_p;
    repeat(5) @(x.cbd);
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
    if (!env.cfg.randomize() with { delay_mode == MAX_DELAY;
                           nr_frames > 50; }) $fatal(1, "Randomize failed");

    super.configure();

    env.enable_rst = 1'b0;
    env.enable_gen = 1'b1;
  endfunction
endclass

// ------------------------------------------------------------
class StresTest extends BaseTest;

  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!env.cfg.randomize() with { delay_mode == NO_DELAY;
                           max_delay == 0; }) $fatal(1, "Randomize failed");
    super.configure();
    
    env.enable_rst = 1'b0;
    env.enable_gen = 1'b1;
  endfunction
endclass


// ------------------------------------------------------------
class ResetTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!env.cfg.randomize() with { delay_mode == MAX_DELAY;
                           max_delay == 5;
                           nr_frames > 50; }) $fatal(1, "Randomize failed");
    super.configure();
    
    env.enable_rst = 1'b1;
    env.enable_gen = 1'b1;
  endfunction
endclass

// ------------------------------------------------------------
class TrafficMixtTest extends BaseTest;
  function new(virtual xw_if.TB x, virtual xw_if.MONITOR xm, virtual xw_if.MONITOR wm, virtual reset_if r_if);
    super.new(x, xm, wm, r_if);
  endfunction

  virtual function void configure();
    if (!env.cfg.randomize() with { delay_mode == MIXT;
                           max_delay == 4;
                           nr_frames > 50;}) $fatal(1, "Randomize failed");
    super.configure();
    
    env.enable_rst = 1'b1;
    env.enable_gen = 1'b1;
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
    env.enable_gen = 1'b0;
    env.enable_rst = 1'b0;
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

    -> env.scb.done_p;
    repeat (5) @(x.cbd);
    $finish;
  endtask
endclass

