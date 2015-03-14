------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:21 01/03/06
-- File : core_iaddr_chk.vhd
-- Design : core_iaddr_chk
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_iaddr_chk IS
   PORT( 
      addr_ovfl             : IN     std_logic;
      addr_viol             : IN     std_logic;
      clk                   : IN     std_logic;
      en_stage              : IN     std_logic_vector (5 DOWNTO 0);
      flush                 : IN     std_logic_vector (3 DOWNTO 0);
      miss_aligned_addr     : IN     std_logic;
      rst_x                 : IN     std_logic;
      sel_pc                : IN     std_logic_vector (2 DOWNTO 0);
      write_pc              : IN     std_logic;
      illegal_jump_q        : OUT    std_logic;
      inst_addr_violation_q : OUT    std_logic;
      jump_addr_overflow_q  : OUT    std_logic;
      miss_aligned_iaddr_q  : OUT    std_logic;
      miss_aligned_jump_q   : OUT    std_logic
   );

-- Declarations

END core_iaddr_chk ;
architecture core_iaddr_chk_arch of core_iaddr_chk is
	signal jumped, rel_jumped : std_logic;
	signal inst_addr_violation_s : std_logic;
	signal miss_aligned_iaddr_s  : std_logic;

begin
	-- saving the source of address. Each source could be
	-- handled separately, but what's the benefit?
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			jumped    <= '0';
			rel_jumped <= '0';
		elsif clk'event and clk = '1' then
			if write_pc = '1' then
				-- absolute and PC relative jumps and scall
				if sel_pc = "001" or sel_pc = "010" or sel_pc = "101" then
					jumped <= '1';
				else
					jumped <= '0';
				end if;
				if sel_pc = "001"  then
					rel_jumped <= '1';
				else
					rel_jumped <= '0';
				end if;
			end if;
		end if;
	end process;

	process(clk, rst_x)
	begin
		if rst_x = '0' then
			illegal_jump_q        <= '0';
			jump_addr_overflow_q  <= '0';
			miss_aligned_jump_q   <= '0';
			inst_addr_violation_s <= '0';
			miss_aligned_iaddr_s  <= '0';
		elsif clk'event and clk = '1' then
			if en_stage(2) = '1' then
				illegal_jump_q       <= jumped and addr_viol and not flush(2);
				jump_addr_overflow_q <= rel_jumped and addr_ovfl and not flush(2);
				miss_aligned_jump_q  <= jumped and miss_aligned_addr and not flush(2);
			end if;
			if en_stage(1) = '1' then
				inst_addr_violation_s <= not jumped and addr_viol and not inst_addr_violation_s;
				miss_aligned_iaddr_s  <= not jumped and miss_aligned_addr and not miss_aligned_iaddr_s;
			end if;
		end if;
	end process;

	inst_addr_violation_q <= inst_addr_violation_s;
	miss_aligned_iaddr_q  <= miss_aligned_iaddr_s;
	
end core_iaddr_chk_arch;









