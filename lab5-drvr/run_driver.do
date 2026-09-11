quit -sim
vlib work
vlog driver.v driver_test.v
vsim -voptargs="+acc" work.driver_test
add wave *
run -all