------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : range_checker_8bit.vhd
-- Design : range_checker_8bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY range_checker_8bit IS
   PORT( 
      value     : IN     std_logic_vector (7 DOWNTO 0);
      hi_bound  : IN     std_logic_vector (7 DOWNTO 0);
      low_bound : IN     std_logic_vector (7 DOWNTO 0);
      inside    : OUT    std_logic
   );

-- Declarations

END range_checker_8bit ;
library coffee;

architecture range_checker_8bit_arch of range_checker_8bit is

	component comparator_4bit
	PORT( 
		a       : IN     std_logic_vector (3 DOWNTO 0);    
		b       : IN     std_logic_vector (3 DOWNTO 0);    
		equal   : OUT    std_logic;                         
		greater : OUT    std_logic --(a > b)
	);
	end component;

	signal eq_lo0, eq_lo1, eq_hi0, eq_hi1 : std_logic;
	signal grt_lo0, grt_lo1, blw_hi0, blw_hi1 : std_logic;
	signal above_bttm, below_top   : std_logic;
	signal equals_bttm, equals_top : std_logic;

begin

	-- greater or equal than low bound, bits 3 downto 0
	lo_comparator0 : comparator_4bit port map
	(
		a       => value(3 downto 0),
		b       => low_bound(3 downto 0),
		equal   => eq_lo0,
		greater => grt_lo0
	);
	-- greater or equal than low bound, bits 7 downto 4
	lo_comparator1 : comparator_4bit port map
	(
		a       => value(7 downto 4),
		b       => low_bound(7 downto 4),
		equal   => eq_lo1,
		greater => grt_lo1
	);

	-- below or equal to high bound, bits 3 downto 0
	hi_comparator0 : comparator_4bit port map
	(
		a       => hi_bound(3 downto 0),
		b       => value(3 downto 0),
		equal   => eq_hi0,
		greater => blw_hi0
	);

	-- below or equal to high bound, bits 7 downto 4
	hi_comparator1 : comparator_4bit port map
	(
		a       => hi_bound(7 downto 4),
		b       => value(7 downto 4),
		equal   => eq_hi1,
		greater => blw_hi1
	);

	-- combining 4 bit comparison
	equals_top  <= eq_hi0 and eq_hi1;

	equals_bttm <= eq_lo0 and eq_lo1;

	below_top   <= blw_hi1 or (eq_hi1 and blw_hi0);

	above_bttm  <= grt_lo1 or (eq_lo1 and grt_lo0);

	-- Finally putting it all together...
	inside <= (equals_top or equals_bttm or (below_top and above_bttm));

end range_checker_8bit_arch;

