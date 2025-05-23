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
