------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 20:25:26 01/11/06
-- File : tristdrv.vhd
-- Design : tristdrv
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee_core_conf;
USE coffee_core_conf.core_conf_pkg.ALL;
USE ieee.std_logic_arith.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tristdrv IS
   PORT( 
	   -- changed from word_width to 31 by guoqing
      non_tristate_out   : IN     std_logic_vector (31 DOWNTO 0);
      tristate_bus_read    : IN     std_logic;
		-- changed from word_width to 31 by guoqing
      non_tristate_in    : OUT    std_logic_vector (31 DOWNTO 0);
      tristate_bus_data_z : INOUT  std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END tristdrv ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 20:11:29 01/11/06
-- File : tristdrv.vhd
-- Design : tristdrv
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------


architecture tristdrv_arch of tristdrv is
begin
	process(tristate_bus_read, non_tristate_out)
	begin
		if tristate_bus_read = '1' then
			tristate_bus_data_z <= non_tristate_out;
		else
			tristate_bus_data_z <= (others => 'Z');
		end if;
	end process;

	non_tristate_in <= tristate_bus_data_z;

end tristdrv_arch;
