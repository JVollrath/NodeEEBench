#100 MHz clock
set_property PACKAGE_PIN W5 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK]

#switches
set_property PACKAGE_PIN V17 [get_ports {SW[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]
set_property PACKAGE_PIN V16 [get_ports {SW[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]
set_property PACKAGE_PIN W16 [get_ports {SW[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]
set_property PACKAGE_PIN W17 [get_ports {SW[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]
set_property PACKAGE_PIN W15 [get_ports {SW[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[4]}]
set_property PACKAGE_PIN V15 [get_ports {SW[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[5]}]
set_property PACKAGE_PIN W14 [get_ports {SW[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[6]}]
set_property PACKAGE_PIN W13 [get_ports {SW[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[7]}]
set_property PACKAGE_PIN V2 [get_ports {SW[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[8]}]
set_property PACKAGE_PIN T3 [get_ports {SW[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[9]}]
set_property PACKAGE_PIN T2 [get_ports {SW[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[10]}]
set_property PACKAGE_PIN R3 [get_ports {SW[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[11]}]
set_property PACKAGE_PIN W2 [get_ports {SW[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[12]}]
set_property PACKAGE_PIN U1 [get_ports {SW[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[13]}]
set_property PACKAGE_PIN T1 [get_ports {SW[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[14]}]
set_property PACKAGE_PIN R2 [get_ports {SW[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[15]}]


#leds
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN V3 [get_ports {LED[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]


#7 segment display
#CA
set_property PACKAGE_PIN W7 [get_ports {SSEG_CA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[0]}]
#CB
set_property PACKAGE_PIN W6 [get_ports {SSEG_CA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[1]}]
#CC
set_property PACKAGE_PIN U8 [get_ports {SSEG_CA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[2]}]
#CD
set_property PACKAGE_PIN V8 [get_ports {SSEG_CA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[3]}]
#CE
set_property PACKAGE_PIN U5 [get_ports {SSEG_CA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[4]}]
#CF
set_property PACKAGE_PIN V5 [get_ports {SSEG_CA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[5]}]
#CG
set_property PACKAGE_PIN U7 [get_ports {SSEG_CA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[6]}]

#DP
set_property PACKAGE_PIN V7 [get_ports SSEG_CA[7]]
set_property IOSTANDARD LVCMOS33 [get_ports SSEG_CA[7]]

#AN0
set_property PACKAGE_PIN U2 [get_ports {SSEG_AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_AN[0]}]
#AN1
set_property PACKAGE_PIN U4 [get_ports {SSEG_AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_AN[1]}]
#AN2
set_property PACKAGE_PIN V4 [get_ports {SSEG_AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_AN[2]}]
#AN3
set_property PACKAGE_PIN W4 [get_ports {SSEG_AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_AN[3]}]


#buttons
#btnC
set_property PACKAGE_PIN U18 [get_ports {BTN[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[4]}]
#btnU
set_property PACKAGE_PIN T18 [get_ports {BTN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[0]}]
#btnL
set_property PACKAGE_PIN W19 [get_ports {BTN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[1]}]
#btnR
set_property PACKAGE_PIN T17 [get_ports {BTN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[2]}]
#btnD
set_property PACKAGE_PIN U17 [get_ports {BTN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[3]}]

#PMOD JC
#JC
set_property PACKAGE_PIN K17 [get_ports {JC[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[0]}]
set_property PACKAGE_PIN M18 [get_ports {JC[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[1]}]
set_property PACKAGE_PIN N17 [get_ports {JC[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]

#PMOD JB
#JB
set_property PACKAGE_PIN A14 [get_ports {JB[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[0]}]
set_property PACKAGE_PIN A16 [get_ports {JB[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[1]}]
set_property PACKAGE_PIN B15 [get_ports {JB[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[2]}]
set_property PACKAGE_PIN B16 [get_ports {JB[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[3]}]
set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
set_property PACKAGE_PIN C15 [get_ports {JB[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
set_property PACKAGE_PIN C16 [get_ports {JB[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]

#PMOD JA
#JA
set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
set_property PACKAGE_PIN G3 [get_ports {JA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]

#Pmod Header JXADC
#Sch name = XA1_P  vauxp6
set_property PACKAGE_PIN J3 [get_ports {JXA[0]}]	 			
set_property IOSTANDARD LVCMOS33 [get_ports {JXA[0]}]
#Sch name = XA2_P vauxp14
set_property PACKAGE_PIN L3 [get_ports {JXA[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[1]}]
#Sch name = XA3_P vauxp7
set_property PACKAGE_PIN M2 [get_ports {JXA[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[2]}]
#Sch name = XA4_P vauxp15
set_property PACKAGE_PIN N2 [get_ports {JXA[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[3]}]
#Sch name = XA1_N vauxn6
set_property PACKAGE_PIN K3 [get_ports {JXA[4]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[4]}]
#Sch name = XA2_N vauxn14
set_property PACKAGE_PIN M3 [get_ports {JXA[5]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[5]}]
#Sch name = XA3_N vauxn7
set_property PACKAGE_PIN M1 [get_ports {JXA[6]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[6]}]
#Sch name = XA4_N vauxn15
set_property PACKAGE_PIN N1 [get_ports {JXA[7]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {JXA[7]}]

#UART 
set_property PACKAGE_PIN B18 [get_ports {RX}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {RX}]
#Sch name = XA4_N vauxn15
set_property PACKAGE_PIN A18 [get_ports {TX}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {TX}]



#different settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUswIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]