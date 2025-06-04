///////////////////////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This interface class contains the signals used for DUT and testbench environment.
//              It also contains two modports for driver and monitor seperately. 
///////////////////////////////////////////////////////////////////////////////////////////////////

interface async_fifo_if #(parameter int DATA_WIDTH = 32);

   // Write domain
   logic                   wr_clk;
   logic                   wr_rst_n;
   logic                   wr_en;
   logic [DATA_WIDTH-1:0]  wr_data;
   logic                   full;
   logic                   half_full;

   // Read domain
   logic                   rd_clk;
   logic                   rd_rst_n;
   logic                   rd_en;
   logic [DATA_WIDTH-1:0]  rd_data;
   logic                   empty;
   logic                   half_empty;

   modport drv_mp (output wr_en, wr_data, rd_en,
                   input wr_clk, rd_clk, full, empty);
   modport mon_mp (input  wr_en, wr_data, full, empty,
                   input  rd_en, rd_data, wr_clk, rd_clk);
endinterface : async_fifo_if
