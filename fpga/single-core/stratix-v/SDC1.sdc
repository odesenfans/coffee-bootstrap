set_time_format -unit ns -decimal_places 3
create_clock -name {CLKIN_50} -period 20.000 -waveform {0.000 10.000} [get_ports CLKIN_50]