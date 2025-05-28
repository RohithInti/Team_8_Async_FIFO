//////////////////////////////////////////////////////////////////////////////////////////////
// File name: environment.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This environment class will initialize and connect together all the components.
/////////////////////////////////////////////////////////////////////////////////////////////

`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "tb_pkg.sv"
`include "coverage_pkg.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"

class environment;
  virtual intf vif;
  mailbox gen2driv, mon_in2scb, mon_out2scb;
  coverage_pkg::fifo_cov cov;
  generator gen;
  driver drv;
  monitor_in mon_in;
  monitor_out mon_out;
  scoreboard scb;

  function new(virtual intf vif);
    this.vif = vif;
    gen2driv = new();
    mon_in2scb = new();
    mon_out2scb = new();
    cov = new(vif);
    gen = new(vif, gen2driv);
    drv = new(vif, gen2driv);
    mon_in = new(vif, mon_in2scb, cov);
    mon_out = new(vif, mon_out2scb, cov);
    scb = new(mon_in2scb, mon_out2scb);
  endfunction

  task run();
    $display("\n=== ENV: Starting all components ===");

    fork
      drv.main();
      mon_in.main();
      mon_out.main();
      scb.main();
    join_none

    // wait for "Driver started"
    @(drv_started);

    gen.main();

    repeat (2*vif.DEPTH + 50) @(posedge vif.rd_clk);

    // coverage report
    cov.report();
    repeat (2*vif.DEPTH + 50) @(posedge vif.rd_clk);

    $display("=====================================================");
    if (scb.err_cnt == 0)
      $display(" TEST PASSED: All data matched.");
    else
      $display(" TEST FAILED: errors=%0d", scb.err_cnt);

    $finish;
  endtask

endclass : environment

`endif // ENVIRONMENT_SV

