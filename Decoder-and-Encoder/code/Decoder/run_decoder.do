vlib work
vlog generic_decoder.v tb_generic_decoder.v
vsim -voptargs="+acc" work.tb_generic_decoder
add wave *
run -all