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

module async_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH = 256,
    localparam int ADDR_WIDTH = $clog2(DEPTH)
)(   
    input logic wr_clk,
    input logic wr_rst_n,
    input logic wr_en,
    input logic [DATA_WIDTH-1:0] wr_data,
    input logic rd_clk,
    input logic rd_rst_n,
    input logic rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic full, half_full,
    output logic empty, half_empty);

// Memory array of given depth
logic [DATA_WIDTH-1:0] mem [DEPTH];

// Gray and Binary Pointer Declarations
logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray;
logic [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray;

// Function for converting Binary to Gray 
function automatic logic [ADDR_WIDTH:0] bin2gray (input logic [ADDR_WIDTH:0] b);
    return (b >> 1) ^ b;
endfunction

// Function for converting Gray to Binary
function automatic logic [ADDR_WIDTH:0] gray2bin (input logic [ADDR_WIDTH:0] g);
    logic [ADDR_WIDTH:0] b;
    b[ADDR_WIDTH] = g[ADDR_WIDTH];
    for (int i = ADDR_WIDTH-1; i >= 0; i--)
        b[i] = b[i+1] ^ g[i];
    return b;
endfunction

// WRITE OPERATION
logic [ADDR_WIDTH:0] rd_ptr_gray_sync1_w, rd_ptr_gray_sync2_w;


always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_ptr_bin <= '0;
        wr_ptr_gray <= '0;
        rd_ptr_gray_sync1_w <= '0;
        rd_ptr_gray_sync2_w <= '0;
        full <= 1'b0;
        half_full <= 1'b0;
    end
    else begin
        automatic logic wr_inc, full_next;
        automatic logic [ADDR_WIDTH:0] wr_ptr_bin_n, wr_ptr_gray_n;
        automatic logic [ADDR_WIDTH:0] rd_bin_w, depth_w;

        // Read pointer CDC Synchronization
        rd_ptr_gray_sync1_w <= rd_ptr_gray;
        rd_ptr_gray_sync2_w <= rd_ptr_gray_sync1_w;

        wr_inc = wr_en & ~full;
        wr_ptr_bin_n = wr_ptr_bin + wr_inc;
        wr_ptr_gray_n = bin2gray(wr_ptr_bin_n);

        // Write to memory operation
        if (wr_inc)
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;

        
        wr_ptr_bin <= wr_ptr_bin_n;
        wr_ptr_gray <= wr_ptr_gray_n;

        // Full Flag Condition
        full_next = (wr_ptr_gray_n[ADDR_WIDTH] != rd_ptr_gray_sync2_w[ADDR_WIDTH]) &&
                    (wr_ptr_gray_n[ADDR_WIDTH-1] != rd_ptr_gray_sync2_w[ADDR_WIDTH-1]) &&
                    (wr_ptr_gray_n[ADDR_WIDTH-2:0] == rd_ptr_gray_sync2_w[ADDR_WIDTH-2:0]);
        full <= full_next;

        rd_bin_w = gray2bin(rd_ptr_gray_sync2_w);
        depth_w = wr_ptr_bin_n - rd_bin_w;
        half_full <= (depth_w >= DEPTH/2);
    end
end    

// READ OPERATION
logic [ADDR_WIDTH:0] wr_ptr_gray_sync1_r, wr_ptr_gray_sync2_r;
logic [DATA_WIDTH-1:0] rd_data_r;

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_ptr_bin <= '0;
        rd_ptr_gray <= '0;
        wr_ptr_gray_sync1_r <= '0;
        wr_ptr_gray_sync2_r <= '0;
        rd_data_r <= '0;
        empty <= 1'b1;
        half_empty <= 1'b0;
    end
    else begin
        automatic logic rd_inc, empty_next;
        automatic logic [ADDR_WIDTH:0]rd_ptr_bin_n, rd_ptr_gray_n;
        automatic logic [ADDR_WIDTH:0]wr_bin_r,  depth_r;

        // Write pointer CDC Synchronization
        wr_ptr_gray_sync1_r <= wr_ptr_gray;
        wr_ptr_gray_sync2_r <= wr_ptr_gray_sync1_r;

        rd_inc = rd_en & ~empty;
        rd_ptr_bin_n = rd_ptr_bin + rd_inc;
        rd_ptr_gray_n = bin2gray(rd_ptr_bin_n);

        // Read from memory operation
        if (rd_inc)
            rd_data_r <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

        rd_ptr_bin <= rd_ptr_bin_n;
        rd_ptr_gray <= rd_ptr_gray_n;

        // Empty Flag Condition
        empty_next = (rd_ptr_gray_n == wr_ptr_gray_sync2_r);
        empty <= empty_next;

        wr_bin_r = gray2bin(wr_ptr_gray_sync2_r);
        depth_r = wr_bin_r - rd_ptr_bin_n;
        half_empty <= (depth_r <= DEPTH/2) && !empty_next;
    end
end

assign rd_data = rd_data_r;

endmodule

