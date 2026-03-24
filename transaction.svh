
class Transaction;

    rand direction d;
    rand logic [15:0] addr;
    rand logic [15:0] data;

    function new();

    endfunction //new()

    function void display(string component = "TR");
        $display("@%0t [%s] Tranzactia este de tip=%s cu adresa=%h si data=%h", $time, component, d.name(), addr, data);
    endfunction
endclass // Transaction

