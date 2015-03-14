------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:19 01/03/06
-- File : core_dbif.vhd
-- Design : core_dbif
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee_core_conf;
USE coffee_core_conf.core_conf_pkg.all;

ENTITY core_dbif IS
   PORT( 
      access_complete : IN     std_logic;
      addr_in         : IN     std_logic_vector (31 DOWNTO 0);
      addr_mask       : IN     std_logic_vector (31 DOWNTO 0);
      ccb_access      : IN     std_logic;
      clk             : IN     std_logic;
      data_in         : IN     std_logic_vector (31 DOWNTO 0);
      float_bus       : IN     std_logic;
      gated_reset_n   : IN     std_logic;
      pcb_access      : IN     std_logic;
      read_access     : IN     std_logic;
      rst_n           : IN     std_logic;
      start_access    : IN     std_logic;
      use_prev_data   : IN     std_logic;
      write_access    : IN     std_logic;
      boot_address    : OUT    std_logic_vector (31 DOWNTO 0);
      mem_data_q      : OUT    std_logic_vector (31 DOWNTO 0);
      read_mem_q      : OUT    std_logic;
      read_pcb_q      : OUT    std_logic;
      write_mem_q     : OUT    std_logic;
      write_pcb_q     : OUT    std_logic;
      addr_qz         : INOUT  std_logic_vector (dbus_abits_c-1 DOWNTO 0);
      data_qz         : INOUT  std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core_dbif ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:20 01/03/06
-- File : core_dbif.vhd
-- Design : core_dbif
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ARCHITECTURE struct OF core_dbif IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL disable_sampling_n      : std_logic;
   SIGNAL keep_old_addr           : std_logic;
   SIGNAL keep_old_data           : std_logic;
   SIGNAL latch_data_from_bus     : std_logic;
   SIGNAL latch_data_from_core    : std_logic;
   SIGNAL masked_addr             : std_logic_vector(31 DOWNTO 0);
   SIGNAL not_keep_old_addr       : std_logic;
   SIGNAL not_keep_old_data       : std_logic;
   SIGNAL not_latch_data_from_bus : std_logic;
   SIGNAL out_z                   : std_logic_vector(31 DOWNTO 0);
   SIGNAL pull_high               : std_logic;
   SIGNAL q                       : std_logic_vector(31 DOWNTO 0);
   SIGNAL q1                      : std_logic_vector(31 DOWNTO 0);
   SIGNAL q2                      : std_logic_vector(dbus_abits_c-1 DOWNTO 0);
   SIGNAL q3                      : std_logic_vector(dbus_abits_c-1 DOWNTO 0);
   SIGNAL rd_en_dmem              : std_logic;
   SIGNAL rd_en_pcb               : std_logic;
   SIGNAL use_mask                : std_logic;
   SIGNAL wr_en_dmem              : std_logic;
   SIGNAL wr_en_pcb               : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL mem_data_q_internal : std_logic_vector (31 DOWNTO 0);


   -- Component Declarations
   COMPONENT dbif_control
   PORT (
      access_complete         : IN     std_logic ;
      addr                    : IN     std_logic_vector (31 DOWNTO 0);
      clk                     : IN     std_logic ;
      float_bus               : IN     std_logic ;
      mask                    : IN     std_logic_vector (31 DOWNTO 0);
      rd_en_dmem              : IN     std_logic ;
      rd_en_pcb               : IN     std_logic ;
      rst_n                   : IN     std_logic ;
      start_access            : IN     std_logic ;
      use_mask                : IN     std_logic ;
      use_prev_data           : IN     std_logic ;
      wr_en_dmem              : IN     std_logic ;
      wr_en_pcb               : IN     std_logic ;
      disable_sampling_n      : OUT    std_logic ;
      keep_old_addr           : OUT    std_logic ;
      keep_old_data           : OUT    std_logic ;
      latch_data_from_bus     : OUT    std_logic ;
      latch_data_from_core    : OUT    std_logic ;
      masked_addr             : OUT    std_logic_vector (31 DOWNTO 0);
      not_keep_old_addr       : OUT    std_logic ;
      not_keep_old_data       : OUT    std_logic ;
      not_latch_data_from_bus : OUT    std_logic ;
      read_mem_q              : OUT    std_logic ;
      read_pcb_q              : OUT    std_logic ;
      write_mem_q             : OUT    std_logic ;
      write_pcb_q             : OUT    std_logic 
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
   COMPONENT rg_we
   GENERIC (
      width_in  : integer := 32;
      width_out : integer := 32
   );
   PORT (
      clk   : IN     std_logic ;
      d     : IN     std_logic_vector (width_in-1 DOWNTO 0);
      en    : IN     std_logic ;
      rst_n : IN     std_logic ;
      q     : OUT    std_logic_vector (width_out-1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT tri_state_32bit
   GENERIC (
      width : integer := 32
   );
   PORT (
      in_z   : IN     std_logic_vector (width-1 DOWNTO 0);
      enable : IN     std_logic ;
      out_z  : OUT    std_logic_vector (width-1 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   pull_high <= '1';

   -- HDL Embedded Text Block 2 eb2
   wr_en_dmem <= write_access and not pcb_access and not ccb_access;
   rd_en_dmem <= read_access and not pcb_access and not ccb_access;
   wr_en_pcb  <= write_access and pcb_access;
   rd_en_pcb  <= read_access and pcb_access;
   use_mask <= pcb_access;

   -- Instance port mappings.
   I4 : dbif_control
      PORT MAP (
         access_complete         => access_complete,
         addr                    => addr_in,
         clk                     => clk,
         float_bus               => float_bus,
         mask                    => addr_mask,
         rd_en_dmem              => rd_en_dmem,
         rd_en_pcb               => rd_en_pcb,
         rst_n                   => rst_n,
         start_access            => start_access,
         use_mask                => use_mask,
         use_prev_data           => use_prev_data,
         wr_en_dmem              => wr_en_dmem,
         wr_en_pcb               => wr_en_pcb,
         disable_sampling_n      => disable_sampling_n,
         keep_old_addr           => keep_old_addr,
         keep_old_data           => keep_old_data,
         latch_data_from_bus     => latch_data_from_bus,
         latch_data_from_core    => latch_data_from_core,
         masked_addr             => masked_addr,
         not_keep_old_addr       => not_keep_old_addr,
         not_keep_old_data       => not_keep_old_data,
         not_latch_data_from_bus => not_latch_data_from_bus,
         read_mem_q              => read_mem_q,
         read_pcb_q              => read_pcb_q,
         write_mem_q             => write_mem_q,
         write_pcb_q             => write_pcb_q
      );
   I8 : r32b_we
      PORT MAP (
         d     => data_in,
         clk   => clk,
         en    => latch_data_from_core,
         rst_x => rst_n,
         q     => q
      );
   I11 : r32b_we
      PORT MAP (
         d     => data_qz,
         clk   => clk,
         en    => disable_sampling_n,
         rst_x => rst_n,
         q     => q1
      );
   I15 : r32b_we
      PORT MAP (
         d     => out_z,
         clk   => clk,
         en    => pull_high,
         rst_x => gated_reset_n,
         q     => mem_data_q_internal
      );
   I17 : r32b_we
      PORT MAP (
         d     => mem_data_q_internal,
         clk   => clk,
         en    => pull_high,
         rst_x => gated_reset_n,
         q     => boot_address
      );
   I7 : rg_we
      GENERIC MAP (
         width_in  => 32,
         width_out => dbus_abits_c
      )
      PORT MAP (
         clk   => clk,
         d     => masked_addr(dbus_abits_c-1 DOWNTO 0),
         en    => latch_data_from_core,
         rst_n => rst_n,
         q     => q3
      );
   I9 : rg_we
      GENERIC MAP (
         width_in  => dbus_abits_c,
         width_out => dbus_abits_c
      )
      PORT MAP (
         clk   => clk,
         d     => addr_qz,
         en    => pull_high,
         rst_n => rst_n,
         q     => q2
      );
   I0 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => q,
         enable => not_keep_old_data,
         out_z  => data_qz
      );
   I1 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => q1,
         enable => keep_old_data,
         out_z  => data_qz
      );
   I2 : tri_state_32bit
      GENERIC MAP (
         width => dbus_abits_c
      )
      PORT MAP (
         in_z   => q2,
         enable => keep_old_addr,
         out_z  => addr_qz
      );
   I3 : tri_state_32bit
      GENERIC MAP (
         width => dbus_abits_c
      )
      PORT MAP (
         in_z   => q3,
         enable => not_keep_old_addr,
         out_z  => addr_qz
      );
   I5 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => data_qz,
         enable => latch_data_from_bus,
         out_z  => out_z
      );
   I6 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => mem_data_q_internal,
         enable => not_latch_data_from_bus,
         out_z  => out_z
      );

   -- Implicit buffered output assignments
   mem_data_q <= mem_data_q_internal;

END struct;
