class Driver;
virtual xw_if.TB vif;


function new(virtual xw_if.TB vif);
    this.vif = vif; 
endfunction //new()

task run();
    Transaction tr;

    forever begin
        $display ("T=%0t [Driver] starting ...", $time);
        @ (vif.cbd);
        vif.cbd.wr_s <= 1'b0;
        vif.cbd.rd_s <= 1'b0;

        wait (vif.cbd.rst_b == 1'b1);

        tr = new();
        tr.d = WRITE;
        tr.addr = 'h4321;
        tr.data = 'ha12b;

        if (tr.d == WRITE) begin
            vif.cbd.wr_s <= 1'b1;
            vif.cbd.addr <= tr.addr;
            vif.cbd.data_wr <= tr.data;

            @(vif.cbd);
            vif.cbd.wr_s <= 1'b0;
        end

        if (tr.d == READ) begin 
            vif.cbd.rd_s <= 1'b1;
            vif.cbd.addr <= tr.addr;

            @(vif.cbd);
            vif.cbd.rd_s <= 1'b0;
        end
    end
endtask

endclass //Driver