//////////////////////////////////////////////////////////////////////////////////////////////
// File name: fifo_scoreboard.sv
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

class fifo_scoreboard extends uvm_component;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) sb_port;
  bit [31:0] ref_q[$];

  // Statistics
  int overflow_cnt  = 0;
  int underflow_cnt = 0;
  int data_mism_cnt = 0;

  function new (string name = "fifo_scoreboard",
                uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_port = new("sb_port", this);
  endfunction

  function void write (fifo_seq_item tr);
    bit [31:0] expected;                 

    //  WRITE 
    if (tr.wr_en) begin
      if (!tr.full)
        ref_q.push_back(tr.data_in);
      else begin
        overflow_cnt++;
        `uvm_warning("FIFO_OFLOW",
                     $sformatf("Write while FULL at %0t", $time))
      end
    end

    //  READ side 
    if (tr.rd_en) begin
      if (!tr.empty) begin
        if (ref_q.size() == 0) begin
          underflow_cnt++;
          `uvm_error(get_type_name(),
                     "Reference queue empty on valid read")
        end
        else begin
          expected = ref_q.pop_front();
          if (expected !== tr.data_out) begin
            data_mism_cnt++;
            `uvm_error("DATA_MISM",
                       $sformatf("Exp %h  Got %h  @%0t",
                                 expected, tr.data_out, $time))
          end
        end
      end
      else begin
        underflow_cnt++;
        `uvm_warning("FIFO_UFLOW",
                     $sformatf("Read while EMPTY at %0t", $time))
      end
    end
  endfunction : write

  function void report_phase (uvm_phase phase);
    int total_pushes;                    
    super.report_phase(phase);

    total_pushes = ref_q.size() + overflow_cnt;

    `uvm_info(get_type_name(),
              "=== FIFO SCOREBOARD SUMMARY ===", UVM_LOW)
    `uvm_info(get_type_name(),
              $sformatf("Total pushes: %0d", total_pushes),
              UVM_LOW)
    `uvm_info(get_type_name(),
              $sformatf("Overflow attempts: %0d", overflow_cnt),
              UVM_LOW)
    `uvm_info(get_type_name(),
              $sformatf("Under-flow attempts: %0d", underflow_cnt),
              UVM_LOW)
    `uvm_info(get_type_name(),
              $sformatf("Data mismatches: %0d", data_mism_cnt),
              UVM_LOW)

    if (data_mism_cnt == 0)
      `uvm_info(get_type_name(),
                "Scoreboard PASSED – no data mismatches detected.", UVM_LOW)
    else
      `uvm_error(get_type_name(),
                 $sformatf("Scoreboard FAILED – %0d mismatches.",
                           data_mism_cnt))
  endfunction : report_phase
endclass
