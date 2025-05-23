//////////////////////////////////////////////////////////////////////////////////////////////
// File name: driver.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This driver class will drive the input values to the DUT via interface. 
/////////////////////////////////////////////////////////////////////////////////////////////

`ifndef DRIVER_SV
`define DRIVER_SV

`include "tb_pkg.sv"

event drv_started;

class driver;
  virtual intf vif;
  mailbox gen2driv;

  function new (virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

  task main();
    tb_pkg::transaction tx;

    $display("[%0t] Driver started", $time);
    -> drv_started;

    forever begin
      gen2driv.get(tx);
      if (tx.wr_en) begin
        @(posedge vif.wr_clk);
        vif.wr_en = 1;
        vif.wr_data = tx.wr_data;
        @(posedge vif.wr_clk);
        vif.wr_en = 0;
      end
      if (tx.rd_en) begin
        @(posedge vif.rd_clk);
        vif.rd_en = 1;
        @(posedge vif.rd_clk);
        vif.rd_en = 0;
      end
    end
  endtask

endclass : driver

`endif // DRIVER_SV

