vlib work

vlog -sv -cover bcefsx +acc +define+QUESTA +fcover tb_pkg.sv coverage_pkg.sv async_fifo.sv top.sv                 

vsim -coverage work.testbench_top

add wave -r /*

