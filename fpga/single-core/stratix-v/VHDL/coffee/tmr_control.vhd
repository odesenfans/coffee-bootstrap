------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:20 01/03/06
-- File : tmr_control.vhd
-- Design : tmr_control
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY tmr_control IS
   PORT( 
      clk        : IN     std_logic;
      rst_x      : IN     std_logic;
      terminated : IN     std_logic;
      tmr_conf   : IN     std_logic_vector (15 DOWNTO 0);
      cont_mode  : OUT    std_logic;
      divisor    : OUT    std_logic_vector (7 DOWNTO 0);
      enable     : OUT    std_logic;
      tmr_int    : OUT    std_logic_vector (7 DOWNTO 0);
      wdog_rst_x : OUT    std_logic
   );

-- Declarations

END tmr_control ;
architecture tmr_control_arch of tmr_control is

	 signal cont, gint, en, wdog : std_logic;
	 signal intn : std_logic_vector(2 downto 0);
	 signal irq, edge  : std_logic;

begin

	en   <= tmr_conf(15); -- en = 1   => enable timer
	cont <= tmr_conf(14); -- cont = 1 => continuous mode
	gint <= tmr_conf(13); -- gint = 1 => interrupt mode
	wdog <= tmr_conf(12); -- wdog = 1 => watchdog mode
	-- bit 11 is reserved
	intn <= tmr_conf(10 downto 8); -- associated interrupt

	-- some asynchronous outputs
	divisor    <= tmr_conf(7 downto 0); -- timer frequency setting
	enable     <= en;
	wdog_rst_x <= not(terminated and wdog and en);
	cont_mode  <= cont;

	-- detecting rising edge of terminated -input.
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			irq <= '0';
		elsif clk'event and clk = '1' then
			irq <= terminated;
		end if;
	end process;

	edge <= not irq and terminated;

	-- generating interrupt request if required
	process(intn, edge, gint, en)
		variable rq : std_logic;
	begin
		rq := edge and gint and en;
		case intn is
		when "000" =>
			tmr_int <= "0000000" & rq;
		when "001" =>
			tmr_int <= "000000" & rq & '0';
		when "010" =>
			tmr_int <= "00000" & rq & "00";
		when "011" =>
			tmr_int <= "0000" & rq & "000";
		when "100" =>
			tmr_int <= "000" & rq & "0000";
		when "101" =>
			tmr_int <= "00" & rq & "00000";
		when "110" =>
			tmr_int <= "0" & rq & "000000";
		when "111" =>
			tmr_int <= rq & "0000000";
		when others =>
			tmr_int <= (others => '0');
		end case;
	end process;

end tmr_control_arch;

