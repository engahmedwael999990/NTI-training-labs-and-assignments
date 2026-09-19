vlib work
vlog fsm_debouncer.v tb_debouncer.v
vsim -voptargs="+acc" work.tb_debouncer
add wave *
run -all