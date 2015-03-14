------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : inth_selector.vhd
-- Design : inth_selector
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY inth_selector IS
   PORT( 
      clk         : IN     std_logic;
      ext_handler : IN     std_logic;
      int_base    : IN     array_12x32_stdl;
      int_mode_il : IN     std_logic_vector (11 DOWNTO 0);
      int_mode_um : IN     std_logic_vector (11 DOWNTO 0);
      int_n_q     : IN     std_logic_vector (11 DOWNTO 0);
      internal    : IN     std_logic_vector (7 DOWNTO 0);
      offset_l    : IN     std_logic_vector (7 DOWNTO 0);
      read_offset : IN     std_logic_vector (7 DOWNTO 0);
      rst_x       : IN     std_logic;
      int_addr    : OUT    std_logic_vector (31 DOWNTO 0);
      int_il      : OUT    std_logic;
      int_rs_rd   : OUT    std_logic;
      int_rs_wr   : OUT    std_logic;
      int_um      : OUT    std_logic
   );

-- Declarations

END inth_selector ;
architecture inth_selector_arch of inth_selector is
	type reg_bank is array (0 to 7) of std_logic_vector(7 downto 0);

	signal offset     : reg_bank;
	signal use_offset : std_logic_vector(7 downto 0);

begin
	-- Saving offset according to new request (from sync)
	-- Note that multiple registers may be written simultaneously
	-- Offsets are used only with external interrupts.
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			offset     <= (others => (others => '0'));
			use_offset <= (others => '0');
		elsif clk'event and clk = '1' then
			for i in 0 to 7 loop

				if read_offset(i) = '1' then
					offset(i) <= offset_l;
				end if;

				if internal(i) = '1' or ext_handler = '0' then -- timer interrupt or offset disabled
					use_offset(i) <= '0';
				elsif read_offset(i) = '1' then -- use the offset...
					use_offset(i) <= '1';
				end if;

			end loop;
		end if;
	end process;

	-- not efficient nor elegant, but simple & straightforward
	process(int_base, int_n_q, offset, use_offset, int_mode_il, int_mode_um)
	begin
		case int_n_q is
		when "000000000001" => -- coprocessor 0
			int_addr  <= int_base(0);
			int_il    <= int_mode_il(0);
			int_rs_rd <= not(int_mode_um(0));
			int_rs_wr <= not(int_mode_um(0));
			int_um    <= int_mode_um(0);
		when "000000000010" => -- coprocessor 1
			int_addr  <= int_base(1);
			int_il    <= int_mode_il(1);
			int_rs_rd <= not(int_mode_um(1));
			int_rs_wr <= not(int_mode_um(1));
			int_um    <= int_mode_um(1);
		when "000000000100" => -- coprocessor 2
			int_addr <= int_base(2);
			int_il    <= int_mode_il(2);
			int_rs_rd <= not(int_mode_um(2));
			int_rs_wr <= not(int_mode_um(2));
			int_um    <= int_mode_um(2);
		when "000000001000" => -- coprocessor 3
			int_addr  <= int_base(3);
			int_il    <= int_mode_il(3);
			int_rs_rd <= not(int_mode_um(3));
			int_rs_wr <= not(int_mode_um(3));
			int_um    <= int_mode_um(3);
		when "000000010000" => -- external interrupt 0
			if use_offset(0) = '1' then
				int_addr <= int_base(4)(31 downto 12) & offset(0) & "0000";
			else
				int_addr <= int_base(4);
			end if;
			int_il    <= int_mode_il(4);
			int_rs_rd <= not(int_mode_um(4));
			int_rs_wr <= not(int_mode_um(4));
			int_um    <= int_mode_um(4);
		when "000000100000" => -- external interrupt 1
			if use_offset(1) = '1' then
				int_addr <= int_base(5)(31 downto 12) & offset(1) & "0000";
			else
				int_addr <= int_base(5);
			end if;
			int_il    <= int_mode_il(5);
			int_rs_rd <= not(int_mode_um(5));
			int_rs_wr <= not(int_mode_um(5));
			int_um    <= int_mode_um(5);
		when "000001000000" => -- external interrupt 2
			if use_offset(2) = '1' then
				int_addr <= int_base(6)(31 downto 12) & offset(2) & "0000";
			else
				int_addr <= int_base(6);
			end if;
			int_il    <= int_mode_il(6);
			int_rs_rd <= not(int_mode_um(6));
			int_rs_wr <= not(int_mode_um(6));
			int_um    <= int_mode_um(6);
		when "000010000000" => -- external interrupt 3
			if use_offset(3) = '1' then
				int_addr <= int_base(7)(31 downto 12) & offset(3) & "0000";
			else
				int_addr <= int_base(7);
			end if;
			int_il    <= int_mode_il(7);
			int_rs_rd <= not(int_mode_um(7));
			int_rs_wr <= not(int_mode_um(7));
			int_um    <= int_mode_um(7);
		when "000100000000" => -- external interrupt 4
			if use_offset(4) = '1' then
				int_addr <= int_base(8)(31 downto 12) & offset(4) & "0000";
			else
				int_addr <= int_base(8);
			end if;
			int_il    <= int_mode_il(8);
			int_rs_rd <= not(int_mode_um(8));
			int_rs_wr <= not(int_mode_um(8));
			int_um    <= int_mode_um(8);
		when "001000000000" => -- external interrupt 5
			if use_offset(5) = '1' then
				int_addr <= int_base(9)(31 downto 12) & offset(5) & "0000";
			else
				int_addr <= int_base(9);
			end if;
			int_il    <= int_mode_il(9);
			int_rs_rd <= not(int_mode_um(9));
			int_rs_wr <= not(int_mode_um(9));
			int_um    <= int_mode_um(9);
		when "010000000000" => -- external interrupt 6
			if use_offset(6) = '1' then
				int_addr <= int_base(10)(31 downto 12) & offset(6) & "0000";
			else
				int_addr <= int_base(10);
			end if;
			int_il    <= int_mode_il(10);
			int_rs_rd <= not(int_mode_um(10));
			int_rs_wr <= not(int_mode_um(10));
			int_um    <= int_mode_um(10);
		when others =>         -- external interrupt 7
			if use_offset(7) = '1' then
				int_addr <= int_base(11)(31 downto 12) & offset(7) & "0000";
			else
				int_addr <= int_base(11);
			end if;
			int_il    <= int_mode_il(11);
			int_rs_rd <= not(int_mode_um(11));
			int_rs_wr <= not(int_mode_um(11));
			int_um    <= int_mode_um(11);
		end case;
	end process;

end inth_selector_arch;

