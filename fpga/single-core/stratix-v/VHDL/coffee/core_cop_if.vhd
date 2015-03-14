------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:11 01/03/06
-- File : core_cop_if.vhd
-- Design : core_cop_if
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_cop_if IS
   PORT( 
      clk        : IN     std_logic;
      cop_indx   : IN     std_logic_vector (1 DOWNTO 0);
      data_in    : IN     std_logic_vector (31 DOWNTO 0);
      enable     : IN     std_logic;
      flush      : IN     std_logic;
      rd_cop     : IN     std_logic;
      reg_indx   : IN     std_logic_vector (4 DOWNTO 0);
      rst_x      : IN     std_logic;
      wr_cop     : IN     std_logic;
      cop_id     : OUT    std_logic_vector (1 DOWNTO 0);
      cop_rd     : OUT    std_logic;
      cop_rgi    : OUT    std_logic_vector (4 DOWNTO 0);
      cop_wr     : OUT    std_logic;
      data_out   : OUT    std_logic_vector (31 DOWNTO 0);
      cop_bus_qz : INOUT  std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core_cop_if ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:11 01/03/06
-- File : core_cop_if.vhd
-- Design : core_cop_if
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------


ARCHITECTURE struct OF core_cop_if IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL cop_indx_q              : std_logic_vector(1 DOWNTO 0);
   SIGNAL keep_old_data           : std_logic;
   SIGNAL latch_data_from_bus     : std_logic;
   SIGNAL latch_data_from_core    : std_logic;
   SIGNAL not_keep_old_data       : std_logic;
   SIGNAL not_latch_data_from_bus : std_logic;
   SIGNAL old_data_out            : std_logic_vector(31 DOWNTO 0);
   SIGNAL out_z                   : std_logic_vector(31 DOWNTO 0);
   SIGNAL pull_high               : std_logic;
   SIGNAL quuuu                   : std_logic_vector(31 DOWNTO 0);
   SIGNAL rd_cop_q                : std_logic;
   SIGNAL reg_indx_q              : std_logic_vector(4 DOWNTO 0);
   SIGNAL wr_cop_q                : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL data_out_internal : std_logic_vector (31 DOWNTO 0);


   -- Component Declarations
   COMPONENT cop_if_cntrl
   PORT (
      clk                     : IN     std_logic ;
      cop_indx                : IN     std_logic_vector (1 DOWNTO 0);
      enable                  : IN     std_logic ;
      flush                   : IN     std_logic ;
      rd_cop                  : IN     std_logic ;
      reg_indx                : IN     std_logic_vector (4 DOWNTO 0);
      rst_x                   : IN     std_logic ;
      wr_cop                  : IN     std_logic ;
      cop_indx_q              : OUT    std_logic_vector (1 DOWNTO 0);
      keep_old_data           : OUT    std_logic ;
      latch_data_from_bus     : OUT    std_logic ;
      latch_data_from_core    : OUT    std_logic ;
      not_keep_old_data       : OUT    std_logic ;
      not_latch_data_from_bus : OUT    std_logic ;
      rd_cop_q                : OUT    std_logic ;
      reg_indx_q              : OUT    std_logic_vector (4 DOWNTO 0);
      wr_cop_q                : OUT    std_logic 
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
   cop_wr <= wr_cop_q;
   cop_rd <= rd_cop_q;
   cop_id <= cop_indx_q;
   cop_rgi <= reg_indx_q;

   -- HDL Embedded Text Block 2 eb2
   pull_high <= '1';

   -- Instance port mappings.
   I12 : cop_if_cntrl
      PORT MAP (
         clk                     => clk,
         cop_indx                => cop_indx,
         enable                  => enable,
         flush                   => flush,
         rd_cop                  => rd_cop,
         reg_indx                => reg_indx,
         rst_x                   => rst_x,
         wr_cop                  => wr_cop,
         cop_indx_q              => cop_indx_q,
         keep_old_data           => keep_old_data,
         latch_data_from_bus     => latch_data_from_bus,
         latch_data_from_core    => latch_data_from_core,
         not_keep_old_data       => not_keep_old_data,
         not_latch_data_from_bus => not_latch_data_from_bus,
         rd_cop_q                => rd_cop_q,
         reg_indx_q              => reg_indx_q,
         wr_cop_q                => wr_cop_q
      );
   I10 : r32b_we
      PORT MAP (
         d     => data_in,
         clk   => clk,
         en    => latch_data_from_core,
         rst_x => rst_x,
         q     => quuuu
      );
   I16 : r32b_we
      PORT MAP (
         d     => cop_bus_qz,
         clk   => clk,
         en    => pull_high,
         rst_x => rst_x,
         q     => old_data_out
      );
   I11 : r32b_we
      PORT MAP (
         d     => out_z,
         clk   => clk,
         en    => pull_high,
         rst_x => rst_x,
         q     => data_out_internal
      );
   I3 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => quuuu,
         enable => not_keep_old_data,
         out_z  => cop_bus_qz
      );
   I4 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => old_data_out,
         enable => keep_old_data,
         out_z  => cop_bus_qz
      );
   I8 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => data_out_internal,
         enable => not_latch_data_from_bus,
         out_z  => out_z
      );
   I9 : tri_state_32bit
      GENERIC MAP (
         width => 32
      )
      PORT MAP (
         in_z   => cop_bus_qz,
         enable => latch_data_from_bus,
         out_z  => out_z
      );

   -- Implicit buffered output assignments
   data_out <= data_out_internal;

END struct;
