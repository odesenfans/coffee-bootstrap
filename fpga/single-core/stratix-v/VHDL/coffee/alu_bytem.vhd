------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : alu_bytem.vhd
-- Design : alu_bytem
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY alu_bytem IS
   PORT( 
      opa  : IN     std_logic_vector (31 DOWNTO 0);
      opb  : IN     std_logic_vector (15 DOWNTO 0);
      oper : IN     std_logic_vector (1 DOWNTO 0);
      rslt : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END alu_bytem ;

architecture alu_bytem_arch of alu_bytem is
begin
process(opa, opb, oper)
begin
    case oper is
    when alu_bm_exb =>	-- exb
        case opb(1 downto 0) is
	    when "00" => 	-- byte 0
	        rslt <= "000000000000000000000000" & opa(7 downto 0);
	    when "01" => 	-- byte 1
		    rslt <= "000000000000000000000000" & opa(15 downto 8);
	    when "10" => 	-- byte 2
	        rslt <= "000000000000000000000000" & opa(23 downto 16);
	    when "11" => 	-- byte 3
		    rslt <= "000000000000000000000000" & opa(31 downto 24);
	    when others =>	-- just for simulation
	        rslt <= (others => '1');
	    end case;
	when alu_bm_exh =>	-- exh
	    if opb(0) = '0' then	-- halfword 0
	        rslt <= "0000000000000000" & opa(15 downto 0);
	    else					-- halfword 1
		    rslt <= "0000000000000000" & opa(31 downto 16);
	    end if;
	when alu_bm_conb =>	-- conb
	    rslt <= "0000000000000000" & opa(7 downto 0) & opb(7 downto 0);
	when alu_bm_conh =>	-- conh
	    rslt <= opb(15 downto 0) & opa(15 downto 0);
	when others =>	-- just for simulation
	    rslt <= (others => '1');
    end case;
end process;		
end alu_bytem_arch;
