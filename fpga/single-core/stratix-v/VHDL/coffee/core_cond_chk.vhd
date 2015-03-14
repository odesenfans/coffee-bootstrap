------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:19 01/03/06
-- File : core_cond_chk.vhd
-- Design : core_cond_chk
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY core_cond_chk IS
   PORT( 
      cond    : IN     std_logic_vector (2 DOWNTO 0);
      cex     : IN     std_logic;                      -- enables condition check
      znc     : IN     std_logic_vector (2 DOWNTO 0);
      execute : OUT    std_logic;
      opcode  : IN     std_logic_vector (5 DOWNTO 0)
   );

-- Declarations

END core_cond_chk ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 18:21:25 06/10/05
-- File : core_cond_chk.vhd
-- Design : core_cond_chk
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned.CONV_INTEGER;

architecture core_cond_chk_opt of core_cond_chk is

    signal c, z, n         : std_logic;
    signal condition       : std_logic_vector(7 downto 0);
	signal cond_code       : std_logic_vector(2 downto 0);
    signal ok_to_execute   : std_logic;
	signal is_cop          : std_logic;

begin

    z <= znc(2);
    n <= znc(1);
    c <= znc(0);

	-- Interpreting flags
    condition(0) <= c;                   -- carry
    condition(1) <= z or not(n);         -- equal or greater than
    condition(2) <= z or n;              -- equal or less than                                           
    condition(3) <= z;                   -- equal
    condition(4) <= not(z) and not(n);   -- greater than
    condition(5) <= n;                   -- less than
    condition(6) <= not(z);              -- not equal
    condition(7) <= not(c);              -- no carry

	-- extracting condition code from instruction word.
	-- cop -instruction does not have conditional execution flag =>
	-- Must be dealt with separately.
	process(opcode, cond)
	begin
		-- branches: condition code inside opcode
		if opcode(5 downto 3) = "100" then
			cond_code <= opcode(2 downto 0);
		else
			cond_code <= cond; -- directly from input
		end if;
		if opcode = cop_opc then
			is_cop <= '1';
		else
			is_cop <= '0';
		end if;
	end process;

	ok_to_execute <= condition(CONV_INTEGER(cond_code));
		
    -- instruction discarded if execution condition is false.
	-- cop -instruction does not have a valid cex -bit.
    execute <= ok_to_execute or not cex or is_cop;

end core_cond_chk_opt;

