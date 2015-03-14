------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : mux2to1_3b.vhd
-- Design : mux2to1_3b
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux2to1_3b IS
   PORT( 
      d0 : IN     std_logic_vector (2 DOWNTO 0);
      d1 : IN     std_logic_vector (2 DOWNTO 0);
      o  : OUT    std_logic_vector (2 DOWNTO 0);
      s  : IN     std_logic
   );

-- Declarations

END mux2to1_3b ;

architecture mux2to1_3b_arch of mux2to1_3b is
begin
 	process(s, d0, d1)
		begin
			if s = '0' then
				o <= d0;
			else
				o <= d1;
			end if;
	 end process;
end mux2to1_3b_arch;
