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

# False paths for JTAG debug interface ports (handled asynchronously / multi-cycle by JTAG DM)
set debug_in_ports [get_ports {debug_halt_req debug_resume_req debug_gpr_addr* debug_gpr_wdata* debug_gpr_wen debug_pc_wen debug_pc_wdata*}]
if { [llength $debug_in_ports] > 0 } {
    set_false_path -from $debug_in_ports
}

set debug_out_ports [get_ports {debug_halted debug_gpr_rdata* debug_pc_rdata*}]
if { [llength $debug_out_ports] > 0 } {
    set_false_path -to $debug_out_ports
}
