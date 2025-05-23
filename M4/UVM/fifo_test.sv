//////////////////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This class builds the environment, starts fifo_main_seq, and routes UVM reports 
//              into four separate log files (info, warn, error, fatal).
//////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_seq_item_sv_unit::*;

class fifo_test extends uvm_test;
   `uvm_component_utils(fifo_test)
   fifo_env env;

   function new(string name="fifo_test", uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = fifo_env::type_id::create("env", this);
   endfunction

   function void start_of_simulation_phase(uvm_phase phase);
      int fd_default, fd_warning, fd_error, fd_fatal;
      fd_default = $fopen("default_file.log", "w");
      fd_warning = $fopen("warning_file.log", "w");
      fd_error = $fopen("error_file.log", "w");
      fd_fatal = $fopen("fatal_file.log", "w");

      set_report_severity_action_hier(UVM_INFO, UVM_DISPLAY | UVM_LOG);
      set_report_severity_action_hier(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
      set_report_severity_action_hier(UVM_ERROR, UVM_DISPLAY | UVM_LOG);
      set_report_severity_action_hier(UVM_FATAL, UVM_DISPLAY | UVM_LOG);

      set_report_severity_file_hier(UVM_INFO, fd_default);
      set_report_severity_file_hier(UVM_WARNING, fd_warning);
      set_report_severity_file_hier(UVM_ERROR, fd_error);
      set_report_severity_file_hier(UVM_FATAL, fd_fatal);
   endfunction

      task run_phase(uvm_phase phase);
      fifo_main_seq seq;                 
      phase.raise_objection(this);
      seq = fifo_main_seq::type_id::create("seq");
      seq.start(env.agt.seqr);
      #1000ns;                           
      phase.drop_objection(this);
   endtask
endclass
