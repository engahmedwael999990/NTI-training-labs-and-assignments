vlib work
vlog encoder_4x2.v tb_encoder_4x2.v
vsim -voptargs="+acc" work.tb_encoder_4x2
add wave *
run -all