------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : adder_32bit.vhd
-- Design : adder_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY adder_32bit IS
   PORT( 
      cin  : IN     std_logic;
      opa  : IN     std_logic_vector (31 DOWNTO 0);
      opb  : IN     std_logic_vector (31 DOWNTO 0);
      cout : OUT    std_logic;
      sum  : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END adder_32bit ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:11:54 06/10/05
-- File : adder_32bit.vhd
-- Design : adder_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";

architecture adder_32bit_opt of adder_32bit is
	signal sum_s : std_logic_vector(32 downto 0);
begin
	sum_s       <= ('0' & opa) + ('0' & opb) + cin;
	cout        <= sum_s(32);
	sum         <= sum_s(31 downto 0);
end adder_32bit_opt;
