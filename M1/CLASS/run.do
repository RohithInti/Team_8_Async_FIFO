vlib work
vmap work work

vlog -sv async_fifo.sv
vlog -sv async_fifo_tb.sv

vsim work.async_fifo_tb -voptargs=+acc

add wave -position insertpoint \
    /async_fifo_tb/wr_clk \
    /async_fifo_tb/rd_clk \
    /async_fifo_tb/wr_rst_n\
    /async_fifo_tb/rd_rst_n\
    /async_fifo_tb/wr_data \
    /async_fifo_tb/rd_data \
    /async_fifo_tb/full \
    /async_fifo_tb/half_full \
    /async_fifo_tb/empty \
    /async_fifo_tb/half_empty \
    /async_fifo_tb/rd_en \
    /async_fifo_tb/wr_en
run -all

