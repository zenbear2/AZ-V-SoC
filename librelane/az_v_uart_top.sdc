current_design $::env(DESIGN_NAME)
set_units -time ns

set clock_port clk
set port_args [get_ports $clock_port]

puts "\[INFO] Using clock $clock_port…"
create_clock $port_args -name $clock_port -period $::env(CLOCK_PERIOD)

set input_delay_value [expr $::env(CLOCK_PERIOD) * 0.2]
set output_delay_value [expr $::env(CLOCK_PERIOD) * 0.2]

set clocks [get_clocks $clock_port]

set clk_input [get_port $clock_port]
set clk_indx [lsearch [all_inputs] $clk_input]
set all_inputs_wo_clk [lreplace [all_inputs] $clk_indx $clk_indx ""]

set_input_delay -min 0 -clock $clocks $all_inputs_wo_clk
set_input_delay -max $input_delay_value -clock $clocks $all_inputs_wo_clk

set_output_delay $output_delay_value -clock $clocks [all_outputs]

set_load 0.05 [all_outputs]
