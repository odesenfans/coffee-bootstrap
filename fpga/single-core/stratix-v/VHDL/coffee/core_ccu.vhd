------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:24 01/03/06
-- File : core_ccu.vhd
-- Design : core_ccu
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_ccu IS
   PORT( 
      alu_exception_of         : IN     std_logic;
      alu_exception_uf         : IN     std_logic;
      bus_req                  : IN     std_logic;
      ccb_access               : IN     std_logic;
      clk                      : IN     std_logic;
      creg_indx_i_q            : IN     std_logic_vector (19 DOWNTO 0);
      current_psr              : IN     std_logic_vector (7 DOWNTO 0);
      d_cache_miss             : IN     std_logic;
      data_addr_exception_of   : IN     std_logic;
      data_addr_exception_usr  : IN     std_logic;
      decode_exception         : IN     std_logic_vector (2 DOWNTO 0);
      execute                  : IN     std_logic;
      extended_iw              : IN     std_logic_vector (31 DOWNTO 0);
      i_cache_miss             : IN     std_logic;
      illegal_jump             : IN     std_logic;
      inst_addr_violation      : IN     std_logic;
      interrupt_req            : IN     std_logic;
      jump_addr_overflow       : IN     std_ulogic;
      miss_aligned_iaddr       : IN     std_logic;
      miss_aligned_jump        : IN     std_logic;
      rs_to_rd                 : IN     std_logic;
      rst_n                    : IN     std_logic;
      stall                    : IN     std_logic;
      wait_cycles              : IN     std_logic_vector (11 DOWNTO 0);
      access_complete          : OUT    std_logic;
      ack                      : OUT    std_logic;
      alu_of_check_en          : OUT    std_logic;
      alu_op_code              : OUT    std_logic_vector (9 DOWNTO 0);
      alu_op_i_fwd             : OUT    std_logic_vector (1 DOWNTO 0);
      alu_op_ii_fwd            : OUT    std_logic_vector (1 DOWNTO 0);
      bus_ack                  : OUT    std_logic;
      ccb_we_exc               : OUT    std_logic;
      check_data_addr_ovfl     : OUT    std_logic;
      check_data_addr_usr      : OUT    std_logic;
      cop_if_cop_indx          : OUT    std_logic_vector (1 DOWNTO 0);
      cop_if_rd_cop            : OUT    std_logic;
      cop_if_reg_indx          : OUT    std_logic_vector (4 DOWNTO 0);
      cop_if_wr_cop            : OUT    std_logic;
      cr_we                    : OUT    std_logic;
      cr_we_all                : OUT    std_logic;
      cr_wr_reg                : OUT    std_logic_vector (2 DOWNTO 0);
      d_cache_data_fwd         : OUT    std_logic_vector (1 DOWNTO 0);
      d_cache_if_use_prev_data : OUT    std_logic;
      done                     : OUT    std_logic;
      en_stage                 : OUT    std_logic_vector (5 DOWNTO 0);
      exception_cause          : OUT    std_logic_vector (7 DOWNTO 0);
      float                    : OUT    std_logic;
      flush                    : OUT    std_logic_vector (3 DOWNTO 0);
      mdata_fwd_op_i           : OUT    std_logic;
      mdata_fwd_op_ii          : OUT    std_logic;
      mdata_fwd_st             : OUT    std_logic;
      pop                      : OUT    std_logic;
      push                     : OUT    std_logic;
      read_access              : OUT    std_logic;
      reg_jmp_fwd              : OUT    std_logic_vector (1 DOWNTO 0);
      rf_we_data               : OUT    std_logic;
      rf_we_spsr               : OUT    std_logic;
      rf_wr_reg                : OUT    std_logic_vector (4 DOWNTO 0);
      rf_wr_rs                 : OUT    std_logic;
      sel_buff_entry           : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data3p               : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data4p               : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data5p               : OUT    std_logic;
      sel_data_from_cop        : OUT    std_logic;
      sel_data_to_cop          : OUT    std_logic;
      sel_pc                   : OUT    std_logic_vector (2 DOWNTO 0);
      sel_psr                  : OUT    std_logic_vector (2 DOWNTO 0);
      start_dmem_access        : OUT    std_logic;
      wr_en_psr                : OUT    std_logic;
      write_access             : OUT    std_logic;
      write_pc                 : OUT    std_logic
   );

-- Declarations

END core_ccu ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:26 01/03/06
-- File : core_ccu.vhd
-- Design : core_ccu
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY coffee;
USE coffee.core_constants_pkg.ALL;

ARCHITECTURE struct OF core_ccu IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL alu_of_check_en_a       : std_logic;
   SIGNAL alu_op_code_a           : std_logic_vector(9 DOWNTO 0);
   SIGNAL cond_execute            : std_logic;
   SIGNAL cond_reg_src            : std_logic_vector(2 DOWNTO 0);
   SIGNAL cond_reg_trgt           : std_logic_vector(2 DOWNTO 0);
   SIGNAL cop_inst                : std_logic;
   SIGNAL data_ready              : std_logic_vector(1 DOWNTO 0);
   SIGNAL flush_stage             : std_logic_vector(4 DOWNTO 0);
   SIGNAL freeze_pc_override      : std_logic;
   SIGNAL insert_nops             : std_logic;
   SIGNAL instruction_updates_psr : std_logic;
   SIGNAL int_req                 : std_logic;
   SIGNAL invalid_pc              : std_logic;
   SIGNAL is_reg_jump             : std_logic;
   SIGNAL is_rel_jump             : std_logic;
   SIGNAL jumped                  : std_logic;
   SIGNAL load                    : std_logic;
   SIGNAL mem_load                : std_logic;
   SIGNAL mul32bit                : std_logic;
   SIGNAL need_reg_operand1       : std_logic;
   SIGNAL need_reg_operand2       : std_logic;
   SIGNAL opcode_stg_ii           : std_logic_vector(5 DOWNTO 0);
   SIGNAL opcode_stg_iii          : std_logic_vector(5 DOWNTO 0);
   SIGNAL rcon                    : std_logic;
   SIGNAL rd_cop                  : std_logic;
   SIGNAL reti                    : std_logic;
   SIGNAL retu                    : std_logic;
   SIGNAL safe_state              : std_logic_vector(2 DOWNTO 0);
   SIGNAL safe_to_switch_cntxt    : std_logic;
   SIGNAL scall                   : std_logic;
   SIGNAL sel_data_to_cop_a       : std_logic;
   SIGNAL sel_pc_override         : std_logic_vector(2 DOWNTO 0);
   SIGNAL sel_psr_override        : std_logic_vector(2 DOWNTO 0);
   SIGNAL status_override         : std_logic;
   SIGNAL store                   : std_logic;
   SIGNAL swm                     : std_logic;
   SIGNAL trap_code               : std_logic_vector(4 DOWNTO 0);
   SIGNAL update_flags            : std_logic;
   SIGNAL user_mode_out           : std_logic;
   SIGNAL wr_cop                  : std_logic;
   SIGNAL write_reg_file          : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL en_stage_internal : std_logic_vector (5 DOWNTO 0);
   SIGNAL flush_internal    : std_logic_vector (3 DOWNTO 0);


   -- Component Declarations
   COMPONENT ccu_decode_i
   PORT (
      cex_bit                 : IN     std_logic ;
      creg_field              : IN     std_logic_vector (2 DOWNTO 0);
      opcode                  : IN     std_logic_vector (5 DOWNTO 0);
      variable_shift          : IN     std_logic ;
      alu_of_check_en_a       : OUT    std_logic ;
      alu_op_code_a           : OUT    std_logic_vector (9 DOWNTO 0);
      cond_execute            : OUT    std_logic ;
      cond_reg_src            : OUT    std_logic_vector (2 DOWNTO 0);
      cond_reg_trgt           : OUT    std_logic_vector (2 DOWNTO 0);
      cop_inst                : OUT    std_logic ;
      data_ready              : OUT    std_logic_vector (1 DOWNTO 0);
      instruction_updates_psr : OUT    std_logic ;
      is_reg_jump             : OUT    std_logic ;
      is_rel_jump             : OUT    std_logic ;
      load                    : OUT    std_logic ;
      mul32bit                : OUT    std_logic ;
      need_reg_operand1       : OUT    std_logic ;
      need_reg_operand2       : OUT    std_logic ;
      rcon                    : OUT    std_logic ;
      rd_cop                  : OUT    std_logic ;
      reti                    : OUT    std_logic ;
      retu                    : OUT    std_logic ;
      safe_state              : OUT    std_logic_vector (2 DOWNTO 0);
      scall                   : OUT    std_logic ;
      sel_data_to_cop_a       : OUT    std_logic ;
      store                   : OUT    std_logic ;
      swm                     : OUT    std_logic ;
      update_flags            : OUT    std_logic ;
      wr_cop                  : OUT    std_logic ;
      write_reg_file          : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ccu_decode_ii
   PORT (
      alu_of_check_en_a : IN     std_logic ;
      alu_op_code_a     : IN     std_logic_vector (9 DOWNTO 0);
      clk               : IN     std_logic ;
      cop_indx_data     : IN     std_logic_vector (1 DOWNTO 0);
      cop_indx_instr    : IN     std_logic_vector (1 DOWNTO 0);
      cop_reg_field     : IN     std_logic_vector (4 DOWNTO 0);
      creg_indx_i       : IN     std_logic_vector (19 DOWNTO 0);
      enable            : IN     std_logic ;
      flush             : IN     std_logic ;
      opcode_in         : IN     std_logic_vector (5 DOWNTO 0);
      rd_cop            : IN     std_logic ;
      rst_x             : IN     std_logic ;
      sel_data_to_cop_a : IN     std_logic ;
      trap_code_in      : IN     std_logic_vector (4 DOWNTO 0);
      user_mode_in      : IN     std_logic ;
      wr_cop            : IN     std_logic ;
      alu_of_check_en   : OUT    std_logic ;
      alu_op_code       : OUT    std_logic_vector (9 DOWNTO 0);
      cop_if_cop_indx   : OUT    std_logic_vector (1 DOWNTO 0);
      cop_if_rd_cop     : OUT    std_logic ;
      cop_if_reg_indx   : OUT    std_logic_vector (4 DOWNTO 0);
      cop_if_wr_cop     : OUT    std_logic ;
      opcode_out        : OUT    std_logic_vector (5 DOWNTO 0);
      sel_data_to_cop   : OUT    std_logic ;
      trap_code_out     : OUT    std_logic_vector (4 DOWNTO 0);
      user_mode_out     : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ccu_decode_iii
   PORT (
      clk                  : IN     std_logic ;
      enable               : IN     std_logic ;
      flush                : IN     std_logic ;
      opcode_in            : IN     std_logic_vector (5 DOWNTO 0);
      rst_x                : IN     std_logic ;
      user_mode            : IN     std_logic ;
      check_data_addr_ovfl : OUT    std_logic ;
      check_data_addr_usr  : OUT    std_logic ;
      opcode_out           : OUT    std_logic_vector (5 DOWNTO 0);
      read_access          : OUT    std_logic ;
      sel_data3p           : OUT    std_logic_vector (1 DOWNTO 0);
      write_access         : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ccu_decode_iv
   PORT (
      ccb_access        : IN     std_logic ;
      clk               : IN     std_logic ;
      enable            : IN     std_logic ;
      opcode            : IN     std_logic_vector (5 DOWNTO 0);
      rst_x             : IN     std_logic ;
      mem_load          : OUT    std_logic ;
      sel_data4p        : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data_from_cop : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ccu_decode_v
   PORT (
      clk        : IN     std_logic ;
      enable     : IN     std_logic ;
      mem_load   : IN     std_logic ;
      rst_x      : IN     std_logic ;
      sel_data5p : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ccu_flow_control
   PORT (
      bus_req                  : IN     std_logic ;
      ccb_access               : IN     std_logic ;
      clk                      : IN     std_logic ;
      cond_execute             : IN     std_logic ;
      cond_reg_src             : IN     std_logic_vector (2 DOWNTO 0);
      cond_reg_trgt            : IN     std_logic_vector (2 DOWNTO 0);
      cop_inst                 : IN     std_logic ;
      d_cache_miss             : IN     std_logic ;
      data_ready               : IN     std_logic_vector (1 DOWNTO 0);
      execute                  : IN     std_logic ;
      first_source_reg_indx    : IN     std_logic_vector (4 DOWNTO 0);
      flush_stage              : IN     std_logic_vector (4 DOWNTO 0);
      freeze_pc                : IN     std_logic ;
      i_cache_miss             : IN     std_logic ;
      insert_nops              : IN     std_logic ;
      instruction_updates_psr  : IN     std_logic ;
      int_req                  : IN     std_logic ;
      is_32b_mul               : IN     std_logic ;
      is_reg_jump              : IN     std_logic ;
      is_rel_jump              : IN     std_logic ;
      load                     : IN     std_logic ;
      need_reg_operand1        : IN     std_logic ;
      need_reg_operand2        : IN     std_logic ;
      rcon                     : IN     std_logic ;
      reg_set_to_read          : IN     std_logic ;
      reg_set_to_write         : IN     std_logic ;
      reti                     : IN     std_logic ;
      retu                     : IN     std_logic ;
      rst_n                    : IN     std_logic ;
      safe_state               : IN     std_logic_vector (2 DOWNTO 0);
      scall                    : IN     std_logic ;
      second_source_reg_indx   : IN     std_logic_vector (4 DOWNTO 0);
      sel_pc_override          : IN     std_logic_vector (2 DOWNTO 0);
      sel_psr_override         : IN     std_logic_vector (2 DOWNTO 0);
      stall                    : IN     std_logic ;
      status_override          : IN     std_logic ;
      store                    : IN     std_logic ;
      swm                      : IN     std_logic ;
      trgt_reg_indx            : IN     std_logic_vector (4 DOWNTO 0);
      update_flags             : IN     std_logic ;
      wait_cycles              : IN     std_logic_vector (11 DOWNTO 0);
      write_reg_file           : IN     std_logic ;
      access_complete          : OUT    std_logic ;
      alu_op_i_fwd             : OUT    std_logic_vector (1 DOWNTO 0);
      alu_op_ii_fwd            : OUT    std_logic_vector (1 DOWNTO 0);
      bus_ack                  : OUT    std_logic ;
      cr_we                    : OUT    std_logic ;
      cr_we_all                : OUT    std_logic ;
      cr_wr_reg                : OUT    std_logic_vector (2 DOWNTO 0);
      d_cache_data_fwd         : OUT    std_logic_vector (1 DOWNTO 0);
      d_cache_if_use_prev_data : OUT    std_logic ;
      done                     : OUT    std_logic ;
      enable                   : OUT    std_logic_vector (5 DOWNTO 0);
      float                    : OUT    std_logic ;
      flush                    : OUT    std_logic_vector (3 DOWNTO 0);
      int_ack                  : OUT    std_logic ;
      invalid_pc               : OUT    std_logic ;
      jumped_q                 : OUT    std_logic ;
      mdata_fwd_op_i           : OUT    std_logic ;
      mdata_fwd_op_ii          : OUT    std_logic ;
      mdata_fwd_st             : OUT    std_logic ;
      pop                      : OUT    std_logic ;
      push                     : OUT    std_logic ;
      reg_jmp_fwd              : OUT    std_logic_vector (1 DOWNTO 0);
      rf_we_data               : OUT    std_logic ;
      rf_we_spsr               : OUT    std_logic ;
      rf_wr_reg                : OUT    std_logic_vector (4 DOWNTO 0);
      rf_wr_rs                 : OUT    std_logic ;
      safe_to_switch_cntxt     : OUT    std_logic ;
      sel_pc                   : OUT    std_logic_vector (2 DOWNTO 0);
      sel_psr                  : OUT    std_logic_vector (2 DOWNTO 0);
      start_dmem_access        : OUT    std_logic ;
      wr_en_psr                : OUT    std_logic ;
      write_pc                 : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ccu_master_control
   PORT (
      alu_exception_of        : IN     std_logic ;
      alu_exception_uf        : IN     std_logic ;
      clk                     : IN     std_logic ;
      current_psr             : IN     std_logic_vector (7 DOWNTO 0);
      data_addr_exception_of  : IN     std_logic ;
      data_addr_exception_usr : IN     std_logic ;
      decode_exception        : IN     std_logic_vector (2 DOWNTO 0);
      enable_3rd_stage        : IN     std_logic ;
      illegal_jump            : IN     std_logic ;
      inst_addr_violation     : IN     std_logic ;
      interrupt_req           : IN     std_logic ;
      invalid_pc              : IN     std_logic ;
      is_reg_jump             : IN     std_logic ;
      is_rel_jump             : IN     std_logic ;
      jump_addr_overflow      : IN     std_logic ;
      jumped                  : IN     std_logic ;
      miss_aligned_iaddr      : IN     std_logic ;
      miss_aligned_jump       : IN     std_logic ;
      mul32bit                : IN     std_logic ;
      rst_n                   : IN     std_logic ;
      safe_to_switch_cntxt    : IN     std_logic ;
      scall                   : IN     std_logic ;
      trap_code               : IN     std_logic_vector (4 DOWNTO 0);
      ccb_we_exc              : OUT    std_logic ;
      exception_cause         : OUT    std_logic_vector (7 DOWNTO 0);
      flush_stage             : OUT    std_logic_vector (4 DOWNTO 0);
      freeze_pc_override      : OUT    std_logic ;
      insert_nops             : OUT    std_logic ;
      int_req                 : OUT    std_logic ;
      sel_buff_entry          : OUT    std_logic_vector (1 DOWNTO 0);
      sel_pc_override         : OUT    std_logic_vector (2 DOWNTO 0);
      sel_psr_override        : OUT    std_logic_vector (2 DOWNTO 0);
      status_override         : OUT    std_logic 
   );
   END COMPONENT;


BEGIN
   -- Instance port mappings.
   I8 : ccu_decode_i
      PORT MAP (
         cex_bit                 => extended_iw(25),
         creg_field              => extended_iw(24 DOWNTO 22),
         opcode                  => extended_iw(31 DOWNTO 26),
         variable_shift          => extended_iw(18),
         alu_of_check_en_a       => alu_of_check_en_a,
         alu_op_code_a           => alu_op_code_a,
         cond_execute            => cond_execute,
         cond_reg_src            => cond_reg_src,
         cond_reg_trgt           => cond_reg_trgt,
         cop_inst                => cop_inst,
         data_ready              => data_ready,
         instruction_updates_psr => instruction_updates_psr,
         is_reg_jump             => is_reg_jump,
         is_rel_jump             => is_rel_jump,
         load                    => load,
         mul32bit                => mul32bit,
         need_reg_operand1       => need_reg_operand1,
         need_reg_operand2       => need_reg_operand2,
         rcon                    => rcon,
         rd_cop                  => rd_cop,
         reti                    => reti,
         retu                    => retu,
         safe_state              => safe_state,
         scall                   => scall,
         sel_data_to_cop_a       => sel_data_to_cop_a,
         store                   => store,
         swm                     => swm,
         update_flags            => update_flags,
         wr_cop                  => wr_cop,
         write_reg_file          => write_reg_file
      );
   I9 : ccu_decode_ii
      PORT MAP (
         alu_of_check_en_a => alu_of_check_en_a,
         alu_op_code_a     => alu_op_code_a,
         clk               => clk,
         cop_indx_data     => extended_iw(11 DOWNTO 10),
         cop_indx_instr    => extended_iw(25 DOWNTO 24),
         cop_reg_field     => extended_iw(16 DOWNTO 12),
         creg_indx_i       => creg_indx_i_q,
         enable            => en_stage_internal(1),
         flush             => flush_internal(1),
         opcode_in         => extended_iw(31 DOWNTO 26),
         rd_cop            => rd_cop,
         rst_x             => rst_n,
         sel_data_to_cop_a => sel_data_to_cop_a,
         trap_code_in      => extended_iw(14 DOWNTO 10),
         user_mode_in      => current_psr(0),
         wr_cop            => wr_cop,
         alu_of_check_en   => alu_of_check_en,
         alu_op_code       => alu_op_code,
         cop_if_cop_indx   => cop_if_cop_indx,
         cop_if_rd_cop     => cop_if_rd_cop,
         cop_if_reg_indx   => cop_if_reg_indx,
         cop_if_wr_cop     => cop_if_wr_cop,
         opcode_out        => opcode_stg_ii,
         sel_data_to_cop   => sel_data_to_cop,
         trap_code_out     => trap_code,
         user_mode_out     => user_mode_out
      );
   I5 : ccu_decode_iii
      PORT MAP (
         clk                  => clk,
         enable               => en_stage_internal(2),
         flush                => flush_internal(2),
         opcode_in            => opcode_stg_ii,
         rst_x                => rst_n,
         user_mode            => user_mode_out,
         check_data_addr_ovfl => check_data_addr_ovfl,
         check_data_addr_usr  => check_data_addr_usr,
         opcode_out           => opcode_stg_iii,
         read_access          => read_access,
         sel_data3p           => sel_data3p,
         write_access         => write_access
      );
   I2 : ccu_decode_iv
      PORT MAP (
         ccb_access        => ccb_access,
         clk               => clk,
         enable            => en_stage_internal(3),
         opcode            => opcode_stg_iii,
         rst_x             => rst_n,
         mem_load          => mem_load,
         sel_data4p        => sel_data4p,
         sel_data_from_cop => sel_data_from_cop
      );
   I4 : ccu_decode_v
      PORT MAP (
         clk        => clk,
         enable     => en_stage_internal(4),
         mem_load   => mem_load,
         rst_x      => rst_n,
         sel_data5p => sel_data5p
      );
   I3 : ccu_flow_control
      PORT MAP (
         bus_req                  => bus_req,
         ccb_access               => ccb_access,
         clk                      => clk,
         cond_execute             => cond_execute,
         cond_reg_src             => cond_reg_src,
         cond_reg_trgt            => cond_reg_trgt,
         cop_inst                 => cop_inst,
         d_cache_miss             => d_cache_miss,
         data_ready               => data_ready,
         execute                  => execute,
         first_source_reg_indx    => extended_iw(9 DOWNTO 5),
         flush_stage              => flush_stage,
         freeze_pc                => freeze_pc_override,
         i_cache_miss             => i_cache_miss,
         insert_nops              => insert_nops,
         instruction_updates_psr  => instruction_updates_psr,
         int_req                  => int_req,
         is_32b_mul               => mul32bit,
         is_reg_jump              => is_reg_jump,
         is_rel_jump              => is_rel_jump,
         load                     => load,
         need_reg_operand1        => need_reg_operand1,
         need_reg_operand2        => need_reg_operand2,
         rcon                     => rcon,
         reg_set_to_read          => rs_to_rd,
         reg_set_to_write         => current_psr(2),
         reti                     => reti,
         retu                     => retu,
         rst_n                    => rst_n,
         safe_state               => safe_state,
         scall                    => scall,
         second_source_reg_indx   => extended_iw(14 DOWNTO 10),
         sel_pc_override          => sel_pc_override,
         sel_psr_override         => sel_psr_override,
         stall                    => stall,
         status_override          => status_override,
         store                    => store,
         swm                      => swm,
         trgt_reg_indx            => extended_iw(4 DOWNTO 0),
         update_flags             => update_flags,
         wait_cycles              => wait_cycles,
         write_reg_file           => write_reg_file,
         access_complete          => access_complete,
         alu_op_i_fwd             => alu_op_i_fwd,
         alu_op_ii_fwd            => alu_op_ii_fwd,
         bus_ack                  => bus_ack,
         cr_we                    => cr_we,
         cr_we_all                => cr_we_all,
         cr_wr_reg                => cr_wr_reg,
         d_cache_data_fwd         => d_cache_data_fwd,
         d_cache_if_use_prev_data => d_cache_if_use_prev_data,
         done                     => done,
         enable                   => en_stage_internal,
         float                    => float,
         flush                    => flush_internal,
         int_ack                  => ack,
         invalid_pc               => invalid_pc,
         jumped_q                 => jumped,
         mdata_fwd_op_i           => mdata_fwd_op_i,
         mdata_fwd_op_ii          => mdata_fwd_op_ii,
         mdata_fwd_st             => mdata_fwd_st,
         pop                      => pop,
         push                     => push,
         reg_jmp_fwd              => reg_jmp_fwd,
         rf_we_data               => rf_we_data,
         rf_we_spsr               => rf_we_spsr,
         rf_wr_reg                => rf_wr_reg,
         rf_wr_rs                 => rf_wr_rs,
         safe_to_switch_cntxt     => safe_to_switch_cntxt,
         sel_pc                   => sel_pc,
         sel_psr                  => sel_psr,
         start_dmem_access        => start_dmem_access,
         wr_en_psr                => wr_en_psr,
         write_pc                 => write_pc
      );
   I7 : ccu_master_control
      PORT MAP (
         alu_exception_of        => alu_exception_of,
         alu_exception_uf        => alu_exception_uf,
         clk                     => clk,
         current_psr             => current_psr,
         data_addr_exception_of  => data_addr_exception_of,
         data_addr_exception_usr => data_addr_exception_usr,
         decode_exception        => decode_exception,
         enable_3rd_stage        => en_stage_internal(3),
         illegal_jump            => illegal_jump,
         inst_addr_violation     => inst_addr_violation,
         interrupt_req           => interrupt_req,
         invalid_pc              => invalid_pc,
         is_reg_jump             => is_reg_jump,
         is_rel_jump             => is_rel_jump,
         jump_addr_overflow      => jump_addr_overflow,
         jumped                  => jumped,
         miss_aligned_iaddr      => miss_aligned_iaddr,
         miss_aligned_jump       => miss_aligned_jump,
         mul32bit                => mul32bit,
         rst_n                   => rst_n,
         safe_to_switch_cntxt    => safe_to_switch_cntxt,
         scall                   => scall,
         trap_code               => trap_code,
         ccb_we_exc              => ccb_we_exc,
         exception_cause         => exception_cause,
         flush_stage             => flush_stage,
         freeze_pc_override      => freeze_pc_override,
         insert_nops             => insert_nops,
         int_req                 => int_req,
         sel_buff_entry          => sel_buff_entry,
         sel_pc_override         => sel_pc_override,
         sel_psr_override        => sel_psr_override,
         status_override         => status_override
      );

   -- Implicit buffered output assignments
   en_stage <= en_stage_internal;
   flush    <= flush_internal;

END struct;
