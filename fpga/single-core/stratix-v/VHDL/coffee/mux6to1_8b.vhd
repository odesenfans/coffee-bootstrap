------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : mux6to1_8b.vhd
-- Design : mux6to1_8b
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux6to1_8b IS
   PORT( 
      d0  : IN     std_logic_vector (7 DOWNTO 0);
      d1  : IN     std_logic_vector (7 DOWNTO 0);
      d2  : IN     std_logic_vector (7 DOWNTO 0);
      d3  : IN     std_logic_vector (7 DOWNTO 0);
      d4  : IN     std_logic_vector (7 DOWNTO 0);
      d5  : IN     std_logic_vector (7 DOWNTO 0);
      sel : IN     std_logic_vector (2 DOWNTO 0);
      o   : OUT    std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END mux6to1_8b ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:21:27 09/20/04
-- File : mux6to1_8b.vhd
-- Design : mux6to1_8b
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
architecture mux6to1_8b_arch of mux6to1_8b is
begin
	process(d0, d1, d2, d3, d4, d5, sel)
	begin
		case sel is
		when "000" => 
			o <= d0;
		when "001" => 
			o <= d1;
		when "010" => 
			o <= d2;
		when "011" => 
			o <= d3;
		when "100" => 
			o <= d4;
		when "101" => 
			o <= d5;
		when others =>
			o <= d0;
		end case;
	end process;

end mux6to1_8b_arch;
