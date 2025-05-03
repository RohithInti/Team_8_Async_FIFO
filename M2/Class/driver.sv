//////////////////////////////////////////////////////////////////////////////////////////////
// File name: driver.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This driver class will drive the input values to the DUT via interface. 
/////////////////////////////////////////////////////////////////////////////////////////////

`include "tb_pkg.sv"

class driver;
    virtual intf vif; // Virtual interface to DUT
    mailbox gen2driv; // Mailbox for generator to driver communication
    bit first = 1; // Flag to indicate first transaction
    // Constructor to initialize virtual interface and mailbox
    function new(virtual intf vif, mailbox gen2driv);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction


    // This main task will continuously process transactions
    task main();
        tb_pkg::transaction tx;
        forever begin
            gen2driv.get(tx);
            if (first) begin
                $display("[%0t] Driver started", $time);
                first = 0;
            end
            // Driving write transactions on write clock
            @(posedge vif.wr_clk);
            vif.wr_en   <= tx.wr_en;
            vif.wr_data <= tx.wr_data;
            // Driving read transactions on read clock
            @(posedge vif.rd_clk);
            vif.rd_en <= tx.rd_en;
            @(posedge vif.wr_clk) 
            vif.wr_en <= 0;
            @(posedge vif.rd_clk) 
            vif.rd_en <= 0;
        end
    endtask
endclass

