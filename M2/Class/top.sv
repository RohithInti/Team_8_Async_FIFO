`timescale 1ns/1ps
`include "interface.sv"
`include "async_fifo.sv"
`include "test.sv"

module testbench_top;
  bit wr_clk=0, rd_clk=0;
  bit wr_rst_n=0, rd_rst_n=0;

  always #1 wr_clk = ~wr_clk;   // 500 MHz
  always #2 rd_clk = ~rd_clk;   // 250 MHz

  initial begin
    repeat (2) @(posedge wr_clk);
    wr_rst_n = 1; rd_rst_n = 1;
  end

  intf #(tb_pkg::DATA_WIDTH, tb_pkg::DEPTH) vif
    (wr_clk, wr_rst_n, rd_clk, rd_rst_n);

  async_fifo #(.DATA_WIDTH(tb_pkg::DATA_WIDTH),
               .DEPTH     (tb_pkg::DEPTH))
  dut (
    .wr_clk     (wr_clk),
    .wr_rst_n   (wr_rst_n),
    .wr_en      (vif.wr_en),
    .wr_data    (vif.wr_data),
    .full       (vif.full),
    .half_full  (vif.half_full),
    .rd_clk     (rd_clk),
    .rd_rst_n   (rd_rst_n),
    .rd_en      (vif.rd_en),
    .rd_data    (vif.rd_data),
    .empty      (vif.empty),
    .half_empty (vif.half_empty)
  );

  test t0 = new(vif);
  initial t0.run();
endmodule

