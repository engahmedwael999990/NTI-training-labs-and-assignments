vlib work
vlog gray2bin.v bin2seg.v top_gray2seg.v tb_top_gray2seg.v
vsim -voptargs="+acc" work.tb_top_gray2seg
add wave *
run -all