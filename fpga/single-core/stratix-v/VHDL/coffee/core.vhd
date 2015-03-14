------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:26 01/03/06
-- File : core.vhd
-- Design : core
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee_core_conf;
USE coffee_core_conf.core_conf_pkg.all;

ENTITY core IS
   PORT( 
      boot_sel      : IN     std_logic;
      bus_req       : IN     std_logic;
      clk           : IN     std_logic;
      cop_exc       : IN     std_logic_vector (3 DOWNTO 0);
      d_cache_miss  : IN     std_logic;
      ext_handler   : IN     std_logic;
      ext_interrupt : IN     std_logic_vector (7 DOWNTO 0);
      i_cache_miss  : IN     std_logic;
      i_word        : IN     std_logic_vector (31 DOWNTO 0);
      offset        : IN     std_logic_vector (7 DOWNTO 0);
      rst_n         : IN     std_logic;
      stall         : IN     std_logic;
      bus_ack       : OUT    std_logic;
      cop_id        : OUT    std_logic_vector (1 DOWNTO 0);
      cop_rd        : OUT    std_logic;
      cop_rgi       : OUT    std_logic_vector (4 DOWNTO 0);
      cop_wr        : OUT    std_logic;
      i_addr        : OUT    std_logic_vector (imem_abits_c-1 DOWNTO 0);
      int_ack       : OUT    std_logic;
      int_done      : OUT    std_logic;
      pcb_rd        : OUT    std_logic;
      pcb_wr        : OUT    std_logic;
      rd            : OUT    std_logic;
      reset_n_out   : OUT    std_logic;
      wr            : OUT    std_logic;
      cop_bus_z     : INOUT  std_logic_vector (31 DOWNTO 0);
      d_addr        : INOUT  std_logic_vector (dbus_abits_c-1 DOWNTO 0);
      data          : INOUT  std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:31 01/03/06
-- File : core.vhd
-- Design : core
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ARCHITECTURE struct OF core IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL abs_jmp_addr             : std_logic_vector(31 DOWNTO 0);
   SIGNAL access_complete          : std_logic;
   SIGNAL ack                      : std_logic;
   SIGNAL addr_mask                : std_logic_vector(31 DOWNTO 0);
   SIGNAL addr_ovfl                : std_logic;
   SIGNAL addr_viol                : std_logic;
   SIGNAL alu_exception_of         : std_logic;
   SIGNAL alu_exception_uf         : std_logic;
   SIGNAL alu_of_check_en          : std_logic;
   SIGNAL alu_op_code              : std_logic_vector(9 DOWNTO 0);
   SIGNAL alu_op_i_fwd             : std_logic_vector(1 DOWNTO 0);
   SIGNAL alu_op_ii_fwd            : std_logic_vector(1 DOWNTO 0);
   SIGNAL base_addr                : array_12x32_stdl;
   SIGNAL boot_address             : std_logic_vector(31 DOWNTO 0);
   SIGNAL buff_addr                : std_logic_vector(31 DOWNTO 0);
   SIGNAL carry_out                : std_logic;
   SIGNAL ccb_access               : std_logic;
   SIGNAL ccb_base                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL ccb_data                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL ccb_we_exc               : std_logic;
   SIGNAL check_data_addr_ovfl     : std_logic;
   SIGNAL check_data_addr_usr      : std_logic;
   SIGNAL check_enable             : std_logic;
   SIGNAL cop_data                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL cop_if_cop_indx          : std_logic_vector(1 DOWNTO 0);
   SIGNAL cop_if_rd_cop            : std_logic;
   SIGNAL cop_if_reg_indx          : std_logic_vector(4 DOWNTO 0);
   SIGNAL cop_if_wr_cop            : std_logic;
   SIGNAL cop_int_pri              : std_logic_vector(15 DOWNTO 0);
   SIGNAL cr0_to_push              : std_logic_vector(2 DOWNTO 0);
   SIGNAL cr_we                    : std_logic;
   SIGNAL cr_we_all                : std_logic;
   SIGNAL cr_wr_reg                : std_logic_vector(2 DOWNTO 0);
   SIGNAL creg_indx_i_q            : std_logic_vector(19 DOWNTO 0);
   SIGNAL current_psr              : std_logic_vector(7 DOWNTO 0);
   SIGNAL d_cache_data_fwd         : std_logic_vector(1 DOWNTO 0);
   SIGNAL d_cache_if_use_prev_data : std_logic;
   SIGNAL d_path1                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL data_addr_exception_of   : std_logic;
   SIGNAL data_addr_exception_usr  : std_logic;
   SIGNAL data_i                   : std_logic_vector(31 DOWNTO 0);
   SIGNAL data_ii                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL data_iii                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL data_to_mem              : std_logic_vector(31 DOWNTO 0);
   SIGNAL dc_mode                  : std_logic;
   SIGNAL decode_exception         : std_logic_vector(2 DOWNTO 0);
   SIGNAL done                     : std_logic;
   SIGNAL en_stage                 : std_logic_vector(5 DOWNTO 0);
   SIGNAL exc_psr                  : std_logic_vector(7 DOWNTO 0);
   SIGNAL exception_addr_q         : std_logic_vector(31 DOWNTO 0);
   SIGNAL exception_cause          : std_logic_vector(7 DOWNTO 0);
   SIGNAL execute                  : std_logic;
   SIGNAL ext_imm                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL ext_int_pri              : std_logic_vector(31 DOWNTO 0);
   SIGNAL extended_iw              : std_logic_vector(31 DOWNTO 0);
   SIGNAL flags                    : std_logic_vector(31 DOWNTO 0);
   SIGNAL float                    : std_logic;
   SIGNAL flush                    : std_logic_vector(3 DOWNTO 0);
   SIGNAL gated_reset_n            : std_logic;
   SIGNAL i_addr_asynch            : std_logic_vector(31 DOWNTO 0) := "11111111111111111111111111111111";
                       -- changed by guoqing:
   SIGNAL i_addr_signal            : std_logic_vector(31 DOWNTO 0);
   SIGNAL il                       : std_logic;
   SIGNAL illegal_jump_q           : std_logic;
   SIGNAL inst_addr_violation_q    : std_logic;
   SIGNAL int_addr                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL int_mask                 : std_logic_vector(11 DOWNTO 0);
   SIGNAL int_mode_il              : std_logic_vector(11 DOWNTO 0);
   SIGNAL int_mode_um              : std_logic_vector(11 DOWNTO 0);
   SIGNAL int_pend                 : std_logic_vector(11 DOWNTO 0);
   SIGNAL int_psr                  : std_logic_vector(7 DOWNTO 0);
   SIGNAL int_serv                 : std_logic_vector(11 DOWNTO 0);
   SIGNAL interrupt_req            : std_logic;
   SIGNAL jump_addr_overflow_q     : std_logic;
   SIGNAL jump_offset              : std_logic_vector(31 DOWNTO 0);
   SIGNAL lui_imm_msb              : std_logic;
   SIGNAL mdata_fwd_op_i           : std_logic;
   SIGNAL mdata_fwd_op_ii          : std_logic;
   SIGNAL mdata_fwd_st             : std_logic;
   SIGNAL mem_data                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL miss_aligned_addr        : std_logic;
   SIGNAL miss_aligned_iaddr_q     : std_logic;
   SIGNAL miss_aligned_jump_q      : std_logic;
   SIGNAL new_psr                  : std_logic_vector(7 DOWNTO 0);
   SIGNAL new_tos_addr             : std_logic_vector(31 DOWNTO 0);
   SIGNAL new_tos_cr0              : std_logic_vector(2 DOWNTO 0);
   SIGNAL new_tos_psr              : std_logic_vector(7 DOWNTO 0);
   SIGNAL next_addr                : std_logic_vector(31 DOWNTO 0);
   SIGNAL next_psr                 : std_logic_vector(7 DOWNTO 0);
   SIGNAL o                        : std_logic_vector(31 DOWNTO 0);
   SIGNAL o2                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL o3                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL o4                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL o5                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL o6                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL o7                       : std_logic_vector(2 DOWNTO 0);
   SIGNAL one                      : std_logic;
   SIGNAL operand_i                : std_logic_vector(31 DOWNTO 0);
   SIGNAL operand_ii               : std_logic_vector(31 DOWNTO 0);
   SIGNAL pc_rel_jmp_addr          : std_logic_vector(31 DOWNTO 0);
   SIGNAL pcb_access               : std_logic;
   SIGNAL pcb_end                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL pcb_start                : std_logic_vector(31 DOWNTO 0);
   SIGNAL pdas_end                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL pdas_start               : std_logic_vector(31 DOWNTO 0);
   SIGNAL pias_end                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL pias_start               : std_logic_vector(31 DOWNTO 0);
   SIGNAL pop                      : std_logic;
   SIGNAL popped_addr              : std_logic_vector(31 DOWNTO 0);
   SIGNAL protect_mode_q           : std_logic_vector(1 DOWNTO 0);
   SIGNAL psr                      : std_logic_vector(7 DOWNTO 0);
   SIGNAL push                     : std_logic;
   SIGNAL q                        : std_logic;
   SIGNAL q1                       : std_logic;
   SIGNAL q10                      : std_logic_vector(31 DOWNTO 0);
   SIGNAL q13                      : std_logic_vector(31 DOWNTO 0);
   SIGNAL q14                      : std_logic_vector(31 DOWNTO 0);
   SIGNAL q2                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL q3                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL q4                       : std_logic;
   SIGNAL q5                       : std_logic;
   SIGNAL q6                       : std_logic;
   SIGNAL q7                       : std_logic;
   SIGNAL q9                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL read_access              : std_logic;
   SIGNAL reg_indx                 : std_logic_vector(7 DOWNTO 0);
   SIGNAL reg_jmp_fwd              : std_logic_vector(1 DOWNTO 0);
   SIGNAL reg_op_i                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL reg_op_ii                : std_logic_vector(31 DOWNTO 0);
   SIGNAL result_2                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL result_3                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL result_4                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL result_q                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL result_qq                : std_logic_vector(31 DOWNTO 0);
   SIGNAL result_qqq               : std_logic_vector(31 DOWNTO 0);
   SIGNAL rf_we_data               : std_logic;
   SIGNAL rf_we_spsr               : std_logic;
   SIGNAL rf_wr_reg                : std_logic_vector(4 DOWNTO 0);
   SIGNAL rf_wr_rs                 : std_logic;
   SIGNAL rs_to_read               : std_logic;
   SIGNAL rst_n_s                  : std_logic;
   SIGNAL saved_psr                : std_logic_vector(7 DOWNTO 0);
   SIGNAL sel_buff_entry           : std_logic_vector(1 DOWNTO 0);
   SIGNAL sel_data3p               : std_logic_vector(1 DOWNTO 0);
   SIGNAL sel_data4p               : std_logic_vector(1 DOWNTO 0);
   SIGNAL sel_data5p               : std_logic;
   SIGNAL sel_data_from_cop        : std_logic;
   SIGNAL sel_data_to_cop          : std_logic;
   SIGNAL sel_op_i                 : std_logic;
   SIGNAL sel_op_ii                : std_logic;
   SIGNAL sel_pc                   : std_logic_vector(2 DOWNTO 0);
   SIGNAL sel_psr                  : std_logic_vector(2 DOWNTO 0);
   SIGNAL start_dmem_access        : std_logic;
   SIGNAL sys_addr_q               : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr0_cnt_in              : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr0_cnt_out             : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr0_int                 : std_logic_vector(7 DOWNTO 0);
   SIGNAL tmr0_max_cnt             : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr0_wdog_rst_n          : std_logic;
   SIGNAL tmr1_cnt_in              : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr1_cnt_out             : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr1_int                 : std_logic_vector(7 DOWNTO 0);
   SIGNAL tmr1_max_cnt             : std_logic_vector(31 DOWNTO 0);
   SIGNAL tmr1_wdog_rst_n          : std_logic;
   SIGNAL tmr_conf                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL tos_addr                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL tos_cr0                  : std_logic_vector(2 DOWNTO 0);
   SIGNAL tos_psr                  : std_logic_vector(7 DOWNTO 0);
   SIGNAL wait_states              : std_logic_vector(11 DOWNTO 0);
   SIGNAL wr_en_psr                : std_logic;
   SIGNAL write_access             : std_logic;
   SIGNAL write_pc                 : std_logic;
   SIGNAL zeros                    : std_logic_vector(31 DOWNTO 0);
   SIGNAL znc_o                    : std_logic_vector(2 DOWNTO 0);
   SIGNAL znc_q                    : std_logic_vector(2 DOWNTO 0);


   -- Component Declarations
   COMPONENT adder_32bit_cla
   PORT (
      cin  : IN     std_logic ;
      opa  : IN     std_logic_vector (31 DOWNTO 0);
      opb  : IN     std_logic_vector (31 DOWNTO 0);
      cout : OUT    std_logic ;
      sum  : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_addr_chk_align
   PORT (
      addr              : IN     std_logic_vector (31 DOWNTO 0);
      il                : IN     std_logic ;                   -- processor mode (16/32 bits)
      miss_aligned_addr : OUT    std_logic ;
      check_enable      : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT core_addr_chk_ovfl
   PORT (
      carry      : IN     std_logic ;
      base_msb   : IN     std_logic ;
      offset_msb : IN     std_logic ;
      addr_msb   : IN     std_logic ;
      addr_ovfl  : OUT    std_logic ;
      chk        : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT core_addr_chk_pcb
   PORT (
      pcb_start     : IN     std_logic_vector (31 DOWNTO 0); -- -- Comes from PCB base register
      ccb_access    : OUT    std_logic ;                     -- -- Indicates an access TO PCB
      accessed_addr : IN     std_logic_vector (31 DOWNTO 0); -- -- Address TO be compared
      reg_indx      : OUT    std_logic_vector (7 DOWNTO 0);
      pcb_end       : IN     std_logic_vector (31 DOWNTO 0);
      pcb_access    : OUT    std_logic ;
      ccb_base      : IN     std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_addr_chk_usr
   PORT (
      enable_check  : IN     std_logic ;                     -- enables checking
      start_addr    : IN     std_logic_vector (31 DOWNTO 0); -- -- Begining of the protected address space
      end_addr      : IN     std_logic_vector (31 DOWNTO 0); -- -- End of the protected...
      accessed_addr : IN     std_logic_vector (31 DOWNTO 0); -- -- Address to be checked
      addr_viol     : OUT    std_logic ;
      protect_mode  : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT core_alu
   PORT (
      chk_of     : IN     std_logic ;
      clk        : IN     std_logic ;
      enable_i   : IN     std_logic ;
      enable_ii  : IN     std_logic ;
      enable_iii : IN     std_logic ;
      flush      : IN     std_logic ;
      operand_i  : IN     std_logic_vector (31 DOWNTO 0);
      operand_ii : IN     std_logic_vector (31 DOWNTO 0);
      operation  : IN     std_logic_vector (9 DOWNTO 0);
      rst_x      : IN     std_logic ;
      of_q       : OUT    std_logic ;
      result_1   : OUT    std_logic_vector (31 DOWNTO 0);
      result_2   : OUT    std_logic_vector (31 DOWNTO 0);
      result_3   : OUT    std_logic_vector (31 DOWNTO 0);
      result_4   : OUT    std_logic_vector (31 DOWNTO 0);
      uf_q       : OUT    std_logic ;
      znc_q      : OUT    std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_ccb
   PORT (
      reg_indx         : IN     std_logic_vector (7 DOWNTO 0);
      user_data_in     : IN     std_logic_vector (31 DOWNTO 0);
      exception_cs_in  : IN     std_logic_vector (7 DOWNTO 0);
      exception_pc_in  : IN     std_logic_vector (31 DOWNTO 0);
      clk              : IN     std_logic ;
      rst_x            : IN     std_logic ;
      int_base         : OUT    array_12x32_stdl ;
      int_mask_q       : OUT    std_logic_vector (11 DOWNTO 0);
      dmem_bound_lo_q  : OUT    std_logic_vector (31 DOWNTO 0);
      dmem_bound_hi_q  : OUT    std_logic_vector (31 DOWNTO 0);
      imem_bound_lo_q  : OUT    std_logic_vector (31 DOWNTO 0);
      imem_bound_hi_q  : OUT    std_logic_vector (31 DOWNTO 0);
      write_access     : IN     std_logic ;
      pcb_start_q      : OUT    std_logic_vector (31 DOWNTO 0);
      exception        : IN     std_logic ;
      data_out         : OUT    std_logic_vector (31 DOWNTO 0);
      sys_addr_q       : OUT    std_logic_vector (31 DOWNTO 0);
      exception_addr_q : OUT    std_logic_vector (31 DOWNTO 0);
      exception_psr    : IN     std_logic_vector (7 DOWNTO 0);
      int_mode_il_q    : OUT    std_logic_vector (11 DOWNTO 0);
      int_mode_um_q    : OUT    std_logic_vector (11 DOWNTO 0);
      int_pend         : IN     std_logic_vector (11 DOWNTO 0);
      int_serv         : IN     std_logic_vector (11 DOWNTO 0);
      wait_states      : OUT    std_logic_vector (11 DOWNTO 0);
      pcb_end_q        : OUT    std_logic_vector (31 DOWNTO 0);
      creg_indx_i_q    : OUT    std_logic_vector (19 DOWNTO 0);
      enable           : IN     std_logic ;
      ext_int_pri      : OUT    std_logic_vector (31 DOWNTO 0);
      cop_int_pri      : OUT    std_logic_vector (15 DOWNTO 0);
      flush            : IN     std_logic ;
      protect_mode_q   : OUT    std_logic_vector (1 DOWNTO 0);
      tmr0_cnt_in      : IN     std_logic_vector (31 DOWNTO 0);
      tmr1_cnt_in      : IN     std_logic_vector (31 DOWNTO 0);
      tmr0_cnt_out     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr1_cnt_out     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr0_max_cnt     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr1_max_cnt     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr_conf         : OUT    std_logic_vector (31 DOWNTO 0);
      ccb_access       : IN     std_logic ;
      tos_addr         : IN     std_logic_vector (31 DOWNTO 0);
      tos_psr          : IN     std_logic_vector (7 DOWNTO 0);
      tos_cr0          : IN     std_logic_vector (2 DOWNTO 0);
      new_tos_addr     : OUT    std_logic_vector (31 DOWNTO 0);
      new_tos_psr      : OUT    std_logic_vector (7 DOWNTO 0);
      new_tos_cr0      : OUT    std_logic_vector (2 DOWNTO 0);
      addr_mask        : OUT    std_logic_vector (31 DOWNTO 0);
      ccb_base         : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_ccu
   PORT (
      alu_exception_of         : IN     std_logic ;
      alu_exception_uf         : IN     std_logic ;
      bus_req                  : IN     std_logic ;
      ccb_access               : IN     std_logic ;
      clk                      : IN     std_logic ;
      creg_indx_i_q            : IN     std_logic_vector (19 DOWNTO 0);
      current_psr              : IN     std_logic_vector (7 DOWNTO 0);
      d_cache_miss             : IN     std_logic ;
      data_addr_exception_of   : IN     std_logic ;
      data_addr_exception_usr  : IN     std_logic ;
      decode_exception         : IN     std_logic_vector (2 DOWNTO 0);
      execute                  : IN     std_logic ;
      extended_iw              : IN     std_logic_vector (31 DOWNTO 0);
      i_cache_miss             : IN     std_logic ;
      illegal_jump             : IN     std_logic ;
      inst_addr_violation      : IN     std_logic ;
      interrupt_req            : IN     std_logic ;
      jump_addr_overflow       : IN     std_ulogic ;
      miss_aligned_iaddr       : IN     std_logic ;
      miss_aligned_jump        : IN     std_logic ;
      rs_to_rd                 : IN     std_logic ;
      rst_n                    : IN     std_logic ;
      stall                    : IN     std_logic ;
      wait_cycles              : IN     std_logic_vector (11 DOWNTO 0);
      access_complete          : OUT    std_logic ;
      ack                      : OUT    std_logic ;
      alu_of_check_en          : OUT    std_logic ;
      alu_op_code              : OUT    std_logic_vector (9 DOWNTO 0);
      alu_op_i_fwd             : OUT    std_logic_vector (1 DOWNTO 0);
      alu_op_ii_fwd            : OUT    std_logic_vector (1 DOWNTO 0);
      bus_ack                  : OUT    std_logic ;
      ccb_we_exc               : OUT    std_logic ;
      check_data_addr_ovfl     : OUT    std_logic ;
      check_data_addr_usr      : OUT    std_logic ;
      cop_if_cop_indx          : OUT    std_logic_vector (1 DOWNTO 0);
      cop_if_rd_cop            : OUT    std_logic ;
      cop_if_reg_indx          : OUT    std_logic_vector (4 DOWNTO 0);
      cop_if_wr_cop            : OUT    std_logic ;
      cr_we                    : OUT    std_logic ;
      cr_we_all                : OUT    std_logic ;
      cr_wr_reg                : OUT    std_logic_vector (2 DOWNTO 0);
      d_cache_data_fwd         : OUT    std_logic_vector (1 DOWNTO 0);
      d_cache_if_use_prev_data : OUT    std_logic ;
      done                     : OUT    std_logic ;
      en_stage                 : OUT    std_logic_vector (5 DOWNTO 0);
      exception_cause          : OUT    std_logic_vector (7 DOWNTO 0);
      float                    : OUT    std_logic ;
      flush                    : OUT    std_logic_vector (3 DOWNTO 0);
      mdata_fwd_op_i           : OUT    std_logic ;
      mdata_fwd_op_ii          : OUT    std_logic ;
      mdata_fwd_st             : OUT    std_logic ;
      pop                      : OUT    std_logic ;
      push                     : OUT    std_logic ;
      read_access              : OUT    std_logic ;
      reg_jmp_fwd              : OUT    std_logic_vector (1 DOWNTO 0);
      rf_we_data               : OUT    std_logic ;
      rf_we_spsr               : OUT    std_logic ;
      rf_wr_reg                : OUT    std_logic_vector (4 DOWNTO 0);
      rf_wr_rs                 : OUT    std_logic ;
      sel_buff_entry           : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data3p               : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data4p               : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data5p               : OUT    std_logic ;
      sel_data_from_cop        : OUT    std_logic ;
      sel_data_to_cop          : OUT    std_logic ;
      sel_pc                   : OUT    std_logic_vector (2 DOWNTO 0);
      sel_psr                  : OUT    std_logic_vector (2 DOWNTO 0);
      start_dmem_access        : OUT    std_logic ;
      wr_en_psr                : OUT    std_logic ;
      write_access             : OUT    std_logic ;
      write_pc                 : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT core_cntxt_buff
   PORT (
      clk       : IN     std_logic ;
      enable    : IN     std_logic_vector (3 DOWNTO 0);
      rst_x     : IN     std_logic ;
      pc_in     : IN     std_logic_vector (31 DOWNTO 0);
      sel_entry : IN     std_logic_vector (1 DOWNTO 0);
      psr_in    : IN     std_logic_vector (7 DOWNTO 0);
      psr       : OUT    std_logic_vector (7 DOWNTO 0);
      addr      : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_cntxt_stack
   PORT (
      rst_x        : IN     std_logic ;
      push         : IN     std_logic ;
      pop          : IN     std_logic ;
      clk          : IN     std_logic ;
      psr_in       : IN     std_logic_vector (7 DOWNTO 0);
      pc_in        : IN     std_logic_vector (31 DOWNTO 0);
      psr_o        : OUT    std_logic_vector (7 DOWNTO 0);
      pc_out       : OUT    std_logic_vector (31 DOWNTO 0);
      cr0_in       : IN     std_logic_vector (2 DOWNTO 0);
      cr0_out      : OUT    std_logic_vector (2 DOWNTO 0);
      flush        : IN     std_logic ;
      new_tos_addr : IN     std_logic_vector (31 DOWNTO 0);
      new_tos_psr  : IN     std_logic_vector (7 DOWNTO 0);
      new_tos_cr0  : IN     std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_cond_chk
   PORT (
      cond    : IN     std_logic_vector (2 DOWNTO 0);
      cex     : IN     std_logic ;                  -- enables condition check
      znc     : IN     std_logic_vector (2 DOWNTO 0);
      execute : OUT    std_logic ;
      opcode  : IN     std_logic_vector (5 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_cop_if
   PORT (
      clk        : IN     std_logic ;
      cop_indx   : IN     std_logic_vector (1 DOWNTO 0);
      data_in    : IN     std_logic_vector (31 DOWNTO 0);
      enable     : IN     std_logic ;
      flush      : IN     std_logic ;
      rd_cop     : IN     std_logic ;
      reg_indx   : IN     std_logic_vector (4 DOWNTO 0);
      rst_x      : IN     std_logic ;
      wr_cop     : IN     std_logic ;
      cop_id     : OUT    std_logic_vector (1 DOWNTO 0);
      cop_rd     : OUT    std_logic ;
      cop_rgi    : OUT    std_logic_vector (4 DOWNTO 0);
      cop_wr     : OUT    std_logic ;
      data_out   : OUT    std_logic_vector (31 DOWNTO 0);
      cop_bus_qz : INOUT  std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_cr
   PORT (
      rst_x   : IN     std_logic ;
      creg_wr : IN     std_logic_vector (2 DOWNTO 0);
      wrcr    : IN     std_logic ;
      clk     : IN     std_logic ;
      creg_rd : IN     std_logic_vector (2 DOWNTO 0);
      wr_all  : IN     std_logic ;
      znc_in  : IN     std_logic_vector (2 DOWNTO 0);
      all_in  : IN     std_logic_vector (23 DOWNTO 0);
      znc_o   : OUT    std_logic_vector (2 DOWNTO 0);
      flush   : IN     std_logic ;
      cr0_out : OUT    std_logic_vector (2 DOWNTO 0);
      all_out : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_dbif
   PORT (
      access_complete : IN     std_logic ;
      addr_in         : IN     std_logic_vector (31 DOWNTO 0);
      addr_mask       : IN     std_logic_vector (31 DOWNTO 0);
      ccb_access      : IN     std_logic ;
      clk             : IN     std_logic ;
      data_in         : IN     std_logic_vector (31 DOWNTO 0);
      float_bus       : IN     std_logic ;
      gated_reset_n   : IN     std_logic ;
      pcb_access      : IN     std_logic ;
      read_access     : IN     std_logic ;
      rst_n           : IN     std_logic ;
      start_access    : IN     std_logic ;
      use_prev_data   : IN     std_logic ;
      write_access    : IN     std_logic ;
      boot_address    : OUT    std_logic_vector (31 DOWNTO 0);
      mem_data_q      : OUT    std_logic_vector (31 DOWNTO 0);
      read_mem_q      : OUT    std_logic ;
      read_pcb_q      : OUT    std_logic ;
      write_mem_q     : OUT    std_logic ;
      write_pcb_q     : OUT    std_logic ;
      addr_qz         : INOUT  std_logic_vector (dbus_abits_c-1 DOWNTO 0);
      data_qz         : INOUT  std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT core_decode
   PORT (
      rst_x        : IN     std_logic ;
      i_word       : IN     std_logic_vector (31 DOWNTO 0);
      current_psr  : IN     std_logic_vector (7 DOWNTO 0);
      clk          : IN     std_logic ;
      new_psr      : OUT    std_logic_vector (7 DOWNTO 0);
      extended_imm : OUT    std_logic_vector (31 DOWNTO 0);
      exception_q  : OUT    std_logic_vector (2 DOWNTO 0);
      en           : IN     std_logic ;
      sel_op_i     : OUT    std_logic ;
      sel_op_ii    : OUT    std_logic ;
      flush        : IN     std_logic ;
      lui_imm_msb  : IN     std_logic ;
      rs_to_read   : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT core_iaddr_chk
   PORT (
      addr_ovfl             : IN     std_logic ;
      addr_viol             : IN     std_logic ;
      clk                   : IN     std_logic ;
      en_stage              : IN     std_logic_vector (5 DOWNTO 0);
      flush                 : IN     std_logic_vector (3 DOWNTO 0);
      miss_aligned_addr     : IN     std_logic ;
      rst_x                 : IN     std_logic ;
      sel_pc                : IN     std_logic_vector (2 DOWNTO 0);
      write_pc              : IN     std_logic ;
      illegal_jump_q        : OUT    std_logic ;
      inst_addr_violation_q : OUT    std_logic ;
      jump_addr_overflow_q  : OUT    std_logic ;
      miss_aligned_iaddr_q  : OUT    std_logic ;
      miss_aligned_jump_q   : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT core_inth
   PORT (
      ack           : IN     std_logic ;                     -- CCU acknoledges a request just before service
      clk           : IN     std_logic ;
      cop_exc       : IN     std_logic_vector (3 DOWNTO 0);  -- requests from coprocessors
      cop_int_pri   : IN     std_logic_vector (15 DOWNTO 0); -- -- priorities for coprocessor interrupts
      done          : IN     std_logic ;                     -- reti causes done TO go high
      ext_handler   : IN     std_logic ;                     -- high if external handler used
      ext_int_pri   : IN     std_logic_vector (31 DOWNTO 0); -- -- priorities for external interrupts
      ext_interrupt : IN     std_logic_vector (7 DOWNTO 0);  -- -- active high signals from external sources
      int_base      : IN     array_12x32_stdl ;              -- -- base addresses of a handler routines
      int_mode_il   : IN     std_logic_vector (11 DOWNTO 0); -- --  what IL mode to switch into
      int_mode_um   : IN     std_logic_vector (11 DOWNTO 0); -- --  what UM mode TO switch into
      mask          : IN     std_logic_vector (11 DOWNTO 0); -- -- Individual mask bits for each source.
      offset        : IN     std_logic_vector (7 DOWNTO 0);  -- this is scaled and added to base
      rst_x         : IN     std_logic ;
      tmr_inta      : IN     std_logic_vector (7 DOWNTO 0);  -- -- timer interrupt a
      tmr_intb      : IN     std_logic_vector (7 DOWNTO 0);  -- -- timer interrupt b
      int_ack       : OUT    std_logic ;
      int_addr      : OUT    std_logic_vector (31 DOWNTO 0); -- -- entry address of an ISR
      int_done      : OUT    std_logic ;
      int_pend      : OUT    std_logic_vector (11 DOWNTO 0);
      int_psr       : OUT    std_logic_vector (7 DOWNTO 0);
      int_serv      : OUT    std_logic_vector (11 DOWNTO 0);
      req_q         : OUT    std_logic                       -- request TO CCU for service
   );
   END COMPONENT;
   COMPONENT core_iw_extend
   PORT (
      i_word       : IN     std_logic_vector (31 DOWNTO 0);
      mode         : IN     std_logic ;
      sel_halfword : IN     std_logic ;
      extended_iw  : OUT    std_logic_vector (31 DOWNTO 0);
      jump_offset  : OUT    std_logic_vector (31 DOWNTO 0);
      lui_imm_msb  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT core_reset_logic
   PORT (
      clk           : IN     std_logic ;
      rst_n         : IN     std_logic ;
      gated_reset_n : OUT    std_logic ;
      ba_ext        : IN     std_logic ;
      wdog0_rst_n   : IN     std_logic ;
      wdog1_rst_n   : IN     std_logic ;
      rst_n_s       : OUT    std_logic ;
      reset_n_out   : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT core_rf
   PORT (
      clk         : IN     std_logic ;
      rst_x       : IN     std_logic ;
      rs_to_read  : IN     std_logic ;                     -- -- Which register set TO read from
      rs_to_write : IN     std_logic ;                     -- -- Which register set TO write to
      wr_en_spsr  : IN     std_logic ;
      wr_en_data  : IN     std_logic ;
      reg_indx1   : IN     std_logic_vector (4 DOWNTO 0);  -- -- index to register operand1
      reg_indx2   : IN     std_logic_vector (4 DOWNTO 0);  -- -- index to register operand2
      reg_indx3   : IN     std_logic_vector (4 DOWNTO 0);  -- -- index to result register
      psr_data_in : IN     std_logic_vector (7 DOWNTO 0);
      data_in     : IN     std_logic_vector (31 DOWNTO 0); -- -- Data to be written to result register if enabled
      psr_o_q     : OUT    std_logic_vector  (7 DOWNTO 0); -- -- Processor status flag output
      spsr_o_q    : OUT    std_logic_vector  (7 DOWNTO 0); -- -- Output of saved status flags
      data_out1   : OUT    std_logic_vector (31 DOWNTO 0);
      data_out2   : OUT    std_logic_vector (31 DOWNTO 0);
      wr_en_psr   : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT core_tmr
   PORT (
      clk         : IN     std_logic ;
      rst_x       : IN     std_logic ;
      tmr_cnt_in  : IN     std_logic_vector (31 DOWNTO 0);
      tmr_conf    : IN     std_logic_vector (15 DOWNTO 0);
      tmr_max_cnt : IN     std_logic_vector (31 DOWNTO 0);
      tmr_cnt_out : OUT    std_logic_vector (31 DOWNTO 0);
      tmr_int     : OUT    std_logic_vector (7 DOWNTO 0);
      wdog_rst_x  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT dff_we
   PORT (
      d     : IN     std_logic ;
      clk   : IN     std_logic ;
      en    : IN     std_logic ;
      q     : OUT    std_logic ;
      rst_x : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT incrementer_32bit_a
   PORT (
      data_in    : IN     std_logic_vector (31 DOWNTO 0);
      inc_amount : IN     std_logic ;                   -- 0 : increment by two, 1: incr by four.
      data_out   : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT mux2to1_32b
   PORT (
      d0 : IN     std_logic_vector (31 DOWNTO 0);
      d1 : IN     std_logic_vector (31 DOWNTO 0);
      o  : OUT    std_logic_vector (31 DOWNTO 0);
      s  : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT mux2to1_3b
   PORT (
      d0 : IN     std_logic_vector (2 DOWNTO 0);
      d1 : IN     std_logic_vector (2 DOWNTO 0);
      o  : OUT    std_logic_vector (2 DOWNTO 0);
      s  : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT mux3to1_32b
   PORT (
      d0 : IN     std_logic_vector (31 DOWNTO 0);
      d1 : IN     std_logic_vector (31 DOWNTO 0);
      d2 : IN     std_logic_vector (31 DOWNTO 0);
      o  : OUT    std_logic_vector (31 DOWNTO 0);
      s  : IN     std_logic_vector (1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT mux4to1_32b
   PORT (
      d0  : IN     std_logic_vector (31 DOWNTO 0);
      d1  : IN     std_logic_vector (31 DOWNTO 0);
      d2  : IN     std_logic_vector (31 DOWNTO 0);
      d3  : IN     std_logic_vector (31 DOWNTO 0);
      o   : OUT    std_logic_vector (31 DOWNTO 0);
      sel : IN     std_logic_vector (1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT mux6to1_8b
   PORT (
      d0  : IN     std_logic_vector (7 DOWNTO 0);
      d1  : IN     std_logic_vector (7 DOWNTO 0);
      d2  : IN     std_logic_vector (7 DOWNTO 0);
      d3  : IN     std_logic_vector (7 DOWNTO 0);
      d4  : IN     std_logic_vector (7 DOWNTO 0);
      d5  : IN     std_logic_vector (7 DOWNTO 0);
      sel : IN     std_logic_vector (2 DOWNTO 0);
      o   : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT mux8to1_32bit
   PORT (
      d0  : IN     std_logic_vector (31 DOWNTO 0);
      d1  : IN     std_logic_vector (31 DOWNTO 0);
      d2  : IN     std_logic_vector (31 DOWNTO 0);
      d3  : IN     std_logic_vector (31 DOWNTO 0);
      d4  : IN     std_logic_vector (31 DOWNTO 0);
      d5  : IN     std_logic_vector (31 DOWNTO 0);
      d6  : IN     std_logic_vector (31 DOWNTO 0);
      d7  : IN     std_logic_vector (31 DOWNTO 0);
      o   : OUT    std_logic_vector (31 DOWNTO 0);
      sel : IN     std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT r32b_we
   PORT (
      d     : IN     std_logic_vector (31 DOWNTO 0);
      clk   : IN     std_logic ;
      en    : IN     std_logic ;
      rst_x : IN     std_logic ;
      q     : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT r32b_we_sset_fuck
   PORT (
      clk   : IN     std_logic ;
      d     : IN     std_logic_vector (31 DOWNTO 0);
      rst_n : IN     std_logic ;
      sset  : IN     std_logic ;
      we    : IN     std_logic ;
      q     : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   i_addr <= i_addr_signal(imem_abits_c+imem_abit_lsb_c-1 downto imem_abit_lsb_c);

   -- HDL Embedded Text Block 4 eb4
   check_enable <= '1' when current_psr(3) = dc_mode else '0';
   il <= current_psr(3);

   -- HDL Embedded Text Block 5 eb5
   exc_psr <= EXCEPTION_PSR;
   one <= '1';
   zeros <= (others => '0');

   -- Instance port mappings.
   I40 : adder_32bit_cla
      PORT MAP (
         cin  => zeros(0),
         opa  => jump_offset,
         opb  => i_addr_signal,
         cout => carry_out,
         sum  => pc_rel_jmp_addr
      );
   I43 : core_addr_chk_align
      PORT MAP (
         addr              => i_addr_signal,
         il                => il,
         miss_aligned_addr => miss_aligned_addr,
         check_enable      => check_enable
      );
   I54 : core_addr_chk_ovfl
      PORT MAP (
         carry      => q5,
         base_msb   => q7,
         offset_msb => q6,
         addr_msb   => i_addr_signal(31),
         addr_ovfl  => addr_ovfl,
         chk        => one
      );
   I10 : core_addr_chk_ovfl
      PORT MAP (
         carry      => znc_q(0),
         base_msb   => q1,
         offset_msb => q,
         addr_msb   => result_q(31),
         addr_ovfl  => data_addr_exception_of,
         chk        => check_data_addr_ovfl
      );
   I24 : core_addr_chk_pcb
      PORT MAP (
         pcb_start     => pcb_start,
         ccb_access    => ccb_access,
         accessed_addr => result_q,
         reg_indx      => reg_indx,
         pcb_end       => pcb_end,
         pcb_access    => pcb_access,
         ccb_base      => ccb_base
      );
   I42 : core_addr_chk_usr
      PORT MAP (
         enable_check  => current_psr(0),
         start_addr    => pias_start,
         end_addr      => pias_end,
         accessed_addr => i_addr_signal,
         addr_viol     => addr_viol,
         protect_mode  => protect_mode_q(0)
      );
   I7 : core_addr_chk_usr
      PORT MAP (
         enable_check  => check_data_addr_usr,
         start_addr    => pdas_start,
         end_addr      => pdas_end,
         accessed_addr => result_q,
         addr_viol     => data_addr_exception_usr,
         protect_mode  => protect_mode_q(1)
      );
   I6 : core_alu
      PORT MAP (
         chk_of     => alu_of_check_en,
         clk        => clk,
         enable_i   => en_stage(2),
         enable_ii  => en_stage(3),
         enable_iii => en_stage(4),
         flush      => flush(2),
         operand_i  => operand_i,
         operand_ii => operand_ii,
         operation  => alu_op_code,
         rst_x      => rst_n_s,
         of_q       => alu_exception_of,
         result_1   => data_i,
         result_2   => result_2,
         result_3   => result_3,
         result_4   => result_4,
         uf_q       => alu_exception_uf,
         znc_q      => znc_q
      );
   I28 : core_ccb
      PORT MAP (
         reg_indx         => reg_indx,
         user_data_in     => data_to_mem,
         exception_cs_in  => exception_cause(7 DOWNTO 0),
         exception_pc_in  => buff_addr,
         clk              => clk,
         rst_x            => rst_n_s,
         int_base         => base_addr,
         int_mask_q       => int_mask,
         dmem_bound_lo_q  => pdas_start,
         dmem_bound_hi_q  => pdas_end,
         imem_bound_lo_q  => pias_start,
         imem_bound_hi_q  => pias_end,
         write_access     => write_access,
         pcb_start_q      => pcb_start,
         exception        => ccb_we_exc,
         data_out         => ccb_data,
         sys_addr_q       => sys_addr_q,
         exception_addr_q => exception_addr_q,
         exception_psr    => psr,
         int_mode_il_q    => int_mode_il,
         int_mode_um_q    => int_mode_um,
         int_pend         => int_pend,
         int_serv         => int_serv,
         wait_states      => wait_states,
         pcb_end_q        => pcb_end,
         creg_indx_i_q    => creg_indx_i_q,
         enable           => en_stage(3),
         ext_int_pri      => ext_int_pri,
         cop_int_pri      => cop_int_pri,
         flush            => flush(3),
         protect_mode_q   => protect_mode_q,
         tmr0_cnt_in      => tmr0_cnt_in,
         tmr1_cnt_in      => tmr1_cnt_in,
         tmr0_cnt_out     => tmr0_cnt_out,
         tmr1_cnt_out     => tmr1_cnt_out,
         tmr0_max_cnt     => tmr0_max_cnt,
         tmr1_max_cnt     => tmr1_max_cnt,
         tmr_conf         => tmr_conf,
         ccb_access       => ccb_access,
         tos_addr         => tos_addr,
         tos_psr          => tos_psr,
         tos_cr0          => tos_cr0,
         new_tos_addr     => new_tos_addr,
         new_tos_psr      => new_tos_psr,
         new_tos_cr0      => new_tos_cr0,
         addr_mask        => addr_mask,
         ccb_base         => ccb_base
      );
   I17 : core_ccu
      PORT MAP (
         alu_exception_of         => alu_exception_of,
         alu_exception_uf         => alu_exception_uf,
         bus_req                  => bus_req,
         ccb_access               => ccb_access,
         clk                      => clk,
         creg_indx_i_q            => creg_indx_i_q,
         current_psr              => current_psr,
         d_cache_miss             => d_cache_miss,
         data_addr_exception_of   => data_addr_exception_of,
         data_addr_exception_usr  => data_addr_exception_usr,
         decode_exception         => decode_exception,
         execute                  => execute,
         extended_iw              => extended_iw,
         i_cache_miss             => i_cache_miss,
         illegal_jump             => illegal_jump_q,
         inst_addr_violation      => inst_addr_violation_q,
         interrupt_req            => interrupt_req,
         jump_addr_overflow       => jump_addr_overflow_q,
         miss_aligned_iaddr       => miss_aligned_iaddr_q,
         miss_aligned_jump        => miss_aligned_jump_q,
         rs_to_rd                 => rs_to_read,
         rst_n                    => rst_n_s,
         stall                    => stall,
         wait_cycles              => wait_states,
         access_complete          => access_complete,
         ack                      => ack,
         alu_of_check_en          => alu_of_check_en,
         alu_op_code              => alu_op_code,
         alu_op_i_fwd             => alu_op_i_fwd,
         alu_op_ii_fwd            => alu_op_ii_fwd,
         bus_ack                  => bus_ack,
         ccb_we_exc               => ccb_we_exc,
         check_data_addr_ovfl     => check_data_addr_ovfl,
         check_data_addr_usr      => check_data_addr_usr,
         cop_if_cop_indx          => cop_if_cop_indx,
         cop_if_rd_cop            => cop_if_rd_cop,
         cop_if_reg_indx          => cop_if_reg_indx,
         cop_if_wr_cop            => cop_if_wr_cop,
         cr_we                    => cr_we,
         cr_we_all                => cr_we_all,
         cr_wr_reg                => cr_wr_reg,
         d_cache_data_fwd         => d_cache_data_fwd,
         d_cache_if_use_prev_data => d_cache_if_use_prev_data,
         done                     => done,
         en_stage                 => en_stage,
         exception_cause          => exception_cause,
         float                    => float,
         flush                    => flush,
         mdata_fwd_op_i           => mdata_fwd_op_i,
         mdata_fwd_op_ii          => mdata_fwd_op_ii,
         mdata_fwd_st             => mdata_fwd_st,
         pop                      => pop,
         push                     => push,
         read_access              => read_access,
         reg_jmp_fwd              => reg_jmp_fwd,
         rf_we_data               => rf_we_data,
         rf_we_spsr               => rf_we_spsr,
         rf_wr_reg                => rf_wr_reg,
         rf_wr_rs                 => rf_wr_rs,
         sel_buff_entry           => sel_buff_entry,
         sel_data3p               => sel_data3p,
         sel_data4p               => sel_data4p,
         sel_data5p               => sel_data5p,
         sel_data_from_cop        => sel_data_from_cop,
         sel_data_to_cop          => sel_data_to_cop,
         sel_pc                   => sel_pc,
         sel_psr                  => sel_psr,
         start_dmem_access        => start_dmem_access,
         wr_en_psr                => wr_en_psr,
         write_access             => write_access,
         write_pc                 => write_pc
      );
   I44 : core_cntxt_buff
      PORT MAP (
         clk       => clk,
         enable    => en_stage(3 DOWNTO 0),
         rst_x     => rst_n_s,
         pc_in     => i_addr_signal,
         sel_entry => sel_buff_entry,
         psr_in    => next_psr,
         psr       => psr,
         addr      => buff_addr
      );
   I45 : core_cntxt_stack
      PORT MAP (
         rst_x        => rst_n_s,
         push         => push,
         pop          => pop,
         clk          => clk,
         psr_in       => current_psr,
         pc_in        => i_addr_signal,
         psr_o        => tos_psr,
         pc_out       => tos_addr,
         cr0_in       => cr0_to_push(2 DOWNTO 0),
         cr0_out      => tos_cr0,
         flush        => flush(3),
         new_tos_addr => new_tos_addr,
         new_tos_psr  => new_tos_psr,
         new_tos_cr0  => new_tos_cr0
      );
   I9 : core_cond_chk
      PORT MAP (
         cond    => extended_iw(21 DOWNTO 19),
         cex     => extended_iw(25),
         znc     => znc_o,
         execute => execute,
         opcode  => extended_iw(31 DOWNTO 26)
      );
   I20 : core_cop_if
      PORT MAP (
         clk        => clk,
         cop_indx   => cop_if_cop_indx,
         data_in    => o6,
         enable     => en_stage(2),
         flush      => flush(2),
         rd_cop     => cop_if_rd_cop,
         reg_indx   => cop_if_reg_indx,
         rst_x      => rst_n_s,
         wr_cop     => cop_if_wr_cop,
         cop_id     => cop_id,
         cop_rd     => cop_rd,
         cop_rgi    => cop_rgi,
         cop_wr     => cop_wr,
         data_out   => cop_data,
         cop_bus_qz => cop_bus_z
      );
   I5 : core_cr
      PORT MAP (
         rst_x   => rst_n_s,
         creg_wr => cr_wr_reg,
         wrcr    => cr_we,
         clk     => clk,
         creg_rd => extended_iw(24 DOWNTO 22),
         wr_all  => cr_we_all,
         znc_in  => o7,
         all_in  => result_q(23 DOWNTO 0),
         znc_o   => znc_o,
         flush   => flush(3),
         cr0_out => cr0_to_push,
         all_out => flags
      );
   I11 : core_dbif
      PORT MAP (
         access_complete => access_complete,
         addr_in         => result_q,
         addr_mask       => addr_mask,
         ccb_access      => ccb_access,
         clk             => clk,
         data_in         => data_to_mem,
         float_bus       => float,
         gated_reset_n   => gated_reset_n,
         pcb_access      => pcb_access,
         read_access     => read_access,
         rst_n           => rst_n,
         start_access    => start_dmem_access,
         use_prev_data   => d_cache_if_use_prev_data,
         write_access    => write_access,
         boot_address    => boot_address,
         mem_data_q      => mem_data,
         read_mem_q      => rd,
         read_pcb_q      => pcb_rd,
         write_mem_q     => wr,
         write_pcb_q     => pcb_wr,
         addr_qz         => d_addr,
         data_qz         => data
      );
   I3 : core_decode
      PORT MAP (
         rst_x        => rst_n_s,
         i_word       => extended_iw,
         current_psr  => current_psr,
         clk          => clk,
         new_psr      => new_psr,
         extended_imm => ext_imm,
         exception_q  => decode_exception,
         en           => en_stage(1),
         sel_op_i     => sel_op_i,
         sel_op_ii    => sel_op_ii,
         flush        => flush(1),
         lui_imm_msb  => lui_imm_msb,
         rs_to_read   => rs_to_read
      );
   I51 : core_iaddr_chk
      PORT MAP (
         addr_ovfl             => addr_ovfl,
         addr_viol             => addr_viol,
         clk                   => clk,
         en_stage              => en_stage,
         flush                 => flush,
         miss_aligned_addr     => miss_aligned_addr,
         rst_x                 => rst_n_s,
         sel_pc                => sel_pc,
         write_pc              => write_pc,
         illegal_jump_q        => illegal_jump_q,
         inst_addr_violation_q => inst_addr_violation_q,
         jump_addr_overflow_q  => jump_addr_overflow_q,
         miss_aligned_iaddr_q  => miss_aligned_iaddr_q,
         miss_aligned_jump_q   => miss_aligned_jump_q
      );
   I41 : core_inth
      PORT MAP (
         ack           => ack,
         clk           => clk,
         cop_exc       => cop_exc,
         cop_int_pri   => cop_int_pri,
         done          => done,
         ext_handler   => ext_handler,
         ext_int_pri   => ext_int_pri,
         ext_interrupt => ext_interrupt,
         int_base      => base_addr,
         int_mode_il   => int_mode_il,
         int_mode_um   => int_mode_um,
         mask          => int_mask,
         offset        => offset,
         rst_x         => rst_n_s,
         tmr_inta      => tmr0_int,
         tmr_intb      => tmr1_int,
         int_ack       => int_ack,
         int_addr      => int_addr,
         int_done      => int_done,
         int_pend      => int_pend,
         int_psr       => int_psr,
         int_serv      => int_serv,
         req_q         => interrupt_req
      );
   I8 : core_iw_extend
      PORT MAP (
         i_word       => d_path1,
         mode         => dc_mode,
         sel_halfword => q4,
         extended_iw  => extended_iw,
         jump_offset  => jump_offset,
         lui_imm_msb  => lui_imm_msb
      );
   I23 : core_reset_logic
      PORT MAP (
         clk           => clk,
         rst_n         => rst_n,
         gated_reset_n => gated_reset_n,
         ba_ext        => boot_sel,
         wdog0_rst_n   => tmr0_wdog_rst_n,
         wdog1_rst_n   => tmr1_wdog_rst_n,
         rst_n_s       => rst_n_s,
         reset_n_out   => reset_n_out
      );
   I4 : core_rf
      PORT MAP (
         clk         => clk,
         rst_x       => rst_n_s,
         rs_to_read  => rs_to_read,
         rs_to_write => rf_wr_rs,
         wr_en_spsr  => rf_we_spsr,
         wr_en_data  => rf_we_data,
         reg_indx1   => extended_iw(9 DOWNTO 5),
         reg_indx2   => extended_iw(14 DOWNTO 10),
         reg_indx3   => rf_wr_reg,
         psr_data_in => next_psr,
         data_in     => result_qqq,
         psr_o_q     => current_psr,
         spsr_o_q    => saved_psr,
         data_out1   => reg_op_i,
         data_out2   => reg_op_ii,
         wr_en_psr   => wr_en_psr
      );
   I29 : core_tmr
      PORT MAP (
         clk         => clk,
         rst_x       => rst_n_s,
         tmr_cnt_in  => tmr0_cnt_out,
         tmr_conf    => tmr_conf(15 DOWNTO 0),
         tmr_max_cnt => tmr0_max_cnt,
         tmr_cnt_out => tmr0_cnt_in,
         tmr_int     => tmr0_int,
         wdog_rst_x  => tmr0_wdog_rst_n
      );
   I52 : core_tmr
      PORT MAP (
         clk         => clk,
         rst_x       => rst_n_s,
         tmr_cnt_in  => tmr1_cnt_out,
         tmr_conf    => tmr_conf(31 DOWNTO 16),
         tmr_max_cnt => tmr1_max_cnt,
         tmr_cnt_out => tmr1_cnt_in,
         tmr_int     => tmr1_int,
         wdog_rst_x  => tmr1_wdog_rst_n
      );
   I71 : dff_we
      PORT MAP (
         d     => i_addr_signal(31),
         clk   => clk,
         en    => write_pc,
         q     => q7,
         rst_x => rst_n_s
      );
   I62 : dff_we
      PORT MAP (
         d     => current_psr(3),
         clk   => clk,
         en    => en_stage(0),
         q     => dc_mode,
         rst_x => rst_n_s
      );
   I72 : dff_we
      PORT MAP (
         d     => jump_offset(31),
         clk   => clk,
         en    => write_pc,
         q     => q6,
         rst_x => rst_n_s
      );
   I73 : dff_we
      PORT MAP (
         d     => carry_out,
         clk   => clk,
         en    => write_pc,
         q     => q5,
         rst_x => rst_n_s
      );
   I67 : dff_we
      PORT MAP (
         d     => operand_ii(31),
         clk   => clk,
         en    => en_stage(2),
         q     => q,
         rst_x => rst_n_s
      );
   I2 : dff_we
      PORT MAP (
         d     => i_addr_signal(1),
         clk   => clk,
         en    => en_stage(0),
         q     => q4,
         rst_x => rst_n_s
      );
   I66 : dff_we
      PORT MAP (
         d     => operand_i(31),
         clk   => clk,
         en    => en_stage(2),
         q     => q1,
         rst_x => rst_n_s
      );
   I0 : incrementer_32bit_a
      PORT MAP (
         data_in    => i_addr_signal,
         inc_amount => current_psr(3),
         data_out   => next_addr
      );
   I14 : mux2to1_32b
      PORT MAP (
         d0 => reg_op_i,
         d1 => next_addr,
         o  => o3,
         s  => sel_op_i
      );
   I19 : mux2to1_32b
      PORT MAP (
         d0 => q2,
         d1 => mem_data,
         o  => operand_i,
         s  => mdata_fwd_op_i
      );
   I25 : mux2to1_32b
      PORT MAP (
         d0 => q13,
         d1 => operand_i,
         o  => o6,
         s  => sel_data_to_cop
      );
   I57 : mux2to1_32b
      PORT MAP (
         d0 => q14,
         d1 => mem_data,
         o  => o4,
         s  => mdata_fwd_st
      );
   I34 : mux2to1_32b
      PORT MAP (
         d0 => buff_addr,
         d1 => tos_addr,
         o  => popped_addr,
         s  => pop
      );
   I35 : mux2to1_32b
      PORT MAP (
         d0 => cop_data,
         d1 => q9,
         o  => result_qq,
         s  => sel_data_from_cop
      );
   I15 : mux2to1_32b
      PORT MAP (
         d0 => o,
         d1 => ext_imm,
         o  => o2,
         s  => sel_op_ii
      );
   I55 : mux2to1_32b
      PORT MAP (
         d0 => q13,
         d1 => mem_data,
         o  => operand_ii,
         s  => mdata_fwd_op_ii
      );
   I33 : mux2to1_32b
      PORT MAP (
         d0 => q10,
         d1 => mem_data,
         o  => result_qqq,
         s  => sel_data5p
      );
   I16 : mux2to1_3b
      PORT MAP (
         d0 => znc_q,
         d1 => tos_cr0,
         o  => o7,
         s  => pop
      );
   I12 : mux3to1_32b
      PORT MAP (
         d0 => q3,
         d1 => data_iii,
         d2 => result_qqq,
         o  => data_to_mem,
         s  => d_cache_data_fwd
      );
   I60 : mux4to1_32b
      PORT MAP (
         d0  => o3,
         d1  => data_i,
         d2  => data_ii,
         d3  => data_iii,
         o   => o5,
         sel => alu_op_i_fwd
      );
   I18 : mux4to1_32b
      PORT MAP (
         d0  => reg_op_i,
         d1  => result_q,
         d2  => result_qq,
         d3  => result_qqq,
         o   => abs_jmp_addr,
         sel => reg_jmp_fwd
      );
   I61 : mux4to1_32b
      PORT MAP (
         d0  => reg_op_ii,
         d1  => data_i,
         d2  => data_ii,
         d3  => data_iii,
         o   => o,
         sel => alu_op_ii_fwd
      );
   I27 : mux4to1_32b
      PORT MAP (
         d0  => zeros,
         d1  => result_q,
         d2  => result_2,
         d3  => flags,
         o   => data_ii,
         sel => sel_data3p
      );
   I31 : mux4to1_32b
      PORT MAP (
         d0  => result_qq,
         d1  => result_3,
         d2  => result_4,
         d3  => ccb_data,
         o   => data_iii,
         sel => sel_data4p
      );
   I13 : mux6to1_8b
      PORT MAP (
         d0  => current_psr,
         d1  => new_psr,
         d2  => int_psr,
         d3  => tos_psr,
         d4  => exc_psr,
         d5  => saved_psr,
         sel => sel_psr,
         o   => next_psr
      );
   I39 : mux8to1_32bit
      PORT MAP (
         d0  => next_addr,
         d1  => pc_rel_jmp_addr,
         d2  => abs_jmp_addr,
         d3  => int_addr,
         d4  => exception_addr_q,
         d5  => sys_addr_q,
         d6  => boot_address,
         d7  => popped_addr,
         o   => i_addr_asynch,
         sel => sel_pc
      );
   I70 : r32b_we
      PORT MAP (
         d     => i_addr_asynch,
         clk   => clk,
         en    => write_pc,
         rst_x => gated_reset_n,
         q     => i_addr_signal
      );
   I64 : r32b_we
      PORT MAP (
         d     => o4,
         clk   => clk,
         en    => en_stage(2),
         rst_x => rst_n_s,
         q     => q3
      );
   I63 : r32b_we
      PORT MAP (
         d     => o,
         clk   => clk,
         en    => en_stage(1),
         rst_x => rst_n_s,
         q     => q14
      );
   I56 : r32b_we
      PORT MAP (
         d     => o2,
         clk   => clk,
         en    => en_stage(1),
         rst_x => rst_n_s,
         q     => q13
      );
   I69 : r32b_we
      PORT MAP (
         d     => data_iii,
         clk   => clk,
         en    => en_stage(4),
         rst_x => rst_n_s,
         q     => q10
      );
   I65 : r32b_we
      PORT MAP (
         d     => data_i,
         clk   => clk,
         en    => en_stage(2),
         rst_x => rst_n_s,
         q     => result_q
      );
   I68 : r32b_we
      PORT MAP (
         d     => data_ii,
         clk   => clk,
         en    => en_stage(3),
         rst_x => rst_n_s,
         q     => q9
      );
   I53 : r32b_we
      PORT MAP (
         d     => o5,
         clk   => clk,
         en    => en_stage(1),
         rst_x => rst_n_s,
         q     => q2
      );
   I1 : r32b_we_sset_fuck
      PORT MAP (
         clk   => clk,
         d     => i_word,
         rst_n => rst_n_s,
         sset  => flush(0),
         we    => en_stage(0),
         q     => d_path1
      );

END struct;
