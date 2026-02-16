class Generator;
   mailbox drv_mbx;
   event drv_done;

   rand int nr_frames;
   constraint c_frames { nr_frames inside {[1:30]}; }

   int max_delay = 5;
   delay_mode_g  delay_mode;

   task run();
    Transaction tr;
    int pause;

    if(!this.randomize()) $fatal("nr_frames randomization failed");
    else $display("T=%0t [Generator] created %0d items, delay mode = %s", $time, nr_frames, delay_mode.name());

    repeat(nr_frames) begin
      tr = new();
      if( !tr.randomize() ) $fatal("Gen:: trans randomization failed");
      $display ("T=%0t [Generator] created an item d=%s addr=%h data=%h", $time, tr.d.name(), tr.addr, tr.data);
      drv_mbx.put(tr);
      @(drv_done);

      case (delay_mode)

        NO_DELAY: begin
          max_delay = 0;
        end

        MAX_DELAY: begin
          if (max_delay > 0) begin
            pause = $urandom_range(1, max_delay);
            $display ("T=%0t pauza", $time);
            #(pause * 10);
          end
        end

      endcase
    end
   endtask
endclass //Generator

