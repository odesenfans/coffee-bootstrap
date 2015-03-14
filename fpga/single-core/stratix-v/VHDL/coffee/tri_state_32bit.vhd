------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:10 01/03/06
-- File : tri_state_32bit.vhd
-- Design : tri_state_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY tri_state_32bit IS
   GENERIC( 
      width : integer := 32
   );
   PORT( 
      in_z   : IN     std_logic_vector (width-1 DOWNTO 0);
      enable : IN     std_logic;
      out_z  : OUT    std_logic_vector (width-1 DOWNTO 0)
   );

-- Declarations

END tri_state_32bit ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:42:53 01/18/05
-- File : tri_state_32bit.vhd
-- Design : tri_state_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
architecture tri_state_generic_arch of tri_state_32bit is

begin

	process(enable,in_z)
	begin
		if enable = '1' then
			out_z <= in_z;
		else
			out_z <= (others => 'Z');
		end if;
	end process;

end tri_state_generic_arch;
