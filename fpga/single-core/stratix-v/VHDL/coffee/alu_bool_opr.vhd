------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : alu_bool_opr.vhd
-- Design : alu_bool_opr
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY alu_bool_opr IS
   PORT( 
      opa    : IN     std_logic_vector (31 DOWNTO 0);
      opb    : IN     std_logic_vector (31 DOWNTO 0);
      oper   : IN     std_logic_vector (1 DOWNTO 0);
      result : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END alu_bool_opr ;

architecture alu_bool_opr_arch of alu_bool_opr is
begin
    process(opa, opb, oper)
    begin
        case oper is
	    when alu_bo_and =>	-- and
	        result <= opa and opb;
	    when alu_bo_not =>	-- not
			result <= not(opa);
	    when alu_bo_or =>	-- or
	        result <= opa or opb;
	    when alu_bo_xor =>	-- xor
			result <= opa xor opb;
	    when others =>	-- just for simulation
			result <= (others => '1');
	    end case;
    end process;
end alu_bool_opr_arch;
