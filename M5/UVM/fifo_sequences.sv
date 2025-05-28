//////////////////////////////////////////////////////////////////////////////////////////////
// File name: fifo_sequences.sv
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

  task body();
    fifo_seq_item tr;

    // 1.  Fill the FIFO completely
    repeat (256) begin
      `uvm_create(tr)
      assert(tr.randomize() with { wr_en == 1; rd_en == 0; });
      `uvm_send(tr)
    end

    // 1a. One *more* write while FULL  
    `uvm_create(tr)
    tr.wr_en   = 1;
    tr.rd_en   = 0;
    tr.data_in = 32'hFFFF_FFFF;   
    `uvm_send(tr)

// 1b.  Sample half-full
repeat (128) begin
  `uvm_create(tr)
  assert(tr.randomize() with { wr_en == 1; rd_en == 0; });
  `uvm_send(tr)
end


    // 2.  Drain the FIFO completely
    repeat (256) begin
      `uvm_create(tr)
      assert(tr.randomize() with { wr_en == 0; rd_en == 1; });
      `uvm_send(tr)
    end

    // 2a. One *extra* read while EMPTY --> samples rd_en/empty cross
    `uvm_create(tr)
    tr.wr_en = 0;
    tr.rd_en = 1;
    `uvm_send(tr)

// 2b.  Sample half-empty
repeat (128) begin
  `uvm_create(tr)
  assert(tr.randomize() with { wr_en == 0; rd_en == 1; });
  `uvm_send(tr)
end

    // 3.  Keep your original 100 random mixed cycles
    repeat (100) begin
      `uvm_create(tr)
      assert(tr.randomize());
      `uvm_send(tr)
    end

// 4.  4 × full-drain cycles
repeat (8) begin
  repeat (256) begin
    `uvm_create(tr)
    tr.wr_en = 1; tr.rd_en = 0;
    assert(tr.randomize() with { rd_en == 0; });
    `uvm_send(tr)
  end
  // draining completely
  repeat (256) begin
    `uvm_create(tr)
    tr.wr_en = 0; tr.rd_en = 1;
    assert(tr.randomize() with { wr_en == 0; });
    `uvm_send(tr)
  end
end

// Force occupancy to exactly 129 → 128 → 127
// This guarantees at least one cycle with half_full == 1
repeat (129) begin                
  `uvm_create(tr)
  tr.wr_en = 1; tr.rd_en = 0;
  assert(tr.randomize() with { rd_en == 0; });
  `uvm_send(tr)
end

// Now do a single read; half_full still asserted
`uvm_create(tr)
tr.wr_en = 0; tr.rd_en = 1;
`uvm_send(tr)

  endtask
endclass

