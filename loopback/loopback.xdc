# KCU105 constraints file
# project: loopback

#USB UART
set_property PACKAGE_PIN K27 [get_ports {rts[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rts[0]}]
set_property PACKAGE_PIN G25 [get_ports rx]
set_property IOSTANDARD LVCMOS18 [get_ports rx]
set_property PACKAGE_PIN K26 [get_ports tx]
set_property IOSTANDARD LVCMOS18 [get_ports tx]

# leds
set_property PACKAGE_PIN AP8 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]
set_property PACKAGE_PIN H23 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]
set_property PACKAGE_PIN P20 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]
set_property PACKAGE_PIN P21 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]
set_property PACKAGE_PIN N22 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[4]}]
set_property PACKAGE_PIN M22 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[5]}]
set_property PACKAGE_PIN R23 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[6]}]
set_property PACKAGE_PIN P23 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[7]}]

#GPIO P.B. SW
set_property PACKAGE_PIN AE10 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btn[0]}]
set_property PACKAGE_PIN AE8 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btn[1]}]
set_property PACKAGE_PIN AD10 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btn[2]}]
set_property PACKAGE_PIN AF8 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btn[3]}]
set_property PACKAGE_PIN AF9 [get_ports {btn[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {btn[4]}]




create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/top_0_axi_RDATA[0]} {design_1_i/top_0_axi_RDATA[1]} {design_1_i/top_0_axi_RDATA[2]} {design_1_i/top_0_axi_RDATA[3]} {design_1_i/top_0_axi_RDATA[4]} {design_1_i/top_0_axi_RDATA[5]} {design_1_i/top_0_axi_RDATA[6]} {design_1_i/top_0_axi_RDATA[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/top_0_axi_ARADDR[0]} {design_1_i/top_0_axi_ARADDR[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/top_0/inst/l/state[0]} {design_1_i/top_0/inst/l/state[1]} {design_1_i/top_0/inst/l/state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/axi_uartlite_0/U0/rx_Data[7]} {design_1_i/axi_uartlite_0/U0/rx_Data[6]} {design_1_i/axi_uartlite_0/U0/rx_Data[5]} {design_1_i/axi_uartlite_0/U0/rx_Data[4]} {design_1_i/axi_uartlite_0/U0/rx_Data[3]} {design_1_i/axi_uartlite_0/U0/rx_Data[2]} {design_1_i/axi_uartlite_0/U0/rx_Data[1]} {design_1_i/axi_uartlite_0/U0/rx_Data[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {led_OBUF[0]} {led_OBUF[1]} {led_OBUF[2]} {led_OBUF[3]} {led_OBUF[4]} {led_OBUF[5]} {led_OBUF[6]} {led_OBUF[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/top_0/inst/l/araddr_set_i_1_n_0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list design_1_i/top_0/inst/l/chrxaddr_set_reg_n_0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list rx_IBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list design_1_i/top_0_axi_ARVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list design_1_i/top_0_axi_RREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list design_1_i/top_0_axi_RVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list design_1_i/axi_uartlite_0/U0/UARTLITE_RX_I/rx_Data_Empty]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out1]
