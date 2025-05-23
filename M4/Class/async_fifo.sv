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

//////////////////////// Calculation of FIFO DEPTH ///////////////////////////////////////////
// Write Clock Frequency = 500MHz, Read Clock Frequency = 250MHz
// Write Clock Period = (1/500MHz) = 2ns, Read Clock Period = (1/250MHz) = 4ns
// Write Idle Cycles = 2, Read Idle Cycles = 1 ( Additional 1 Cycle is needed to process data)
// Burst Length = 1024 Words
// Write Idle Clock Period = 3 * 2ns = 6ns
// Read Idle Clock Period = 2 * 4ns = 8ns
// Total Write Time = 1024 * 6ns = 6144ns
// Total Word to be read in total write time = 6144ns / 8ns = 768
// FIFO Depth = 1024 - 768 = 256
//////////////////////////////////////////////////////////////////////////////////////////////

`ifndef ASYNC_FIFO_SV
`define ASYNC_FIFO_SV

module async_fifo #(
  parameter int DATA_WIDTH = 32,
  parameter int DEPTH = 256,
  parameter int ADDR_WIDTH = $clog2(DEPTH),
  // one extra bit to detect full/empty
  parameter int PTR_WIDTH = ADDR_WIDTH + 1
)(
  // write side
  input  logic wr_clk,
  input  logic wr_rst_n,
  input  logic wr_en,
  input  logic [DATA_WIDTH-1:0]  wr_data,
  output logic full,
  output logic half_full,

  // read side
  input  logic rd_clk,
  input  logic rd_rst_n,
  input  logic rd_en,
  output logic [DATA_WIDTH-1:0]  rd_data,
  output logic empty,
  output logic half_empty
);

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // binary pointers
  logic [PTR_WIDTH-1:0] wr_ptr_bin, wr_ptr_bin_next;
  logic [PTR_WIDTH-1:0] rd_ptr_bin, rd_ptr_bin_next;

  // gray pointers
  logic [PTR_WIDTH-1:0] wr_ptr_gray, rd_ptr_gray;
  // sync registers
  logic [PTR_WIDTH-1:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
  logic [PTR_WIDTH-1:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

  function automatic logic [PTR_WIDTH-1:0] bin2gray(input logic [PTR_WIDTH-1:0] b);
    bin2gray = b ^ (b >> 1);
  endfunction

  function automatic logic [PTR_WIDTH-1:0] gray2bin(input logic [PTR_WIDTH-1:0] g);
    integer i;
    logic [PTR_WIDTH-1:0] b;
    begin
      b[PTR_WIDTH-1] = g[PTR_WIDTH-1];
      for (i = PTR_WIDTH-2; i >= 0; i = i - 1)
        b[i] = b[i+1] ^ g[i];
      return b;
    end
  endfunction

  // ----------------------------------------------------------------
  // WRITE SIDE
  // ----------------------------------------------------------------

  always_comb begin
    if (wr_en && !full)
      wr_ptr_bin_next = wr_ptr_bin + 1;
    else
      wr_ptr_bin_next = wr_ptr_bin;
  end

  always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
      wr_ptr_bin <= '0;
      wr_ptr_gray <= '0;
    end else begin
      if (wr_en && !full)
        mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
      wr_ptr_bin <= wr_ptr_bin_next;
      wr_ptr_gray <= bin2gray(wr_ptr_bin_next);
    end
  end

  // Synchronize read pointer into write clock domain
  always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
      rd_ptr_gray_sync1 <= '0;
      rd_ptr_gray_sync2 <= '0;
    end else begin
      rd_ptr_gray_sync1 <= rd_ptr_gray;
      rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end
  end

  // Convert synced read Gray back to binary
  logic [PTR_WIDTH-1:0] rd_ptr_bin_wsync;
  assign rd_ptr_bin_wsync = gray2bin(rd_ptr_gray_sync2);

  // Compute write-side occupancy
  logic [PTR_WIDTH-1:0] wr_occupancy;
  always_comb wr_occupancy = wr_ptr_bin - rd_ptr_bin_wsync;

  // Generate flags
  assign full = (wr_occupancy >= DEPTH);
  assign half_full = (wr_occupancy >= (DEPTH/2));

  // ----------------------------------------------------------------
  // READ SIDE
  // ----------------------------------------------------------------

  // Decide next read-pointer
  always_comb begin
    if (rd_en && !empty)
      rd_ptr_bin_next = rd_ptr_bin + 1;
    else
      rd_ptr_bin_next = rd_ptr_bin;
  end

  // On read clock: update pointer, output data, update Gray
  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
      rd_ptr_bin <= '0;
      rd_ptr_gray <= '0;
      rd_data <= '0;
    end else begin
      if (rd_en && !empty)
        rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
      rd_ptr_bin <= rd_ptr_bin_next;
      rd_ptr_gray <= bin2gray(rd_ptr_bin_next);
    end
  end

  // Synchronize write pointer into read clock domain
  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
      wr_ptr_gray_sync1 <= '0;
      wr_ptr_gray_sync2 <= '0;
    end else begin
      wr_ptr_gray_sync1 <= wr_ptr_gray;
      wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
  end

  // Convert synced write Gray back to binary
  logic [PTR_WIDTH-1:0] wr_ptr_bin_rsync;
  assign wr_ptr_bin_rsync = gray2bin(wr_ptr_gray_sync2);

  // Compute read-side occupancy
  logic [PTR_WIDTH-1:0] rd_occupancy;
  always_comb rd_occupancy = wr_ptr_bin_rsync - rd_ptr_bin;

  // Generate read flags
  assign empty = (rd_occupancy == 0);
  assign half_empty = (rd_occupancy <= (DEPTH/2));

endmodule

`endif // ASYNC_FIFO_SV
