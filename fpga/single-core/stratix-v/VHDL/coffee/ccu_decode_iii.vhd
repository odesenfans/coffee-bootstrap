------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:24 01/03/06
-- File : ccu_decode_iii.vhd
-- Design : ccu_decode_iii
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY ccu_decode_iii IS
   PORT( 
      clk                  : IN     std_logic;
      enable               : IN     std_logic;
      flush                : IN     std_logic;
      opcode_in            : IN     std_logic_vector (5 DOWNTO 0);
      rst_x                : IN     std_logic;
      user_mode            : IN     std_logic;
      check_data_addr_ovfl : OUT    std_logic;
      check_data_addr_usr  : OUT    std_logic;
      opcode_out           : OUT    std_logic_vector (5 DOWNTO 0);
      read_access          : OUT    std_logic;
      sel_data3p           : OUT    std_logic_vector (1 DOWNTO 0);
      write_access         : OUT    std_logic
   );

-- Declarations

END ccu_decode_iii ;

architecture ccu_decode_iii_arch of ccu_decode_iii is

	signal is_load, is_store : std_logic;
	signal sel_data3p_a      : std_logic_vector(1 downto 0);

begin
	-- decoding part
	process(opcode_in)
	begin
	-- sel_data3p = "00" is reserved for custom instructions
		case opcode_in is
			when scon_opc =>
				sel_data3p_a <= "11";
			when muls_16_opc =>
				sel_data3p_a <= "10";
			when mulu_16_opc =>
				sel_data3p_a <= "10";
			when mulus_16_opc =>
				sel_data3p_a <= "10";
			when others =>
				sel_data3p_a <= "01";
		end case;
		if opcode_in = ld_opc then
			is_load <= '1';
		else
			is_load <= '0';
		end if;
		if opcode_in = st_opc then
			is_store <= '1';
		else
			is_store <= '0';
		end if;
	end process;

	-- synchronous part
	process(clk, rst_x)
	begin
		if rst_x = '0' then
				check_data_addr_ovfl <= '0';
				check_data_addr_usr  <= '0';
				sel_data3p           <= "00";
				opcode_out           <= nop_opc;
		elsif clk'event and clk = '1' then
			if enable = '1' then
				check_data_addr_ovfl <= (is_load or is_store) and not flush;
				check_data_addr_usr  <= (is_load or is_store) and user_mode
				                         and not flush;
				sel_data3p <= sel_data3p_a;

				if flush = '1' then
					opcode_out <= nop_opc;
				else
					opcode_out <= opcode_in;
				end if;

				read_access  <= is_load and not flush;
				write_access <= is_store and not flush;
				
			end if;
		end if;
	end process;

end ccu_decode_iii_arch;
