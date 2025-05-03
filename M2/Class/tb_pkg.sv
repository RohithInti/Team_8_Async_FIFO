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
    parameter int DATA_WIDTH = 32;
    parameter int DEPTH = 256;
    
    // This class handles read and write operations with randomization and constraint with status monitoring.
    class transaction;
      rand bit wr_en;
      rand bit rd_en;
      rand logic [DATA_WIDTH-1:0] wr_data;
      logic [DATA_WIDTH-1:0] rd_data;
      logic full, half_full;
      logic empty, half_empty;
    
      // Write and read cannot occur simultaneously
      constraint c_onehot { wr_en + rd_en == 1; }
    
      // Constructor to initialize all fields to zero
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
    
      // Print function for transaction details
      function void print();
        $display("[%0t] Transaction: WR=%b DATA=0x%08h | RD=%b DATA=0x%08h| FULL=%b HF=%b EMPTY=%b HE=%b",
                 $time, wr_en, wr_data,
                 rd_en, rd_data,
                 full,   half_full,
                 empty,  half_empty);
      endfunction
    endclass
endpackage

`endif  // TB_PKG_SV

