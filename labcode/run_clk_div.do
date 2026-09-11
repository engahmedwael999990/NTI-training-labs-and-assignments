vlib work
vlog clk_div_100hz.v tb_clk_div.v
vsim -voptargs="+acc" work.tb_clk_div
add wave *
run -all