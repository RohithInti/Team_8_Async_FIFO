//////////////////////////////////////////////////////////////////////////////////////////////
// File name: test.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This test class contains the complete environment and initiates and controls
//              the test execution.
/////////////////////////////////////////////////////////////////////////////////////////////

`include "environment.sv"

class test;
    environment env;
    // Constructor to initialize virtual interface and environment
    function new(virtual intf vif);
      env = new(vif);
    endfunction
    
    task run();
      env.run();
    endtask
endclass

