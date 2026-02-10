class Generator;
   mailbox drv_mbx;
   event drv_done;

   task run();
    Transaction tr;
    repeat(3) begin
      tr = new();
      tr.randomize();
      $display ("T=%0t [Generator] created an item d=%s addr=%h data=%h", $time, tr.d.name(), tr.addr, tr.data);
      drv_mbx.put(tr);
      @(drv_done);
    end
   endtask
endclass //Generator

