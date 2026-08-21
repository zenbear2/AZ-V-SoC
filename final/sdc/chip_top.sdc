###############################################################################
# Created by write_sdc
###############################################################################
current_design chip_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk_PAD -period 40.0000 [get_pins {clk_pad/Y}]
set_clock_transition 0.1500 [get_clocks {clk_PAD}]
set_clock_uncertainty 0.2500 clk_PAD
set_propagated_clock [get_clocks {clk_PAD}]
create_clock -name jtag_tck -period 100.0000 [get_ports {input_PAD[0]}]
set_clock_groups -name group1 -asynchronous \
 -group [get_clocks {clk_PAD}]\
 -group [get_clocks {jtag_tck}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[0]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[0]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[10]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[10]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[11]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[11]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[12]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[12]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[13]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[13]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[14]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[14]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[15]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[15]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[16]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[16]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[17]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[17]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[18]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[18]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[19]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[19]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[1]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[1]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[20]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[20]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[21]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[21]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[22]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[22]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[23]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[23]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[24]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[24]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[25]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[25]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[26]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[26]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[27]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[27]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[28]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[28]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[29]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[29]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[2]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[2]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[30]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[30]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[31]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[31]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[32]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[32]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[33]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[33]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[34]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[34]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[35]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[35]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[36]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[36]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[37]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[37]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[38]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[38]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[39]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[39]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[3]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[3]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[4]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[4]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[5]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[5]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[6]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[6]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[7]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[7]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[8]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[8]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {bidir_PAD[9]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {bidir_PAD[9]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[0]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[0]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[10]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[10]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[11]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[11]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[1]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[1]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[2]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[2]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[3]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[3]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[4]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[4]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[5]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[5]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[6]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[6]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[7]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[7]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[8]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[8]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {input_PAD[9]}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {input_PAD[9]}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {rst_n_PAD}]
set_input_delay 8.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {rst_n_PAD}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[0]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[10]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[11]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[12]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[13]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[14]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[15]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[16]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[17]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[18]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[19]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[1]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[20]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[21]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[22]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[23]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[24]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[25]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[26]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[27]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[28]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[29]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[2]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[30]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[31]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[32]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[33]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[34]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[35]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[36]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[37]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[38]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[39]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[3]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[4]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[5]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[6]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[7]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[8]}]
set_output_delay 8.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {bidir_PAD[9]}]
set_false_path\
    -from [list [get_ports {input_PAD[1]}]\
           [get_ports {input_PAD[4]}]\
           [get_ports {rst_n_PAD}]]
set_false_path\
    -through [list [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_addr[0]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_addr[1]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_addr[2]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_addr[3]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_addr[4]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[0]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[10]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[11]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[12]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[13]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[14]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[15]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[16]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[17]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[18]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[19]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[1]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[20]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[21]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[22]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[23]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[24]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[25]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[26]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[27]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[28]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[29]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[2]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[30]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[31]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[3]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[4]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[5]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[6]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[7]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[8]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_rdata[9]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[0]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[10]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[11]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[12]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[13]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[14]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[15]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[16]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[17]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[18]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[19]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[1]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[20]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[21]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[22]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[23]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[24]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[25]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[26]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[27]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[28]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[29]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[2]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[30]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[31]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[3]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[4]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[5]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[6]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[7]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[8]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wdata[9]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_gpr_wen}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_halt_req}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_halted}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[0]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[10]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[11]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[12]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[13]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[14]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[15]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[16]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[17]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[18]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[19]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[1]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[20]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[21]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[22]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[23]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[24]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[25]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[26]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[27]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[28]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[29]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[2]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[30]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[31]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[3]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[4]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[5]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[6]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[7]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[8]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_rdata[9]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[0]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[10]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[11]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[12]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[13]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[14]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[15]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[16]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[17]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[18]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[19]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[1]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[20]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[21]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[22]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[23]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[24]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[25]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[26]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[27]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[28]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[29]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[2]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[30]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[31]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[3]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[4]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[5]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[6]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[7]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[8]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wdata[9]}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_pc_wen}]\
           [get_pins {i_chip_core.u_soc.u_cpu/debug_resume_req}]]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0729 [get_ports {clk_PAD}]
set_load -pin_load 0.0729 [get_ports {rst_n_PAD}]
set_load -pin_load 0.0729 [get_ports {analog_PAD[1]}]
set_load -pin_load 0.0729 [get_ports {analog_PAD[0]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[39]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[38]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[37]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[36]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[35]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[34]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[33]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[32]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[31]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[30]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[29]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[28]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[27]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[26]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[25]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[24]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[23]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[22]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[21]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[20]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[19]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[18]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[17]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[16]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[15]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[14]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[13]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[12]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[11]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[10]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[9]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[8]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[7]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[6]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[5]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[4]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[3]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[2]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[1]}]
set_load -pin_load 0.0729 [get_ports {bidir_PAD[0]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[11]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[10]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[9]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[8]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[7]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[6]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[5]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[4]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[3]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[2]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[1]}]
set_load -pin_load 0.0729 [get_ports {input_PAD[0]}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 3.0000 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
