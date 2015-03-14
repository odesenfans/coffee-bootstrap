------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:19 01/03/06
-- File : mux3to1_32b.vhd
-- Design : mux3to1_32b
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux3to1_32b IS
   PORT( 
      d0 : IN     std_logic_vector (31 DOWNTO 0);
      d1 : IN     std_logic_vector (31 DOWNTO 0);
      d2 : IN     std_logic_vector (31 DOWNTO 0);
      o  : OUT    std_logic_vector (31 DOWNTO 0);
      s  : IN     std_logic_vector (1 DOWNTO 0)
   );

-- Declarations

END mux3to1_32b ;

architecture mux3to1_32b_arch of mux3to1_32b is
begin
	process(s, d0, d1, d2)
		begin
                  case s is
                    when "00" =>
                      o <= d0;
                    when "01" =>
                      o <= d1;
                    when "10" =>
                      o <= d2;
                     when others =>
                      o <= d2;
                  end case;
	 end process;
end mux3to1_32b_arch;
