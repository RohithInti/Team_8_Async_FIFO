//////////////////////////////////////////////////////////////////////////////////////////////
// File name: monitor_in.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This monitor_in class will capture write transaction and FIFO status.
/////////////////////////////////////////////////////////////////////////////////////////////

`ifndef MONITOR_IN_SV
`define MONITOR_IN_SV

`include "tb_pkg.sv"
`include "coverage_pkg.sv"

class monitor_in;
  virtual intf vif;
  mailbox mon_in2scb;
  coverage_pkg::fifo_cov cov;

  function new (virtual intf vif, mailbox mon_in2scb, coverage_pkg::fifo_cov cov);
    this.vif = vif;
    this.mon_in2scb = mon_in2scb;
    this.cov = cov;
  endfunction


  task main();
    tb_pkg::transaction tx;
    bit prev_wr_en = 0;

    $display("[%0t] MON_IN: Started", $time);

    forever begin
      @(posedge vif.wr_clk);  
      #0;
      cov.sample_wr();

      if (vif.wr_en) begin
        tx = new();
        tx.wr_en = 1;
        tx.wr_data = vif.wr_data;
        tx.full = vif.full;
        tx.half_full = vif.half_full;
        mon_in2scb.put(tx);

        if (!prev_wr_en) 
            tx.print();
      end
      prev_wr_en = vif.wr_en;
    end
  endtask
endclass : monitor_in

`endif // MONITOR_IN_SV
