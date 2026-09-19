vlib work
vlog memory.v memory_test.v
vsim -voptargs="+acc" work.memory_test
add wave *
run -all