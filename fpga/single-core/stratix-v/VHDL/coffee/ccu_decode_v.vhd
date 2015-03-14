------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:24 01/03/06
-- File : ccu_decode_v.vhd
-- Design : ccu_decode_v
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ccu_decode_v IS
   PORT( 
      clk        : IN     std_logic;
      enable     : IN     std_logic;
      mem_load   : IN     std_logic;
      rst_x      : IN     std_logic;
      sel_data5p : OUT    std_logic
   );

-- Declarations

END ccu_decode_v ;
architecture ccu_decode_v_arch of ccu_decode_v is
begin
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			sel_data5p <= '0';
		elsif clk'event and clk = '1' then
			if enable = '1' then
				sel_data5p <= mem_load;
			end if;
		end if;
	end process;
end ccu_decode_v_arch;

