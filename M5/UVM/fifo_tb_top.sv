////////////////////////////////////////////////////////////////////////////////////////////////////
// File name: fifo_tb_top.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This is simple testbench top which creates interface, clocks, resets, instantiates 
//              the DUT, puts the virtual interface into the config DB, and starts the UVM test.
////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo_tb_top;
   localparam int DATA_WIDTH = 32;
   localparam int DEPTH = 256;

   // Clock periods
   localparam time WR_CLK_T = 2ns;   // 500 MHz
   localparam time RD_CLK_T = 4ns;   // 250 MHz

   // Interface instantiation
   async_fifo_if #(.DATA_WIDTH(DATA_WIDTH)) intf();

   // DUT instantiation
   async_fifo #(
      .DATA_WIDTH (DATA_WIDTH),
      .DEPTH (DEPTH)
   ) dut (
      // Write side
      .wr_clk (intf.wr_clk),
      .wr_rst_n (intf.wr_rst_n),
      .wr_en (intf.wr_en),
      .wr_data (intf.wr_data),
      .full (intf.full),
      .half_full (intf.half_full),
      // Read side
      .rd_clk (intf.rd_clk),
      .rd_rst_n (intf.rd_rst_n),
      .rd_en (intf.rd_en),
      .rd_data (intf.rd_data),
      .empty (intf.empty),
      .half_empty (intf.half_empty)
   );

   // Clock generation
   initial begin
      intf.wr_clk = 0;
      forever #(WR_CLK_T/2) intf.wr_clk = ~intf.wr_clk;
   end

   initial begin
      intf.rd_clk = 0;
      forever #(RD_CLK_T/2) intf.rd_clk = ~intf.rd_clk;
   end

   // Asynchronous reset sequence
   initial begin
      intf.wr_rst_n = 0;
      intf.rd_rst_n = 0;
      repeat (4) @(posedge intf.wr_clk);
      intf.wr_rst_n = 1;
      repeat (2) @(posedge intf.rd_clk);
      intf.rd_rst_n = 1;
   end

   initial begin
      uvm_config_db#(virtual async_fifo_if)::set(null, "*", "vif", intf);
   end

   // Start UVM
   initial begin
      run_test("fifo_test");
   end
endmodule : fifo_tb_top


