vlib work
vlog edge_detector.v tb_edge_detector.v
vsim -voptargs="+acc" work.tb_edge_detector
add wave *
run -all