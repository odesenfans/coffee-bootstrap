------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : core_ccb.vhd
-- Design : core_ccb
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY core_ccb IS
   PORT( 
      reg_indx         : IN     std_logic_vector (7 DOWNTO 0);
      user_data_in     : IN     std_logic_vector (31 DOWNTO 0);
      exception_cs_in  : IN     std_logic_vector (7 DOWNTO 0);
      exception_pc_in  : IN     std_logic_vector (31 DOWNTO 0);
      clk              : IN     std_logic;
      rst_x            : IN     std_logic;
      int_base         : OUT    array_12x32_stdl;
      int_mask_q       : OUT    std_logic_vector (11 DOWNTO 0);
      dmem_bound_lo_q  : OUT    std_logic_vector (31 DOWNTO 0);
      dmem_bound_hi_q  : OUT    std_logic_vector (31 DOWNTO 0);
      imem_bound_lo_q  : OUT    std_logic_vector (31 DOWNTO 0);
      imem_bound_hi_q  : OUT    std_logic_vector (31 DOWNTO 0);
      write_access     : IN     std_logic;
      pcb_start_q      : OUT    std_logic_vector (31 DOWNTO 0);
      exception        : IN     std_logic;
      data_out         : OUT    std_logic_vector (31 DOWNTO 0);
      sys_addr_q       : OUT    std_logic_vector (31 DOWNTO 0);
      exception_addr_q : OUT    std_logic_vector (31 DOWNTO 0);
      exception_psr    : IN     std_logic_vector (7 DOWNTO 0);
      int_mode_il_q    : OUT    std_logic_vector (11 DOWNTO 0);
      int_mode_um_q    : OUT    std_logic_vector (11 DOWNTO 0);
      int_pend         : IN     std_logic_vector (11 DOWNTO 0);
      int_serv         : IN     std_logic_vector (11 DOWNTO 0);
      wait_states      : OUT    std_logic_vector (11 DOWNTO 0);
      pcb_end_q        : OUT    std_logic_vector (31 DOWNTO 0);
      creg_indx_i_q    : OUT    std_logic_vector (19 DOWNTO 0);
      enable           : IN     std_logic;
      ext_int_pri      : OUT    std_logic_vector (31 DOWNTO 0);
      cop_int_pri      : OUT    std_logic_vector (15 DOWNTO 0);
      flush            : IN     std_logic;
      protect_mode_q   : OUT    std_logic_vector (1 DOWNTO 0);
      tmr0_cnt_in      : IN     std_logic_vector (31 DOWNTO 0);
      tmr1_cnt_in      : IN     std_logic_vector (31 DOWNTO 0);
      tmr0_cnt_out     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr1_cnt_out     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr0_max_cnt     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr1_max_cnt     : OUT    std_logic_vector (31 DOWNTO 0);
      tmr_conf         : OUT    std_logic_vector (31 DOWNTO 0);
      ccb_access       : IN     std_logic;
      tos_addr         : IN     std_logic_vector (31 DOWNTO 0);
      tos_psr          : IN     std_logic_vector (7 DOWNTO 0);
      tos_cr0          : IN     std_logic_vector (2 DOWNTO 0);
      new_tos_addr     : OUT    std_logic_vector (31 DOWNTO 0);
      new_tos_psr      : OUT    std_logic_vector (7 DOWNTO 0);
      new_tos_cr0      : OUT    std_logic_vector (2 DOWNTO 0);
      addr_mask        : OUT    std_logic_vector (31 DOWNTO 0);
      ccb_base         : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core_ccb ;
-- Core Control Block contains registers to configure the hardware
-- and a few status registers. See documentation about registers
-----------------------------------------------------------------------------
-- Notes:
-- For read & write registers the timing has to be consistent with
-- memory access timing (data availability). Therefore access to these
-- registers has to be delayed one clock cycle. In practise it means
-- adding a flip-flop stage to inputs which have valid data one cycle
-- before the access. These signals are:
--
-- reg_indx
-- user_data_in
--
-----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_arith.all;

architecture core_ccb_arch of core_ccb is

	constant last_indx_i    : integer := number_of_ccb_registers_c - 1;
	constant last_indx_std : std_logic_vector(7 downto 0) := CONV_STD_LOGIC_VECTOR(last_indx_i,8);

	type reg_bank is array (0 to last_indx_i) of std_logic_vector(31 downto 0);

	signal reg_out        : reg_bank;
	signal reg_in         : reg_bank;

	signal indx           : std_logic_vector(7 downto 0);
	signal data           : std_logic_vector(31 downto 0);
	signal en             : std_logic_vector(last_indx_i downto 0);
	signal write_enable   : std_logic_vector(last_indx_i downto 0);
	signal a              : std_logic_vector(7 downto 0);
	signal write          : std_logic;

	component range_checker_8bit
	PORT( 
		value     : IN     std_logic_vector (7 DOWNTO 0);    
		hi_bound  : IN     std_logic_vector (7 DOWNTO 0);    
		low_bound : IN     std_logic_vector (7 DOWNTO 0);    
		inside    : OUT    std_logic                          
	);
	end component;

	signal hi_bound, lo_bound : std_logic_vector (7 DOWNTO 0);
	signal match : std_logic;

begin
	-- for debug only
--	process(reg_out)
--	begin
--		for i in ccb_regs_out'range loop
--			ccb_regs_out(i) <= reg_out(i);
--		end loop;
--	end process;
	-- comparator is used to check whether register index maps
	-- to one of implemented registers.
	comparator : range_checker_8bit
	port map
	(
		value     => reg_indx,
		hi_bound  => hi_bound,
		low_bound => lo_bound,
		inside    => match
	);
	lo_bound <= (others => '0');
	hi_bound <= last_indx_std;
-------------------------------------------------
-- Delay registers
-------------------------------------------------
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			indx  <= (others => '0');
			data  <= (others => '0');
			write <= '0';
		elsif clk'event and clk = '1' then
			if enable = '1' then
				indx  <= reg_indx;
				data  <= user_data_in;
				write <= write_access and ccb_access and not flush and match;
			end if;
		end if;
	end process;

-----------------------------------------------------------------
-- Data registers
-- Registers INT_PEND, INT_SERV, RETI_ADDR, RETI_PSR and RETI_CR0
-- are visible via CCB but implemented elsewhere.
-----------------------------------------------------------------

	process(clk, rst_x, reg_in)
	begin
		if rst_x = '0' then
			reg_out(CCB_BASE_INDX)      <= CCB_BASE_RVAL;
			reg_out(PCB_BASE_INDX)      <= PCB_BASE_RVAL;
			reg_out(PCB_END_INDX)       <= PCB_END_RVAL;
			reg_out(PCB_AMASK_INDX)     <= PCB_AMASK_RVAL;
			reg_out(COP0_INT_VEC_INDX)  <= COP0_INT_VEC_RVAL;
			reg_out(COP1_INT_VEC_INDX)  <= COP1_INT_VEC_RVAL;
			reg_out(COP2_INT_VEC_INDX)  <= COP2_INT_VEC_RVAL;
			reg_out(COP3_INT_VEC_INDX)  <= COP3_INT_VEC_RVAL;
			reg_out(EXT_INT0_VEC_INDX)  <= EXT_INT0_VEC_RVAL;
			reg_out(EXT_INT1_VEC_INDX)  <= EXT_INT1_VEC_RVAL;
			reg_out(EXT_INT2_VEC_INDX)  <= EXT_INT2_VEC_RVAL;
			reg_out(EXT_INT3_VEC_INDX)  <= EXT_INT3_VEC_RVAL;
			reg_out(EXT_INT4_VEC_INDX)  <= EXT_INT4_VEC_RVAL;
			reg_out(EXT_INT5_VEC_INDX)  <= EXT_INT5_VEC_RVAL;
			reg_out(EXT_INT6_VEC_INDX)  <= EXT_INT6_VEC_RVAL;
			reg_out(EXT_INT7_VEC_INDX)  <= EXT_INT7_VEC_RVAL;
			reg_out(INT_MODE_IL_INDX)   <= INT_MODE_IL_RVAL;
			reg_out(INT_MODE_UM_INDX)   <= INT_MODE_UM_RVAL;
			reg_out(INT_MASK_INDX)      <= INT_MASK_RVAL;
			reg_out(EXT_INT_PRI_INDX)   <= EXT_INT_PRI_RVAL;
			reg_out(COP_INT_PRI_INDX)   <= COP_INT_PRI_RVAL;
			reg_out(EXCEPTION_CS_INDX)  <= EXCEPTION_CS_RVAL;
			reg_out(EXCEPTION_PC_INDX)  <= EXCEPTION_PC_RVAL;
			reg_out(EXCEPTION_PSR_INDX) <= EXCEPTION_PSR_RVAL;
			reg_out(DMEM_BOUND_LO_INDX) <= DMEM_BOUND_LO_RVAL;
			reg_out(DMEM_BOUND_HI_INDX) <= DMEM_BOUND_HI_RVAL;
			reg_out(IMEM_BOUND_LO_INDX) <= IMEM_BOUND_LO_RVAL;
			reg_out(IMEM_BOUND_HI_INDX) <= IMEM_BOUND_HI_RVAL;
			reg_out(MEM_CONF_INDX)      <= MEM_CONF_RVAL;
			reg_out(SYSTEM_ADDR_INDX)   <= SYSTEM_ADDR_RVAL;
			reg_out(EXCEP_ADDR_INDX)    <= EXCEP_ADDR_RVAL;
			reg_out(BUS_CONF_INDX)      <= BUS_CONF_RVAL;
			reg_out(COP_CONF_INDX)      <= COP_CONF_RVAL;
			reg_out(TMR0_CNT_INDX)      <= TMR0_CNT_RVAL;
			reg_out(TMR0_MAX_CNT_INDX)  <= TMR0_MAX_CNT_RVAL;
			reg_out(TMR1_CNT_INDX)      <= TMR1_CNT_RVAL;
			reg_out(TMR1_MAX_CNT_INDX)  <= TMR1_MAX_CNT_RVAL;
			reg_out(TMR_CONF_INDX)      <= TMR_CONF_RVAL;
		elsif clk'event and clk = '1' then
			for i in reg_out'range loop
				if write_enable(i) = '1' then
					reg_out(i) <= reg_in(i);
				end if;
			end loop;
			-- always updated
			reg_out(TMR0_CNT_INDX) <= reg_in(TMR0_CNT_INDX);
			reg_out(TMR1_CNT_INDX) <= reg_in(TMR1_CNT_INDX);
		end if;
		-- implementation elsewhere, read only...
		reg_out(INT_SERV_INDX)  <= reg_in(INT_SERV_INDX);
		reg_out(INT_PEND_INDX)  <= reg_in(INT_PEND_INDX);
		-- Implementation elsewhere, writable 
		reg_out(RETI_ADDR_INDX) <= reg_in(RETI_ADDR_INDX);
		reg_out(RETI_PSR_INDX)  <= reg_in(RETI_PSR_INDX);
		reg_out(RETI_CR0_INDX)  <= reg_in(RETI_CR0_INDX);
	end process;

-------------------------------------------------
-- Write enables from decoded index
-------------------------------------------------
	process(en, write, exception)
	begin
		for i in 0 to last_indx_i loop
			write_enable(i) <= write and en(i);
		end loop;
		-- Exception data registers
		write_enable(EXCEPTION_CS_INDX) <= exception;
		write_enable(EXCEPTION_PC_INDX) <= exception;
		write_enable(EXCEPTION_PSR_INDX) <= exception;
	end process;

-------------------------------------------------
-- Data routing to register inputs
-------------------------------------------------
	process(data, exception_cs_in, exception_psr, exception_pc_in,
	        int_serv, int_pend, tmr0_cnt_in, tmr1_cnt_in, write_enable,
	        tos_addr, tos_psr, tos_cr0)

		variable tmr0_counter_next_value : std_logic_vector(31 downto 0);
		variable tmr1_counter_next_value : std_logic_vector(31 downto 0);
	begin
		-- timer counters can be updated by programmer or incrementer
		if write_enable(TMR0_CNT_INDX) = '1' then
			tmr0_counter_next_value := data;
		else
			tmr0_counter_next_value := tmr0_cnt_in;
		end if;
		if write_enable(TMR1_CNT_INDX) = '1' then
			tmr1_counter_next_value := data;
		else
			tmr1_counter_next_value := tmr1_cnt_in;
		end if;
		
		-- Top of HW stack can be written by software
		-- (registers elsewhere...)
		if write_enable(RETI_ADDR_INDX) = '1' then
			new_tos_addr <= data;
		else
			new_tos_addr <= tos_addr;
		end if;
		if write_enable(RETI_PSR_INDX) = '1' then
			new_tos_psr <= data(7 downto 0);
		else
			new_tos_psr <= tos_psr;
		end if;
		if write_enable(RETI_CR0_INDX) = '1' then
			new_tos_cr0 <= data(2 downto 0);
		else
			new_tos_cr0 <= tos_cr0;
		end if;

		reg_in(CCB_BASE_INDX)        <= data;
		reg_in(PCB_BASE_INDX)        <= data;
		reg_in(PCB_END_INDX)         <= data;
		reg_in(PCB_AMASK_INDX)       <= data;
		reg_in(COP0_INT_VEC_INDX)    <= data;
		reg_in(COP1_INT_VEC_INDX)    <= data;
		reg_in(COP2_INT_VEC_INDX)    <= data;
		reg_in(COP3_INT_VEC_INDX)    <= data;
		reg_in(EXT_INT0_VEC_INDX)    <= data;
		reg_in(EXT_INT1_VEC_INDX)    <= data;
		reg_in(EXT_INT2_VEC_INDX)    <= data;
		reg_in(EXT_INT3_VEC_INDX)    <= data;
		reg_in(EXT_INT4_VEC_INDX)    <= data;
		reg_in(EXT_INT5_VEC_INDX)    <= data;
		reg_in(EXT_INT6_VEC_INDX)    <= data;
		reg_in(EXT_INT7_VEC_INDX)    <= data;
		reg_in(INT_MODE_IL_INDX)     <= "00000000000000000000" & data(11 downto 0);
		reg_in(INT_MODE_UM_INDX)     <= "00000000000000000000" & data(11 downto 0);
		reg_in(INT_MASK_INDX)        <= "00000000000000000000" & data(11 downto 0);
		reg_in(EXT_INT_PRI_INDX)     <= data;
		reg_in(COP_INT_PRI_INDX)     <= "0000000000000000" & data(15 downto 0);
		reg_in(EXCEPTION_CS_INDX)    <= "000000000000000000000000" & exception_cs_in;
		reg_in(EXCEPTION_PC_INDX)    <= exception_pc_in;
		reg_in(EXCEPTION_PSR_INDX)   <= "000000000000000000000000" & exception_psr;
		reg_in(DMEM_BOUND_LO_INDX)   <= data;
		reg_in(DMEM_BOUND_HI_INDX)   <= data;
		reg_in(IMEM_BOUND_LO_INDX)   <= data;
		reg_in(IMEM_BOUND_HI_INDX)   <= data;
		reg_in(MEM_CONF_INDX)        <= "000000000000000000000000000000" & data(1 downto 0);
		reg_in(SYSTEM_ADDR_INDX)     <= data;
		reg_in(EXCEP_ADDR_INDX)      <= data;
		reg_in(BUS_CONF_INDX)        <= "00000000000000000000" & data(11 downto 0);
		reg_in(COP_CONF_INDX)        <= "0000" & data(27 downto 0);
		reg_in(INT_SERV_INDX)        <= "00000000000000000000" & int_serv;
		reg_in(INT_PEND_INDX)        <= "00000000000000000000" & int_pend;
		reg_in(TMR0_MAX_CNT_INDX)    <= data;
		reg_in(TMR_CONF_INDX)        <= data;
		reg_in(TMR1_MAX_CNT_INDX)    <= data;
		reg_in(TMR0_CNT_INDX)        <= tmr0_counter_next_value;
		reg_in(TMR1_CNT_INDX)        <= tmr1_counter_next_value;
		reg_in(RETI_ADDR_INDX)       <= tos_addr;
		reg_in(RETI_PSR_INDX)        <= "000000000000000000000000" & tos_psr;
		reg_in(RETI_CR0_INDX)        <= "00000000000000000000000000000" & tos_cr0;

	end process;

----------------------------------------------------------
-- Direct outputs (except registers implemented elsewhere)
----------------------------------------------------------

	int_base(0)       <= reg_out(COP0_INT_VEC_INDX);
	int_base(1)       <= reg_out(COP1_INT_VEC_INDX);
	int_base(2)       <= reg_out(COP2_INT_VEC_INDX);
	int_base(3)       <= reg_out(COP3_INT_VEC_INDX);
	int_base(4)       <= reg_out(EXT_INT0_VEC_INDX);
	int_base(5)       <= reg_out(EXT_INT1_VEC_INDX);
	int_base(6)       <= reg_out(EXT_INT2_VEC_INDX);
	int_base(7)       <= reg_out(EXT_INT3_VEC_INDX);
	int_base(8)       <= reg_out(EXT_INT4_VEC_INDX);
	int_base(9)       <= reg_out(EXT_INT5_VEC_INDX);
	int_base(10)      <= reg_out(EXT_INT6_VEC_INDX);
	int_base(11)      <= reg_out(EXT_INT7_VEC_INDX);
	int_mask_q        <= reg_out(INT_MASK_INDX)(11 DOWNTO 0);
	dmem_bound_lo_q   <= reg_out(DMEM_BOUND_LO_INDX);
	dmem_bound_hi_q   <= reg_out(DMEM_BOUND_HI_INDX);
	imem_bound_lo_q   <= reg_out(IMEM_BOUND_LO_INDX);
	imem_bound_hi_q   <= reg_out(IMEM_BOUND_HI_INDX);
	protect_mode_q    <= reg_out(MEM_CONF_INDX)(1 downto 0);
	ccb_base          <= reg_out(CCB_BASE_INDX);
	pcb_start_q       <= reg_out(PCB_BASE_INDX);
	addr_mask         <= reg_out(PCB_AMASK_INDX);

	sys_addr_q        <= reg_out(SYSTEM_ADDR_INDX);
	exception_addr_q  <= reg_out(EXCEP_ADDR_INDX);
	int_mode_il_q     <= reg_out(INT_MODE_IL_INDX)(11 DOWNTO 0);
	int_mode_um_q     <= reg_out(INT_MODE_UM_INDX)(11 DOWNTO 0);
	wait_states       <= reg_out(BUS_CONF_INDX)(11 DOWNTO 0);
	pcb_end_q         <= reg_out(PCB_END_INDX);
	creg_indx_i_q     <= reg_out(COP_CONF_INDX)(19 DOWNTO 0);
	ext_int_pri       <= reg_out(EXT_INT_PRI_INDX);
	cop_int_pri       <= reg_out(COP_INT_PRI_INDX)(15 DOWNTO 0);

	tmr0_cnt_out       <= reg_out(TMR0_CNT_INDX);
	tmr1_cnt_out       <= reg_out(TMR1_CNT_INDX);
	tmr0_max_cnt       <= reg_out(TMR0_MAX_CNT_INDX);
	tmr1_max_cnt       <= reg_out(TMR1_MAX_CNT_INDX);
	tmr_conf           <= reg_out(TMR_CONF_INDX);

-------------------------------------------------
-- Data output routing
-------------------------------------------------

	-- output, multiplexer version. Try using tri-states...

	process(reg_out, indx)
	begin
	case indx is
		when "00000000" =>
			data_out <= reg_out(0);
		when "00000001" =>
			data_out <= reg_out(1);
		when "00000010" =>
			data_out <= reg_out(2);
		when "00000011" =>
			data_out <= reg_out(3);
		when "00000100" =>
			data_out <= reg_out(4);
		when "00000101" =>
			data_out <= reg_out(5);
		when "00000110" =>
			data_out <= reg_out(6);
		when "00000111" =>
			data_out <= reg_out(7);
		when "00001000" =>
			data_out <= reg_out(8);
		when "00001001" =>
			data_out <= reg_out(9);
		when "00001010" =>
			data_out <= reg_out(10);
		when "00001011" =>
			data_out <= reg_out(11);
		when "00001100" =>
			data_out <= reg_out(12);
		when "00001101" =>
			data_out <= reg_out(13);
		when "00001110" =>
			data_out <= reg_out(14);
		when "00001111" =>
			data_out <= reg_out(15);
		when "00010000" =>
			data_out <= reg_out(16);
		when "00010001" =>
			data_out <= reg_out(17);
		when "00010010" =>
			data_out <= reg_out(18);
		when "00010011" =>
			data_out <= reg_out(19);
		when "00010100" =>
			data_out <= reg_out(20);
		when "00010101" =>
			data_out <= reg_out(21);
		when "00010110" =>
			data_out <= reg_out(22);
		when "00010111" =>
			data_out <= reg_out(23);
		when "00011000" =>
			data_out <= reg_out(24);
		when "00011001" =>
			data_out <= reg_out(25);
		when "00011010" =>
			data_out <= reg_out(26);
		when "00011011" =>
			data_out <= reg_out(27);
		when "00011100" =>
			data_out <= reg_out(28);
		when "00011101" =>
			data_out <= reg_out(29);
		when "00011110" =>
			data_out <= reg_out(30);
		when "00011111" =>
			data_out <= reg_out(31);
		when "00100000" =>
			data_out <= reg_out(32);
		when "00100001" =>
			data_out <= reg_out(33);
		when "00100010" =>
			data_out <= reg_out(34);
		when "00100011" =>
			data_out <= reg_out(35);
		when "00100100" =>
			data_out <= reg_out(36);
		when "00100101" =>
			data_out <= reg_out(37);
		when "00100110" =>
			data_out <= reg_out(38);
		when "00100111" =>
			data_out <= reg_out(39);
		when "00101000" =>
			data_out <= reg_out(40);
		when "00101001" =>
			data_out <= reg_out(41);
		when "00101010" =>
			data_out <= reg_out(42);
		when others =>
			data_out <= (others => '0');
	end case;
	end process;


----------------------------------------------------------
-- Decode for Write & read enables
----------------------------------------------------------

	a <= indx;

    en(0)  <= not a(5) and not a(4) and not a(3) and not a(2) and not a(1) and not a(0); -- 000000
    en(1)  <= not a(5) and not a(4) and not a(3) and not a(2) and not a(1) and     a(0);
    en(2)  <= not a(5) and not a(4) and not a(3) and not a(2) and     a(1) and not a(0);
    en(3)  <= not a(5) and not a(4) and not a(3) and not a(2) and     a(1) and     a(0);
    en(4)  <= not a(5) and not a(4) and not a(3) and     a(2) and not a(1) and not a(0);
    en(5)  <= not a(5) and not a(4) and not a(3) and     a(2) and not a(1) and     a(0);
    en(6)  <= not a(5) and not a(4) and not a(3) and     a(2) and     a(1) and not a(0);
    en(7)  <= not a(5) and not a(4) and not a(3) and     a(2) and     a(1) and     a(0);
    en(8)  <= not a(5) and not a(4) and     a(3) and not a(2) and not a(1) and not a(0);
    en(9)  <= not a(5) and not a(4) and     a(3) and not a(2) and not a(1) and     a(0);
    en(10) <= not a(5) and not a(4) and     a(3) and not a(2) and     a(1) and not a(0);
    en(11) <= not a(5) and not a(4) and     a(3) and not a(2) and     a(1) and     a(0);
    en(12) <= not a(5) and not a(4) and     a(3) and     a(2) and not a(1) and not a(0);
    en(13) <= not a(5) and not a(4) and     a(3) and     a(2) and not a(1) and     a(0);
    en(14) <= not a(5) and not a(4) and     a(3) and     a(2) and     a(1) and not a(0);
    en(15) <= not a(5) and not a(4) and     a(3) and     a(2) and     a(1) and     a(0);
    en(16) <= not a(5) and     a(4) and not a(3) and not a(2) and not a(1) and not a(0);
    en(17) <= not a(5) and     a(4) and not a(3) and not a(2) and not a(1) and     a(0);
    en(18) <= not a(5) and     a(4) and not a(3) and not a(2) and     a(1) and not a(0);
    en(19) <= not a(5) and     a(4) and not a(3) and not a(2) and     a(1) and     a(0);
    en(20) <= not a(5) and     a(4) and not a(3) and     a(2) and not a(1) and not a(0);
    en(21) <= not a(5) and     a(4) and not a(3) and     a(2) and not a(1) and     a(0);
    en(22) <= not a(5) and     a(4) and not a(3) and     a(2) and     a(1) and not a(0);
    en(23) <= not a(5) and     a(4) and not a(3) and     a(2) and     a(1) and     a(0);
    en(24) <= not a(5) and     a(4) and     a(3) and not a(2) and not a(1) and not a(0);
    en(25) <= not a(5) and     a(4) and     a(3) and not a(2) and not a(1) and     a(0);
    en(26) <= not a(5) and     a(4) and     a(3) and not a(2) and     a(1) and not a(0);
    en(27) <= not a(5) and     a(4) and     a(3) and not a(2) and     a(1) and     a(0);
    en(28) <= not a(5) and     a(4) and     a(3) and     a(2) and not a(1) and not a(0);
    en(29) <= not a(5) and     a(4) and     a(3) and     a(2) and not a(1) and     a(0);
    en(30) <= not a(5) and     a(4) and     a(3) and     a(2) and     a(1) and not a(0);
    en(31) <= not a(5) and     a(4) and     a(3) and     a(2) and     a(1) and     a(0);
    en(32) <=     a(5) and not a(4) and not a(3) and not a(2) and not a(1) and not a(0);
    en(33) <=     a(5) and not a(4) and not a(3) and not a(2) and not a(1) and     a(0);
    en(34) <=     a(5) and not a(4) and not a(3) and not a(2) and     a(1) and not a(0);
    en(35) <=     a(5) and not a(4) and not a(3) and not a(2) and     a(1) and     a(0);
    en(36) <=     a(5) and not a(4) and not a(3) and     a(2) and not a(1) and not a(0);
    en(37) <=     a(5) and not a(4) and not a(3) and     a(2) and not a(1) and     a(0);
    en(38) <=     a(5) and not a(4) and not a(3) and     a(2) and     a(1) and not a(0);
    en(39) <=     a(5) and not a(4) and not a(3) and     a(2) and     a(1) and     a(0);
    en(40) <=     a(5) and not a(4) and     a(3) and not a(2) and not a(1) and not a(0);
    en(41) <=     a(5) and not a(4) and     a(3) and not a(2) and not a(1) and     a(0);
    en(42) <=     a(5) and not a(4) and     a(3) and not a(2) and     a(1) and not a(0);

end core_ccb_arch;

    