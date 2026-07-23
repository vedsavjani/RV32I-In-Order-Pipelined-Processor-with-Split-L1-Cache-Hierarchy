create_clock -period 20.000 -name sys_clk [get_ports clk]
set_input_delay -clock sys_clk 2.0 [get_ports reset]
set_output_delay -clock sys_clk 2.0 [get_ports *]
