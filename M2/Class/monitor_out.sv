//////////////////////////////////////////////////////////////////////////////////////////////
// File name: monitor_out.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This monitor_in class will capture read transaction and FIFO status.
/////////////////////////////////////////////////////////////////////////////////////////////

`include "tb_pkg.sv"

class monitor_out;
    virtual intf vif;
    mailbox      mon_out2scb;
    
    // Constructor to initialize virtual interface and mailbox
    function new(virtual intf vif, mailbox mon_out2scb);
      this.vif         = vif;
      this.mon_out2scb = mon_out2scb;
    endfunction
    
    
    // Main task will monitor read transactions continuously
    task main();
      tb_pkg::transaction tx;
      $display("[%0t] MON_OUT started", $time);
      forever begin
        @(posedge vif.rd_clk); #0;
        if (vif.rd_en) begin
          tx = new();
          tx.rd_en      = vif.rd_en;
          tx.rd_data    = vif.rd_data;
          tx.empty      = vif.empty;
          tx.half_empty = vif.half_empty;
          mon_out2scb.put(tx);
          tx.print();
        end
      end
    endtask
endclass

