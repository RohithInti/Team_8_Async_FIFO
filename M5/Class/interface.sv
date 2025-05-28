//////////////////////////////////////////////////////////////////////////////////////////////
// File name: interface.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This interface will connect testbench to DUT.
/////////////////////////////////////////////////////////////////////////////////////////////

`include "tb_pkg.sv"

interface intf #(
    parameter int DATA_WIDTH = tb_pkg::DATA_WIDTH, // Data Bus Width
    parameter int DEPTH = tb_pkg::DEPTH) // FIFO Depth
    (input logic wr_clk, wr_rst_n,
     input logic rd_clk, rd_rst_n);
    
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, half_full, empty, half_empty;
endinterface

