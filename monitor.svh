class Monitor;
    virtual xw_if.MONITOR vif;
    Transaction tr;
    string name;
    mailbox msg_mbx; //pentru ref_dut(doar X)
    mailbox actual_mbx; //pt comparator(X sau W)

    logic [15:0] read_addr_q[$]; //adrese de read in asteptare

    function new(virtual xw_if.MONITOR vif, string name = "MON", mailbox msg_mbx, mailbox actual_mbx);
        this.vif = vif;
        this.name = name;
        this.msg_mbx = msg_mbx;
        this.actual_mbx = actual_mbx;
    endfunction //new()
    
    task run();
    forever begin

        @(vif.cbm);

        if (vif.cbm.wr_s) begin
            tr = new();
            tr.d = WRITE;
            tr.addr = vif.cbm.addr;
            tr.data = vif.cbm.data_wr; 
            $display("@%0t WRITE pe [%s]", $time, name);
            tr.display();

            if (msg_mbx != null) msg_mbx.put(tr); //x msg merge la ref_dut
            $display("@%0t trimit msg wr pentru ref_dut", $time);
            actual_mbx.put(tr); //merge la comparator
            $display("@%0t trimit actual wr", $time);
        end

        if (read_addr_q.size() > 0) begin
            tr = new();
            tr.d = READ;
            tr.addr = read_addr_q.pop_front();          
            tr.data = vif.cbm.data_rd;
            $display("@%0t READ pe [%s]", $time, name);
            tr.display();
            if (msg_mbx != null) msg_mbx.put(tr); 
            $display("@%0t trimit msg rd pentru ref_dut", $time);
            actual_mbx.put(tr); //merge la comparator
            $display("@%0ttrimit actual rd", $time);
        end

        if (vif.cbm.rd_s) begin
            read_addr_q.push_back(vif.cbm.addr); //consider read request 
            $display("@%0t se cere read", $time);
        end

    end
    
    endtask
    
endclass //Monitor()

