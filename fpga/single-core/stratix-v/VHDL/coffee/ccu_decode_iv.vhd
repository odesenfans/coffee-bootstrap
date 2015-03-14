------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:24 01/03/06
-- File : ccu_decode_iv.vhd
-- Design : ccu_decode_iv
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY ccu_decode_iv IS
   PORT( 
      ccb_access        : IN     std_logic;
      clk               : IN     std_logic;
      enable            : IN     std_logic;
      opcode            : IN     std_logic_vector (5 DOWNTO 0);
      rst_x             : IN     std_logic;
      mem_load          : OUT    std_logic;
      sel_data4p        : OUT    std_logic_vector (1 DOWNTO 0);
      sel_data_from_cop : OUT    std_logic
   );

-- Declarations

END ccu_decode_iv ;

architecture ccu_decode_iv_arch of ccu_decode_iv is
begin

	process(clk, rst_x)
	begin
		if rst_x = '0' then
			sel_data4p <= "00";
			mem_load   <= '0';
			sel_data_from_cop <= '0';
		elsif clk'event and clk = '1' then
			if enable = '1' then
				case opcode is
					when muli_opc =>
						sel_data4p <= "01";
					when muls_opc =>
						sel_data4p <= "01";
					when mulu_opc =>
						sel_data4p <= "01";
					when mulus_opc =>
						sel_data4p <= "01";
					when mulhi_opc =>
						sel_data4p <= "10";
					when ld_opc =>
						sel_data4p <= "11";
					when others =>
						sel_data4p <= "00";
				end case;
				if opcode = ld_opc then
					mem_load <= not ccb_access;
				else
					mem_load <= '0';
				end if;
				if opcode = movfc_opc then
					sel_data_from_cop <= '0';
				else
					sel_data_from_cop <= '1';
				end if;
			end if;
		end if;
	end process;

end ccu_decode_iv_arch;

