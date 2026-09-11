vlib work
vlog edge_counter.v tb_edge_counter.v
vsim -voptargs="+acc" work.tb_edge_counter
add wave *
run -all