------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : inth_pri_chk.vhd
-- Design : inth_pri_chk
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY inth_pri_chk IS
   PORT( 
      ack         : IN     std_logic;
      clk         : IN     std_logic;
      cop_int_pri : IN     std_logic_vector (15 DOWNTO 0);
      ext_int_pri : IN     std_logic_vector (31 DOWNTO 0);
      fixed_pri   : IN     std_logic;
      int_mask    : IN     std_logic_vector (11 DOWNTO 0);
      int_pend    : IN     std_logic_vector (11 DOWNTO 0);
      int_serv    : IN     std_logic_vector (11 DOWNTO 0);
      rst_x       : IN     std_logic;
      int_n_q     : OUT    std_logic_vector (11 DOWNTO 0);
      req_q       : OUT    std_logic
   );

-- Declarations

END inth_pri_chk ;
----------------------------------------------------------
-- This unit might be time critical. If so, use two clock
-- cycles to check priority.
----------------------------------------------------------

architecture inth_pri_chk_arch of inth_pri_chk is

	component inth_dmux
		PORT( 
			data0  : IN     std_logic_vector(15 downto 0);
			data1  : IN     std_logic_vector(15 downto 0);
			data2  : IN     std_logic_vector(15 downto 0);
			data3  : IN     std_logic_vector(15 downto 0);
			data4  : IN     std_logic_vector(15 downto 0);
			data5  : IN     std_logic_vector(15 downto 0);
			data6  : IN     std_logic_vector(15 downto 0);
			data7  : IN     std_logic_vector(15 downto 0);
			data8  : IN     std_logic_vector(15 downto 0);
			data9  : IN     std_logic_vector(15 downto 0);
			data10 : IN     std_logic_vector(15 downto 0);
			data11 : IN     std_logic_vector(15 downto 0);
			data12 : IN     std_logic_vector(15 downto 0);
			data13 : IN     std_logic_vector(15 downto 0);
			data14 : IN     std_logic_vector(15 downto 0);
			data15 : IN     std_logic_vector(15 downto 0);
			sel    : IN     std_logic_vector (3 DOWNTO 0);    
			dout   : OUT    std_logic_vector(15 downto 0);
			dec    : OUT    std_logic_vector(15 downto 0)
		);
   end component;


	type array_12x4_stdl  is array (0 to 11) of std_logic_vector(3 downto 0);
	type array_12x16_stdl is array (0 to 11) of std_logic_vector(15 downto 0);
	type array_16x16_stdl is array (0 to 15) of std_logic_vector(15 downto 0);

	-- First phase priority check signals
	signal priority      : array_12x4_stdl;   -- priority of individual source
	signal clear_pri     : array_12x4_stdl;   -- 
	signal m             : array_12x16_stdl;  -- derived priority masks
	signal n             : array_12x16_stdl;  -- decoded priorities (one hot)
	signal pri_mask      : array_16x16_stdl;  -- predefined masks(could be
	signal masked        : array_12x16_stdl;
	-- defined as constant

	signal priority_level : std_logic_vector(15 downto 0); -- cumulative priority
	signal request_vector : std_logic_vector(11 downto 0);
	signal irq_pend :  std_logic_vector(11 downto 0);
	signal irq_serv :  std_logic_vector(11 downto 0);
begin
	-- Two levels of priority check is needed: User configurable
	-- priority masking and, fixed order priority masking.
	-- This implementation combines priorities of individual sources to form
	-- a 'level' of priority which every source compares its priority to.
	-- A request with priority n causes a cumulative priority n which
	-- blocks requests with priorities n+1...15.

	-- If external handler is used, user defined priorities are ignored and
	-- set to 15 (lowest), except for coprocessor exceptions/interrupts
	-- which are always software configurable. Note, that also requests
	-- currently in service affect the cumulative priority level.

	-------------------------------------------------------------------------
	-- Checking if priority set by the programmer has to be
	-- taken into account: a request is pending and not masked, or in service
	-- and external handler is not used(ext_ints only)
	-------------------------------------------------------------------------
	clear_pri(0)  <= (others => (not(int_pend(0) or int_serv(0)) or not int_mask(0)));
	clear_pri(1)  <= (others => (not(int_pend(1) or int_serv(1)) or not int_mask(1)));
	clear_pri(2)  <= (others => (not(int_pend(2) or int_serv(2)) or not int_mask(2)));
	clear_pri(3)  <= (others => (not(int_pend(3) or int_serv(3)) or not int_mask(3)));
	clear_pri(4)  <= (others => (not int_mask(4) or fixed_pri or not(int_pend(4) or int_serv(4))));
	clear_pri(5)  <= (others => (not int_mask(5) or fixed_pri or not(int_pend(5) or int_serv(5))));
	clear_pri(6)  <= (others => (not int_mask(6) or fixed_pri or not(int_pend(6) or int_serv(6))));
	clear_pri(7)  <= (others => (not int_mask(7) or fixed_pri or not(int_pend(7) or int_serv(7))));
	clear_pri(8)  <= (others => (not int_mask(8) or fixed_pri or not(int_pend(8) or int_serv(8))));
	clear_pri(9)  <= (others => (not int_mask(9) or fixed_pri or not(int_pend(9) or int_serv(9))));
	clear_pri(10) <= (others => (not int_mask(10) or fixed_pri or not(int_pend(10) or int_serv(10))));
	clear_pri(11) <= (others => (not int_mask(11) or fixed_pri or not(int_pend(11) or int_serv(11))));

	----------------------------------------------------------
	-- Extracting priorities and setting to 15 if required
	----------------------------------------------------------
	priority(0)  <= cop_int_pri(3 downto 0) or clear_pri(0); -- COP0_INT
	priority(1)  <= cop_int_pri(7 downto 4) or clear_pri(1);
	priority(2)  <= cop_int_pri(11 downto 8) or clear_pri(2);
	priority(3)  <= cop_int_pri(15 downto 12) or clear_pri(3); -- COP3_INT
	priority(4)  <= ext_int_pri(3 downto 0) or clear_pri(4); -- EXT_INT0
	priority(5)  <= ext_int_pri(7 downto 4) or clear_pri(5);
	priority(6)  <= ext_int_pri(11 downto 8) or clear_pri(6);
	priority(7)  <= ext_int_pri(15 downto 12) or clear_pri(7);
	priority(8)  <= ext_int_pri(19 downto 16) or clear_pri(8);
	priority(9)  <= ext_int_pri(23 downto 20) or clear_pri(9);
	priority(10) <= ext_int_pri(27 downto 24) or clear_pri(10);
	priority(11) <= ext_int_pri(31 downto 28) or clear_pri(11); -- EXT_INT7

	----------------------------------------------------------------------
	-- Priority masks for individual sources. For example, a request with
	-- priority 5 will mask requests with priorities 6 to 15. A cumulative
	-- mask is produced by combining individual masks.
	----------------------------------------------------------------------
	pri_mask(15) <= "1111111111111111";	-- lowest
	pri_mask(14) <= "0111111111111111";
	pri_mask(13) <= "0011111111111111";
	pri_mask(12) <= "0001111111111111";
	pri_mask(11) <= "0000111111111111";
	pri_mask(10) <= "0000011111111111";
	pri_mask(9)  <= "0000001111111111";
	pri_mask(8)  <= "0000000111111111";
	pri_mask(7)  <= "0000000011111111";
	pri_mask(6)  <= "0000000001111111";
	pri_mask(5)  <= "0000000000111111";
	pri_mask(4)  <= "0000000000011111";
	pri_mask(3)  <= "0000000000001111";
	pri_mask(2)  <= "0000000000000111";
	pri_mask(1)  <= "0000000000000011";
	pri_mask(0)  <= "0000000000000001";	-- highest

	---------------------------------------------------------
	-- Multiplexers with decoders are used to select a mask
	-- which corresponds to priority of an individual source.
	---------------------------------------------------------
	masks : for i in 0 to 11 generate
		mux : inth_dmux
		port map
		(
			data0  => pri_mask(0),
			data1  => pri_mask(1),
			data2  => pri_mask(2),
			data3  => pri_mask(3),
			data4  => pri_mask(4),
			data5  => pri_mask(5),
			data6  => pri_mask(6),
			data7  => pri_mask(7),
			data8  => pri_mask(8),
			data9  => pri_mask(9),
			data10 => pri_mask(10),
			data11 => pri_mask(11),
			data12 => pri_mask(12),
			data13 => pri_mask(13),
			data14 => pri_mask(14),
			data15 => pri_mask(15),
			sel    => priority(i),
			dout   => m(i), -- contributed individual mask
			dec    => n(i)  -- decoded priority (one hot signal)
		);
	end generate;

	------------------------------------------------------------
	-- Forming a combined priority mask and blocking individual
	-- sources. A request gets through if combined mask does
	-- not clear its decoded priority bit n.
	------------------------------------------------------------
	priority_level <= m(0) and m(1) and m(2) and m(3) and m(4) and m(5) and 
	                  m(6) and m(7) and m(8) and m(9) and m(10) and m(11);

	-- masking requests
	masked(0)  <= priority_level and n(0);
	masked(1)  <= priority_level and n(1);
	masked(2)  <= priority_level and n(2);
	masked(3)  <= priority_level and n(3);
	masked(4)  <= priority_level and n(4);
	masked(5)  <= priority_level and n(5);
	masked(6)  <= priority_level and n(6);
	masked(7)  <= priority_level and n(7);
	masked(8)  <= priority_level and n(8);
	masked(9)  <= priority_level and n(9);
	masked(10) <= priority_level and n(10);
	masked(11) <= priority_level and n(11);


	-- insert a register here for shorter clock cycles...
	process(clk, rst_x)
		variable pass : std_logic_vector(11 downto 0);
	begin
		if rst_x = '0' then
			irq_pend <= (others => '0');
			irq_serv <= (others => '0');
		elsif clk'event and clk = '1' then
			for i in 0 to 11 loop
				pass(i) := (masked(i)(15) or masked(i)(14) or masked(i)(13) or
				            masked(i)(12) or masked(i)(11) or masked(i)(10) or 
				            masked(i)(9) or masked(i)(8) or masked(i)(7) or 
				            masked(i)(6) or masked(i)(5) or masked(i)(4) or 
				            masked(i)(3) or masked(i)(2) or masked(i)(1) or 
				            masked(i)(0));
				-- any active ISRs with the same priority than passed requests?
			end loop;
			irq_pend <= pass and int_pend and not int_serv;
			irq_serv <= pass and int_serv;
		end if;
	end process;

	----------------------------------------------------------------
	-- The second phase of priority checking is checking against
	-- fixed priority order. Be aware, that after the first phase
	-- multiple requests having the same priority might get through.
	-- Requests which have already passed on to service 
	-- (resident in int_serv register) either have the same or lower
	-- priority than current passed requests. If priorities equal
	-- we have to take them into account in the second phase of
	-- priority checking
	----------------------------------------------------------------
	process(irq_pend, irq_serv, int_mask)
		variable p : std_logic_vector(11 downto 0);
		variable pass : std_logic_vector(11 downto 0);
	begin
		p := irq_pend or irq_serv;
		pass(11) := p(11) and not p(10) and not p(9) and not p(8) and not p(7) and not p(6) and not 
		            p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(10) := p(10) and not p(9) and not p(8) and not p(7) and not p(6) and not 
		            p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(9) :=  p(9) and not p(8) and not p(7) and not p(6) and not 
		            p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(8) :=  p(8) and not p(7) and not p(6) and not 
		            p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(7) :=  p(7) and not p(6) and not 
		            p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(6) :=  p(6) and not 
		            p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(5) :=  p(5) and not p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(4) :=  p(4) and not p(3) and not p(2) and not p(1) and not p(0);
		pass(3) :=  p(3) and not p(2) and not p(1) and not p(0);
		pass(2) :=  p(2) and not p(1) and not p(0);
		pass(1) :=  p(1) and not p(0);
		pass(0) :=  p(0); -- highest priority will always be accepted

		-- New request from source i is signalled when priority check is passed(pass(i) = '1')
		request_vector <= irq_pend and pass and int_mask;
	end process;

	process(clk, rst_x)
	begin
		if rst_x = '0' then
			int_n_q <= (others => '0');
			req_q   <= '0';
		elsif clk'event and clk = '1' then
			if request_vector /= "000000000000" then
				req_q <= not(ack);
			else
				req_q <= '0';
			end if;
			int_n_q    <= request_vector;
		end if;
    end process;

end inth_pri_chk_arch;

