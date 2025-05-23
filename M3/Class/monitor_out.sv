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
`include "coverage_pkg.sv"

class monitor_out;
  virtual intf vif;
  mailbox mon_out2scb;
  coverage_pkg::fifo_cov cov;

  function new (virtual intf vif, mailbox mon_out2scb, coverage_pkg::fifo_cov cov);
    this.vif = vif;
    this.mon_out2scb = mon_out2scb;
    this.cov = cov;
  endfunction


  task main();
    tb_pkg::transaction tx;
    bit prev_rd_en = 0;

    $display("[%0t] MON_OUT: Started", $time);

    forever begin
      @(posedge vif.rd_clk);  
      #0;
      cov.sample_rd();

      if (vif.rd_en) begin
        tx = new();
        tx.rd_en = 1;
        tx.rd_data = vif.rd_data;
        tx.empty = vif.empty;
        tx.half_empty = vif.half_empty;
        mon_out2scb.put(tx);

        if (!prev_rd_en) tx.print();
      end
      prev_rd_en = vif.rd_en;
    end
  endtask
endclass : monitor_out
