class Monitor;
    virtual xw_if.MONITOR vif;
    

    function new(virtual xw_if.MONITOR vif);
        this.vif = vif;
    endfunction //new()
    
    task run();
    forever begin
        @(vif.cbm);
        if (vif.cbm.wr_s) begin
            $display("@%0t A fost ceruta o scriere la adresa=%h si data=%h", $time, vif.cbm.addr, vif.cbm.data_wr);
        end

        if (vif.cbm.rd_s) begin
            $display("@%0t A fost ceruta citirea pentru adresa=%h", $time, vif.cbm.addr);
            @(vif.cbm);
            $display("@%0t Data returnata este data=%h", $time, vif.cbm.data_rd);
        end
    end
    endtask
    
endclass //Monitor()