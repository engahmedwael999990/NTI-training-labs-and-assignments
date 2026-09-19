vlib work
vlog counter.v counter_test.v
vsim -voptargs="+acc" work.counter_test
add wave *
run -all