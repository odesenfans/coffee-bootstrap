------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : core_inth.vhd
-- Design : core_inth
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY core_inth IS
   PORT( 
      ack           : IN     std_logic;                       -- CCU acknoledges a request just before service
      clk           : IN     std_logic;
      cop_exc       : IN     std_logic_vector (3 DOWNTO 0);   -- requests from coprocessors
      cop_int_pri   : IN     std_logic_vector (15 DOWNTO 0);  -- -- priorities for coprocessor interrupts
      done          : IN     std_logic;                       -- reti causes done to go high
      ext_handler   : IN     std_logic;                       -- high if external handler used
      ext_int_pri   : IN     std_logic_vector (31 DOWNTO 0);  -- -- priorities for external interrupts
      ext_interrupt : IN     std_logic_vector (7 DOWNTO 0);   -- -- active high signals from external sources
      int_base      : IN     array_12x32_stdl;                -- -- base addresses of a handler routines
      int_mode_il   : IN     std_logic_vector (11 DOWNTO 0);  -- --  what IL mode to switch into
      int_mode_um   : IN     std_logic_vector (11 DOWNTO 0);  -- --  what UM mode to switch into
      mask          : IN     std_logic_vector (11 DOWNTO 0);  -- -- Individual mask bits for each source.
      offset        : IN     std_logic_vector (7 DOWNTO 0);   -- this is scaled and added to base
      rst_x         : IN     std_logic;
      tmr_inta      : IN     std_logic_vector (7 DOWNTO 0);   -- -- timer interrupt a
      tmr_intb      : IN     std_logic_vector (7 DOWNTO 0);   -- -- timer interrupt b
      int_ack       : OUT    std_logic;
      int_addr      : OUT    std_logic_vector (31 DOWNTO 0);  -- -- entry address of an ISR
      int_done      : OUT    std_logic;
      int_pend      : OUT    std_logic_vector (11 DOWNTO 0);
      int_psr       : OUT    std_logic_vector (7 DOWNTO 0);
      int_serv      : OUT    std_logic_vector (11 DOWNTO 0);
      req_q         : OUT    std_logic                        -- request to CCU for service
   );

-- Declarations

END core_inth ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:23 01/03/06
-- File : core_inth.vhd
-- Design : core_inth
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ARCHITECTURE struct OF core_inth IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL cop_request    : std_logic_vector(3 DOWNTO 0);
   SIGNAL ext_request    : std_logic_vector(7 DOWNTO 0);
   SIGNAL int_il         : std_logic;
   SIGNAL int_n_q        : std_logic_vector(11 DOWNTO 0);
   SIGNAL int_rs_rd      : std_logic;
   SIGNAL int_rs_wr      : std_logic;
   SIGNAL int_um         : std_logic;
   SIGNAL intrnl_request : std_logic_vector(7 DOWNTO 0);
   SIGNAL read_offset    : std_logic_vector(7 DOWNTO 0);

   -- Implicit buffer signal declarations
   SIGNAL int_serv_internal : std_logic_vector (11 DOWNTO 0);
   SIGNAL int_pend_internal : std_logic_vector (11 DOWNTO 0);


   -- Component Declarations
   COMPONENT inth_pri_chk
   PORT (
      ack         : IN     std_logic ;
      clk         : IN     std_logic ;
      cop_int_pri : IN     std_logic_vector (15 DOWNTO 0);
      ext_int_pri : IN     std_logic_vector (31 DOWNTO 0);
      fixed_pri   : IN     std_logic ;
      int_mask    : IN     std_logic_vector (11 DOWNTO 0);
      int_pend    : IN     std_logic_vector (11 DOWNTO 0);
      int_serv    : IN     std_logic_vector (11 DOWNTO 0);
      rst_x       : IN     std_logic ;
      int_n_q     : OUT    std_logic_vector (11 DOWNTO 0);
      req_q       : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT inth_selector
   PORT (
      clk         : IN     std_logic ;
      ext_handler : IN     std_logic ;
      int_base    : IN     array_12x32_stdl ;
      int_mode_il : IN     std_logic_vector (11 DOWNTO 0);
      int_mode_um : IN     std_logic_vector (11 DOWNTO 0);
      int_n_q     : IN     std_logic_vector (11 DOWNTO 0);
      internal    : IN     std_logic_vector (7 DOWNTO 0);
      offset_l    : IN     std_logic_vector (7 DOWNTO 0);
      read_offset : IN     std_logic_vector (7 DOWNTO 0);
      rst_x       : IN     std_logic ;
      int_addr    : OUT    std_logic_vector (31 DOWNTO 0);
      int_il      : OUT    std_logic ;
      int_rs_rd   : OUT    std_logic ;
      int_rs_wr   : OUT    std_logic ;
      int_um      : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT inth_status
   PORT (
      ack            : IN     std_logic ;
      clk            : IN     std_logic ;
      cop_request    : IN     std_logic_vector (3 DOWNTO 0);
      done           : IN     std_logic ;
      ext_request    : IN     std_logic_vector (7 DOWNTO 0);
      int_n_q        : IN     std_logic_vector (11 DOWNTO 0);
      intrnl_request : IN     std_logic_vector (7 DOWNTO 0);
      rst_x          : IN     std_logic ;
      int_ack        : OUT    std_logic ;
      int_done       : OUT    std_logic ;
      int_pend       : OUT    std_logic_vector (11 DOWNTO 0);
      int_serv       : OUT    std_logic_vector (11 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT inth_sync
   PORT (
      clk            : IN     std_logic ;
      cop_exc        : IN     std_logic_vector (3 DOWNTO 0);
      ext_handler    : IN     std_logic ;
      ext_interrupt  : IN     std_logic_vector (7 DOWNTO 0);
      rst_n          : IN     std_logic ;
      tmr_inta       : IN     std_logic_vector (7 DOWNTO 0);
      tmr_intb       : IN     std_logic_vector (7 DOWNTO 0);
      cop_request    : OUT    std_logic_vector (3 DOWNTO 0);
      ext_request    : OUT    std_logic_vector (7 DOWNTO 0);
      intrnl_request : OUT    std_logic_vector (7 DOWNTO 0);
      read_offset    : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   int_psr <= "0000" & int_il & int_rs_wr & int_rs_rd & int_um;

   -- Instance port mappings.
   I1 : inth_pri_chk
      PORT MAP (
         ack         => ack,
         clk         => clk,
         cop_int_pri => cop_int_pri,
         ext_int_pri => ext_int_pri,
         fixed_pri   => ext_handler,
         int_mask    => mask,
         int_pend    => int_pend_internal,
         int_serv    => int_serv_internal,
         rst_x       => rst_x,
         int_n_q     => int_n_q,
         req_q       => req_q
      );
   I2 : inth_selector
      PORT MAP (
         clk         => clk,
         ext_handler => ext_handler,
         int_base    => int_base,
         int_mode_il => int_mode_il,
         int_mode_um => int_mode_um,
         int_n_q     => int_n_q,
         internal    => intrnl_request,
         offset_l    => offset,
         read_offset => read_offset,
         rst_x       => rst_x,
         int_addr    => int_addr,
         int_il      => int_il,
         int_rs_rd   => int_rs_rd,
         int_rs_wr   => int_rs_wr,
         int_um      => int_um
      );
   I0 : inth_status
      PORT MAP (
         ack            => ack,
         clk            => clk,
         cop_request    => cop_request,
         done           => done,
         ext_request    => ext_request,
         int_n_q        => int_n_q,
         intrnl_request => intrnl_request,
         rst_x          => rst_x,
         int_ack        => int_ack,
         int_done       => int_done,
         int_pend       => int_pend_internal,
         int_serv       => int_serv_internal
      );
   I4 : inth_sync
      PORT MAP (
         clk            => clk,
         cop_exc        => cop_exc,
         ext_handler    => ext_handler,
         ext_interrupt  => ext_interrupt,
         rst_n          => rst_x,
         tmr_inta       => tmr_inta,
         tmr_intb       => tmr_intb,
         cop_request    => cop_request,
         ext_request    => ext_request,
         intrnl_request => intrnl_request,
         read_offset    => read_offset
      );

   -- Implicit buffered output assignments
   int_serv <= int_serv_internal;
   int_pend <= int_pend_internal;

END struct;
