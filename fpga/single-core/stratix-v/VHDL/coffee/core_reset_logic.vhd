------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:19 01/03/06
-- File : core_reset_logic.vhd
-- Design : core_reset_logic
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_reset_logic IS
   PORT( 
      clk           : IN     std_logic;
      rst_n         : IN     std_logic;
      gated_reset_n : OUT    std_logic;
      ba_ext        : IN     std_logic;
      wdog0_rst_n   : IN     std_logic;
      wdog1_rst_n   : IN     std_logic;
      rst_n_s       : OUT    std_logic;
      reset_n_out   : OUT    std_logic
   );

-- Declarations

END core_reset_logic ;
architecture core_reset_logic_arch of core_reset_logic is
	signal reset_s_n        : std_logic;
	signal reset_ss_n       : std_logic;
	signal rst_n_s_internal : std_logic;
	signal wdog_rst_s_n     : std_logic;
begin

	
	process(clk)
	begin
		if clk'event and clk = '1' then
			-- Asyncronous reset is routed via two flip-flops...
			reset_s_n  <= rst_n;     -- reset_s is synchronized
			reset_ss_n <= reset_s_n; -- reset_ss is safely synchronized
			-- Watchdog resets from internal timers
			wdog_rst_s_n  <= wdog0_rst_n and wdog1_rst_n;
		end if;
	end process;

	-- this reset signal is routed to core registers
	rst_n_s_internal  <= wdog_rst_s_n and reset_ss_n;
	rst_n_s           <= rst_n_s_internal;
	-- reset signal is driven to boot address sampling registers
	-- if external boot address is disabled
	gated_reset_n <= ba_ext or reset_ss_n;
	-- signal for resetting external logic
	reset_n_out <= rst_n_s_internal;

end core_reset_logic_arch;

