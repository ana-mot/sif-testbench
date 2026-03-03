class Generator;
  mailbox drv_mbx;
  event drv_done;
  event gen_done;

  Configuration cfg;
  virtual xw_if.TB vif;

  function new(Configuration cfg=null, virtual xw_if.TB vif);
    this.cfg = cfg;
	this.vif = vif;
  endfunction

  task run();
    Transaction tr;
    int pause;

    $display("T=%0t [Generator] created %0d items, delay mode = %s", $time, cfg.nr_frames, cfg.delay_mode.name());

    repeat(cfg.nr_frames) begin
      tr = new();
      if( !tr.randomize() ) $fatal("Gen:: trans randomization failed");
      $display ("T=%0t [Generator] created an item d=%s addr=%h data=%h", $time, tr.d.name(), tr.addr, tr.data);
      drv_mbx.put(tr);
      @(drv_done);

      case (cfg.delay_mode)

        NO_DELAY: begin
          cfg.max_delay = 0;
        end

        MAX_DELAY: begin
          if (cfg.max_delay > 0) begin
            pause = $urandom_range(1, cfg.max_delay);
            $display("T=%0t [Generator] pause=%0d cycles", $time, pause);
            repeat(pause) @(vif.cbd);
          end
        end

      endcase
    end
    -> gen_done;
      $display("T=%0t Generator DONE", $time);
  endtask
endclass //Generator