class Scoreboard;
    mailbox x_msg_mbx; //pt ref dut
    mailbox x_actual_mbx;
    mailbox w_actual_mbx;

    mailbox x_expected_mbx;
    mailbox w_expected_mbx;

    event done_p;

    function new(mailbox x_msg_mbx, mailbox x_actual_mbx, mailbox w_actual_mbx);
        this.x_msg_mbx = x_msg_mbx;
        this.x_actual_mbx = x_actual_mbx;
        this.w_actual_mbx = w_actual_mbx;
        x_expected_mbx = new();
        w_expected_mbx = new();
    endfunction //new()

    function automatic logic [15:0] calc_read_data(logic [15:0] addr);
        calc_read_data = { addr[15:9], (addr[8] ^ addr[4]), (addr[7] ^ addr[5]), addr[6:0] };
    endfunction

    task ref_dut_run();
        forever begin
        Transaction tr_in; 
        x_msg_mbx.get(tr_in); //asteapta tranzactie de la monitor X

        if (tr_in.d == READ) begin //READ
            Transaction tr_exp = new(); //se creeaza tranzactia expected
            tr_exp.d = READ;
            tr_exp.addr = tr_in.addr;
            tr_exp.data = calc_read_data(tr_in.addr);
            x_expected_mbx.put(tr_exp); // se trimite in Xexpected

        end
        else begin //WRITE
            Transaction tr_exp = new(); //se creeaza tranzactia expected
            tr_exp.d = WRITE;
            tr_exp.addr = tr_in.addr;
            tr_exp.data = tr_in.data;
            w_expected_mbx.put(tr_exp); // se trimite in Wexpected
        end
        end
    endtask

    task x_compare_run();
        forever begin
        Transaction act, exp;        

        do begin
            x_actual_mbx.get(act);
            $display("@%0t scot actual pentru x_comp = %h", $time, act.addr);
        end while (act.d != READ);

        x_expected_mbx.get(exp);
        $display("@%0t scot expected din ref pentru x_comp = %h", $time, exp.addr);

        if (act.addr != exp.addr | act.data != exp.data) begin
            $display("@%0t [XCOMPARE] FAIL addr act=%h exp=%h data act=%h exp=%h", $time, act.addr, exp.addr, act.data, exp.data);
        end else begin
            $display("@%0t [XCOMPARE] PASS addr=%h data=%h", $time, act.addr, act.data);
        end
        end
    endtask

    task w_compare_run();
        forever begin
        Transaction act, exp;
        w_actual_mbx.get(act);
        $display("@%0t scot actual pentru w_comp = %h", $time, act.addr);

        w_expected_mbx.get(exp);
        $display("@%0t scot expected din ref pentru w_comp = %h", $time, exp.addr);

        if (act.d != WRITE) $error("@%0t Non write ", $time); 

        if (act.addr != exp.addr | act.data != exp.data) begin
            $display("@%0t [WCOMPARE] FAIL addr act=%h exp=%h data act=%h exp=%h", $time, act.addr, exp.addr, act.data, exp.data);
        end else begin
            $display("@%0t [WCOMPARE] PASS addr=%h data=%h", $time, act.addr, act.data);
        end
        end
    endtask

    task check_empty();
        @done_p;
        if(x_msg_mbx.num() == 0 && x_actual_mbx.num() == 0 && w_actual_mbx.num() == 0 && x_expected_mbx.num() == 0 && w_expected_mbx.num() == 0) begin
            $display("@%0t [Scoreboard] mailbox-uri goale", $time);
        end else begin
            $display("@%0t [Scoreboard] inca mai sunt date in xm= %0d, xa= %0d, wa= %0d, xe= %0d, we= %0d", $time, x_msg_mbx.num(), x_actual_mbx.num(), w_actual_mbx.num(), x_expected_mbx.num(), w_expected_mbx.num());
        end

    endtask


    task run();
        fork
        ref_dut_run();
        x_compare_run();
        w_compare_run();
        check_empty();
        join_none
    endtask

endclass //Scoreboard

