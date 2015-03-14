------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:11 01/03/06
-- File : r32b_we.vhd
-- Design : r32b_we
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY r32b_we IS
   PORT( 
      d     : IN     std_logic_vector (31 DOWNTO 0);
      clk   : IN     std_logic;
      en    : IN     std_logic;
      rst_x : IN     std_logic;
      q     : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END r32b_we ;

architecture r32b_we_arch of r32b_we is
begin
	process(clk,rst_x)
	begin
		if rst_x = '0' then
			q <= (others => '0');           
	elsif clk'event and clk = '1' then
		if en = '1' then
			q <= d;
		end if;
	end if;
end process;
end r32b_we_arch;

