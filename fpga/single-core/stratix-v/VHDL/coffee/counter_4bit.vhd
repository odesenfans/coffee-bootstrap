------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:24 01/03/06
-- File : counter_4bit.vhd
-- Design : counter_4bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY counter_4bit IS
   GENERIC( 
      reset_value_g : integer := 0
   );
   PORT( 
      start_value : IN     std_logic_vector (3 DOWNTO 0);
      load        : IN     std_logic;
      zero        : OUT    std_logic;
      clk         : IN     std_logic;
      rst_n       : IN     std_logic;
      nonzero     : OUT    std_logic;
      down        : IN     std_logic
   );

-- Declarations

END counter_4bit ;
-- 4 bit UP/DOWN counter, halts when zero is reached
library ieee;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;

architecture counter_4bit_arch of counter_4bit is
	signal count_i : std_logic_vector(3 downto 0);
	signal clear_i : std_logic_vector(3 downto 0);
begin
	process(clk, rst_n)
		variable t : std_logic_vector(3 downto 0); -- toggle
		variable c : std_logic_vector(3 downto 0); -- count
		variable d : std_logic_vector(3 downto 0); -- direction
	begin
		if rst_n = '0' then
			count_i <= CONV_STD_LOGIC_VECTOR(reset_value_g, 4);
		elsif clk'event and clk = '1' then
			if load = '1' then
				count_i <= start_value;
			else
				-- Decrementing = counting zeros
				-- Incrementing = counting ones
				d := (others => down);
				c := count_i xor d;
				-- Evaluate toggle bits, t(i) = '1' => toggle c(i)
				-- LSB toggles always
				t(0) := '1';
				t(1) := c(0);
				t(2) := c(1) and c(0);
				t(3) := c(2) and c(1) and c(0);
				-- new count value, halt to zero
				count_i <= (count_i xor t) and not(clear_i);
			end if;				
		end if;
	end process;

	-- outputs and halt logic
	process(count_i)
	begin
		if (count_i = "0000") then
			clear_i <= "1111";
			zero    <= '1';
			nonzero <= '0';
		else
			clear_i   <= "0000";
			zero     <= '0';
			nonzero  <= '1';
		end if;
	end process;

end counter_4bit_arch;
