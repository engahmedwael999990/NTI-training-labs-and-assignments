vlib work
vlog clk_div_100hz.v edge_detector.v edge_counter.v hex2seg_single.v hex_6seg_decoder.v top_edge_system.v tb_top_system.v
vsim -voptargs="+acc" work.tb_top_system
add wave *
run -all