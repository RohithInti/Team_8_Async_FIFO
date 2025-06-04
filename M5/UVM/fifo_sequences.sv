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

  localparam bit BUG_INJECTION = 1;

  function new(string name = "fifo_main_seq");
    super.new(name);
  endfunction : new

  task body();
    fifo_seq_item tr;
    bit bug_injection_flag = BUG_INJECTION;

    if (bug_injection_flag) begin
      `uvm_info(get_type_name(),
                "Bug injection ON: flooding with extra writes", UVM_MEDIUM)
      repeat (300) begin
        `uvm_create(tr)
        assert(tr.randomize() with { wr_en == 1; rd_en == 0; });
        `uvm_send(tr)
      end

      `uvm_info(get_type_name(),
                "Bug injection ON: flooding with extra reads", UVM_MEDIUM)
      repeat (300) begin
        `uvm_create(tr)
        assert(tr.randomize() with { wr_en == 0; rd_en == 1; });
        `uvm_send(tr)
      end
    end

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

    // 2.  Drain the FIFO completely
    repeat (255) begin
      `uvm_create(tr)
      assert(tr.randomize() with { wr_en == 0; rd_en == 1; });
      `uvm_send(tr)
    end

    // 2a. One extra read 
    `uvm_create(tr)
    tr.wr_en = 0;
    tr.rd_en = 1;
    `uvm_send(tr)

    // 3.  100 Random Transactions
    repeat (100) begin
      `uvm_create(tr)
      assert(tr.randomize());
      `uvm_send(tr)
    end

// 4. Multiple full-empty cycles
repeat (8) begin
  repeat (257) begin
    `uvm_create(tr)
    tr.wr_en = 1; tr.rd_en = 0;
    assert(tr.randomize() with { rd_en == 0; });
    `uvm_send(tr)
  end
  // draining completely
  repeat (257) begin
    `uvm_create(tr)
    tr.wr_en = 0; tr.rd_en = 1;
    assert(tr.randomize() with { wr_en == 0; });
    `uvm_send(tr)
  end
end 


  endtask
endclass

