onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /single_core_stratix5/b2v_inst/i_addr_signal
add wave -noupdate /single_core_stratix5/b2v_inst19/rst
add wave -noupdate /single_core_stratix5/b2v_inst19/refclk
add wave -noupdate /single_core_stratix5/b2v_inst19/outclk_0
add wave -noupdate /single_core_stratix5/b2v_inst19/outclk_1
add wave -noupdate /single_core_stratix5/b2v_inst19/locked
add wave -noupdate -radix hexadecimal /single_core_stratix5/b2v_inst/i_addr
add wave -noupdate -radix hexadecimal /single_core_stratix5/b2v_inst/i_word
add wave -noupdate /single_core_stratix5/b2v_inst/clk
add wave -noupdate -radix hexadecimal /single_core_stratix5/b2v_inst/i_addr_asynch
add wave -noupdate /single_core_stratix5/b2v_inst/exception_cause
add wave -noupdate /single_core_stratix5/b2v_inst/ccb_we_exc
add wave -noupdate -radix hexadecimal /single_core_stratix5/b2v_inst/rst_n
add wave -noupdate /single_core_stratix5/b2v_inst/rst_n_s
add wave -noupdate -radix hexadecimal /single_core_stratix5/b2v_inst/i_addr_signal
add wave -noupdate /single_core_stratix5/b2v_inst/sel_pc
add wave -noupdate /single_core_stratix5/b2v_inst/write_pc
add wave -noupdate /single_core_stratix5/b2v_inst/d_addr
add wave -noupdate /single_core_stratix5/b2v_inst/data
add wave -noupdate /single_core_stratix5/b2v_inst/wr
add wave -noupdate /single_core_stratix5/b2v_inst/rd
add wave -noupdate /single_core_stratix5/b2v_inst16/wren
add wave -noupdate /single_core_stratix5/b2v_inst16/address
add wave -noupdate -radix hexadecimal /single_core_stratix5/b2v_inst16/q
add wave -noupdate /single_core_stratix5/b2v_inst16/clock
add wave -noupdate -divider {ccu flow}
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/freeze_pc
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/cond_stall
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/cop_stall
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/atomic_stall
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/alu_stall_i
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/alu_stall_ii
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/dmem_stall
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/imem_stall
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/stall
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/status_override
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/i_cache_miss
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/imem_wait
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I3/flush_fetch
add wave -noupdate -divider ccu_decode_i
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I8/load
add wave -noupdate /single_core_stratix5/b2v_inst/I17/I8/store
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {850 ns} 0}
configure wave -namecolwidth 136
configure wave -valuecolwidth 68
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {782 ns} {918 ns}
