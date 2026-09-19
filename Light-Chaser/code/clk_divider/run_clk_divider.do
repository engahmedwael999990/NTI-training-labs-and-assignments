vlib work
vlog clk_divider.v tb_clk_divider.v
vsim -voptargs="+acc" work.tb_clk_divider
add wave *
run -all