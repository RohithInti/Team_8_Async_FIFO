//////////////////////////////////////////////////////////////////////////////////////////////
// File name: scoreboard.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This scoreboard class verifies FIFO functionality by comparing actual vs expected data.
/////////////////////////////////////////////////////////////////////////////////////////////

`include "tb_pkg.sv"

class scoreboard;
    mailbox mon_in2scb, mon_out2scb;
    logic [tb_pkg::DATA_WIDTH-1:0] model_q[$];
    int err_cnt = 0;
    
    // Constructor to initialize virtual interface and mailbox
    function new(mailbox in2scb, mailbox out2scb);
      mon_in2scb = in2scb;
      mon_out2scb = out2scb;
    endfunction
    
    // Main task will process parallel transactions
    task main();
      fork
        collect_writes();
        check_reads();
      join
    endtask
    
    // This task will store expected data from write transactions
    task collect_writes();
      tb_pkg::transaction tx;
      forever begin
        mon_in2scb.get(tx);
        model_q.push_back(tx.wr_data);
      end
    endtask
    
    // This task will verify read transaction with reference model
    task check_reads();
      tb_pkg::transaction tx;
      forever begin
        mon_out2scb.get(tx);
        if (model_q.size()==0) begin
        end else begin
          logic [tb_pkg::DATA_WIDTH-1:0] exp = model_q.pop_front();
          if (tx.rd_data !== exp) begin
            $display("[%0t] SCOREBOARD: **ERROR** Data mismatch! Expected: 0x%08h Received: 0x%08h",
                     $time, exp, tx.rd_data);
            err_cnt++;
          end
        end
      end
    endtask
endclass

