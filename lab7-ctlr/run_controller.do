vlib work
vlog controller.v controller_test.v
vsim -voptargs="+acc" work.controller_test
add wave *
run -all