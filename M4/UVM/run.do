vlib work
vlog -sv async_fifo.sv fifo_seq_item.sv fifo_agent_pkg.sv fifo_scoreboard.sv
vlog -sv -mfcu async_fifo_if.sv fifo_sequences.sv fifo_env.sv fifo_test.sv fifo_tb_top.sv
vsim -voptargs=+acc -L mtiUvm work.fifo_tb_top +UVM_TESTNAME=fifo_test -sv_seed  random -do "run -all"

