//////////////////////////////////////////////////////////////////////////////////////////////
// File name: tb_pkg.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This package contains FIFO global parameters and transaction class.
/////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TB_PKG_SV
`define TB_PKG_SV

package tb_pkg;

  // ----------------------------------------------------------------
  // Global parameters
  // ----------------------------------------------------------------
  parameter int DATA_WIDTH = 32;
  parameter int DEPTH      = 256;

  class transaction;

    rand bit wr_en;
    rand bit rd_en;
    rand logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;

    logic full, half_full;
    logic empty, half_empty;

    // Only one of wr_en / rd_en may be asserted (or neither)
    constraint c_onehot { wr_en + rd_en <= 1; }

    // Constrain data to valid FIFO range (e.g., 0 to DEPTH-1)
    constraint data_valid_range { wr_data < DEPTH; }

    function new();
      wr_en = 0;
      rd_en = 0;
      wr_data = '0;
      rd_data = '0;
      full = 0;
      half_full = 0;
      empty = 0;
      half_empty = 0;
    endfunction

    function void print();
      if (wr_en) begin
        $display("[%0t] WRITE : DATA=0x%08h | FULL=%b HF=%b", $time, wr_data, full, half_full);
      end
      else if (rd_en) begin
        $display("[%0t] READ  : DATA=0x%08h | EMPTY=%b HE=%b", $time, rd_data, empty, half_empty);
      end
    endfunction

  endclass : transaction

endpackage : tb_pkg

`endif // TB_PKG_SV
