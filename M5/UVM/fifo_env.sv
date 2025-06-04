//////////////////////////////////////////////////////////////////////////////////////////////////////
// File name: fifo_env.sv
// Group: 8
//
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
//
// Description: This class contains the top level environment that instantiates agent, scoreboard 
//              and coverage classes. 
//////////////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_agent_pkg::*;    
import fifo_scoreboard_sv_unit::*; 
import fifo_coverage_sv_unit::*; 

class fifo_env extends uvm_env;
   `uvm_component_utils(fifo_env)

   fifo_agent agt;   
   fifo_scoreboard sb;
   fifo_coverage cov;

   function new(string name="fifo_env", uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt = fifo_agent::type_id::create("agt", this);
      sb = fifo_scoreboard::type_id::create("sb", this);
      cov = fifo_coverage::type_id::create("cov", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.mon_ap.connect(sb.sb_port);
      agt.mon.mon_ap.connect(cov.analysis_export);
   endfunction
endclass : fifo_env
