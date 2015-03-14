------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : core_addr_chk_pcb.vhd
-- Design : core_addr_chk_pcb
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_addr_chk_pcb IS
   PORT( 
      pcb_start     : IN     std_logic_vector (31 DOWNTO 0);  -- -- Comes from PCB base register
      ccb_access    : OUT    std_logic;                       -- -- Indicates an access to PCB
      accessed_addr : IN     std_logic_vector (31 DOWNTO 0);  -- -- Address to be compared
      reg_indx      : OUT    std_logic_vector (7 DOWNTO 0);
      pcb_end       : IN     std_logic_vector (31 DOWNTO 0);
      pcb_access    : OUT    std_logic;
      ccb_base      : IN     std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core_addr_chk_pcb ;

architecture core_addr_chk_pcb_arch of core_addr_chk_pcb is

	signal in_range          : std_logic;
	signal ccb_access_signal : std_logic;

	component range_checker_32bit
	PORT( 
		value     : IN     std_logic_vector (31 DOWNTO 0);    
		hi_bound  : IN     std_logic_vector (31 DOWNTO 0);    
		low_bound : IN     std_logic_vector (31 DOWNTO 0);    
		inside    : OUT    std_logic                          
	);
	end component;



begin
	-- PCB address bounds are compared against accessed address
	-- If in range, access is to internal or external PCB.
    comparator : range_checker_32bit
	port map(
		value     => accessed_addr,
		hi_bound  => pcb_end,
		low_bound => pcb_start,
		inside    => in_range
	);

	-- Memory access points to internal core control block if
	-- bits 31 downto 8 are the same in accessed_addr and ccb_start.
	-- This follows from alignment requirements of ccb_start.

	process(ccb_base, accessed_addr)
	begin
		if ccb_base(31 downto 8) = accessed_addr(31 downto 8) then
			ccb_access_signal <= '1';
		else
			ccb_access_signal <= '0';
		end if;
	end process;

	pcb_access <= in_range and not ccb_access_signal;
	reg_indx   <= accessed_addr(7 downto 0);
	ccb_access <= ccb_access_signal;

end core_addr_chk_pcb_arch;



