------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:21 01/03/06
-- File : core_tmr.vhd
-- Design : core_tmr
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_tmr IS
   PORT( 
      clk         : IN     std_logic;
      rst_x       : IN     std_logic;
      tmr_cnt_in  : IN     std_logic_vector (31 DOWNTO 0);
      tmr_conf    : IN     std_logic_vector (15 DOWNTO 0);
      tmr_max_cnt : IN     std_logic_vector (31 DOWNTO 0);
      tmr_cnt_out : OUT    std_logic_vector (31 DOWNTO 0);
      tmr_int     : OUT    std_logic_vector (7 DOWNTO 0);
      wdog_rst_x  : OUT    std_logic
   );

-- Declarations

END core_tmr ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:21 01/03/06
-- File : core_tmr.vhd
-- Design : core_tmr
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;





ARCHITECTURE struct OF core_tmr IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL cont_mode  : std_logic;
   SIGNAL divisor    : std_logic_vector(7 DOWNTO 0);
   SIGNAL enable     : std_logic;
   SIGNAL increment  : std_logic;
   SIGNAL terminated : std_logic;


   -- Component Declarations
   COMPONENT tmr_control
   PORT (
      clk        : IN     std_logic ;
      rst_x      : IN     std_logic ;
      terminated : IN     std_logic ;
      tmr_conf   : IN     std_logic_vector (15 DOWNTO 0);
      cont_mode  : OUT    std_logic ;
      divisor    : OUT    std_logic_vector (7 DOWNTO 0);
      enable     : OUT    std_logic ;
      tmr_int    : OUT    std_logic_vector (7 DOWNTO 0);
      wdog_rst_x : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT tmr_counter
   PORT (
      cont_mode   : IN     std_logic ;
      enable      : IN     std_logic ;
      increment   : IN     std_logic ;
      tmr_cnt_in  : IN     std_logic_vector (31 DOWNTO 0);
      tmr_max_cnt : IN     std_logic_vector (31 DOWNTO 0);
      terminated  : OUT    std_logic ;
      tmr_cnt_out : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT tmr_divider
   PORT (
      clk       : IN     std_logic ;
      divisor   : IN     std_logic_vector (7 DOWNTO 0);
      enable    : IN     std_logic ;
      rst_x     : IN     std_logic ;
      increment : OUT    std_logic 
   );
   END COMPONENT;


BEGIN
   -- Instance port mappings.
   I0 : tmr_control
      PORT MAP (
         clk        => clk,
         rst_x      => rst_x,
         terminated => terminated,
         tmr_conf   => tmr_conf,
         cont_mode  => cont_mode,
         divisor    => divisor,
         enable     => enable,
         tmr_int    => tmr_int,
         wdog_rst_x => wdog_rst_x
      );
   I2 : tmr_counter
      PORT MAP (
         cont_mode   => cont_mode,
         enable      => enable,
         increment   => increment,
         tmr_cnt_in  => tmr_cnt_in,
         tmr_max_cnt => tmr_max_cnt,
         terminated  => terminated,
         tmr_cnt_out => tmr_cnt_out
      );
   I1 : tmr_divider
      PORT MAP (
         clk       => clk,
         divisor   => divisor,
         enable    => enable,
         rst_x     => rst_x,
         increment => increment
      );

END struct;
