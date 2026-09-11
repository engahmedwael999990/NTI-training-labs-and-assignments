/* 
vlib work
vlog .\module.v
vsim -c -do "run -all; quit" top_module


vlib work
vlog '.\module.v'
vsim -voptargs=+acc -do "add wave -r /*" work.top_module
*/


vsim -voptargs=+acc -do "add wave -r /*; force -freeze /top/clk 1 0, 0 {5 ns} -r 10" work.top
