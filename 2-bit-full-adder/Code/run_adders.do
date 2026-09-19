vlib work
vlog half_adder.v full_adder_1bit.v full_adder_2bit.v fa_2bit_gate.v fa_2bit_behavioral.v tb_2bit_full_adders.v
vsim -voptargs="+acc" work.tb_2bit_full_adders
add wave *
run -all