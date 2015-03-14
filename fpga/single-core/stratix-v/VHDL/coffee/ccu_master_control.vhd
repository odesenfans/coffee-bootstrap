------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:23 01/03/06
-- File : ccu_master_control.vhd
-- Design : ccu_master_control
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY ccu_master_control IS
   PORT( 
      alu_exception_of        : IN     std_logic;
      alu_exception_uf        : IN     std_logic;
      clk                     : IN     std_logic;
      current_psr             : IN     std_logic_vector (7 DOWNTO 0);
      data_addr_exception_of  : IN     std_logic;
      data_addr_exception_usr : IN     std_logic;
      decode_exception        : IN     std_logic_vector (2 DOWNTO 0);
      enable_3rd_stage        : IN     std_logic;
      illegal_jump            : IN     std_logic;
      inst_addr_violation     : IN     std_logic;
      interrupt_req           : IN     std_logic;
      invalid_pc              : IN     std_logic;
      is_reg_jump             : IN     std_logic;
      is_rel_jump             : IN     std_logic;
      jump_addr_overflow      : IN     std_logic;
      jumped                  : IN     std_logic;
      miss_aligned_iaddr      : IN     std_logic;
      miss_aligned_jump       : IN     std_logic;
      mul32bit                : IN     std_logic;
      rst_n                   : IN     std_logic;
      safe_to_switch_cntxt    : IN     std_logic;
      scall                   : IN     std_logic;
      trap_code               : IN     std_logic_vector (4 DOWNTO 0);
      ccb_we_exc              : OUT    std_logic;
      exception_cause         : OUT    std_logic_vector (7 DOWNTO 0);
      flush_stage             : OUT    std_logic_vector (4 DOWNTO 0);
      freeze_pc_override      : OUT    std_logic;
      insert_nops             : OUT    std_logic;
      int_req                 : OUT    std_logic;
      sel_buff_entry          : OUT    std_logic_vector (1 DOWNTO 0);
      sel_pc_override         : OUT    std_logic_vector (2 DOWNTO 0);
      sel_psr_override        : OUT    std_logic_vector (2 DOWNTO 0);
      status_override         : OUT    std_logic
   );

-- Declarations

END ccu_master_control ;

architecture ccu_master_control_arch of ccu_master_control is
	
	signal exception_in_stage        : std_logic_vector(4 downto 1);
	signal switch_to_esr             : std_logic;
	signal fetch_one_more            : std_logic;
	signal reverse_one               : std_logic;
	signal exception                 : std_logic;
	signal data_addr_exception_usr_s : std_logic;
	signal data_addr_exception_of_s  : std_logic;
	signal exception_stage           : std_logic_vector(1 downto 0);
	signal interrupt_pending         : std_logic;
	signal interrupts_enabled        : std_logic;
	signal exception_pending         : std_logic;
	signal flush_stage1              : std_logic;
	
begin
	-----------------------------------------------------------------
	-- Main control logic for context switching, asynchronous outputs
	-----------------------------------------------------------------
	process(exception, exception_stage, safe_to_switch_cntxt, interrupt_pending,
	        exception_pending, reverse_one, rst_n)
	begin
		if exception = '1' or exception_pending = '1' then
			switch_to_esr      <= safe_to_switch_cntxt; -- if safe, change context immediately
			sel_pc_override    <= "100"; -- update PC with exception address
			sel_psr_override   <= "100"; -- update PSR with exception handler flags
			status_override    <= '1'; -- force PC and PSR to be updated by selected values
			sel_buff_entry     <= exception_stage; -- route correct exception data to CCB
			insert_nops        <= '1'; -- cancel fetch from current address
			freeze_pc_override <= '0'; -- default for irrelevant signal
			flush_stage1       <= '0'; -- default for irrelevant signal
			int_req            <= '0'; -- default for irrelevant signal
		elsif interrupt_pending = '1' then
			switch_to_esr  <= '0';  -- default for irrelevant signal
			sel_buff_entry <= "00"; -- Reverse PC from buffer if needed.
			if reverse_one = '1' then
				sel_pc_override    <= "111"; -- select previous address
				sel_psr_override   <= "000"; -- keep current PSR
				status_override    <= '1'; -- force PC and PSR to set values
				flush_stage1       <= '1'; -- flush mul32
				insert_nops        <= '1'; -- Cancel fetch of mulhi
				int_req            <= '0'; -- default for irrelevant signal
				freeze_pc_override <= '0'; -- default for irrelevant signal
			elsif safe_to_switch_cntxt = '1' then
				sel_pc_override    <= "011"; -- select ISR vector as PC value
				sel_psr_override   <= "010"; -- select ISR status for PSR
				-- forcing selection could change behavior of decoded instruction
				status_override    <= '0';
				insert_nops        <= '1'; -- cancel current fetch
				int_req            <= '1'; -- request update from flow control
				flush_stage1       <= '0'; -- default for irrelevant signal
				freeze_pc_override <= '0'; -- default for irrelevant signal
			else -- have to wait for some instructions to advance
				freeze_pc_override <= '1'; -- freeze PC
				status_override    <= '0'; -- status might still change
				sel_pc_override    <= "000";
				sel_psr_override   <= "000";
				insert_nops        <= '1'; -- feed nops to pipeline
				flush_stage1       <= '0'; -- default for irrelevant signal
				int_req            <= '0'; -- default for irrelevant signal
			end if;
		else -- normal execution conditions or boot condition
			sel_buff_entry     <= "00"; -- don't care
			freeze_pc_override <= '0';  -- let PC run
			-- rst_n is assumed to be synchronized
			-- Force PC to be updated with boot address when reset is asserted
			if rst_n = '0' then
				sel_pc_override    <= "110";
				status_override    <= '1';
				insert_nops        <= '1';
			else
				sel_pc_override    <= "000";
				status_override    <= '0';
				insert_nops        <= '0';
			end if;
			sel_psr_override   <= "000";
			flush_stage1       <= '0'; -- no flushing
			switch_to_esr      <= '0'; -- no switching
			int_req            <= '0'; -- no interrupting
		end if;
	end process;

	---------------------------------------------------------------------------
	--  Signals derived from exception inputs
	---------------------------------------------------------------------------

	-- Synchronizing asycnhronous exception signals from stage 3
	-- Asynchronous signals are needed to flush violating instruction
	-- (and one following instruction)
	-- but context switch shall take place when the instruction has
	-- propagated to stage 4
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			data_addr_exception_usr_s <= '0';
			data_addr_exception_of_s  <= '0';
		elsif clk'event and clk = '1' then
			if enable_3rd_stage = '1' then
				data_addr_exception_usr_s <= data_addr_exception_usr;
				data_addr_exception_of_s  <= data_addr_exception_of;
			end if;
		end if;
	end process;

	exception_in_stage(1) <= inst_addr_violation or miss_aligned_iaddr;

	exception_in_stage(2) <= decode_exception(2) or decode_exception(1) or
	                         decode_exception(0);

	exception_in_stage(3) <= alu_exception_of or alu_exception_uf or jump_addr_overflow
	                         or illegal_jump or miss_aligned_jump;

	exception_in_stage(4) <= data_addr_exception_of_s or data_addr_exception_usr_s;

	exception <= exception_in_stage(4) or exception_in_stage(3) or
	             exception_in_stage(2) or exception_in_stage(1);


	-- encoding exception stage (used to retrieve right context data)
	process(exception_in_stage)		
	begin
		if exception_in_stage(4) = '1' then
			exception_stage <= "11";
		elsif exception_in_stage(3) = '1' then
			exception_stage <= "10";
		elsif exception_in_stage(2) = '1' then
			exception_stage <= "01";
		else -- exception in stage 1 or no exceptions
			exception_stage <= "00";
		end if;
	end process;


	-- producing a sticky exception signal (exception inputs might go low
	-- before switching to exception handler routine)
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			exception_pending  <= '0';
		elsif clk'event and clk = '1' then
			exception_pending <= (exception or exception_pending) and not switch_to_esr;
		end if;
	end process;
	
	-- Signals for cancelling violating and following instructions as needed.
	-- flush_stage1 signal is used only to cancel mul32 instruction in stage1
	-- when switching to an interrupt service routine.
	-- Note preflushing on data address violation in order to prevent
	-- memory access and possible coprocessor access to take place.
	-- (also hardware stack corruption must be prevented: reti)
	flush_stage(0) <= exception;
	flush_stage(1) <= exception or flush_stage1;
	flush_stage(2) <= exception_in_stage(2) or exception_in_stage(3) or
	                  exception_in_stage(4) or data_addr_exception_of or
	                  data_addr_exception_usr;
	flush_stage(3) <= exception_in_stage(3) or exception_in_stage(4) or 
	                  data_addr_exception_of or data_addr_exception_usr;
	flush_stage(4) <= exception_in_stage(4);

	-- Enable update of exception status registers inside CCB
	ccb_we_exc <= exception;

	-- Evaluating exception cause code based on priority
	process(data_addr_exception_of_s, data_addr_exception_usr_s, decode_exception, 
	        illegal_jump, inst_addr_violation, jump_addr_overflow, trap_code, 
			miss_aligned_iaddr, miss_aligned_jump, alu_exception_of, alu_exception_uf)

	begin
		if data_addr_exception_usr_s = '1' then
			exception_cause <= ec_data_addr_viol;
		elsif data_addr_exception_of_s = '1' then
			exception_cause <= ec_data_addr_overflw;
		elsif jump_addr_overflow = '1' then
			exception_cause <= ec_jmp_addr_overflw;
		elsif miss_aligned_jump = '1' then
			exception_cause <= ec_miss_aligned_jmp;
		elsif illegal_jump = '1' then
			exception_cause <= ec_illegal_jmp;
		elsif alu_exception_of = '1' or alu_exception_uf = '1' then
			exception_cause <= ec_arith_overflow;
		elsif decode_exception(0) = '1' then -- unknown opcode
			exception_cause <= ec_unknown_opcode;
		elsif decode_exception(1) = '1' then -- illegal instruction
			exception_cause <= ec_illegal_instr;
		elsif decode_exception(2) = '1' then -- trap
			exception_cause <= "111" & trap_code;
		elsif miss_aligned_iaddr = '1' then
			exception_cause <= ec_iaddr_miss_alignd;
		elsif inst_addr_violation = '1' then
			exception_cause <= ec_inst_addr_viol;
		else
			exception_cause <= ec_trace;
		end if;

	end process;

	--------------------------------------------------------------------------
	-- Signals affecting switching to interrupt service routine
	--------------------------------------------------------------------------
	-- Need to delay interrupting in some cases
	fetch_one_more     <= is_rel_jump or is_reg_jump or scall or invalid_pc;

	-- Need to cancel already fetched instruction and save its address
	reverse_one        <= mul32bit and not jumped;

	interrupts_enabled <= current_psr(4);
	-- Ready to interrupt, interrupt_req should be high until the request has
	-- been acknowledged by flow control. This in turn is requested by this module
	-- by asserting int_req signal.
	interrupt_pending  <= interrupt_req and interrupts_enabled and not fetch_one_more;

end ccu_master_control_arch;

