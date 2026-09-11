vlib work
vlog alu.v alu_test.v
vsim -voptargs="+acc" work.alu_test
add wave *
run -all