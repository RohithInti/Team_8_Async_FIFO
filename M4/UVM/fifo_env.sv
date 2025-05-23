//////////////////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This asynchronous fifo design uses the 256 depth (calculation is shown below)
//              The module uses uses gray code pointers for corect synchronization between 
//              write and read controller. We have defined 4 status flags to know the fifo 
//              conditions such as full, half_full, empty, and half_empty. 
//////////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_agent_pkg::*;    
import fifo_scoreboard_sv_unit::*; 

class fifo_env extends uvm_env;
   `uvm_component_utils(fifo_env)

   fifo_agent agt;   
   fifo_scoreboard sb;

   function new(string name="fifo_env", uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt = fifo_agent::type_id::create("agt", this);
      sb = fifo_scoreboard::type_id::create("sb",  this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.mon_ap.connect(sb.sb_port);
   endfunction
endclass : fifo_env
