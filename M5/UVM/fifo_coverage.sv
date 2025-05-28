//////////////////////////////////////////////////////////////////////////////////////////////////////
// File name: fifo_coverage.sv
//
// Group: 8
//
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
//
// Description: This class contains the functional covergroup for data patterns and flag transitions.
//////////////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_seq_item_sv_unit::*;   

class fifo_coverage extends uvm_subscriber #(fifo_seq_item);
  `uvm_component_utils(fifo_coverage)

  fifo_seq_item tr;

  // Covergroup
  covergroup cg_fifo with function sample ();

    cp_wr_en: coverpoint tr.wr_en {bins off = {0}; bins on = {1}; }
    cp_rd_en: coverpoint tr.rd_en {bins off = {0}; bins on = {1}; }

    cp_full : coverpoint tr.full {bins no = {0}; bins yes = {1}; }
    cp_empty: coverpoint tr.empty {bins no = {0}; bins yes = {1}; }

    cp_half_f: coverpoint tr.half_full  {bins no = {0}; bins yes = {1}; }
    cp_half_e: coverpoint tr.half_empty {bins no = {0}; bins yes = {1}; }

    cp_data_in: coverpoint tr.data_in  {
      //option.auto_bin_max = 16;               
      wildcard bins zero = {32'h0000_0000};
      wildcard bins all_ones = {32'hFFFF_FFFF};
    }

    cross_wr_full: cross cp_wr_en, cp_full;
    cross_rd_empty: cross cp_rd_en, cp_empty;

  endgroup : cg_fifo

  function new (string name = "fifo_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_fifo = new();
  endfunction

  function void write (fifo_seq_item t);
    tr = t;
    cg_fifo.sample();
  endfunction

  function void report_phase (uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
              $sformatf("Functional coverage = %0.2f%%",
                        cg_fifo.get_inst_coverage()),
              UVM_MEDIUM)
  endfunction
endclass : fifo_coverage

