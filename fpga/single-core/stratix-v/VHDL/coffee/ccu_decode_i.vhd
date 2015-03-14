------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:23 01/03/06
-- File : ccu_decode_i.vhd
-- Design : ccu_decode_i
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY ccu_decode_i IS
   PORT( 
      cex_bit                 : IN     std_logic;
      creg_field              : IN     std_logic_vector (2 DOWNTO 0);
      opcode                  : IN     std_logic_vector (5 DOWNTO 0);
      variable_shift          : IN     std_logic;
      alu_of_check_en_a       : OUT    std_logic;
      alu_op_code_a           : OUT    std_logic_vector (9 DOWNTO 0);
      cond_execute            : OUT    std_logic;
      cond_reg_src            : OUT    std_logic_vector (2 DOWNTO 0);
      cond_reg_trgt           : OUT    std_logic_vector (2 DOWNTO 0);
      cop_inst                : OUT    std_logic;
      data_ready              : OUT    std_logic_vector (1 DOWNTO 0);
      instruction_updates_psr : OUT    std_logic;
      is_reg_jump             : OUT    std_logic;
      is_rel_jump             : OUT    std_logic;
      load                    : OUT    std_logic;
      mul32bit                : OUT    std_logic;
      need_reg_operand1       : OUT    std_logic;
      need_reg_operand2       : OUT    std_logic;
      rcon                    : OUT    std_logic;
      rd_cop                  : OUT    std_logic;
      reti                    : OUT    std_logic;
      retu                    : OUT    std_logic;
      safe_state              : OUT    std_logic_vector (2 DOWNTO 0);
      scall                   : OUT    std_logic;
      sel_data_to_cop_a       : OUT    std_logic;
      store                   : OUT    std_logic;
      swm                     : OUT    std_logic;
      update_flags            : OUT    std_logic;
      wr_cop                  : OUT    std_logic;
      write_reg_file          : OUT    std_logic
   );

-- Declarations

END ccu_decode_i ;

architecture ccu_decode_i_arch of ccu_decode_i is

	signal n                  : std_logic_vector(63 downto 0);
	signal c                  : std_logic_vector(5 downto 0);
	signal safe_in_stage      : std_logic_vector(4 downto 2);
	signal is_branch          : std_logic;
	signal is_jump_s          : std_logic;
	signal is_rel_jump_s      : std_logic;
	signal is_reg_jump_s      : std_logic;
	signal two_alu_cycles     : std_logic;
	signal three_alu_cycles   : std_logic;
	signal immediate_shift    : std_logic;
	signal implicit_write_cr0 : std_logic;
	signal updates_cr0        : std_logic;

begin

	-- Some arithmetic instructions write CR0 implicitly...
	implicit_write_cr0 <= n(add_opc_i) or n(addi_opc_i) or n(addiu_opc_i) or
	                      n(addu_opc_i) or n(sub_opc_i) or n(subu_opc_i) or
	                      n(sll_opc_i) or n(rcon_opc_i) or n(reti_opc_i);

	-- CR0 is updated either implicitly by some instruction or when flags 
	-- resulting from a comparison are targeted to CR0 (or by rcon).

	updates_cr0 <= implicit_write_cr0 or ((n(cmp_opc_i) or n(cmpi_opc_i)) and
	               not creg_field(2) and not creg_field(1) and not creg_field(0));

	process(implicit_write_cr0, creg_field)
	begin
		if implicit_write_cr0 = '1' then
			cond_reg_trgt <= "000";
		else
			cond_reg_trgt <= creg_field;
		end if;
	end process;


	cond_reg_src <= creg_field;

	alu_of_check_en_a <= n(add_opc_i) or n(addi_opc_i) or n(sub_opc_i);

	                     -- special encoding used with branches
	is_branch         <= opcode(5) and not opcode(4) and not opcode(3);

	is_rel_jump_s      <= is_branch or n(jal_opc_i) or n(jmp_opc_i);

	is_reg_jump_s      <= n(jalr_opc_i) or n(jmpr_opc_i) or n(retu_opc_i);

	is_jump_s         <= is_rel_jump_s or is_reg_jump_s;


	is_rel_jump        <= is_rel_jump_s;

	is_reg_jump        <= is_reg_jump_s;

	update_flags      <= n(add_opc_i) or n(addi_opc_i) or n(addu_opc_i) or
	                     n(addiu_opc_i) or n(cmp_opc_i) or n(cmpi_opc_i) or
	                     n(sll_opc_i) or n(slli_opc_i) or n(sub_opc_i)or
	                     n(subu_opc_i) or n(reti_opc_i);

	cond_execute      <= cex_bit and not n(cop_opc_i);
	cop_inst          <= n(cop_opc_i) or n(movtc_opc_i) or n(movfc_opc_i);
	load              <= n(ld_opc_i);
	rcon              <= n(rcon_opc_i);
	rd_cop            <= n(movfc_opc_i);
	reti              <= n(reti_opc_i);
	retu              <= n(retu_opc_i);
	scall             <= n(scall_opc_i);
	sel_data_to_cop_a <= not n(cop_opc_i);
	store             <= n(st_opc_i);
	swm               <= n(swm_opc_i);
	wr_cop            <= n(movtc_opc_i) or n(cop_opc_i);

	-- Only instructions which provide 'new' flags(retu not included here)
	instruction_updates_psr <= n(scall_opc_i) or n(swm_opc_i) or n(di_opc_i) or
	                           n(ei_opc_i) or n(chrs_opc_i);

	three_alu_cycles <= n(muli_opc_i) or n(muls_opc_i) or n(mulu_opc_i)
	                    or n(mulus_opc_i) or n(mulhi_opc_i) or n(ld_opc_i) 
						or n(movfc_opc_i);

	mul32bit         <= n(muli_opc_i) or n(muls_opc_i) or n(mulu_opc_i)
	                    or n(mulus_opc_i);

	two_alu_cycles   <= n(muls_16_opc_i) or n(mulu_16_opc_i) or n(mulus_16_opc_i) or
	                    n(scon_opc_i);

	-- Data ready encoding:
	-- data ready after 1 ALU cycle  - "11"
	-- data ready after 2 ALU cycles - "10"
	-- data ready after 3 ALU cycles - "00"

	data_ready(0) <= not two_alu_cycles and not three_alu_cycles;
	data_ready(1) <= not three_alu_cycles;

	
	write_reg_file <= (not is_jump_s and not n(cmpi_opc_i) and not n(cmp_opc_i) and
	                  not n(st_opc_i) and not n(cop_opc_i) and not n(movtc_opc_i)
	                  and not n(rcon_opc_i) and not n(trap_opc_i)and not n(nop_opc_i)
	                  and not n(chrs_opc_i) and not n(di_opc_i) and not n(ei_opc_i)
	                  and not n(swm_opc_i) and not n(reti_opc_i) and not n(retu_opc_i))
					  or n(jal_opc_i) or n(jalr_opc_i) or n(scall_opc_i);

	need_reg_operand1 <= not n(mulhi_opc_i) and not n(lli_opc_i) and not is_rel_jump_s
	                     and not n(cop_opc_i) and not n(movfc_opc_i) and not n(scon_opc_i) and not
	                     n(chrs_opc_i) and not n(di_opc_i) and not n(ei_opc_i) and not
	                     n(swm_opc_i) and not n(reti_opc_i) and not n(scall_opc_i)
						 and not n(nop_opc_i) and not n(trap_opc_i);


	immediate_shift   <= (n(slli_opc_i) or n(srli_opc_i) or n(srai_opc_i)) and not
	                     variable_shift;

				-- most of the instructions requiring two register operands
				-- have an opcode with msb zero.

	need_reg_operand2 <= (not opcode(5) and not n(trap_opc_i) and not n(rcon_opc_i)
	                     and not n(jmpr_opc_i) and not n(scon_opc_i) and not n(not_opc_i) and not 
	                     n(di_opc_i) and not n(ei_opc_i) and not n(reti_opc_i) and not n(mulhi_opc_i) and not 
	                     n(trap_opc_i) and not n(mov_opc_i) and not immediate_shift) or n(st_opc_i);
	---------------------------------------------------------------------------
	-- Evaluating safe state infromation.
	---------------------------------------------------------------------------
	-- An instruction is said to be in safe
	-- state when it cannot cause any exceptions further on pipeline nor change
	-- the status of the processor (including flags in CR0). Encoding used here:
	--
	-- safe_state = "000" - Will be 'safe' in stage 4
	-- safe_state = "100" - Will be 'safe' in stage 3
	-- safe_state = "110" - Will be 'safe' in stage 2
	-- safe_state = "111" - Will be 'safe' in stage 1
	
	safe_in_stage(2) <= n(chrs_opc_i) or n(di_opc_i) or n(ei_opc_i) or
	                    n(lui_opc_i) or n(lli_opc_i) or n(exbfi_opc_i)
	                    or n(cop_opc_i) or n(trap_opc_i);

	safe_in_stage(3) <= n(scall_opc_i) or n(swm_opc_i) or updates_cr0 or
	                    n(reti_opc_i) or is_jump_s;

	safe_in_stage(4) <= n(ld_opc_i) or n(st_opc_i);


	safe_state(0) <= not safe_in_stage(4) and not safe_in_stage(3) and
	                 not safe_in_stage(2);
	safe_state(1) <= not safe_in_stage(4) and not safe_in_stage(3);
	safe_state(2) <= not safe_in_stage(4);


	process(opcode)
	begin
		-- Decoding ALU opcode from instruction 'opcode'
		case opcode is
			when add_opc =>
				alu_op_code_a(4 downto 0) <= alu_add;
			when addi_opc =>
				alu_op_code_a(4 downto 0) <= alu_add;
			when addiu_opc =>
				alu_op_code_a(4 downto 0) <= alu_add;
			when addu_opc =>
				alu_op_code_a(4 downto 0) <= alu_add;
			when ld_opc =>
				alu_op_code_a(4 downto 0) <= alu_add;
			when st_opc =>
				alu_op_code_a(4 downto 0) <= alu_add;
			when and_opc =>
				alu_op_code_a(4 downto 0) <= alu_and;
			when andi_opc =>
				alu_op_code_a(4 downto 0) <= alu_and;
			when cmp_opc =>
				alu_op_code_a(4 downto 0) <= alu_cmp;
			when cmpi_opc =>
				alu_op_code_a(4 downto 0) <= alu_cmp;
			when conb_opc =>
				alu_op_code_a(4 downto 0) <= alu_conb;
			when conh_opc =>
				alu_op_code_a(4 downto 0) <= alu_conh;
			when lui_opc =>
				alu_op_code_a(4 downto 0) <= alu_conh;
			when exbf_opc =>
				alu_op_code_a(4 downto 0) <= alu_exbf;
			when exbfi_opc =>
				alu_op_code_a(4 downto 0) <= alu_exbf;
			when exb_opc =>
				alu_op_code_a(4 downto 0) <= alu_exb;
			when exh_opc =>
				alu_op_code_a(4 downto 0) <= alu_exh;
			when jal_opc =>
				alu_op_code_a(4 downto 0) <= alu_bypass_i;
			when jalr_opc =>
				alu_op_code_a(4 downto 0) <= alu_bypass_i;
			when mov_opc =>
				alu_op_code_a(4 downto 0) <= alu_bypass_i;
			when rcon_opc =>
				alu_op_code_a(4 downto 0) <= alu_bypass_i;
			when scall_opc =>
				alu_op_code_a(4 downto 0) <= alu_bypass_i;
			when lli_opc =>
				alu_op_code_a(4 downto 0) <= alu_bypass_ii;
			when muli_opc =>
				alu_op_code_a(4 downto 0) <= alu_muls;
			when muls_opc =>
				alu_op_code_a(4 downto 0) <= alu_muls;
			when muls_16_opc =>
				alu_op_code_a(4 downto 0) <= alu_muls_16;
			when mulu_opc =>
				alu_op_code_a(4 downto 0) <= alu_mulu;
			when mulu_16_opc =>
				alu_op_code_a(4 downto 0) <= alu_mulu_16;
			when mulus_opc =>
				alu_op_code_a(4 downto 0) <= alu_mulus;
			when mulus_16_opc =>
				alu_op_code_a(4 downto 0) <= alu_mulus_16;
			when not_opc =>
				alu_op_code_a(4 downto 0) <= alu_not;
			when or_opc =>
				alu_op_code_a(4 downto 0) <= alu_or;
			when ori_opc =>
				alu_op_code_a(4 downto 0) <= alu_or;
			when sext_opc =>
				alu_op_code_a(4 downto 0) <= alu_sext;
			when sexti_opc =>
				alu_op_code_a(4 downto 0) <= alu_sext;
			when sll_opc =>
				alu_op_code_a(4 downto 0) <= alu_sll;
			when sra_opc =>
				alu_op_code_a(4 downto 0) <= alu_sra;
			when srl_opc =>
				alu_op_code_a(4 downto 0) <= alu_srl;
			when sub_opc =>
				alu_op_code_a(4 downto 0) <= alu_sub;
			when subu_opc =>
				alu_op_code_a(4 downto 0) <= alu_sub;
			when xor_opc =>
				alu_op_code_a(4 downto 0) <= alu_xor;
			when others =>
				alu_op_code_a(4 downto 0) <= (others => '1');
		end case;

		case opcode is
			when sub_opc =>
				alu_op_code_a(6 downto 5) <= alu_asc_sub;
			when subu_opc =>
				alu_op_code_a(6 downto 5) <= alu_asc_sub;
			when cmp_opc =>
				alu_op_code_a(6 downto 5) <= alu_asc_cmp;
			when cmpi_opc =>
				alu_op_code_a(6 downto 5) <= alu_asc_cmp;
			when others =>
				alu_op_code_a(6 downto 5) <= alu_asc_add;
		end case;

		case opcode is
			-- bit 9 - 16 or 32 bit
			-- bit 8 - operand i type
			-- bit 7 - operand ii type
			when muli_opc =>
				alu_op_code_a(9 downto 7) <= "111";
			when muls_opc =>
				alu_op_code_a(9 downto 7) <= "111";
			when muls_16_opc =>
				alu_op_code_a(9 downto 7) <= "011";
			when mulu_opc =>
				alu_op_code_a(9 downto 7) <= "100";
			when mulu_16_opc =>
				alu_op_code_a(9 downto 7) <= "000";
			when mulus_opc =>
				alu_op_code_a(9 downto 7) <= "101";
			when mulus_16_opc =>
				alu_op_code_a(9 downto 7) <= "001";
			when others =>
				alu_op_code_a(9 downto 7) <= "000";
		end case;

	end process;


	---------------------------------------------------------------------------
	-- Decoding operation code
	---------------------------------------------------------------------------
	c     <= opcode;
    n(0)  <= not c(5) and not c(4) and not c(3) and not c(2) and not c(1) and not c(0);  --000000
    n(1)  <= not c(5) and not c(4) and not c(3) and not c(2) and not c(1) and c(0);  --000001
    n(2)  <= not c(5) and not c(4) and not c(3) and not c(2) and c(1) and not c(0);  --000010
    n(3)  <= not c(5) and not c(4) and not c(3) and not c(2) and c(1) and c(0);  --000011
    n(4)  <= not c(5) and not c(4) and not c(3) and c(2) and not c(1) and not c(0);  --000100
    n(5)  <= not c(5) and not c(4) and not c(3) and c(2) and not c(1) and c(0);  --000101
    n(6)  <= not c(5) and not c(4) and not c(3) and c(2) and c(1) and not c(0);  --000110
    n(7)  <= not c(5) and not c(4) and not c(3) and c(2) and c(1) and c(0);  --000111
    n(8)  <= not c(5) and not c(4) and c(3) and not c(2) and not c(1) and not c(0);  --001000
    n(9)  <= not c(5) and not c(4) and c(3) and not c(2) and not c(1) and c(0);  --001001
    n(10) <= not c(5) and not c(4) and c(3) and not c(2) and c(1) and not c(0);  --001010
    n(11) <= not c(5) and not c(4) and c(3) and not c(2) and c(1) and c(0);  --001011
    n(12) <= not c(5) and not c(4) and c(3) and c(2) and not c(1) and not c(0);  --001100
    n(13) <= not c(5) and not c(4) and c(3) and c(2) and not c(1) and c(0);  --001101
    n(14) <= not c(5) and not c(4) and c(3) and c(2) and c(1) and not c(0);  --001110
    n(15) <= not c(5) and not c(4) and c(3) and c(2) and c(1) and c(0);  --001111
    n(16) <= not c(5) and c(4) and not c(3) and not c(2) and not c(1) and not c(0);  --010000
    n(17) <= not c(5) and c(4) and not c(3) and not c(2) and not c(1) and c(0);  --010001
    n(18) <= not c(5) and c(4) and not c(3) and not c(2) and c(1) and not c(0);  --010010
    n(19) <= not c(5) and c(4) and not c(3) and not c(2) and c(1) and c(0);  --010011
    n(20) <= not c(5) and c(4) and not c(3) and c(2) and not c(1) and not c(0);  --010100
    n(21) <= not c(5) and c(4) and not c(3) and c(2) and not c(1) and c(0);  --010101
    n(22) <= not c(5) and c(4) and not c(3) and c(2) and c(1) and not c(0);  --010110
    n(23) <= not c(5) and c(4) and not c(3) and c(2) and c(1) and c(0);  --010111
    n(24) <= not c(5) and c(4) and c(3) and not c(2) and not c(1) and not c(0);  --011000
    n(25) <= not c(5) and c(4) and c(3) and not c(2) and not c(1) and c(0);  --011001
    n(26) <= not c(5) and c(4) and c(3) and not c(2) and c(1) and not c(0);  --011010
    n(27) <= not c(5) and c(4) and c(3) and not c(2) and c(1) and c(0);  --011011
    n(28) <= not c(5) and c(4) and c(3) and c(2) and not c(1) and not c(0);  --011100
    n(29) <= not c(5) and c(4) and c(3) and c(2) and not c(1) and c(0);  --011101
    n(30) <= not c(5) and c(4) and c(3) and c(2) and c(1) and not c(0);  --011110
    n(31) <= not c(5) and c(4) and c(3) and c(2) and c(1) and c(0);  --011111 not used
    n(32) <= c(5) and not c(4) and not c(3) and not c(2) and not c(1) and not c(0);  --100000
    n(33) <= c(5) and not c(4) and not c(3) and not c(2) and not c(1) and c(0);  --100001
    n(34) <= c(5) and not c(4) and not c(3) and not c(2) and c(1) and not c(0);  --100010
    n(35) <= c(5) and not c(4) and not c(3) and not c(2) and c(1) and c(0);  --100011
    n(36) <= c(5) and not c(4) and not c(3) and c(2) and not c(1) and not c(0);  --100100
    n(37) <= c(5) and not c(4) and not c(3) and c(2) and not c(1) and c(0);  --100101
    n(38) <= c(5) and not c(4) and not c(3) and c(2) and c(1) and not c(0);  --100110
    n(39) <= c(5) and not c(4) and not c(3) and c(2) and c(1) and c(0);  --100111
    n(40) <= c(5) and not c(4) and c(3) and not c(2) and not c(1) and not c(0);  --101000
    n(41) <= c(5) and not c(4) and c(3) and not c(2) and not c(1) and c(0);  --101001
    n(42) <= c(5) and not c(4) and c(3) and not c(2) and c(1) and not c(0);  --101010
    n(43) <= c(5) and not c(4) and c(3) and not c(2) and c(1) and c(0);  --101011
    n(44) <= c(5) and not c(4) and c(3) and c(2) and not c(1) and not c(0);  --101100
    n(45) <= c(5) and not c(4) and c(3) and c(2) and not c(1) and c(0);  --101101
    n(46) <= c(5) and not c(4) and c(3) and c(2) and c(1) and not c(0);  --101110
    n(47) <= c(5) and not c(4) and c(3) and c(2) and c(1) and c(0);  --101111
    n(48) <= c(5) and c(4) and not c(3) and not c(2) and not c(1) and not c(0);  --110000
    n(49) <= c(5) and c(4) and not c(3) and not c(2) and not c(1) and c(0);  --110001
    n(50) <= c(5) and c(4) and not c(3) and not c(2) and c(1) and not c(0);  --110010
    n(51) <= c(5) and c(4) and not c(3) and not c(2) and c(1) and c(0);  --110011
    n(52) <= c(5) and c(4) and not c(3) and c(2) and not c(1) and not c(0);  --110100
    n(53) <= c(5) and c(4) and not c(3) and c(2) and not c(1) and c(0);  --110101
    n(54) <= c(5) and c(4) and not c(3) and c(2) and c(1) and not c(0);  --110110
    n(55) <= c(5) and c(4) and not c(3) and c(2) and c(1) and c(0);  --110111
    n(56) <= c(5) and c(4) and c(3) and not c(2) and not c(1) and not c(0);  --111000
    n(57) <= c(5) and c(4) and c(3) and not c(2) and not c(1) and c(0);  --111001
    n(58) <= c(5) and c(4) and c(3) and not c(2) and c(1) and not c(0);  --111010
    n(59) <= c(5) and c(4) and c(3) and not c(2) and c(1) and c(0);  --111011
    n(60) <= c(5) and c(4) and c(3) and c(2) and not c(1) and not c(0);  --111100
    n(61) <= c(5) and c(4) and c(3) and c(2) and not c(1) and c(0);  --111101
    n(62) <= c(5) and c(4) and c(3) and c(2) and c(1) and not c(0);  --111110
    n(63) <= c(5) and c(4) and c(3) and c(2) and c(1) and c(0);  --111111
-------------------------------- end of decoding  --------------------------------


end ccu_decode_i_arch;
