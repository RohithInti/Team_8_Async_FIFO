//////////////////////////////////////////////////////////////////////////////////////////////
// File name: generator.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This generator class will generate stimulus for FIFO operations.
/////////////////////////////////////////////////////////////////////////////////////////////

`include "tb_pkg.sv"

class generator;
    virtual intf vif;
    mailbox gen2driv;
    event done;
    
    
    // Constructor to initialize virtual interface and mailbox
    function new(virtual intf vif, mailbox gen2driv);
      this.vif = vif;
      this.gen2driv = gen2driv;
    endfunction
    
    // Main task which will start the stimulus generation
    task main();
      tb_pkg::transaction tx;
      int i;
    
      // Write Operations
      $display("\n=== GENERATOR: Starting write phase (FILL %0d words) ===", tb_pkg::DEPTH);
      for (i = 0; i < tb_pkg::DEPTH; i++) begin
        @(posedge vif.wr_clk);
        tx = new();
        tx.wr_en = 1;
        tx.wr_data = i;             
        gen2driv.put(tx);
        $display("[%0t] WRITE | DATA: 0x%08h | STATUS: FULL=%0b HALF_FULL=%0b",
                 $time, tx.wr_data, vif.full, vif.half_full);
      end
      @(posedge vif.wr_clk);
      tx = new(); tx.wr_en = 0; gen2driv.put(tx);
    
      // Read Operations
      $display("\n=== GENERATOR: Starting read phase (DRAIN %0d words) ===", tb_pkg::DEPTH);
      for (i = 0; i < tb_pkg::DEPTH; i++) begin
        @(posedge vif.rd_clk);
        tx = new();
        tx.rd_en = 1;
        gen2driv.put(tx);
        $display("[%0t] READ | DATA: 0x%08h | STATUS: EMPTY=%0b HALF_EMPTY=%0b",
                 $time, vif.rd_data, vif.empty, vif.half_empty);
      end
      @(posedge vif.rd_clk);
      tx = new(); tx.rd_en = 0; gen2driv.put(tx);
    
      -> done;
      $display("\n=== GENERATOR: Completed %0d write / read operations) ===", tb_pkg::DEPTH);
    endtask
endclass

