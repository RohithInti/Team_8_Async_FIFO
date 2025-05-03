//////////////////////////////////////////////////////////////////////////////////////////////
// File name: environment.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This environment class will initialize and connect together all the components.
/////////////////////////////////////////////////////////////////////////////////////////////

// Including all required files
`include "tb_pkg.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"

class environment;
    generator gen;
    driver drv;
    monitor_in mon_in;
    monitor_out mon_out;
    scoreboard scb;
    
    mailbox gen2drv = new();
    mailbox mon_in2scb = new();
    mailbox mon_out2scb = new();
    virtual intf vif;
    
    // Constructor to initialize virtual interface and components
    function new(virtual intf vif);
        this.vif = vif;
        gen = new(vif, gen2drv);
        drv = new(vif, gen2drv);
        mon_in = new(vif, mon_in2scb);
        mon_out = new(vif, mon_out2scb);
        scb = new(mon_in2scb, mon_out2scb);
    endfunction
    
    // Run task will start all the components inside it in parallel
    task run();
        fork
            gen.main();
            drv.main();
            mon_in.main();
            mon_out.main();
            scb.main();
        join_any

        // Reporting whether test passed or failed
        repeat (20) @(posedge vif.rd_clk);
        $display("=====================================================");
        if (scb.err_cnt == 0)
            $display("TEST PASSED: All data matched.");
        else
            $display("TEST FAILED: errors=%0d", scb.err_cnt);
        $finish;
    endtask
endclass

