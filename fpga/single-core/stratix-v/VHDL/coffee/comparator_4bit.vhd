------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : comparator_4bit.vhd
-- Design : comparator_4bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY comparator_4bit IS
   PORT( 
      a       : IN     std_logic_vector (3 DOWNTO 0);
      b       : IN     std_logic_vector (3 DOWNTO 0);
      equal   : OUT    std_logic;
      greater : OUT    std_logic
   );

-- Declarations

END comparator_4bit ;
-- Tests if a is greater or equal to b
architecture comparator_4bit_arch of comparator_4bit is
	 signal grt : std_logic_vector(3 downto 0); -- bitwise greater than
	 signal eq  : std_logic_vector(3 downto 0); -- bitwise equality
begin
	-- bitwise comparison
	process(a, b)
	begin
		for i in 0 to 3 loop
			grt(i) <= a(i) and not(b(i));
			eq(i)  <= not(a(i) xor b(i));
		end loop;
	end process;

	-- chaining bitwise comparison results to 4 bit comparison
	greater <= grt(3) or (eq(3) and grt(2)) or (eq(3) and eq(2) and grt(1))
	           or (eq(3) and eq(2) and eq(1) and grt(0));
	equal   <= eq(3) and eq(2) and eq(1) and eq(0);

end comparator_4bit_arch;

