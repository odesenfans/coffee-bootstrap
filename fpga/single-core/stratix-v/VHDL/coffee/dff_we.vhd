------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:11 01/03/06
-- File : dff_we.vhd
-- Design : dff_we
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY dff_we IS
   PORT( 
      d     : IN     std_logic;
      clk   : IN     std_logic;
      en    : IN     std_logic;
      q     : OUT    std_logic;
      rst_x : IN     std_logic
   );

-- Declarations

END dff_we ;

architecture dff_we_arch of dff_we is
begin
	process(clk, en, rst_x)
	begin
	    if rst_x = '0' then
			q <= '0';
		elsif clk'event and clk = '1' then
			if en = '1' then
				q <= d;
			end if;
		end if;
	end process;
end dff_we_arch;
