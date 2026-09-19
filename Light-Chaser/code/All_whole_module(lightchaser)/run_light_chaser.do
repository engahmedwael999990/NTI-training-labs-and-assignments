vlib work
vlog clk_divider.v shift_register.v light_chaser.v tb_light_chaser.v
vsim -voptargs="+acc" work.tb_light_chaser
add wave *
run -all