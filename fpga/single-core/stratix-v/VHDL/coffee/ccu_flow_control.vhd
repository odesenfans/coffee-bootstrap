------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:24 01/03/06
-- File : ccu_flow_control.vhd
-- Design : ccu_flow_control
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ccu_flow_control IS
   PORT( 
      bus_req                  : IN     std_logic;
      ccb_access               : IN     std_logic;
      clk                      : IN     std_logic;
      cond_execute             : IN     std_logic;
      cond_reg_src             : IN     std_logic_vector (2 DOWNTO 0);
      cond_reg_trgt            : IN     std_logic_vector (2 DOWNTO 0);
      cop_inst                 : IN     std_logic;
      d_cache_miss             : IN     std_logic;
      data_ready               : IN     std_logic_vector (1 DOWNTO 0);
      execute                  : IN     std_logic;
      first_source_reg_indx    : IN     std_logic_vector (4 DOWNTO 0);
      flush_stage              : IN     std_logic_vector (4 DOWNTO 0);
      freeze_pc                : IN     std_logic;
      i_cache_miss             : IN     std_logic;
      insert_nops              : IN     std_logic;
      instruction_updates_psr  : IN     std_logic;
      int_req                  : IN     std_logic;
      is_32b_mul               : IN     std_logic;
      is_reg_jump              : IN     std_logic;
      is_rel_jump              : IN     std_logic;
      load                     : IN     std_logic;
      need_reg_operand1        : IN     std_logic;
      need_reg_operand2        : IN     std_logic;
      rcon                     : IN     std_logic;
      reg_set_to_read          : IN     std_logic;
      reg_set_to_write         : IN     std_logic;
      reti                     : IN     std_logic;
      retu                     : IN     std_logic;
      rst_n                    : IN     std_logic;
      safe_state               : IN     std_logic_vector (2 DOWNTO 0);
      scall                    : IN     std_logic;
      second_source_reg_indx   : IN     std_logic_vector (4 DOWNTO 0);
      sel_pc_override          : IN     std_logic_vector (2 DOWNTO 0);
      sel_psr_override         : IN     std_logic_vector (2 DOWNTO 0);
      stall                    : IN     std_logic;
      status_override          : IN     std_logic;
      store                    : IN     std_logic;
      swm                      : IN     std_logic;
      trgt_reg_indx            : IN     std_logic_vector (4 DOWNTO 0);
      update_flags             : IN     std_logic;
      wait_cycles              : IN     std_logic_vector (11 DOWNTO 0);
      write_reg_file           : IN     std_logic;
      access_complete          : OUT    std_logic;
      alu_op_i_fwd             : OUT    std_logic_vector (1 DOWNTO 0);
      alu_op_ii_fwd            : OUT    std_logic_vector (1 DOWNTO 0);
      bus_ack                  : OUT    std_logic;
      cr_we                    : OUT    std_logic;
      cr_we_all                : OUT    std_logic;
      cr_wr_reg                : OUT    std_logic_vector (2 DOWNTO 0);
      d_cache_data_fwd         : OUT    std_logic_vector (1 DOWNTO 0);
      d_cache_if_use_prev_data : OUT    std_logic;
      done                     : OUT    std_logic;
      enable                   : OUT    std_logic_vector (5 DOWNTO 0);
      float                    : OUT    std_logic;
      flush                    : OUT    std_logic_vector (3 DOWNTO 0);
      int_ack                  : OUT    std_logic;
      invalid_pc               : OUT    std_logic;
      jumped_q                 : OUT    std_logic;
      mdata_fwd_op_i           : OUT    std_logic;
      mdata_fwd_op_ii          : OUT    std_logic;
      mdata_fwd_st             : OUT    std_logic;
      pop                      : OUT    std_logic;
      push                     : OUT    std_logic;
      reg_jmp_fwd              : OUT    std_logic_vector (1 DOWNTO 0);
      rf_we_data               : OUT    std_logic;
      rf_we_spsr               : OUT    std_logic;
      rf_wr_reg                : OUT    std_logic_vector (4 DOWNTO 0);
      rf_wr_rs                 : OUT    std_logic;
      safe_to_switch_cntxt     : OUT    std_logic;
      sel_pc                   : OUT    std_logic_vector (2 DOWNTO 0);
      sel_psr                  : OUT    std_logic_vector (2 DOWNTO 0);
      start_dmem_access        : OUT    std_logic;
      wr_en_psr                : OUT    std_logic;
      write_pc                 : OUT    std_logic
   );

-- Declarations

END ccu_flow_control ;
-------------------------------------------------------------------------------
-- Different stall situations (with different control):
-------------------------------------------------------------------------------
-- 5.0 Waiting for stall -signal to go low
-- 5.0 Waiting for bus_lock -signal to go low when about to access data memory
-- 5.1 Waiting for data cache access, memory miss
-- 5.1 Waiting for data cache access, wait cycles
-- 5.1 Waiting for coprocessor access
-- 1.2 Waiting for data from ALU,PCB or data memory
-- 1.2 Waiting for jump address, register jumps only
-- 1.2 Waiting for flags (conditional execution and jumps)
-- 1.1 or 2.1 Waiting for instruction cache access, memory miss
-- 1.1 or 2.1 Waiting for instruction cache access, wait cycles

-- The first number means that stages up to that stage are
-- stalled.
-- The second number tells the priority (0 - highest)


-- Note that there's no need to forward from stage 5
-- because RF has internal forward logic
-------------------------------------------------------------------------------
-- Conventions used in this module
-------------------------------------------------------------------------------
-- Array indexes are used to refer to pipeline stages. For example:
-- target_rgi(2) refers to target register index of an instruction
-- currently in stage 2
-- The name of a synchronous signal ends with '_s' (others are inputs,
-- intermediate or asynchronous signals)
-------------------------------------------------------------------------------
library coffee;
use coffee.core_constants_pkg.all;

architecture ccu_flow_control_debug_arch of ccu_flow_control is

	type array_2to3_stdlv_5dt0 is array (2 to 3) of std_logic_vector(5 downto 0);
	type array_2to5_stdlv_1dt0 is array (2 to 5) of std_logic_vector(1 downto 0);
	type array_2to4_stdlv_4dt3 is array (2 to 4) of std_logic_vector(4 downto 3);
	type array_2to5_stdlv_5dt0 is array (2 to 5) of std_logic_vector(5 downto 0);
	type array_2to3_stdlv_2dt0 is array (2 to 3) of std_logic_vector(2 downto 0);
	type array_2to3_stdlv_3dt1 is array (2 to 3) of std_logic_vector(3 downto 1);
	type array_1to1_stdlv_5dt0 is array (1 to 1) of std_logic_vector(5 downto 0);
	type array_1to3_stdlv_5dt0 is array (1 to 3) of std_logic_vector(5 downto 0);
	type array_1to5_stdlv_5dt0 is array (1 to 5) of std_logic_vector(5 downto 0);
	type array_2to5_stdlv_4dt0 is array (2 to 5) of std_logic_vector(4 downto 0);
	type array_2to5_stdlv_0dt0 is array (2 to 5) of std_logic;
	type array_2to4_stdlv_0dt0 is array (2 to 4) of std_logic;
	type array_2to2_stdlv_0dt0 is array (2 to 2) of std_logic;
	type array_2to3_stdlv_0dt0 is array (2 to 3) of std_logic;	
	
	type bus_state_t is (RESERVED, ACCESSED, IDLE);

    COMPONENT counter_4bit
	GENERIC
	( 
		reset_value_g : integer := 0
	);
	PORT
	( 
		start_value : IN     std_logic_vector (3 DOWNTO 0);
		load        : IN     std_logic;
		zero        : OUT    std_logic;
		clk         : IN     std_logic;
		rst_n       : IN     std_logic;
		nonzero     : OUT    std_logic;
		down        : IN     std_logic
	);
	END COMPONENT;

	-- State machine state signals
	signal bus_state  : bus_state_t;
	-- Intermediate signals
	
	signal enable_i        : std_logic_vector(5 downto 0);
	signal flush_i         : std_logic_vector(4 downto 0);
	signal is_safe_a       : std_logic_vector(3 downto 1);
	signal pr30lock        : std_logic_vector(4 downto 2);
	signal fsource_rgi     : std_logic_vector(2 downto 0);
	signal ftarget_rgi     : std_logic_vector(2 downto 0);
	signal alu_op_i_fwd_i  : std_logic_vector(1 downto 0);
	signal alu_op_ii_fwd_i : std_logic_vector(1 downto 0);
	signal sel_pc_i        : std_logic_vector(2 downto 0);

	signal source_i_rgi  : array_1to1_stdlv_5dt0;
	signal source_ii_rgi : array_1to3_stdlv_5dt0;
	signal target_rgi    : array_1to5_stdlv_5dt0;
	
	signal pop_s                : std_logic;
	signal psr_as_target        : std_logic;
	signal spsr_as_target_a     : std_logic;
	signal dep2_i               : std_logic;
	signal dep3_i               : std_logic;
	signal dep4_i               : std_logic;
	signal dep2_ii              : std_logic;
	signal dep3_ii              : std_logic;
	signal dep4_ii              : std_logic;
	signal dep34_ii             : std_logic;
	signal dep35_ii             : std_logic;
	signal dep_cr               : std_logic;
	signal discard              : std_logic;
	signal alu_stall_i          : std_logic;
	signal jmp_stall            : std_logic;
	signal alu_stall_ii         : std_logic;
	signal start_dmem_access_i  : std_logic;
	signal start_cop_access     : std_logic;
	signal start_imem_access    : std_logic;
	signal flush_fetch          : std_logic;
	signal d_cache_miss_i       : std_logic;
	signal imem_stall           : std_logic;
	signal dmem_stall           : std_logic;
	signal bus_stall            : std_logic;
	signal atomic_stall         : std_logic;
	signal cond_stall           : std_logic;
	signal cop_stall            : std_logic;
	signal write_pc_i           : std_logic;
	signal need_flags           : std_logic;
	signal internal_access      : std_logic;
	signal one                  : std_logic;
	signal imem_wait            : std_logic;
	signal dmem_wait            : std_logic;
	signal new_access_pending   : std_logic;
	signal dmem_access_complete : std_logic;
	signal int_ack_s            : std_logic;
	signal int_req_s            : std_logic;
	signal wr_en_psr_s          : std_logic;
	
	
	-- Control pipeline signals
	signal src_reg2_indx_s    : array_2to3_stdlv_5dt0;
	signal write_reg_file_s   : array_2to5_stdlv_1dt0;
	signal load_s             : array_2to4_stdlv_0dt0;
	signal store_s            : array_2to4_stdlv_0dt0;
	signal cop_inst_s         : array_2to2_stdlv_0dt0;
	signal update_flags_s     : array_2to3_stdlv_0dt0;
	signal update_all_flags   : array_2to3_stdlv_0dt0;
	signal reti_s             : array_2to3_stdlv_0dt0;
	signal spsr_as_target     : array_2to4_stdlv_0dt0;
	signal data_ready_s       : array_2to4_stdlv_4dt3;
	signal reg_set_to_write_s : array_2to5_stdlv_0dt0;
	signal trgt_reg_indx_s    : array_2to5_stdlv_4dt0;
	signal ftrg_reg_indx      : array_2to3_stdlv_2dt0;
	signal swm_s              : array_2to3_stdlv_0dt0;
	signal is_safe            : array_2to3_stdlv_3dt1;

begin

	--------------------------
	-- for debug only!
	--------------------------
--	cop_stall_debug <= cop_stall;
--	dmem_stall_debug <= dmem_stall;
--	imem_stall_debug <= imem_stall;
--	ext_stall_debug <= stall;
--	bus_stall_debug <= bus_stall;
--	cond_stall_debug <= cond_stall;
--	jmp_stall_debug <= jmp_stall;
--	alu_stall_i_debug <= alu_stall_i;
--	alu_stall_ii_debug <= alu_stall_ii;
--	i_cache_miss_debug <= i_cache_miss;
--	d_cache_miss_debug <= d_cache_miss_i;
--	atomic_stall_debug <= atomic_stall;
	-----------------------------------
	-----------------------------------

	-----------------------------------------------------------------
	-- Source and target register indexes for data register bank
	-----------------------------------------------------------------
	-- Source register indexes of an instruction currently in stage 1
	-- (fetching operands)
	source_i_rgi(1)  <= reg_set_to_read & first_source_reg_indx;
	source_ii_rgi(1) <= reg_set_to_read & second_source_reg_indx;

	-- Source register indexes of instructions currently in stages 2 or 3
	-- (Used by late forwarding for st instruction)
	source_ii_rgi(2) <= src_reg2_indx_s(2);
	source_ii_rgi(3) <= src_reg2_indx_s(3);

	-- Target register indexes of instructions in pipeline stages 1 to 5
	target_rgi(1)    <= reg_set_to_write      & trgt_reg_indx;
	target_rgi(2)    <= reg_set_to_write_s(2) & trgt_reg_indx_s(2);
	target_rgi(3)    <= reg_set_to_write_s(3) & trgt_reg_indx_s(3);
	target_rgi(4)    <= reg_set_to_write_s(4) & trgt_reg_indx_s(4);
	target_rgi(5)    <= reg_set_to_write_s(5) & trgt_reg_indx_s(5);

	-- Special registers:
	-- PSR cannot be written, SPSR can be written if
	-- scall instruction is not on pipeline
	process(target_rgi, write_reg_file, source_i_rgi, source_ii_rgi)
	begin
		if target_rgi(1) = PSR_INDX then
			psr_as_target <= '1';
		else
			psr_as_target <= '0';
		end if;
		if target_rgi(1) = SPSR_INDX then
			spsr_as_target_a <= write_reg_file;
		else
			spsr_as_target_a <= '0';
		end if;
	end process;

	-----------------------------------------------------------------
	-- Source and target register indexes for flag register bank
	-----------------------------------------------------------------
	fsource_rgi <= cond_reg_src;
	ftarget_rgi <= ftrg_reg_indx(2);

	-----------------------------------------------------------------
	-- Evaluating all dependencies
	-----------------------------------------------------------------
	process(source_i_rgi, source_ii_rgi, target_rgi, fsource_rgi, ftarget_rgi,
	        write_reg_file_s, update_all_flags, need_flags, need_reg_operand1,
			need_reg_operand2, update_flags_s)
	begin
		-- 1st register operand
		if(source_i_rgi(1) = target_rgi(2))then
			dep2_i <= need_reg_operand1 and write_reg_file_s(2)(0);
		else
			dep2_i <= '0';
		end if;
		if(source_i_rgi(1) = target_rgi(3))then
			dep3_i <= need_reg_operand1 and write_reg_file_s(3)(0);
		else
			dep3_i <= '0';
		end if;
		if(source_i_rgi(1) = target_rgi(4))then
			dep4_i <= need_reg_operand1 and write_reg_file_s(4)(0);
		else
			dep4_i <= '0';
		end if;

		-- 2nd register operand
		if(source_ii_rgi(1) = target_rgi(2))then
			dep2_ii <= need_reg_operand2 and write_reg_file_s(2)(0);
		else
			dep2_ii <= '0';
		end if;
		if(source_ii_rgi(1) = target_rgi(3))then
			dep3_ii <= need_reg_operand2 and write_reg_file_s(3)(0);
		else
			dep3_ii <= '0';
		end if;
		if(source_ii_rgi(1) = target_rgi(4))then
			dep4_ii <= need_reg_operand2 and write_reg_file_s(4)(0);
		else
			dep4_ii <= '0';
		end if;

		-- Dependencies for late forwarding of 2nd operand of a store
		-- instruction. Note that we are using other bit of write_reg_file
		-- than above. Should be the bit which is not cleared by scall
		-- instruction entering the pipeline.
		if(source_ii_rgi(3) = target_rgi(4))then
			dep34_ii <= write_reg_file_s(4)(1);
		else
			dep34_ii <= '0';
		end if;

		if(source_ii_rgi(3) = target_rgi(5))then
			dep35_ii <= write_reg_file_s(5)(1);
		else
			dep35_ii <= '0';
		end if;

		-- Condition registers
		if(fsource_rgi = ftarget_rgi)then
			dep_cr <= need_flags and (update_flags_s(2) or update_all_flags(2));
		else
			dep_cr <= update_all_flags(2) and need_flags;
		end if;
	end process;

	-- Discard signal is used to flush an instruction when its execution
	-- condition is false.
	discard <= not execute;
	-----------------------------------------------------------------------
	-- Forward and stall signals caused by data dependencies
	-----------------------------------------------------------------------
	-- If multiple instructions have the same target register, only the one
	-- latest in the order of execution is taken into account.
	-- Data forwarding is slightly different for register jumps
	-- and ALU operands: ALU operands are clocked directly to
	-- operand registers whereas data used as address is clocked first
	-- to a pipeline register of the following stage and the forwarded
	-- to program counter, PC. Register jumps cause an additional stall
	-- cycle in case of a dependency.
	-- If an instruction is discarded because of its execution condition
	-- is false, we should not stall (if condition flags are not ready
	-- we stall stage 1 anyway).

	-- data dependency of the 2nd operand of st instruction never causes
	-- stalling because there's two points for forwarding: If the data is
	-- not ready in at the 1st point, it will be at 2nd point.

	-- Data ready encoding:
	-- data ready after 1 ALU cycle  - "11"
	-- data ready after 2 ALU cycles - "10"
	-- data ready after 3 ALU cycles - "00"
	-- Example: data_ready_s(2)(4) = '1' means that data calculated by an
	-- instruction currently in stage 2 will be ready (available)
	-- in stage 4 or earlier. Ready in this case means that the data can
	-- be read from an output of a pipeline register. Forwarding of register
	-- operands is asynchronous (data is routed from the input of a pipeline
	-- register instead of output), which means that we can forward data
	-- from stage x if it will be ready in stage x+1. This does not apply
	-- for register jumps.
	------------------------------------------------------------------------

	process(dep4_i, dep3_i, dep2_i, discard, data_ready_s, is_reg_jump)
		variable dependency    : std_logic_vector(2 downto 0);
		variable alu_operation : std_logic_vector(1 downto 0);
	begin
		-- Forward control for 1st ALU operand
		-- Stall control for 1st register operand (includes jumps)
		dependency(2) := dep4_i;
		dependency(1) := dep3_i;
		dependency(0) := dep2_i;
		alu_operation(1) := not is_reg_jump;
		alu_operation(0) := not is_reg_jump;

		case dependency is
			when "000" => -- No need to forward
				alu_op_i_fwd_i <= "00";
				alu_stall_i  <= '0';
				jmp_stall    <= '0';
			when "001" => -- Forward data evaluated in stage 2
				alu_op_i_fwd_i <= "01" and alu_operation;
				alu_stall_i    <= not(data_ready_s(2)(3)) and not discard;
				jmp_stall      <= is_reg_jump and not discard;
			when "010" => -- Forward data evaluated in stage 3
				alu_op_i_fwd_i <= "10" and alu_operation;
				alu_stall_i    <= not(data_ready_s(3)(4)) and not discard;
				jmp_stall      <= is_reg_jump and not(data_ready_s(3)(3)) and not discard;
			when "011" => -- Forward data evaluated in stage 2
				alu_op_i_fwd_i <= "01" and alu_operation;
				alu_stall_i    <= not(data_ready_s(2)(3)) and not discard;
				jmp_stall      <= is_reg_jump and not discard;
			when "100" => -- Forward data evaluated in stage 4
				alu_op_i_fwd_i <= "11" and alu_operation;
				alu_stall_i    <= '0'; -- data will always be ready 
				jmp_stall      <= is_reg_jump and not(data_ready_s(4)(4)) and not discard;
			when "101" => -- Forward data evaluated in stage 2
				alu_op_i_fwd_i <= "01" and alu_operation;
				alu_stall_i    <= not(data_ready_s(2)(3)) and not discard;
				jmp_stall      <= is_reg_jump and not discard;
			when "110" =>  -- Forward data evaluated in stage 3
				alu_op_i_fwd_i <= "10" and alu_operation;
				alu_stall_i    <= not(data_ready_s(3)(4)) and not discard;
				jmp_stall      <= is_reg_jump and not(data_ready_s(3)(3)) and not discard;
			when "111" => -- Forward data evaluated in stage 2
				alu_op_i_fwd_i <= "01" and alu_operation;
				alu_stall_i    <= not(data_ready_s(2)(3)) and not discard;
				jmp_stall      <= is_reg_jump and not discard;
			when others => -- for simulation only
				alu_op_i_fwd_i <= "00";
				alu_stall_i    <= '0';
				jmp_stall      <= '0';
		end case;
	end process;

	alu_op_i_fwd <= alu_op_i_fwd_i;
	---------------------------------------------------------------------------
	-- Forward and stall control for 2nd ALU operand.
	-- Note that even though st -instruction needs both register
	-- operands, not having 2nd operand available in stage 1 does
	--  not cause a stall because it can be forwarded later just
	-- before memory access!
	---------------------------------------------------------------------------
	process(dep4_ii, dep3_ii, dep2_ii, discard, data_ready_s, store)
		variable dependency : std_logic_vector(2 downto 0);
	begin
		dependency(2) := dep4_ii;
		dependency(1) := dep3_ii;
		dependency(0) := dep2_ii;
		case dependency is
			when "000" => -- No need to forward
				alu_op_ii_fwd_i <= "00";
				alu_stall_ii    <= '0';
			when "001" => -- Forward data evaluated in stage 2
				alu_op_ii_fwd_i <= "01";
				alu_stall_ii    <= not(data_ready_s(2)(3)) and not store
				                   and not discard;
			when "010" => -- Forward data evaluated in stage 3
				alu_op_ii_fwd_i <= "10";
				alu_stall_ii    <= not(data_ready_s(3)(4)) and not store
				                   and not discard;
			when "011" => -- Forward data evaluated in stage 2
				alu_op_ii_fwd_i <= "01";
				alu_stall_ii    <= not(data_ready_s(2)(3)) and not store
				                   and not discard;
			when "100" => -- Forward data evaluated in stage 4
				alu_op_ii_fwd_i <= "11";
				alu_stall_ii    <= '0'; -- will always be ready 
			when "101" => -- Forward data evaluated in stage 2
				alu_op_ii_fwd_i <= "01";
				alu_stall_ii    <= not(data_ready_s(2)(3)) and not store
				                   and not discard;
			when "110" =>  -- Forward data evaluated in stage 3
				alu_op_ii_fwd_i <= "10";
				alu_stall_ii    <= not(data_ready_s(3)(4)) and not store
				                   and not discard;
			when "111" => -- Forward data evaluated in stage 2
				alu_op_ii_fwd_i <= "01";
				alu_stall_ii    <= not(data_ready_s(2)(3)) and not store
				                   and not discard;
			when others => -- just for simulation
				alu_op_ii_fwd_i <= "00";
				alu_stall_ii    <= '0';
		end case;
	end process;
	alu_op_ii_fwd <= alu_op_ii_fwd_i;

	---------------------------------------------------------------------------
	-- Asynchronous forwarding cannot be applied when loading data from memory
	-- because that would reduce memory access time which is unacceptable. Forwarding
	-- of fetched data is done with additional multiplexers just before ALU
	-- (adding some delay to ALU data path). Here's the control
	---------------------------------------------------------------------------
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			mdata_fwd_op_i  <= '0';
			mdata_fwd_op_ii <= '0';
			mdata_fwd_st    <= '0';
		elsif clk'event and clk = '1' then
			if enable_i(1) = '1' then
				-- trying to forward data from stage 4 while loading memory data.
				-- (internal_access - access to core configuration block)
				if alu_op_i_fwd_i = "11" then
					mdata_fwd_op_i <= load_s(4) and not internal_access;
				else
					mdata_fwd_op_i <= '0';
				end if;
				-- Same as above except with store instruction: store uses immediate
				-- value as 2nd ALU operand even though it needs two register operands
				-- as well.
				if alu_op_ii_fwd_i = "11" then
					mdata_fwd_op_ii <= load_s(4) and not internal_access and not store;
				else
					mdata_fwd_op_ii <= '0';
				end if;
				-- Finally forwarding 2nd register operand of store instruction
				-- (data to be written to memory) separately.
				if alu_op_ii_fwd_i = "11" then
					mdata_fwd_st <= load_s(4) and not internal_access;
				else
					mdata_fwd_st <= '0';
				end if;
			end if;
		end if;
	end process;

	---------------------------------------------------------------------------
	-- Data forwarding of register jumps and late forwarding for st -instruction.
	-- Again late forwarding of data which is fetched from memory gives us
	-- a headache. This is solved by an additional signal which controls
	-- the memory interface block directly. Power saving feature which holds
	-- data from previous access on bus is used as a way to forward data!
	-- (a store instruction following a load instruction)
	---------------------------------------------------------------------------
	process(dep34_ii, dep35_ii, dep3_i, dep4_i, load_s, internal_access)
	begin
		if dep34_ii = '1' then
			d_cache_data_fwd <= "01";
			d_cache_if_use_prev_data <= load_s(4) and not internal_access;
		elsif dep35_ii = '1' then
			d_cache_data_fwd <= "10";
			d_cache_if_use_prev_data <= '0';
		else
			d_cache_data_fwd <= "00";
			d_cache_if_use_prev_data <= '0';
		end if;
		if dep3_i = '1' then
			reg_jmp_fwd <= "01";
		elsif dep4_i = '1' then
			reg_jmp_fwd <= "10";
		else
			reg_jmp_fwd <= "00";
		end if;
	end process;
	
	
	--------------------------------------------------------------------------
	-- Memory and coprocessor access wait cycle counters.
	--------------------------------------------------------------------------
	-- Wait cycle counters are loaded with new value when appropiate
	-- instruction enters access stage. nonzero value in any of the
	-- counters will stall the pipeline fully or partially.
	-- Counters run independent of other stalls merely just keeping address
	-- (and data) and control signals valid for a minimum of predefined
	-- number of cycles.
	--------------------------------------------------------------------------
	one <= '1';

	wait_cycle_counter_imem : counter_4bit
	generic map
	(
		reset_value_g => 15 --"1111"
	)
	port map
	( 
		start_value => wait_cycles(3 downto 0),
		load        => start_imem_access,
		zero        => open,
		clk         => clk,
		rst_n       => rst_n,
		nonzero     => imem_wait,
		down        => one
	);

	wait_cycle_counter_dmem : counter_4bit
	generic map
	(
		reset_value_g => 0 --"0000"
	)
	port map
	( 
		start_value => wait_cycles(7 downto 4),
		load        => start_dmem_access_i,
		zero        => open,
		clk         => clk,
		rst_n       => rst_n,
		nonzero     => dmem_wait,
		down        => one
	);

	wait_cycle_counter_cop : counter_4bit
	generic map
	(
		reset_value_g => 0 --"0000"
	)
	port map
	( 
		start_value => wait_cycles(11 downto 8),
		load        => start_cop_access,
		zero        => open,
		clk         => clk,
		rst_n       => rst_n,
		nonzero     => cop_stall,
		down        => one
	);

	-- Evaluation of control signals for wait cycle counters
	start_dmem_access_i <= (load_s(3) or store_s(3)) and enable_i(3)
	                        and not ccb_access and not flush_i(3);

	start_cop_access  <= cop_inst_s(2) and enable_i(2) and not flush_i(2);

	start_imem_access <= write_pc_i;

	--------------------------------------------------------------------------
	-- Derived signals from wait cycle counters outputs, internal
	-- and external signals
	--------------------------------------------------------------------------

	-- Few instructions cause following instructions to be flushed:
	-- scall and retu => flush the instruction in jump slot
	-- reti => flush three following instructions
	-- swm  => flush two following instructions
	-- All flushed instructions should be nops (if using conforming assembler)

	-- flush_fetch - discard fetched instruction, do not wait fetch to complete
	flush_fetch <= scall or retu or reti or reti_s(2) or reti_s(3) or swm or swm_s(2);

	-- d_cache_miss input might go active even though the core is not accessing
	-- memory. (This depends on implementation of data cache controller).

	-- d_cache_miss_i - requested data is not in cache, have to wait
	d_cache_miss_i <= (load_s(4) or store_s(4)) and d_cache_miss and not internal_access;


	---------------------------------------------------------------------------
	-- stall signals derived from internal and external signals
	---------------------------------------------------------------------------
	-- imem_stall - Wait for fetch to complete, allow rest to run
	imem_stall <= (imem_wait or i_cache_miss) and not flush_fetch;
	-- dmem_stall - Halt the whole pipeline
	dmem_stall     <= d_cache_miss_i or dmem_wait;
	-- bus_stall - Halt the whole pipeline (bus is needed but reserved)
	bus_stall <= new_access_pending and bus_req;

	-- A 32 bit multiplication instruction followed by a mulhi -instruction
	-- is an atomic pair, that is, they cannot be executed separately. We
	-- cannot allow multiplication instruction to proceed 
	-- without mulhi. Also, a jump instruction cannot be executed
	-- because we must fetch the slot instruction before writing PC.
	-- Jump instructions which do not require fetching slot instruction:
	-- scall and retu (they must be followed by nop)

	-- atomic_stall - wait for fetch to complete, freeze decode stage
	atomic_stall  <= (imem_wait or i_cache_miss) and not discard and not retu 
	                 and (is_32b_mul or is_reg_jump or is_rel_jump);

	-- Flag dependency will always cause one cycle stall even though
	-- the instruction might not be executed at all.
	-- stall fetch and decode, let the head run
	cond_stall <= dep_cr;

	---------------------------------------------------------------------------
	-- External and internal stall signals combined to pipeline register enables
	-- and flush signals.
	---------------------------------------------------------------------------

	write_pc_i <= (not(cop_stall or dmem_stall or imem_stall or stall or bus_stall
	               or cond_stall or jmp_stall or alu_stall_i or alu_stall_ii) or
	               status_override) and not freeze_pc;

	enable_i(0)  <= not(cop_stall or dmem_stall or bus_stall or stall or
	              cond_stall or jmp_stall or alu_stall_ii or
	              alu_stall_i or atomic_stall) or flush_stage(0);

	enable_i(1)  <= not(cop_stall or dmem_stall or bus_stall or stall) or 
	              flush_stage(1);

	enable_i(2)  <= not(cop_stall or dmem_stall or bus_stall or stall) or 
	              flush_stage(2);

	enable_i(3)  <= not(cop_stall or dmem_stall or bus_stall or stall) or 
	              flush_stage(3);

	enable_i(4)  <= not(cop_stall or dmem_stall or bus_stall or stall) or 
	              flush_stage(4);

	enable_i(5)  <= not(cop_stall or dmem_stall or bus_stall or stall);

	-- Flush signals coming from master control override flush signals calculated
	-- here => they must also set enable signals high in order to do the actual
	-- flushing because normally(in this design) enable overrides flush.

	-- Enable overrides flush => No need to disable flush -signals
	-- in case of stalls.
	flush_i(0) <= imem_stall or flush_fetch or insert_nops or flush_stage(0);

	flush_i(1) <= cond_stall or jmp_stall or alu_stall_i or alu_stall_ii or
	            atomic_stall or discard or flush_stage(1);

	flush_i(2)  <= flush_stage(2);

	flush_i(3)  <= flush_stage(3);
	flush_i(4)  <= flush_stage(4);


	--------------------------------------------------------------------
	-- Data bus interface signals & control
	--------------------------------------------------------------------
	-- These asynchronous signals cause data bus interface block to
	-- drive its synchronous outputs to correct states.
	dmem_access_complete <= not dmem_stall;
	-- bus requested by an external device and core is not using it anymore
	-- => float the bus on next cycle (access will always be granted)
	-- the bus will be floated as long as bus_req is high
	float <= dmem_access_complete and bus_req;
	-- last cycle of the current access, clock data in from bus (reads only)
	access_complete   <= dmem_access_complete;
	-- new access started on the next clock cycle.
	start_dmem_access <= start_dmem_access_i;

	new_access_pending <= (load_s(3) or store_s(3)) and not ccb_access and not flush_i(3);
	--------------------------------------------------------------------
	-- 'state machine' controlling the handshake signals of data bus
	--------------------------------------------------------------------
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			bus_state <= RESERVED;
			bus_ack <= '0';
		elsif clk'event and clk = '1' then
			case bus_state is
			when RESERVED => -- used externally
				-- pull ack low if core needs the bus
				bus_ack <= bus_req and not new_access_pending;
				-- bus state transitions
				if bus_req = '1' then
					bus_state <= RESERVED;
				elsif new_access_pending = '1' then
					bus_state <= ACCESSED;
				else
					bus_state <= IDLE;
				end if;
			when IDLE =>
				-- assert ack if bus is requested
				bus_ack <= bus_req;
				-- bus state transitions
				if bus_req = '1' then
					bus_state <= RESERVED;
				elsif new_access_pending = '1' then
					bus_state <= ACCESSED;
				else
					bus_state <= IDLE;
				end if;
			when ACCESSED =>
				-- assert ack as soon as current access completes
				bus_ack <= bus_req and dmem_access_complete;
				-- bus state transitions
				if bus_req = '1' then
					if dmem_access_complete = '1' then
						bus_state <= RESERVED;
					else
						bus_state <= ACCESSED;
					end if;
				elsif new_access_pending = '1' or dmem_access_complete = '0' then
					bus_state <= ACCESSED;
				else
					bus_state <= IDLE;
				end if;
			when others => -- Unknown
				bus_ack <= '0';
				bus_state <= RESERVED;
			end case;
		end if;
	end process;

	--------------------------------------------------------------------------
	-- Some inputs
	--------------------------------------------------------------------------
	need_flags              <= cond_execute;
	is_safe_a(3)            <= safe_state(2);
	is_safe_a(2)            <= safe_state(1);
	is_safe_a(1)            <= safe_state(0);

	--------------------------------------------------------------------------
	-- Various outputs...
	--------------------------------------------------------------------------

	-- popping context information from hardware stack when returning from
	-- an interrupt service routine.
	 process(clk, rst_n)
	 begin
	 	if rst_n = '0' then
			pop_s <= '0';
		elsif clk'event and clk = '1' then
			pop_s <= reti_s(2) and enable_i(2) and not flush_i(2);
		end if;
	 end process;
 
	done      <= pop_s;
	pop       <= pop_s;

	-- data flow control
	rf_wr_rs   <= reg_set_to_write_s(5);
	rf_wr_reg  <= trgt_reg_indx_s(5);
	cr_wr_reg  <= ftrg_reg_indx(3);
	cr_we      <= update_flags_s(3);
	cr_we_all  <= update_all_flags(3);
	rf_we_data <= write_reg_file_s(5)(0);
	rf_we_spsr <= scall and enable_i(1) and not flush_i(1);

	-- pipeline control
	write_pc  <= write_pc_i;	
	enable(0) <= enable_i(0);
	enable(1) <= enable_i(1);
	enable(2) <= enable_i(2);
	enable(3) <= enable_i(3);
	enable(4) <= enable_i(4);
	enable(5) <= enable_i(5);

	flush <= flush_i(3 downto 0);
--	flush <= flush_i;	-- debug version

	-- Changing decoding mode might change the length of instruction which
	-- in turn changes increment of program counter => invalid address
	invalid_pc <= swm or swm_s(2);

	-- Signalling to master control/interrupt control that interrupt request
	-- was accepted and status modified.
	process(rst_n, clk)
	begin
		if rst_n = '0' then
			int_ack_s <= '0';
			int_req_s <= '0';
		elsif clk'event and clk = '1' then
			int_req_s <= int_req;
			int_ack_s <= wr_en_psr_s and write_pc_i and int_req and not int_ack_s;
		end if;
	end process;

	int_ack <= int_ack_s; -- goes directly to interrupt handler

	-- when master control asserts int_req, values in PC, PSR and CR0 should
	-- correspond the status of the interrupted instruction. The values
	-- are pushed to hardware stack only once (on rising edge of int_req)
	push    <= int_req and not int_req_s; -- save PC, PSR and CR0

	-- Each instruction carries a three bit code which contains information
	-- about the 'safety' of an instruction. An instruction is considered to
	-- be safe if it has proceeded far enough not to cause exceptions or 
	-- modify critical resources. Coding is shown below
	-- safe_state = "000" - Will be 'safe' in stage 4
	-- safe_state = "100" - Will be 'safe' in stage 3
	-- safe_state = "110" - Will be 'safe' in stage 2
	-- safe_state = "111" - Will be 'safe' in stage 1
	safe_to_switch_cntxt <= is_safe_a(1) and is_safe(2)(2) and is_safe(3)(3);

	---------------------------------------------------------------------------
	-- program counter source selection. 
	---------------------------------------------------------------------------
	-- PC sources:
	-- 000 - sequential execution, incremented address
	-- 001 - pc relative jump address
	-- 010 - register jump address
	-- 011 - interrupt address (driven via override)
	-- 100 - exception address (driven via override)
	-- 101 - system address (scall)
	-- 110 - external boot address (driven via override)
	-- 111 - popped address from hardware stack

	process(is_reg_jump, is_rel_jump, sel_pc_override, pop_s, flush_i, scall)
		variable absjump, reljump, syscall: std_logic;
	begin
		-- These variables are mutually exclusive, so we can optimize a bit.
		-- (Unnecessary optimization is the root of evil)
		absjump := is_reg_jump and not flush_i(1);
		reljump := is_rel_jump and not flush_i(1);
		syscall := scall and not flush_i(1);

		if sel_pc_override = "000" then
			sel_pc_i(2) <= pop_s or syscall;
			sel_pc_i(1) <= absjump or pop_s;
			sel_pc_i(0) <= reljump or syscall or pop_s;
		else
			sel_pc_i <= sel_pc_override;
		end if;
	end process;

	sel_pc <= sel_pc_i;

	-- jumped - signal is needed by master control -unit to cope with the problem
	-- encountered when a 32 bit multiplication instruction is placed into branch
	-- slot: Usually when a context switch request is signalled while one of the
	-- 32 bit multiplication instructions is in stage 1, the address of that
	-- instruction is saved instead of the address in PC. This is because PC might
	-- point to a mulhi -instruction which cannot be executed on its own.
	-- If the instruction is in branch slot and the branch is taken, the saved
	-- address should be the target of the jump. Then again, if the branch
	-- is not taken, the address of the slot instruction (mul32 only) should be
	-- saved!
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			jumped_q <= '0';
		elsif clk'event and clk = '1' then
			-- 
			if sel_pc_i = "001" or sel_pc_i = "010" then
				jumped_q <= write_pc_i;
			else
				jumped_q <= '0';
			end if;
		end if;
	end process;
	---------------------------------------------------------------------------
	-- Processor status register source selection
	---------------------------------------------------------------------------
	-- PSR sources
	-- 000 Current PSR
	-- 001 new PSR by instructions which update PSR...
	-- 010 interrupt PSR (driven via override)
	-- 011 popped PSR from hw stack
	-- 100 exception PSR (driven via override)
	-- 101 SPSR
	process(instruction_updates_psr, sel_psr_override, pop_s, retu, flush_i)
		variable new_psr, spsr : std_logic;
	begin
		-- These variables are mutually exclusive, so we can optimize a bit.
		-- (Unnecessary optimization is the root of evil)
		new_psr := instruction_updates_psr and not flush_i(1); -- special instruction 
		spsr    := retu and not flush_i(1); -- copy from spsr
		if sel_psr_override = "000" then
			sel_psr(0) <= new_psr or spsr or pop_s;
			sel_psr(1) <= pop_s;
			sel_psr(2) <= spsr;
		else
			sel_psr   <= sel_psr_override;
		end if;
	end process;

	wr_en_psr_s  <= pop_s or status_override or (enable_i(1) and not flush_i(1));
	wr_en_psr    <= wr_en_psr_s;

	-- scall will lock SPSR -register to preserve order of execution.
	pr30lock(2) <= spsr_as_target(2) and scall and not flush_i(1);
	pr30lock(3) <= spsr_as_target(3) and scall and not flush_i(1);
	pr30lock(4) <= spsr_as_target(4) and scall and not flush_i(1);

	--------------------------------------------------------------------------
	-- The control pipeline used to preserve relevant information about
	-- instructions currently on data pipeline
	--------------------------------------------------------------------------
	-- synchronous signals, kept data
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			write_reg_file_s   <= (others => (others => '0'));
			load_s             <= (others => '0');
			store_s            <= (others => '0');
			cop_inst_s         <= (others => '0');
			update_flags_s     <= (others => '0');
			update_all_flags   <= (others => '0');
			reti_s             <= (others => '0');
			data_ready_s       <= (others => (others => '0'));
			reg_set_to_write_s <= (others => '0');
			trgt_reg_indx_s    <= (others => (others => '0'));
			ftrg_reg_indx      <= (others => (others => '0'));
			swm_s              <= (others => '0');
			is_safe            <= (others => (others => '0'));
			internal_access    <= '0';
			spsr_as_target     <= (others => '0');
			src_reg2_indx_s    <= (others => (others => '0'));
		elsif clk'event and clk = '1' then
		-- When stage i is enabled data can be clocked to stage i+1
		-- Flushing will clear only signals which affect control.

		-- A scall -instruction in stage 1 will lock SPSR register for three
		-- clock cycles. This prevents instructions further on the pipeline
		--(instructions before the scall in the order of execution) from
		-- updating SPSR. This guarantees the right order of execution and
		-- safe return using retu -instruction.
		-- Note, that data forwarding should also be affected except the
		-- late forwarding of a st -instruction.
			if enable_i(1) = '1' then
				src_reg2_indx_s(2)     <= source_ii_rgi(1);
				write_reg_file_s(2)(0) <= write_reg_file and not psr_as_target and not flush_i(1);
				write_reg_file_s(2)(1) <= write_reg_file and not psr_as_target and not flush_i(1);
				load_s(2)              <= load and not flush_i(1);
				store_s(2)             <= store and not flush_i(1);
				cop_inst_s(2)          <= cop_inst and not flush_i(1);
				update_flags_s(2)      <= update_flags and not flush_i(1);
				update_all_flags(2)    <= rcon and not flush_i(1);
				reti_s(2)              <= reti and not flush_i(1);
				spsr_as_target(2)      <= spsr_as_target_a and not flush_i(1);
				data_ready_s(2)        <= data_ready;
				reg_set_to_write_s(2)  <= reg_set_to_write or scall; -- scall writes PR31 instead of R31
				trgt_reg_indx_s(2)     <= trgt_reg_indx;
				ftrg_reg_indx(2)       <= cond_reg_trgt;
				swm_s(2)               <= swm and not flush_i(1);
				is_safe(2)             <= is_safe_a or (flush_i(1) & flush_i(1) & flush_i(1));
			end if;
			if enable_i(2) = '1' then
				src_reg2_indx_s(3)     <= src_reg2_indx_s(2);
				spsr_as_target(3)      <= spsr_as_target(2) and not flush_i(2);
				write_reg_file_s(3)(0) <= write_reg_file_s(2)(0) and not pr30lock(2) and not flush_i(2);
				write_reg_file_s(3)(1) <= write_reg_file_s(2)(1) and not flush_i(2);
				load_s(3)              <= load_s(2) and not flush_i(2);
				store_s(3)             <= store_s(2) and not flush_i(2);
				reti_s(3)              <= reti_s(2) and not flush_i(2);
				update_flags_s(3)      <= update_flags_s(2) and not flush_i(2);
				update_all_flags(3)    <= update_all_flags(2) and not flush_i(2);
				data_ready_s(3)        <= data_ready_s(2);
				reg_set_to_write_s(3)  <= reg_set_to_write_s(2);
				trgt_reg_indx_s(3)     <= trgt_reg_indx_s(2);
				ftrg_reg_indx(3)       <= ftrg_reg_indx(2);
				swm_s(3)               <= swm_s(2) and not flush_i(2);
				is_safe(3)             <= is_safe(2) or (flush_i(2) & flush_i(2) & flush_i(2));
			end if;
			if enable_i(3) = '1' then
				spsr_as_target(4)      <= spsr_as_target(3) and not flush_i(3);
				write_reg_file_s(4)(0) <= write_reg_file_s(3)(0) and not pr30lock(3) and not flush_i(3);
				write_reg_file_s(4)(1) <= write_reg_file_s(3)(1) and not flush_i(3);
				load_s(4)              <= load_s(3) and not flush_i(3);
				store_s(4)             <= store_s(3) and not flush_i(3);
				data_ready_s(4)        <= data_ready_s(3);
				reg_set_to_write_s(4)  <= reg_set_to_write_s(3);
				trgt_reg_indx_s(4)     <= trgt_reg_indx_s(3);
				internal_access        <= ccb_access;
			end if;
			if enable_i(4) = '1' then
				write_reg_file_s(5)(0) <= write_reg_file_s(4)(0) and not pr30lock(4) and not flush_i(4);
				write_reg_file_s(5)(1) <= write_reg_file_s(4)(1) and not flush_i(4);
				reg_set_to_write_s(5)  <= reg_set_to_write_s(4);
				trgt_reg_indx_s(5)     <= trgt_reg_indx_s(4);
			end if;
		end if;
	end process;
end ccu_flow_control_debug_arch;

