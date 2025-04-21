//////////////////////////////////////////////////////////////////////////////////
// File name: async_fifo_tb.sv
// Group: 8
// Authors: Vaishnavi Pandhare
//          Rohith Shri Krishna Inti 
//          Mrudula Chekuri
//          Venkat Sahith Reddy Cheedu
// Description: This testbench module will test the ASYNC FIFO DUT by completely
//             filling it up to test full, half_full flags and draining it by 
//             reading all those locations to test empty and half_empty flags.
//////////////////////////////////////////////////////////////////////////////////

module async_fifo_tb;

localparam int DATA_WIDTH = 32;
localparam int DEPTH = 256;

logic wr_clk;
logic rd_clk;
logic wr_rst_n;
logic rd_rst_n;
logic wr_en;
logic rd_en;
logic [DATA_WIDTH-1:0] wr_data;
logic [DATA_WIDTH-1:0] rd_data;
logic full;
logic half_full;
logic empty;
logic half_empty;

// DUT INSTANTIATION
async_fifo #(
    .DATA_WIDTH (DATA_WIDTH), 
    .DEPTH (DEPTH)
) dut (
    .wr_clk (wr_clk),
    .wr_rst_n (wr_rst_n),
    .wr_en (wr_en),
    .wr_data (wr_data),
    .full (full),
    .half_full (half_full),
    .rd_clk (rd_clk),
    .rd_rst_n (rd_rst_n),
    .rd_en (rd_en),
    .rd_data (rd_data),
    .empty (empty),
    .half_empty (half_empty)
  );

initial begin
    // Initialize clock, reset, control signals
    wr_clk    = 0;
    rd_clk    = 0;
    wr_rst_n  = 0;
    rd_rst_n  = 0;
    wr_en     = 0;
    rd_en     = 0;
    wr_data   = 0;

    forever begin
      #1  wr_clk = ~wr_clk;
    end
  end

initial begin
    forever begin
      #2  rd_clk = ~rd_clk;
    end
end

// TASK FOR WRITE UNTIL FULL OPERATION
task write_until_full();
    wr_data = 0;
    wr_en = 1;
    while (!full) 
    @(posedge wr_clk)
    wr_data++;
    wr_en = 0;
endtask

// TASK FOR READ UNTIL EMPTY OPERATION
task read_until_empty();
    rd_en = 1;
    while (!empty) 
    @(posedge rd_clk);
    rd_en = 0;
endtask

// DISPLAY WRITE DATA
always_ff @(posedge wr_clk) begin
    if (wr_rst_n && wr_en) begin
      $display("[WRITE at time = %4t] wr_ptr=%d  data=0x%h  full=%b hf=%b  empty=%b he=%b",
               $time, dut.wr_ptr_bin, wr_data, full, half_full, empty, half_empty);
    end
end

// DISPLAY READ DATA
always_ff @(posedge rd_clk) begin
    if (rd_rst_n && rd_en) begin
      $display("[READ at time = %4t] rd_ptr=%d  data=0x%h  full=%b hf=%b  empty=%b he=%b",
               $time, dut.rd_ptr_bin, rd_data, full, half_full, empty, half_empty);
    end
end


initial begin
    // Deassert RESET
    wr_rst_n = 0;
    rd_rst_n = 0;
    repeat (5) @(posedge wr_clk);

    // Assert RESET
    wr_rst_n = 1; 
    rd_rst_n = 1;
    repeat (2) @(posedge wr_clk)

    $display("\n INITIATING THE TESTCASE ");
    write_until_full();
    read_until_empty();

    repeat (5) @(posedge wr_clk);
    $display("ALL TESTS COMPLETED");
    $finish;
end

endmodule