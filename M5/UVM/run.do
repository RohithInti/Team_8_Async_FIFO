vlib work
vlog -sv +acc=rn +cover=bcesft async_fifo.sv fifo_seq_item.sv fifo_agent_pkg.sv fifo_scoreboard.sv fifo_coverage.sv
vlog -sv +acc=rn +cover=bcesft -mfcu async_fifo_if.sv fifo_sequences.sv fifo_env.sv fifo_test.sv fifo_tb_top.sv
vsim -voptargs=+acc -L mtiUvm work.fifo_tb_top +UVM_TESTNAME=fifo_test -coverage -sv_seed  random -do "run -all"
coverage exclude -srcfile fifo_seq_item.sv     -linerange 23 24 25 26 27 28 29 30 31 -code bcs
coverage exclude -srcfile fifo_coverage.sv     -linerange 58 -code b
coverage exclude -srcfile fifo_sequences.sv     -linerange 17 26 34 40 48 55 61 68 77 84 94 100 -code b
coverage exclude -srcfile fifo_sequences.sv     -linerange 17 -code cs
coverage exclude -srcfile fifo_env.sv     -linerange 21 -code s
coverage exclude -srcfile fifo_agent_pkg.sv     -linerange 39 40 88 89 -code b
coverage exclude -srcfile fifo_agent_pkg.sv     -linerange 21 29 40 146 76 89 -code s
coverage exclude -srcfile fifo_scoreboard.sv     -linerange 46 56 63 71 83 85 88 91 94 99 102 -code b
coverage exclude -srcfile fifo_scoreboard.sv     -linerange 54 98 -code c
coverage exclude -srcfile fifo_scoreboard.sv     -linerange 55 56 70 71 99 -code s
coverage exclude -srcfile fifo_coverage.sv     -linerange 58 -code b
