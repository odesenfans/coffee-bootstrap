------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:14 01/03/06
-- File : r16b_we.vhd
-- Design : r16b_we
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY r16b_we IS
   PORT( 
      d     : IN     std_logic_vector (15 DOWNTO 0);
      clk   : IN     std_logic;
      en    : IN     std_logic;
      q     : OUT    std_logic_vector (15 DOWNTO 0);
      rst_x : IN     std_logic
   );

-- Declarations

END r16b_we ;

architecture reg16_arch of r16b_we is
begin
    process(clk, en, rst_x)
    begin
        if rst_x = '0' then
            q <= (others => '0');
        elsif clk'event and clk = '1' then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;
end reg16_arch;
