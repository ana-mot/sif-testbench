class Monitor;
    virtual xw_if.MONITOR vif;
    Transaction tr;
    string name;
    mailbox msg_mbx; //pentru ref_dut(doar X)
    mailbox actual_mbx; //pt comparator(X sau W)

    function new(virtual xw_if.MONITOR vif, string name = "MON", mailbox msg_mbx, mailbox actual_mbx);
        this.vif = vif;
        this.name = name;
        this.msg_mbx = msg_mbx;
        this.actual_mbx = actual_mbx;
    endfunction //new()
    
    task run();
    forever begin

        @(vif.cbm);
        
        tr = new();
        tr.addr = vif.cbm.addr;

        if (vif.cbm.wr_s) begin
            tr.d = WRITE;
            tr.data = vif.cbm.data_wr; 
            $display("@%0t WRITE pe [%s]", $time, name);
            tr.display();

            if (msg_mbx != null) msg_mbx.put(tr); //x msg merge la ref_dut
            actual_mbx.put(tr); //merge la comparator
        end

        if (vif.cbm.rd_s) begin
            tr.d = READ;
            @(vif.cbm);           
            tr.data = vif.cbm.data_rd;
            $display("@%0t READ pe [%s]", $time, name);
            tr.display();
            if (msg_mbx != null) msg_mbx.put(tr); 
            actual_mbx.put(tr); ////merge la comparator
        end

        
    end
    
    endtask
    
endclass //Monitor()
