//////////////////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This class Generates four scenarios—fill, overflow, drain, and then 100 mixed 
//              random cycles by sending queued fifo_seq_items.
//////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_seq_item_sv_unit::*;

class fifo_main_seq extends uvm_sequence #(fifo_seq_item);
   `uvm_object_utils(fifo_main_seq)
   int unsigned DEPTH = 256;
   function new(string name="fifo_main_seq"); 
        super.new(name); 
   endfunction

   task body();
      fifo_seq_item tx; int unsigned i;

      // a) Fill to FULL -------------------------------------------------------
      for (i = 0; i < DEPTH; i++) begin
         tx = fifo_seq_item::type_id::create($sformatf("fill_%0d", i));
         start_item(tx);
           tx.wr_en = 1; tx.rd_en = 0; tx.data_in = $urandom();
         finish_item(tx);
      end

      // b) ONE extra write to overflow --------------------------------
      tx = fifo_seq_item::type_id::create("overflow");
      start_item(tx);  tx.wr_en = 1; tx.rd_en = 0; tx.data_in = $urandom();
      finish_item(tx);

      // c) Drain to EMPTY ------------------------------------------------------
      for (i = 0; i < DEPTH; i++) begin
         tx = fifo_seq_item::type_id::create($sformatf("drain_%0d", i));
         start_item(tx);  tx.wr_en = 0; tx.rd_en = 1; tx.data_in = '0; finish_item(tx);
      end

      // d) Constrained‑random mixed traffic (100 cycles) ----------------------
      repeat (100) begin
         tx = fifo_seq_item::type_id::create("rand_tx");
         start_item(tx);
            void'(tx.randomize() with {
               wr_en dist {0 := 5, 1 := 5};
               rd_en dist {0 := 5, 1 := 5};
               wr_en || rd_en; });
            if (tx.wr_en) tx.data_in = $urandom();
            else tx.data_in = '0;
         finish_item(tx);
      end
   endtask
endclass : fifo_main_seq
