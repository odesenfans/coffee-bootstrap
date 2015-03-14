------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : inth_status.vhd
-- Design : inth_status
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY inth_status IS
   PORT( 
      ack            : IN     std_logic;
      clk            : IN     std_logic;
      cop_request    : IN     std_logic_vector (3 DOWNTO 0);
      done           : IN     std_logic;
      ext_request    : IN     std_logic_vector (7 DOWNTO 0);
      int_n_q        : IN     std_logic_vector (11 DOWNTO 0);
      intrnl_request : IN     std_logic_vector (7 DOWNTO 0);
      rst_x          : IN     std_logic;
      int_ack        : OUT    std_logic;
      int_done       : OUT    std_logic;
      int_pend       : OUT    std_logic_vector (11 DOWNTO 0);
      int_serv       : OUT    std_logic_vector (11 DOWNTO 0)
   );

-- Declarations

END inth_status ;
library coffee;
use coffee.core_constants_pkg.all;

architecture inth_status_arch of inth_status is

	type array_12x5_stdl is array (0 to 11) of std_logic_vector(4 downto 0);

	signal pending         : std_logic_vector(11 downto 0);
	signal ext_pend        : std_logic_vector(7 downto 0);
	signal set_pend        : std_logic_vector(11 downto 0);
	-- additonal register for detecting cases when handshaking
	-- with external handler should be done
	signal set_ext_pend    : std_logic_vector(7 downto 0);
	signal clear_pend      : std_logic_vector(11 downto 0);
	signal in_serv         : std_logic_vector(11 downto 0);
	signal set_serv        : std_logic_vector(11 downto 0);
	signal clear_serv      : std_logic_vector(11 downto 0);
	signal latest_in_serv  : std_logic_vector(11 downto 0);
	signal next_in_serv    : std_logic_vector(11 downto 0);
	signal acknowledge     : std_logic_vector(11 downto 0);
	signal serv_done       : std_logic_vector(11 downto 0);
	signal request         : std_logic_vector(11 downto 0);
	signal int_number      : std_logic_vector(4 downto 0);
	signal external_done   : std_logic;
	signal external_ack    : std_logic;
	signal serv_stack      : array_12x5_stdl;

begin

	acknowledge  <= (others => ack);
	serv_done    <= (others => done);
	-- need to sync int_n_q with ack!
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			next_in_serv <= (others => '0');
		elsif clk'event and clk = '1' then
			next_in_serv <= int_n_q;
		end if;
	end process;

	request(11 downto 4) <= ext_request or intrnl_request;
	request(3 downto 0)  <= cop_request;

	--------------------------------------------------
	-- Bitmasks are used as follows:
	-- A high bit in set_xxx -mask will set a bit
	-- A low bit in clear_xxx -mask will clear a bit
	-- Set -operation overrides clear operation
	--------------------------------------------------

	-- Next goes in service when acknowledged
	set_serv    <= next_in_serv and acknowledge;
	-- Clearing INT_SERV bit after service
	clear_serv  <= not(latest_in_serv and serv_done);

	-- add new request to pend register
	set_pend     <= request;
	set_ext_pend <= ext_request; 

	-- Clear INT_PEND bit when moving to INT_SERV (acknowledged)
	clear_pend  <= not(next_in_serv and acknowledge);

	-- Updating INT_PEND and INT_SERV. Signal ack (from CCU) will transfer
	-- a pending request to service (from INT_PEND to INT_SERV). Signal
	-- done will end service, that is, clear a bit in INT_SERV.
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			pending  <= INT_PEND_RVAL(11 downto 0);
			in_serv  <= INT_SERV_RVAL(11 downto 0);
			ext_pend <= (others => '0');
		elsif clk'event and clk = '1' then
			ext_pend <= (ext_pend and clear_pend(11 downto 4)) or set_ext_pend;
			pending  <= (pending and clear_pend) or set_pend;
			in_serv  <= (in_serv and clear_serv) or set_serv;
		end if;
	end process;

	-- Interrupts from multiple sources can be active simultaneously if nested
	-- interrupting is desired. Because priorities between sources can be
	-- configured by software, we cannot know which source is served by 
	-- inspecting bits in int_serv => need to memorize the order in which
	-- routines where entered, that is, the order in which bits were set.
	-- To reduce the number or flip flops, source is coded in four bits.
	-- Coding and decoding adds logic...
	-- We also need to know whether a request came from external or internal
	-- source to enable or disable signalling with external interrupt
	-- handler.

	stack:process(clk, rst_x)
	begin
		if rst_x = '0' then
			serv_stack <= (others => (others => '0'));
		elsif clk'event and clk = '1' then
			if ack = '1' then
				serv_stack(0) <= int_number;
				serv_stack(1) <= serv_stack(0);
				serv_stack(2) <= serv_stack(1);
				serv_stack(3) <= serv_stack(2);
				serv_stack(4) <= serv_stack(3);
				serv_stack(5) <= serv_stack(4);
				serv_stack(6) <= serv_stack(5);
				serv_stack(7) <= serv_stack(6);
				serv_stack(8) <= serv_stack(7);
				serv_stack(9) <= serv_stack(8);
				serv_stack(10) <= serv_stack(9);
				serv_stack(11) <= serv_stack(10);
			elsif done = '1' then
				serv_stack(11) <= (others => '0');
				serv_stack(10) <= serv_stack(11);
				serv_stack(9) <= serv_stack(10);
				serv_stack(8) <= serv_stack(9);
				serv_stack(7) <= serv_stack(8);
				serv_stack(6) <= serv_stack(7);
				serv_stack(5) <= serv_stack(6);
				serv_stack(4) <= serv_stack(5);
				serv_stack(3) <= serv_stack(4);
				serv_stack(2) <= serv_stack(3);
				serv_stack(1) <= serv_stack(2);
				serv_stack(0) <= serv_stack(1);
			end if;
		end if;
	end process;

	-- Coding and decoding one hot signals
	process(serv_stack, next_in_serv, ext_pend)
		variable s : std_logic_vector(4 downto 0);
--		variable n : std_logic_vector(11 downto 0);
	begin
		-- encoding
		case next_in_serv is 
			when "000000000010" =>
				int_number <= "00001";
				external_ack <= '0';
			when "000000000100" =>
				int_number <= "00010";
				external_ack <= '0';
			when "000000001000" =>
				int_number <= "00011";
				external_ack <= '0';
			when "000000010000" =>
				int_number <= ext_pend(0) & "0100";
				external_ack <= ext_pend(0);
			when "000000100000" =>
				int_number <= ext_pend(1) & "0101";
				external_ack <= ext_pend(1);
			when "000001000000" =>
				int_number <= ext_pend(2) & "0110";
				external_ack <= ext_pend(2);
			when "000010000000" =>
				int_number <= ext_pend(3) & "0111";
				external_ack <= ext_pend(3);
			when "000100000000" =>
				int_number <= ext_pend(4) & "1000";
				external_ack <= ext_pend(4);
			when "001000000000" =>
				int_number <= ext_pend(5) & "1001";
				external_ack <= ext_pend(5);
			when "010000000000" =>
				int_number <= ext_pend(6) & "1010";
				external_ack <= ext_pend(6);
			when "100000000000" =>
				int_number <= ext_pend(7) & "1011";
				external_ack <= ext_pend(7);
			when others =>  -- includes also "000000000001"
				int_number <= "00000";
				external_ack <= '0';
		end case;
		-- Ultra fast implementation by Markus Moisio (The Chief)
		-- Hand optimization rules!
--		n := next_in_serv;
--		int_number(0) <= n(0) or  n(2) or n(4) or n(6) or n(8) or n(10);
--		int_number(1) <= n(1) or  n(2) or n(5) or n(6) or n(9) or n(10);
--		int_number(2) <= n(3) or  n(4) or n(5) or n(6) or n(11);
--		int_number(3) <= n(7) or  n(8) or n(9) or n(10) or n(11);

		-- decoding (int_number on top of stack)
		s := serv_stack(0);
		latest_in_serv(0)  <= not s(3) and not s(2)and not s(1)and not s(0);
		latest_in_serv(1)  <= not s(3) and not s(2)and not s(1)and     s(0);
		latest_in_serv(2)  <= not s(3) and not s(2)and     s(1)and not s(0);
		latest_in_serv(3)  <= not s(3) and not s(2)and     s(1)and     s(0);
		latest_in_serv(4)  <= not s(3) and     s(2)and not s(1)and not s(0);
		latest_in_serv(5)  <= not s(3) and     s(2)and not s(1)and     s(0);
		latest_in_serv(6)  <= not s(3) and     s(2)and     s(1)and not s(0);
		latest_in_serv(7)  <= not s(3) and     s(2)and     s(1)and     s(0);
		latest_in_serv(8)  <=     s(3) and not s(2)and not s(1)and not s(0);
		latest_in_serv(9)  <=     s(3) and not s(2)and not s(1)and     s(0);
		latest_in_serv(10) <=     s(3) and not s(2)and     s(1)and not s(0);
		latest_in_serv(11) <=     s(3) and not s(2)and     s(1)and     s(0);
		external_done <= s(4);
	end process;

	-- Outputs
	int_pend <= pending;
	int_serv <= in_serv;

	-- Signalling to an external interrupt controller if a request is accepted
	-- or service has ended. Note that in case of a coprocessor 
	-- interrupt/exception or timer interrupt (internal timers), signalling
	-- disabled.

	process(clk, rst_x)
	begin
		if rst_x = '0' then
			int_done <= '0';
			int_ack  <= '0';
		elsif clk'event and clk = '1' then
			int_done <= done and external_done;
			int_ack  <= ack and external_ack;
		end if;
	end process;


end inth_status_arch;

