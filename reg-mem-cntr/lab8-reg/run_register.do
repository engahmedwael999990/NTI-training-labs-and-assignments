vlib work
vlog register.v register_test.v
vsim -voptargs="+acc" work.register_test
add wave *
run -all