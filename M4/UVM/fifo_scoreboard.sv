//////////////////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This class contains a simple reference model which ushes every write into a 
//              queue and pops, compares on each read, issuing UVM errors on mismatches. 
//////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_seq_item_sv_unit::*; 

class fifo_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(fifo_scoreboard)

   fifo_seq_item exp_queue[$];
   uvm_analysis_imp #(fifo_seq_item,
                      fifo_scoreboard)  sb_port;

   function new(string name = "fifo_scoreboard",
                uvm_component parent = null);
      super.new(name, parent);
   endfunction

   //  BUILD PHASE
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_port = new("sb_port", this);
   endfunction

   function void write(fifo_seq_item t);

      fifo_seq_item model;

      if (t.wr_en)
         exp_queue.push_back(t);

      if (t.rd_en) begin
         if (exp_queue.size == 0) begin
            `uvm_error(get_type_name(),
               "Read but model queue empty ? underflow?")
            return;
         end
         model = exp_queue.pop_front();
         if (model.data_in !== t.data_out) begin
            `uvm_error(get_type_name(),
               $sformatf("Mismatch: expected 0x%0h got 0x%0h",
                         model.data_in, t.data_out))
         end
         else begin
            `uvm_info(get_type_name(),
               $sformatf("Match OK: 0x%0h", t.data_out), UVM_LOW)
         end
      end
   endfunction

endclass

