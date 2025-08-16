# sclk set to work in 25MHz
create_clock -name SCLK -period 40.0 [get_nets design_1_i/spi_sl_0/sclk]

# async clocks
set_clock_groups -group [get_clocks -include_generated_clocks -of [get_nets design_1_i/spi_sl_0/sclk]] -group [get_clocks -include_generated_clocks -of [get_nets design_1_i/zynq_ultra_ps_e_0_pl_clk0]] -asynchronous

set_property PACKAGE_PIN AL11 [get_ports {leds_0[0]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[0]}]

set_property PACKAGE_PIN AL13 [get_ports {leds_0[1]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[1]}]

set_property PACKAGE_PIN AK13 [get_ports {leds_0[2]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[2]}]

set_property PACKAGE_PIN AE15 [get_ports {leds_0[3]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[3]}]

set_property PACKAGE_PIN AM8  [get_ports {leds_0[4]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[4]}]

set_property PACKAGE_PIN AM9  [get_ports {leds_0[5]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[5]}]

set_property PACKAGE_PIN AM10 [get_ports {leds_0[6]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[6]}]

set_property PACKAGE_PIN AM11 [get_ports {leds_0[7]}]
set_property IOSTANDARD  LVCMOS12 [get_ports {leds_0[7]}]
