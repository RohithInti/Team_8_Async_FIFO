//////////////////////////////////////////////////////////////////////////////////////////////
// File name: monitor_in.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This monitor_in class will capture write transaction and FIFO status.
/////////////////////////////////////////////////////////////////////////////////////////////

`include "tb_pkg.sv"

class monitor_in;
    virtual intf vif;
    mailbox mon_in2scb;
    
    // Constructor to initialize virtual interface and mailbox
    function new(virtual intf vif, mailbox mon_in2scb);
      this.vif = vif;
      this.mon_in2scb = mon_in2scb;
    endfunction
    
    // Main task will monitor write transactions continuously
    task main();
      tb_pkg::transaction tx;
      $display("[%0t] MON_IN:Started monitoring write interface", $time);
      forever begin
        @(posedge vif.wr_clk); #0;
        if (vif.wr_en) begin
          tx = new();
          tx.wr_en = vif.wr_en;
          tx.wr_data = vif.wr_data;
          tx.full = vif.full;
          tx.half_full = vif.half_full;
          mon_in2scb.put(tx);
          tx.print();
        end
      end
    endtask
endclass

