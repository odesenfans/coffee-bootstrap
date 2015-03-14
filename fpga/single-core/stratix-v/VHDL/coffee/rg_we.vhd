------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:19 01/03/06
-- File : rg_we.vhd
-- Design : rg_we
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY rg_we IS
   GENERIC( 
      width_in  : integer := 32;
      width_out : integer := 32
   );
   PORT( 
      clk   : IN     std_logic;
      d     : IN     std_logic_vector (width_in-1 DOWNTO 0);
      en    : IN     std_logic;
      rst_n : IN     std_logic;
      q     : OUT    std_logic_vector (width_out-1 DOWNTO 0)
   );

-- Declarations

END rg_we ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 17:42:34 01/18/05
-- File : rg_we.vhd
-- Design : rg_we
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
architecture rg_we_arch of rg_we is
begin
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			q <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				q(width_out-1 downto 0) <= d(width_out-1 downto 0);
			end if;
		end if;
	end process;
end rg_we_arch;
