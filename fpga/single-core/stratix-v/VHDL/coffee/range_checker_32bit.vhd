------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : range_checker_32bit.vhd
-- Design : range_checker_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY range_checker_32bit IS
   PORT( 
      value     : IN     std_logic_vector (31 DOWNTO 0);
      hi_bound  : IN     std_logic_vector (31 DOWNTO 0);
      low_bound : IN     std_logic_vector (31 DOWNTO 0);
      inside    : OUT    std_logic
   );

-- Declarations

END range_checker_32bit ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 22:17:23 06/10/05
-- File : range_checker_32bit.vhd
-- Design : range_checker_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
architecture range_checker_32bit_opt of range_checker_32bit is
begin
	inside <= '1' when value >= low_bound and value <= hi_bound else '0';
end range_checker_32bit_opt;

