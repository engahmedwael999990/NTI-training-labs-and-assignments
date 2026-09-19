vlib work
vlog shift_register.v tb_shift_register.v
vsim -voptargs="+acc" work.tb_shift_register
add wave *
run -all