vlib work
vlog stream_parity_gen.v tb_stream_parity_gen.v
vsim -voptargs="+acc" work.tb_stream_parity_gen
add wave *
run -all