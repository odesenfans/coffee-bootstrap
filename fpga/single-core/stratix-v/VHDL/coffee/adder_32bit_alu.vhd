------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : adder_32bit_alu.vhd
-- Design : adder_32bit_alu
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY adder_32bit_alu IS
   PORT( 
      inv   : IN     std_logic;                       -- -- invert opb
      opa   : IN     std_logic_vector (31 DOWNTO 0);
      opb   : IN     std_logic_vector (31 DOWNTO 0);
      cout  : OUT    std_logic;
      sum   : OUT    std_logic_vector (31 DOWNTO 0);
      zflag : OUT    std_logic
   );

-- Declarations

END adder_32bit_alu ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 10:59:02 06/08/05
-- File : adder_32bit_alu.vhd
-- Design : adder_32bit_alu
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";

architecture adder_32bit_alu_arch of adder_32bit_alu is
	signal sum_s       : std_logic_vector(32 downto 0);
	signal operand_a_s : std_logic_vector(32 downto 0);
	signal operand_b_s : std_logic_vector(32 downto 0);
	signal invert_s    : std_logic_vector(31 downto 0);
	signal cin_s       : std_logic;
begin

	cin_s       <= inv;
	invert_s    <= (others => inv);
	operand_b_s <= '0' & (opb xor invert_s);
	operand_a_s <= '0' & opa;
	sum_s       <= operand_a_s + operand_b_s + cin_s;
	cout        <= sum_s(32);
	sum         <= sum_s(31 downto 0);

	-----------------------------------------------------------------------------
	-- Accelerated flag logic (evaluated directly from operands, not from result)
	-----------------------------------------------------------------------------
	-- Removed all of it to reduce size
	-----------------------------------------------------------------------------
	zflag <= '1' when sum_s(31 downto 0) = "00000000000000000000000000000000" else '0';

end adder_32bit_alu_arch;
