
class Transaction;
    rand direction d;
    rand logic [15:0] addr;
    rand logic [15:0] data;

    function void display();
        $display("@%0t Tranzactia este de tip=%s cu adresa=%h si data=%h", $time, d.name(), addr, data);
    endfunction

    function new();
        
    endfunction //new()
endclass // Transaction

