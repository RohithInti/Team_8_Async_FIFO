vlib work
vmap work work

vlog -sv async_fifo.sv
vlog -sv tb_pkg.sv
vlog -sv interface.sv
vlog -sv generator.sv
vlog -sv driver.sv
vlog -sv monitor_in.sv
vlog -sv monitor_out.sv
vlog -sv scoreboard.sv
vlog -sv environment.sv
vlog -sv test.sv
vlog -sv top.sv

vsim work.testbench_top -voptargs=+acc

add wave -position insertpoint  \
   /testbench_top/vif/wr_clk \
   /testbench_top/vif/wr_rst_n \
   /testbench_top/vif/rd_clk \
   /testbench_top/vif/rd_rst_n \
   /testbench_top/vif/wr_en \
   /testbench_top/vif/wr_data \
   /testbench_top/vif/rd_en \
   /testbench_top/vif/rd_data \
   /testbench_top/vif/full \
   /testbench_top/vif/half_full \
   /testbench_top/vif/empty \
   /testbench_top/vif/half_empty

run -all

