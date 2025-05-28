//////////////////////////////////////////////////////////////////////////////////////////////
// File name: generator.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This generator class will generate stimulus for FIFO operations.
/////////////////////////////////////////////////////////////////////////////////////////////

`ifndef GENERATOR_SV
`define GENERATOR_SV

`include "tb_pkg.sv"

class generator;
  virtual intf vif;
  mailbox gen2driv;
  event done, full_reached;

  function new(virtual intf vif, mailbox      gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

  task main();
    tb_pkg::transaction tx;
    int i;

    // 1) FILL TO FULL
    $display("\n=== GEN: Fill to full ===");
    for (i = 0; i <= vif.DEPTH; i++) begin
      @(posedge vif.wr_clk);
      tx = new();
      tx.wr_en = 1;
      tx.rd_en = 0;
      tx.wr_data = i;
      gen2driv.put(tx);
    end
    @(posedge vif.wr_clk);
    tx = new(); 
    tx.wr_en = 0; 
    tx.rd_en = 0;
    gen2driv.put(tx);

    -> full_reached;
    $display("=== GEN: FIFO is FULL at %0t ===", $time);

    // 2) OVERFLOW TEST
    $display("\n=== GEN: Overflow test ===");
    @(posedge vif.wr_clk);
    tx = new(); 
    tx.wr_en = 1; 
    tx.rd_en = 0; 
    tx.wr_data = 'hDEAD;
    gen2driv.put(tx);
    @(posedge vif.wr_clk);
    tx = new(); 
    tx.wr_en = 1; 
    tx.rd_en = 0; 
    tx.wr_data = 'hABCD;
    gen2driv.put(tx);
    @(posedge vif.wr_clk);
    tx = new(); 
    tx.wr_en = 0; 
    tx.rd_en = 0;
    gen2driv.put(tx);

    // 3) DRAIN TO EMPTY
    @(posedge vif.rd_clk);
    $display("\n=== GEN: Drain to empty ===");
    for (i = 0; i <= vif.DEPTH; i++) begin
      @(posedge vif.rd_clk);
      tx = new();
      tx.wr_en = 0;
      tx.rd_en = 1;
      gen2driv.put(tx);
    end
    @(posedge vif.rd_clk);
    tx = new(); 
    tx.wr_en = 0; 
    tx.rd_en = 0;
    gen2driv.put(tx);

    // 4) RESET + RANDOM R/W
    @(posedge vif.wr_clk);
    $display("\n=== GEN: Reset FIFO and random R/W ===");
    repeat (2) @(posedge vif.wr_clk);

    for (i = 0; i <= vif.DEPTH/2; i++) begin
      @(posedge vif.wr_clk or posedge vif.rd_clk);
      tx = new();
      if (!tx.randomize()) begin
        $display("** GEN WARNING: randomize failed at iteration %0d", i);
      end
      gen2driv.put(tx);
    end
    @(posedge vif.wr_clk);
    tx = new(); 
    tx.wr_en = 0; 
    tx.rd_en = 0;
    gen2driv.put(tx);

    -> done;
    $display("\n=== GEN: All phases complete ===");
  endtask

endclass : generator

`endif // GENERATOR_SV

