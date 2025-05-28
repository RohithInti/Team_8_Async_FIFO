//////////////////////////////////////////////////////////////////////////////////////////////
// File name: scoreboard.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This scoreboard class verifies FIFO functionality by comparing actual vs expected data.
/////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "tb_pkg.sv"

class scoreboard;
  mailbox mon_in2scb, mon_out2scb;
  int err_cnt;
  bit [tb_pkg::DATA_WIDTH-1:0] expected_queue[$];

  function new(mailbox in2scb, mailbox out2scb);
    mon_in2scb  = in2scb;
    mon_out2scb = out2scb;
    err_cnt = 0;
  endfunction

  task write_monitor();
    tb_pkg::transaction tx;
    forever begin
      mon_in2scb.get(tx);
      if (tx.wr_en && tx.full == 0) begin
        expected_queue.push_back(tx.wr_data);
      end
    end
  endtask

  task read_monitor();
    tb_pkg::transaction tx;
    bit [tb_pkg::DATA_WIDTH-1:0] exp;
    forever begin
      mon_out2scb.get(tx);
      if (tx.rd_en && tx.empty == 0) begin
        if (expected_queue.size() == 0) begin
          $display("[%0t] SCOREBOARD: **ERROR** Unexpected read 0x%0h",
                   $time, tx.rd_data);
          err_cnt++;
        end else begin
          exp = expected_queue.pop_front();
          if (exp !== tx.rd_data) begin
            $display("[%0t] SCOREBOARD: **ERROR** Data mismatch! Expected: 0x%0h Received: 0x%0h",
                     $time, exp, tx.rd_data);
            err_cnt++;
          end
        end
      end
    end
  endtask

  task main();
    $display("[%0t] SCOREBOARD: Started", $time);
    fork
      write_monitor();
      read_monitor();
    join_none
  endtask

endclass : scoreboard

`endif // SCOREBOARD_SV

