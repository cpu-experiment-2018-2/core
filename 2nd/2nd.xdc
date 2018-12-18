# KCU105 constraints file
# project: loopback

#USB UART
#set_property PACKAGE_PIN K27 [get_ports {rts[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {rts[0]}]
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
#set_property PACKAGE_PIN AE10 [get_ports {btn[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {btn[0]}]
#set_property PACKAGE_PIN AE8 [get_ports {btn[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {btn[1]}]
#set_property PACKAGE_PIN AD10 [get_ports {btn[2]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {btn[2]}]
#set_property PACKAGE_PIN AF8 [get_ports {btn[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {btn[3]}]
#set_property PACKAGE_PIN AF9 [get_ports {btn[4]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {btn[4]}]

