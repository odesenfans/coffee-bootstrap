transcript on
if ![file isdirectory Single_Core_Stratix5_iputf_libs] {
	file mkdir Single_Core_Stratix5_iputf_libs
}

if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}

vlib vhdl_libs/altera
vmap altera ./vhdl_libs/altera
vcom -93 -work altera {c:/altera/12.1/quartus/eda/sim_lib/altera_syn_attributes.vhd}
vcom -93 -work altera {c:/altera/12.1/quartus/eda/sim_lib/altera_standard_functions.vhd}
vcom -93 -work altera {c:/altera/12.1/quartus/eda/sim_lib/alt_dspbuilder_package.vhd}
vcom -93 -work altera {c:/altera/12.1/quartus/eda/sim_lib/altera_europa_support_lib.vhd}
vcom -93 -work altera {c:/altera/12.1/quartus/eda/sim_lib/altera_primitives_components.vhd}
vcom -93 -work altera {c:/altera/12.1/quartus/eda/sim_lib/altera_primitives.vhd}

vlib vhdl_libs/lpm
vmap lpm ./vhdl_libs/lpm
vcom -93 -work lpm {c:/altera/12.1/quartus/eda/sim_lib/220pack.vhd}
vcom -93 -work lpm {c:/altera/12.1/quartus/eda/sim_lib/220model.vhd}

vlib vhdl_libs/sgate
vmap sgate ./vhdl_libs/sgate
vcom -93 -work sgate {c:/altera/12.1/quartus/eda/sim_lib/sgate_pack.vhd}
vcom -93 -work sgate {c:/altera/12.1/quartus/eda/sim_lib/sgate.vhd}

vlib vhdl_libs/altera_mf
vmap altera_mf ./vhdl_libs/altera_mf
vcom -93 -work altera_mf {c:/altera/12.1/quartus/eda/sim_lib/altera_mf_components.vhd}
vcom -93 -work altera_mf {c:/altera/12.1/quartus/eda/sim_lib/altera_mf.vhd}

vlib vhdl_libs/altera_lnsim
vmap altera_lnsim ./vhdl_libs/altera_lnsim
vlog -sv -work altera_lnsim {c:/altera/12.1/quartus/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv}
vcom -93 -work altera_lnsim {c:/altera/12.1/quartus/eda/sim_lib/altera_lnsim_components.vhd}

vlib vhdl_libs/stratixv
vmap stratixv ./vhdl_libs/stratixv
vlog -vlog01compat -work stratixv {c:/altera/12.1/quartus/eda/sim_lib/mentor/stratixv_atoms_ncrypt.v}
vcom -93 -work stratixv {c:/altera/12.1/quartus/eda/sim_lib/stratixv_atoms.vhd}
vcom -93 -work stratixv {c:/altera/12.1/quartus/eda/sim_lib/stratixv_components.vhd}

vlib vhdl_libs/stratixv_hssi
vmap stratixv_hssi ./vhdl_libs/stratixv_hssi
vlog -vlog01compat -work stratixv_hssi {c:/altera/12.1/quartus/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v}
vcom -93 -work stratixv_hssi {c:/altera/12.1/quartus/eda/sim_lib/stratixv_hssi_components.vhd}
vcom -93 -work stratixv_hssi {c:/altera/12.1/quartus/eda/sim_lib/stratixv_hssi_atoms.vhd}

vlib vhdl_libs/stratixv_pcie_hip
vmap stratixv_pcie_hip ./vhdl_libs/stratixv_pcie_hip
vlog -vlog01compat -work stratixv_pcie_hip {c:/altera/12.1/quartus/eda/sim_lib/mentor/stratixv_pcie_hip_atoms_ncrypt.v}
vcom -93 -work stratixv_pcie_hip {c:/altera/12.1/quartus/eda/sim_lib/stratixv_pcie_hip_components.vhd}
vcom -93 -work stratixv_pcie_hip {c:/altera/12.1/quartus/eda/sim_lib/stratixv_pcie_hip_atoms.vhd}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlib coffee_core_conf
vcom -93 -work coffee_core_conf {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee_core_conf/core_conf_pkg.vhd}


# ----------------------------------------
# Copy ROM/RAM files to simulation directory

vcom "D:/user/zhangg/Single_Core_Stratix5/PLL_sim/PLL.vho"

vlib coffee

vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_constants_pkg.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/tri_state_32bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/tmr_divider.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/tmr_counter.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/tmr_control.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/rg_we.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/range_checker_32bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/range_checker_8bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/r32b_we_sset_fuck.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/r32b_we.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/r16b_we.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/r3b_we.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mux8to1_32bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mux6to1_8b.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mux4to1_32b.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mux3to1_32b.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mux2to1_32b.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mux2to1_3b.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mul_32bit_sign_logic.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mul_16bit_2c.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mu_csa_typ_f.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mu_csa_typ_a.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/m16b_opt_s2.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/m16b_opt_s1.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/inth_sync.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/inth_pri_chk.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/inth_dmux.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/incrementer_32bit_a.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/half_adder.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/dff_we.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/dbif_control.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/counter_4bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_tmr.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_reset_logic.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_mu.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_iaddr_chk.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_cr.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_cop_if.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_cntxt_buff.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_alu.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_addr_chk_usr.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_addr_chk_pcb.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_addr_chk_ovfl.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_addr_chk_align.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/cop_if_cntrl.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/comparator_4bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/cla_8bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_decode_v.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/alu_add_sub_unit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/adder_32bit_nc.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/adder_32bit_cla.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/adder_32bit_alu.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/adder_32bit.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/mul_16bit_u.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/m16b_uns_s2.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/m16b_uns_s1.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/inth_status.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/inth_selector.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_rf.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_iw_extend.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_inth.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_decode.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_dbif.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_cond_chk.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_cntxt_stack.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_ccu.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core_ccb.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_master_control.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_flow_control.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_decode_iv.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_decode_iii.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_decode_ii.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/ccu_decode_i.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/alu_shifter.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/alu_ctrl.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/alu_bytem.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/alu_bool_opr.vhd}
vcom -93 -work coffee {D:/user/zhangg/Single_Core_Stratix5/VHDL/coffee/core.vhd}


vcom -93 -work work {D:/user/zhangg/Single_Core_Stratix5/i_mem.vhd}
vcom -93 -work work {D:/user/zhangg/Single_Core_Stratix5/d_mem.vhd}
vcom -93 -work work {D:/user/zhangg/Single_Core_Stratix5/tristdrv.vhd}

vcom -93 -work work {D:/user/zhangg/Single_Core_Stratix5/Single_Core_Stratix5.vhd}

