//////////////////////////////////////////////////////////////////////////////////////////////
// File name: top.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This is the testbench top where all the components will be utalized.
/////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "interface.sv"
`include "async_fifo.sv"
`include "test.sv"

module testbench_top;
  logic wr_clk = 0;
  logic rd_clk = 0;
  logic wr_rst_n = 1;   
  logic rd_rst_n = 1;

  // 100 MHz write clock (2 ns period)
  always #1 wr_clk = ~wr_clk;

  // ~71 MHz read clock (4 ns period)
  always #2 rd_clk = ~rd_clk;

  initial begin
    #3ns;

    wr_rst_n = 0;
    rd_rst_n = 0;

    #6ns;

    wr_rst_n = 1;
    rd_rst_n = 1;
  end

  intf vif (.wr_clk (wr_clk), .wr_rst_n (wr_rst_n), .rd_clk (rd_clk), .rd_rst_n (rd_rst_n));

  async_fifo #(
    .DATA_WIDTH(32),
    .DEPTH (256),
    .ADDR_WIDTH (8)
  ) dut (.wr_clk (vif.wr_clk),.wr_rst_n (vif.wr_rst_n), .wr_en (vif.wr_en), .wr_data (vif.wr_data), .full (vif.full),
         .half_full (vif.half_full), .rd_clk (vif.rd_clk), .rd_rst_n (vif.rd_rst_n), .rd_en (vif.rd_en), .rd_data (vif.rd_data),
         .empty (vif.empty), .half_empty (vif.half_empty));

  test t0;

  initial begin
    wait (wr_rst_n && rd_rst_n);

    @(posedge wr_clk);

    t0 = new(vif);
    t0.run();
  end

endmodule

