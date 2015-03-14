------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : core_addr_chk_usr.vhd
-- Design : core_addr_chk_usr
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_addr_chk_usr IS
   PORT( 
      enable_check  : IN     std_logic;                       -- enables checking
      start_addr    : IN     std_logic_vector (31 DOWNTO 0);  -- -- Begining of the protected address space
      end_addr      : IN     std_logic_vector (31 DOWNTO 0);  -- -- End of the protected...
      accessed_addr : IN     std_logic_vector (31 DOWNTO 0);  -- -- Address to be checked
      addr_viol     : OUT    std_logic;
      protect_mode  : IN     std_logic
   );

-- Declarations

END core_addr_chk_usr ;

architecture core_addr_chk_usr_arch of core_addr_chk_usr is

	signal in_range : std_logic;

	component range_checker_32bit
	PORT( 
		value     : IN     std_logic_vector (31 DOWNTO 0);    
		hi_bound  : IN     std_logic_vector (31 DOWNTO 0);    
		low_bound : IN     std_logic_vector (31 DOWNTO 0);    
		inside    : OUT    std_logic                          
	);
	end component;

begin
	-- Address checking might be on critical path: Address has to be checked
	-- and control has to have time to react to invalid address inside one
	-- clock cycle.
	-- Address violation condition is
	-- start_addr < accessed_addr < end_addr

    comparator : range_checker_32bit
	port map(
		value     => accessed_addr,
		hi_bound  => end_addr,
		low_bound => start_addr,
		inside    => in_range
	);

	addr_viol <= (in_range and protect_mode and enable_check) or 
	             (not in_range and not protect_mode and enable_check);

end core_addr_chk_usr_arch;


