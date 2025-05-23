/////////////////////////////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This UVM Class is carrying wr_en, rd_en, and one 32-bit data word of stimulus & checking. 
////////////////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;

class fifo_seq_item extends uvm_sequence_item;
   rand bit wr_en;
   rand bit rd_en;
   rand bit [31:0] data_in;

   bit  [31:0] data_out;
   bit full, half_full;
   bit empty, half_empty;

   `uvm_object_utils_begin(fifo_seq_item)
      `uvm_field_int (wr_en, UVM_DEFAULT)
      `uvm_field_int (rd_en, UVM_DEFAULT)
      `uvm_field_int (data_in, UVM_DEFAULT | UVM_HEX)
      `uvm_field_int (data_out, UVM_DEFAULT | UVM_HEX)
      `uvm_field_int (full, UVM_DEFAULT)
      `uvm_field_int (half_full, UVM_DEFAULT)
      `uvm_field_int (empty, UVM_DEFAULT)
      `uvm_field_int (half_empty, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name="fifo_seq_item");
      super.new(name);
   endfunction
endclass : fifo_seq_item
