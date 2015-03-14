------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:14 01/03/06
-- File : half_adder.vhd
-- Design : half_adder
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY half_adder IS
   PORT( 
      a : IN     std_logic;
      b : IN     std_logic;
      s : OUT    std_logic;
      c : OUT    std_logic
   );

-- Declarations

END half_adder ;

architecture half_adder_arch of half_adder is
begin
 	s <= a xor b;
	c <= a and b;
end half_adder_arch;
