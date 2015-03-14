------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : r3b_we.vhd
-- Design : r3b_we
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY r3b_we IS
   PORT( 
      d     : IN     std_logic_vector (2 DOWNTO 0);
      clk   : IN     std_logic;
      en    : IN     std_logic;
      q     : OUT    std_logic_vector (2 DOWNTO 0);
      rst_x : IN     std_logic
   );

-- Declarations

END r3b_we ;

architecture r3b_we_arch of r3b_we is
begin
	process(clk, rst_x)
	begin
	    if rst_x = '0' then
			q <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				q <= d;
			end if;
		end if;
	end process;
end r3b_we_arch;
