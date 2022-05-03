create_clock -name clock -period 20.000 [get_ports {clock}]
create_clock -name clock_delay -period 40.000 [get_pins {clock_delay|q}]
create_clock -name dct_clock -period 40.000 [get_pins {dct_clock|q}]
create_clock -name clock_delay_2 -period 80.000 [get_pins {clock_delay_2|q}]