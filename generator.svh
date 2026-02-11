class Generator;
   mailbox drv_mbx;
   event drv_done;

   task run();
    Transaction tr;
    int pause;

    repeat(3) begin
      tr = new();
      tr.randomize();
      $display ("T=%0t [Generator] created an item d=%s addr=%h data=%h", $time, tr.d.name(), tr.addr, tr.data);
      drv_mbx.put(tr);
      @(drv_done);

      pause = $urandom_range(1,5);
      $display ("T=%0t pauza", $time);
      #(pause * 10);
    end
   endtask
endclass //Generator

