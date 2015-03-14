------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:26 01/03/06
-- File : incrementer_32bit_a.vhd
-- Design : incrementer_32bit_a
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY incrementer_32bit_a IS
   PORT( 
      data_in    : IN     std_logic_vector (31 DOWNTO 0);
      inc_amount : IN     std_logic;                       -- 0 : increment by two, 1: incr by four.
      data_out   : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END incrementer_32bit_a ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 22:40:37 06/10/05
-- File : incrementer_32bit_a.vhd
-- Design : incrementer_32bit_a
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";
architecture incrementer_32bit_a_opt of incrementer_32bit_a is
	signal value : std_logic_vector(31 downto 0);
begin
	value    <= data_in + 2 when inc_amount = '0' else data_in + 4;
	-- align
	data_out <= (value(31 downto 1) & '0') when inc_amount = '0' else
	            (value(31 downto 2) & "00");
end incrementer_32bit_a_opt;
