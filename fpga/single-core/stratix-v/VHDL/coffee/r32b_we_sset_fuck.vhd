------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:26 01/03/06
-- File : r32b_we_sset_fuck.vhd
-- Design : r32b_we_sset_fuck
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY r32b_we_sset_fuck IS
   PORT( 
      clk   : IN     std_logic;
      d     : IN     std_logic_vector (31 DOWNTO 0);
      rst_n : IN     std_logic;
      sset  : IN     std_logic;
      we    : IN     std_logic;
      q     : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END r32b_we_sset_fuck ;
library coffee;
use coffee.core_constants_pkg.nop_pattern_c;

-- Thanks s_y_n_o_p_s_y_s for great tools
architecture r32b_we_sset_arch of r32b_we_sset_fuck is
begin
	process(clk, rst_n)
	begin
		if (rst_n = '0') then
			q <= nop_pattern_c;
		elsif clk'event and clk = '1' then
			if (we = '1') then
				if (sset = '1') then
					q <= nop_pattern_c;
				else
					q <= d;
				end if;
			end if;
		end if;
	end process;
end r32b_we_sset_arch;
