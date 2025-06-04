//////////////////////////////////////////////////////////////////////////////////////////////
// File name: fifo_ageng_pkg.sv
//
// Group: 8
//
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This class bundles the sequencer, driver, and monitor and initializes them.
//
//////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
package fifo_agent_pkg;
   import uvm_pkg::*;
   import fifo_seq_item_sv_unit::*;   

   // Sequencer
   class fifo_seqr extends uvm_sequencer #(fifo_seq_item);
      `uvm_component_utils(fifo_seqr)
      function new (string name="fifo_seqr", uvm_component parent=null);
         super.new(name,parent);
      endfunction
   endclass

   // Driver
   class fifo_drv extends uvm_driver #(fifo_seq_item);
      `uvm_component_utils(fifo_drv)

      virtual async_fifo_if vif;

      function new (string name="fifo_drv", uvm_component parent=null);
         super.new(name,parent);
      endfunction

      function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         if (!uvm_config_db#(virtual async_fifo_if)::get(this,"*","vif",vif))
            `uvm_fatal(get_type_name(),
                       "virtual interface not set via config DB (key \"vif\")" )
      endfunction

      task run_phase(uvm_phase phase);
         fifo_seq_item tr;

         // reset interface
         vif.wr_en   <= 0;
         vif.rd_en   <= 0;
         vif.wr_data <= '0;

         forever begin
            seq_item_port.get_next_item(tr);

            // WRITE
            @(posedge vif.wr_clk);
            vif.wr_en   <= tr.wr_en;
            vif.wr_data <= tr.data_in;

            @(posedge vif.wr_clk)  vif.wr_en <= 0; vif.wr_data <= 0; 
            // READ
            @(posedge vif.rd_clk);
            vif.rd_en   <= tr.rd_en;

            // returning interface to idle
            @(posedge vif.wr_clk)  vif.wr_en <= 0;
            @(posedge vif.rd_clk)  vif.rd_en <= 0;

            seq_item_port.item_done();
         end
      endtask
   endclass

   // Monitor
class fifo_mon extends uvm_monitor;
   `uvm_component_utils(fifo_mon)

   virtual async_fifo_if vif;
   uvm_analysis_port #(fifo_seq_item) mon_ap;

   function new(string name="fifo_mon", uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon_ap = new("mon_ap", this);
      if (!uvm_config_db#(virtual async_fifo_if)::get(this,"*","vif",vif))
         `uvm_fatal(get_type_name(),
                    "virtual interface not set via config DB (key=\"vif\")")
   endfunction


   //  RUN PHASE
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      // CAPTURE WRITE
      fork
         forever begin
            @(posedge vif.wr_clk);
            if (vif.wr_en) begin
               fifo_seq_item tx =
                   fifo_seq_item::type_id::create("tx_wr", this);
               tx.wr_en = 1;
               tx.rd_en = 0;
               tx.data_in = vif.wr_data;
               tx.full = vif.full;
               tx.empty = vif.empty;
               tx.half_full = vif.half_full;
               tx.half_empty = vif.half_empty;
               mon_ap.write(tx);
            end
         end

         // CAPTURE READ 
         begin
            bit rd_en_d   = 0;
            bit empty_d   = 1;
            bit [31:0] rd_data_d = '0;

            forever begin
               @(posedge vif.rd_clk);

               if (rd_en_d) begin
                  fifo_seq_item tx =
                      fifo_seq_item::type_id::create("tx_rd", this);
                  tx.wr_en = 0;
                  tx.rd_en = 1;
                  tx.data_out = rd_data_d;
                  tx.full = vif.full;    
                  tx.empty = empty_d;
                  mon_ap.write(tx);
               end

               rd_en_d = vif.rd_en;
               empty_d = vif.empty;
               rd_data_d = vif.rd_data;
            end
         end
      join_none

      phase.drop_objection(this);
   endtask
endclass

   class fifo_agent extends uvm_agent;
      `uvm_component_utils(fifo_agent)

      fifo_seqr seqr;
      fifo_drv drv;
      fifo_mon mon;

      function new(string name="fifo_agent", uvm_component parent=null);
         super.new(name,parent);
      endfunction

      function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         seqr = fifo_seqr::type_id::create("seqr", this);
         drv = fifo_drv ::type_id::create("drv", this);
         mon = fifo_mon ::type_id::create("mon", this);
      endfunction

      function void connect_phase(uvm_phase phase);
         super.connect_phase(phase);
         drv.seq_item_port.connect(seqr.seq_item_export);
      endfunction
   endclass : fifo_agent

endpackage : fifo_agent_pkg

