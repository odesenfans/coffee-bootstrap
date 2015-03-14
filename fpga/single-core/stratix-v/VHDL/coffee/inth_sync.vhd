------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : inth_sync.vhd
-- Design : inth_sync
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY inth_sync IS
   PORT( 
      clk            : IN     std_logic;
      cop_exc        : IN     std_logic_vector (3 DOWNTO 0);
      ext_handler    : IN     std_logic;
      ext_interrupt  : IN     std_logic_vector (7 DOWNTO 0);
      rst_n          : IN     std_logic;
      tmr_inta       : IN     std_logic_vector (7 DOWNTO 0);
      tmr_intb       : IN     std_logic_vector (7 DOWNTO 0);
      cop_request    : OUT    std_logic_vector (3 DOWNTO 0);
      ext_request    : OUT    std_logic_vector (7 DOWNTO 0);
      intrnl_request : OUT    std_logic_vector (7 DOWNTO 0);
      read_offset    : OUT    std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END inth_sync ;
architecture inth_sync_arch of inth_sync is

	type array3x8_stdl is array (0 to 2) of std_logic_vector(7 downto 0);
	type array3x4_stdl is array (0 to 2) of std_logic_vector(3 downto 0);
	type array2x8_stdl is array (0 to 1) of std_logic_vector(7 downto 0);


	signal offset_enabled : std_logic_vector(7 downto 0);
	signal ext_request_i  : std_logic_vector(7 downto 0);
	signal ext_irq        : array3x8_stdl;
	signal tmr_irq        : array2x8_stdl;
	signal cop_irq        : array3x4_stdl;

begin


	-- Synchronizing interrupt and exception lines
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			ext_irq  <= (others => (others => '0'));
			tmr_irq  <= (others => (others => '0'));
			cop_irq  <= (others => (others => '0'));
		elsif clk'event and clk = '1' then
			tmr_irq(0)  <= tmr_inta or tmr_intb;
			tmr_irq(1)  <= tmr_irq(0);
			ext_irq(0) <= ext_interrupt;
			ext_irq(1) <= ext_irq(0);
			ext_irq(2) <= ext_irq(1);
			cop_irq(0) <= cop_exc;
			cop_irq(1) <= cop_irq(0);
			cop_irq(2) <= cop_irq(1);
		end if;
	end process;

	offset_enabled <= (others => ext_handler);
	ext_request_i  <= ext_irq(1) and not ext_irq(2);
	ext_request    <= ext_request_i;
	intrnl_request <= tmr_irq(0) and not tmr_irq(1);
	cop_request    <= cop_irq(1) and not cop_irq(2);

	-- Offset should be read only once after rising edge on
	-- one or more of the extrenal interrupt inputs
	-- (if enabled)

	read_offset <= offset_enabled and ext_request_i;

end inth_sync_arch;
