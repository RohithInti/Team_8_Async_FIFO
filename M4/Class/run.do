vlib work

vlog -sv -cover bcefsx +acc +define+QUESTA +fcover *.sv

vsim -coverage work.testbench_top

