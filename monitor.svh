class Monitor;
    virtual xw_if.MONITOR vif;
    Transaction tr;

    function new(virtual xw_if.MONITOR vif);
        this.vif = vif;
    endfunction //new()
    
    task run();
    forever begin

        @(vif.cbm);
        
        tr = new();
        tr.addr = vif.cbm.addr;

        if (vif.cbm.wr_s) begin
            tr.d = WRITE;
            tr.data = vif.cbm.data_wr;
            tr.display(); 
        end

        if (vif.cbm.rd_s) begin
            tr.d = READ;
            @(vif.cbm);           
            tr.data = vif.cbm.data_rd;
            tr.display();
        end

        
    end
    
    endtask
    
endclass //Monitor()

 /* 
        if (vif.cbm.wr_s) begin
            //$display("@%0t A fost ceruta o scriere la adresa=%h si data=%h", $time, vif.cbm.addr, vif.cbm.data_wr);
            tr = new();
            tr.addr = vif.cbm.addr;
            tr.data = vif.cbm.data_wr;
            tr.d = WRITE;
            tr.display();
        end

        if (vif.cbm.rd_s) begin
            //$display("@%0t A fost ceruta citirea pentru adresa=%h", $time, vif.cbm.addr);
            tr = new();
            tr.addr = vif.cbm.addr;
            tr.d = READ;
            @(vif.cbm);
            tr.data = vif.cbm.data_rd;
            //$display("@%0t Data returnata este data=%h", $time, vif.cbm.data_rd);
            tr.display();
        end*/