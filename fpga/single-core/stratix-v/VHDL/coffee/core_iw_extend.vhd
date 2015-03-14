------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:12 01/03/06
-- File : core_iw_extend.vhd
-- Design : core_iw_extend
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY core_iw_extend IS
   PORT( 
      i_word       : IN     std_logic_vector (31 DOWNTO 0);
      mode         : IN     std_logic;
      sel_halfword : IN     std_logic;
      extended_iw  : OUT    std_logic_vector (31 DOWNTO 0);
      jump_offset  : OUT    std_logic_vector (31 DOWNTO 0);
      lui_imm_msb  : OUT    std_logic
   );

-- Declarations

END core_iw_extend ;



architecture core_iw_extend_arch of core_iw_extend is

	type array_9x26 is array (0 to 8) of std_logic_vector(25 downto 0);

	signal c, opcode    : std_logic_vector(5 downto 0);
	signal i_word_16bit : std_logic_vector(15 downto 0);
	signal imm_sign     : std_logic;
	signal n            : std_logic_vector(63 downto 0); -- decoded opcode
	
	signal class_aef    : std_logic;
	signal class_b      : std_logic;
	signal class_c      : std_logic;
	signal class_d      : std_logic;
	signal class_g      : std_logic;
	signal class_h      : std_logic;
	signal class_i      : std_logic;
	signal class_j      : std_logic;

	signal class_aef_mask : std_logic_vector(25 downto 0);
	signal class_b_mask   : std_logic_vector(25 downto 0);
	signal class_c_mask   : std_logic_vector(25 downto 0);
	signal class_d_mask   : std_logic_vector(25 downto 0);
	signal class_g_mask   : std_logic_vector(25 downto 0);
	signal class_h_mask   : std_logic_vector(25 downto 0);
	signal class_i_mask   : std_logic_vector(25 downto 0);
	signal class_j_mask   : std_logic_vector(25 downto 0);
	signal no_exp_mask    : std_logic_vector(25 downto 0);

	signal expansion : array_9x26;
	signal selected  : array_9x26;

begin
	-------------------------------------------------------------
	-- In 16 bit mode, when address bit A1 is high, core
	-- refers to less signigicant halfword of the word(coffee is
	-- big endian: most significant end is stored first,
	-- that is, in the smallest address.)
	-------------------------------------------------------------
	-- Selecting the right halfword and opcode field
	-------------------------------------------------------------
	process(sel_halfword, mode, i_word)
	begin
		if sel_halfword = '1' then
			i_word_16bit <= i_word(15 downto 0);
		else
			i_word_16bit <= i_word(31 downto 16);
		end if;
		if sel_halfword = '1' and mode = '0' then
			opcode <= i_word(15 downto 10);
		else
			opcode <= i_word(31 downto 26);
		end if;

	end process;

	
	-- Only part of the decoded signlas are used. Might want to remove unused..
	----------------------------- decoding the opcode (actually id) ------------------
	c     <= opcode;
    n(0)  <= not c(5) and not c(4) and not c(3) and not c(2) and not c(1) and not c(0);
    n(1)  <= not c(5) and not c(4) and not c(3) and not c(2) and not c(1) and     c(0);
    n(2)  <= not c(5) and not c(4) and not c(3) and not c(2) and     c(1) and not c(0);
    n(3)  <= not c(5) and not c(4) and not c(3) and not c(2) and     c(1) and     c(0);
    n(4)  <= not c(5) and not c(4) and not c(3) and     c(2) and not c(1) and not c(0);
    n(5)  <= not c(5) and not c(4) and not c(3) and     c(2) and not c(1) and     c(0);
    n(6)  <= not c(5) and not c(4) and not c(3) and     c(2) and     c(1) and not c(0);
    n(7)  <= not c(5) and not c(4) and not c(3) and     c(2) and     c(1) and     c(0);
    n(8)  <= not c(5) and not c(4) and     c(3) and not c(2) and not c(1) and not c(0);
    n(9)  <= not c(5) and not c(4) and     c(3) and not c(2) and not c(1) and     c(0);
    n(10) <= not c(5) and not c(4) and     c(3) and not c(2) and     c(1) and not c(0);
    n(11) <= not c(5) and not c(4) and     c(3) and not c(2) and     c(1) and     c(0);
    n(12) <= not c(5) and not c(4) and     c(3) and     c(2) and not c(1) and not c(0);
    n(13) <= not c(5) and not c(4) and     c(3) and     c(2) and not c(1) and     c(0);
    n(14) <= not c(5) and not c(4) and     c(3) and     c(2) and     c(1) and not c(0);
    n(15) <= not c(5) and not c(4) and     c(3) and     c(2) and     c(1) and     c(0);
    n(16) <= not c(5) and     c(4) and not c(3) and not c(2) and not c(1) and not c(0);
    n(17) <= not c(5) and     c(4) and not c(3) and not c(2) and not c(1) and     c(0);
    n(18) <= not c(5) and     c(4) and not c(3) and not c(2) and     c(1) and not c(0);
    n(19) <= not c(5) and     c(4) and not c(3) and not c(2) and     c(1) and     c(0);
    n(20) <= not c(5) and     c(4) and not c(3) and     c(2) and not c(1) and not c(0);
    n(21) <= not c(5) and     c(4) and not c(3) and     c(2) and not c(1) and     c(0);
    n(22) <= not c(5) and     c(4) and not c(3) and     c(2) and     c(1) and not c(0);
    n(23) <= not c(5) and     c(4) and not c(3) and     c(2) and     c(1) and     c(0);
    n(24) <= not c(5) and     c(4) and     c(3) and not c(2) and not c(1) and not c(0);
    n(25) <= not c(5) and     c(4) and     c(3) and not c(2) and not c(1) and     c(0);
    n(26) <= not c(5) and     c(4) and     c(3) and not c(2) and     c(1) and not c(0);
    n(27) <= not c(5) and     c(4) and     c(3) and not c(2) and     c(1) and     c(0);
    n(28) <= not c(5) and     c(4) and     c(3) and     c(2) and not c(1) and not c(0);
    n(29) <= not c(5) and     c(4) and     c(3) and     c(2) and not c(1) and     c(0);
    n(30) <= not c(5) and     c(4) and     c(3) and     c(2) and     c(1) and not c(0);
    n(31) <= not c(5) and     c(4) and     c(3) and     c(2) and     c(1) and     c(0);
    n(32) <=     c(5) and not c(4) and not c(3) and not c(2) and not c(1) and not c(0);
    n(33) <=     c(5) and not c(4) and not c(3) and not c(2) and not c(1) and     c(0);
    n(34) <=     c(5) and not c(4) and not c(3) and not c(2) and     c(1) and not c(0);
    n(35) <=     c(5) and not c(4) and not c(3) and not c(2) and     c(1) and     c(0);
    n(36) <=     c(5) and not c(4) and not c(3) and     c(2) and not c(1) and not c(0);
    n(37) <=     c(5) and not c(4) and not c(3) and     c(2) and not c(1) and     c(0);
    n(38) <=     c(5) and not c(4) and not c(3) and     c(2) and     c(1) and not c(0);
    n(39) <=     c(5) and not c(4) and not c(3) and     c(2) and     c(1) and     c(0);
    n(40) <=     c(5) and not c(4) and     c(3) and not c(2) and not c(1) and not c(0);
    n(41) <=     c(5) and not c(4) and     c(3) and not c(2) and not c(1) and     c(0);
    n(42) <=     c(5) and not c(4) and     c(3) and not c(2) and     c(1) and not c(0);
    n(43) <=     c(5) and not c(4) and     c(3) and not c(2) and     c(1) and     c(0);
    n(44) <=     c(5) and not c(4) and     c(3) and     c(2) and not c(1) and not c(0);
    n(45) <=     c(5) and not c(4) and     c(3) and     c(2) and not c(1) and     c(0);
    n(46) <=     c(5) and not c(4) and     c(3) and     c(2) and     c(1) and not c(0);
    n(47) <=     c(5) and not c(4) and     c(3) and     c(2) and     c(1) and     c(0);
    n(48) <=     c(5) and     c(4) and not c(3) and not c(2) and not c(1) and not c(0);
    n(49) <=     c(5) and     c(4) and not c(3) and not c(2) and not c(1) and     c(0);
    n(50) <=     c(5) and     c(4) and not c(3) and not c(2) and     c(1) and not c(0);
    n(51) <=     c(5) and     c(4) and not c(3) and not c(2) and     c(1) and     c(0);
    n(52) <=     c(5) and     c(4) and not c(3) and     c(2) and not c(1) and not c(0);
    n(53) <=     c(5) and     c(4) and not c(3) and     c(2) and not c(1) and     c(0);
    n(54) <=     c(5) and     c(4) and not c(3) and     c(2) and     c(1) and not c(0);
    n(55) <=     c(5) and     c(4) and not c(3) and     c(2) and     c(1) and     c(0);
    n(56) <=     c(5) and     c(4) and     c(3) and not c(2) and not c(1) and not c(0);
    n(57) <=     c(5) and     c(4) and     c(3) and not c(2) and not c(1) and     c(0);
    n(58) <=     c(5) and     c(4) and     c(3) and not c(2) and     c(1) and not c(0);
    n(59) <=     c(5) and     c(4) and     c(3) and not c(2) and     c(1) and     c(0);
    n(60) <=     c(5) and     c(4) and     c(3) and     c(2) and not c(1) and not c(0);
	n(61) <=     c(5) and     c(4) and     c(3) and     c(2) and not c(1) and     c(0);
    n(62) <=     c(5) and     c(4) and     c(3) and     c(2) and     c(1) and not c(0);
	n(63) <=     c(5) and     c(4) and     c(3) and     c(2) and     c(1) and     c(0);
	-------------------------------- end of decoding  --------------------------------

	-------------------------------------------------------------
	-- Deciding what kind of expansion pattern to use. See 
	-- document extending_by_class -for details about different
	-- encoding classes.
	-- Classes a, e and f are combined, the rest require
	-- different expansion.
	-------------------------------------------------------------
	-- Shared opcodes with shifts having immediate operand
	-- and shifts having register operand.
	-- Shared opcodes with movdxc and movcxc, x = f or x = t
	-------------------------------------------------------------
	class_aef <= (not c(5) and not n(trap_opc_i) and not n(srl_opc_i) and
	             not n(sra_opc_i) and not n(sll_opc_i) and not n(retu_opc_i))
	             or n(scall_opc_i) or n(jalr_opc_i) or n(nop_opc_i);

	class_b   <= n(exb_opc_i) or n(exh_opc_i) or n(ld_opc_i);

	class_c   <= n(addi_opc_i) or n(addiu_opc_i) or n(andi_opc_i) or
	             n(muli_opc_i) or n(ori_opc_i) or n(sexti_opc_i);

	class_d   <= n(chrs_opc_i) or n(swm_opc_i) or n(trap_opc_i);

	class_g   <= n(cmpi_opc_i) or n(st_opc_i) or n(retu_opc_i);

	class_h   <= n(movfc_opc_i) or n(movtc_opc_i);

	class_i   <= n(srl_opc_i) or n(sra_opc_i) or n(sll_opc_i);

	class_j   <= n(bc_opc_i) or n(begt_opc_i) or n(belt_opc_i) or
	             n(beq_opc_i) or n(bgt_opc_i) or n(blt_opc_i) or
				 n(bne_opc_i) or n(jal_opc_i) or n(jmp_opc_i) or
				 n(bnc_opc_i);

	-------------------------------------------------------------
	-- Different expansion patterns
	-------------------------------------------------------------
	-- classes a, e, f
	-------------------------------------------------------------
	-- Conditional execution fields set to all zeros.
	expansion(0)(25 downto 15) <= (others => '0');
	-- source register 2 and destination register
	expansion(0)(14 downto 10) <= "11" & i_word_16bit(2 downto 0);
	expansion(0)(4 downto 0)   <= "11" & i_word_16bit(2 downto 0);
	-- source register 1
	expansion(0)(9 downto 5)   <= "11" & i_word_16bit(9 downto 7);

	-------------------------------------------------------------
	-- class b, following ld -instruction encoding
	-------------------------------------------------------------
	-- Cex bit is set to zero.
	expansion(1)(25) <= '0';
	-- Sign extended immediate
	expansion(1)(24 downto 14) <= (others => i_word_16bit(6));
	expansion(1)(13 downto 10) <= i_word_16bit(6 downto 3);
	-- source register 1
	expansion(1)(9 downto 5)   <= "11" & i_word_16bit(9 downto 7);
	-- Destination register
	expansion(1)(4 downto 0)   <= "11" & i_word_16bit(2 downto 0);

	-------------------------------------------------------------
	-- class c, Immediate can be sign extended or zero extended.
	-------------------------------------------------------------
	imm_sign <= i_word_16bit(9) and (n(addi_opc_i) or n(muli_opc_i));
	-- Cex bit is set to zero.
	expansion(2)(25) <= '0';
	-- Extended immediate
	expansion(2)(24 downto 17) <= (others => imm_sign);
	expansion(2)(16 downto 10) <= i_word_16bit(9 downto 3);
	-- source register is the same as destinaton
	expansion(2)(9 downto 5)   <= "11" & i_word_16bit(2 downto 0);
	-- Destination register
	expansion(2)(4 downto 0)   <= "11" & i_word_16bit(2 downto 0);

	-------------------------------------------------------------
	-- class d, Following the encoding of swm.
	-------------------------------------------------------------
	-- Conditional execution fields and unused bits set to zeros.
	expansion(3)(25 downto 16) <= (others => '0');
	-- immediate
	expansion(3)(15 downto 10) <= i_word_16bit(8 downto 3);
	-- Register indexes do not exist. Set to zeros.
	expansion(3)(9 downto 0)   <= (others => '0');

	-------------------------------------------------------------
	-- class g, cmpi, st and retu
	-------------------------------------------------------------
	process(n, i_word_16bit)
	begin
		if n(cmpi_opc_i) = '1' then
			-- cex and creg fields to zero
			expansion(4)(25 downto 22) <= (others =>'0');
			-- right part of the immediate sign extended
			expansion(4)(21 downto 17) <= (others =>i_word_16bit(6));
			expansion(4)(16 downto 10) <= i_word_16bit(6 downto 0);
		else  -- st and retu (for retu only sreg1 is of importance)
			-- cex <= zero
			expansion(4)(25) <= '0';
			-- right part of the immediate sign extended (st only)
			expansion(4)(24 downto 19) <= (others =>i_word_16bit(6));
			expansion(4)(18 downto 15) <= i_word_16bit(6 downto 3);
			-- 2nd source register
			expansion(4)(14 downto 10) <= "11" & i_word_16bit(2 downto 0);
		end if;
			-- 1st source register
			expansion(4)(9 downto 5)   <= "11" & i_word_16bit(9 downto 7);
			-- left part of the immediate (only sign bits)
			expansion(4)(4 downto 0)   <= (others =>i_word_16bit(6));
	end process;
	-------------------------------------------------------------
	-- class h, coprocessor data transfer
	-------------------------------------------------------------
	process(n, i_word_16bit)
	begin
		-- conditional execution fields set to zeros
		expansion(5)(25 downto 17) <= (others => '0');
		if n(movfc_opc_i) = '1' then
			-- coprocessor register index and id
			expansion(5)(16 downto 10) <= i_word_16bit(9 downto 3);
			-- sreg1 -field (don't care) set to zeros
			expansion(5)(9 downto 5)   <= (others => '0');
			-- Destination register
			expansion(5)(4 downto 0)   <= "11" & i_word_16bit(2 downto 0);
		else -- movtc
			-- coprocessor register index and id
			expansion(5)(16 downto 10) <= i_word_16bit(6 downto 0);
			-- source register
			expansion(5)(9 downto 5)   <= "11" & i_word_16bit(9 downto 7);
			-- Destination register (don't care)
			expansion(5)(4 downto 0)   <= (others => '0');
		end if;
	end process;

	-------------------------------------------------------------
	-- class i, shifts
	-------------------------------------------------------------
	process(n, i_word_16bit)
	begin
		if i_word_16bit(3) = '1' then --  register shift
			-- 2nd source register (+ one don't care bit)
			expansion(6)(15 downto 10) <= "011" & i_word_16bit(2 downto 0);
			-- 1st source register
			expansion(6)(9 downto 5)   <= "11" & i_word_16bit(9 downto 7);
		else -- immediate shift
			-- immediate operand
			expansion(6)(15 downto 10) <= i_word_16bit(9 downto 4);
			-- source register
			expansion(6)(9 downto 5)   <= "11" & i_word_16bit(2 downto 0);
		end if;
		-- conditional execution fields set to zeros
		expansion(6)(25 downto 19) <= (others => '0');
		-- selector bit: immediate or register operand
		expansion(6)(18)           <= i_word_16bit(3);
		-- don't care
		expansion(6)(17 downto 16) <= (others => '0');
		-- destination register
		expansion(6)(4 downto 0) <= "11" & i_word_16bit(2 downto 0);
	end process;

	-------------------------------------------------------------
	-- class j, conditional branches and unconditional jumps
	-- (PC relative)
	-- NOTE:
	-- Jump offset is expanded separately and driven to jump_offset
	-- -output. Here we don't care about the offset!!!
	-------------------------------------------------------------
	process(n)
	begin
		if n(jal_opc_i) = '1' or n(jmp_opc_i) = '1' then
			-- cex bit set to zero...
			expansion(7)(25 downto 22) <= "0000";
		else -- conditional branch
			-- cex bit set to 1 and cr set to 000
			expansion(7)(25 downto 22) <= "1000";
		end if;
		expansion(7)(21 downto 5) <= (others => '0'); -- don't care
		-- jal uses R31 as target for link address, setting
		-- dreg to 31.
		expansion(7)(4 downto 0)     <= "11111";
	end process;

	-------------------------------------------------------------
	-- no expansion, Special case. lui is not defined in 16 bit mode
	-- but the 32 bit version needs 'expanding'
	-------------------------------------------------------------
	process(n, i_word)
	begin
		-- lui preserves lower bits of its destination register,
		-- so it uses dreg as sreg1. Note, that source must be
		-- from the same set as destination!
		if n(lui_opc_i) = '1' then
			expansion(8)(9 downto 5)   <= i_word(4 downto 0);
		else
			expansion(8)(9 downto 5)   <= i_word(9 downto 5);
		end if;
			expansion(8)(25 downto 10) <= i_word(25 downto 10);
		if n(jal_opc_i) = '1' then
			-- jal uses R31 as target for link address, setting
			-- dreg to 31.
			expansion(8)(4 downto 0)   <= "11111";
		else
			expansion(8)(4 downto 0)   <= i_word(4 downto 0);
		end if;
	end process;

	-------------------------------------------------------------
	-- Multiplexing the right expansion (or no expansion...)
	-------------------------------------------------------------
	
	class_aef_mask <= (others => (class_aef and not mode));
	class_b_mask   <= (others => (class_b and not mode));
	class_c_mask   <= (others => (class_c and not mode));
	class_d_mask   <= (others => (class_d and not mode));
	class_g_mask   <= (others => (class_g and not mode));
	class_h_mask   <= (others => (class_h and not mode));
	class_i_mask   <= (others => (class_i and not mode));
	class_j_mask   <= (others => (class_j and not mode));
	no_exp_mask    <= (others => mode);


	selected(0)    <= class_aef_mask and expansion(0);
	selected(1)    <= class_b_mask   and expansion(1);
	selected(2)    <= class_c_mask   and expansion(2);
	selected(3)    <= class_d_mask   and expansion(3);
	selected(4)    <= class_g_mask   and expansion(4);
	selected(5)    <= class_h_mask   and expansion(5);
	selected(6)    <= class_i_mask   and expansion(6);
	selected(7)    <= class_j_mask   and expansion(7);
	selected(8)    <= no_exp_mask    and expansion(8);

	extended_iw <= opcode & 
	            (selected(0) or selected(1) or selected(2) or selected(3) 
	            or selected(4) or selected(5) or selected(6) or selected(7)
				or selected(8));

	-------------------------------------------------------------
	-- Driving jump offset separately, time critical
	-------------------------------------------------------------
	process(opcode, i_word_16bit, i_word, mode)
		variable offset : std_logic_vector(24 downto 0);
	begin
		if mode = '0' then
			offset(24 downto 10) := (others => i_word_16bit(9));
			offset(9 downto 0)   := i_word_16bit(9 downto 0);
		else
			offset := i_word(24 downto 0);
		end if;

		if opcode(5 downto 3) = "100" then
		 -- conditional branch, sign extend and shift one bit
			jump_offset(31 downto 23) <= (others => offset(21));
			jump_offset(22 downto 0) <= offset(21 downto 0) & '0';
		else
		-- jal or jmp (or don't care), sign extend and shift one bit
			jump_offset(31 downto 26) <= (others => offset(24));
			jump_offset(25 downto 0) <= offset(24 downto 0) & '0';
		end if;

	end process;

	--------------------------------------------------------------
	-- With lui, all needed bits do not fit into instruction word,
	-- using a separate signal for passing one bit!
	--------------------------------------------------------------
	lui_imm_msb <= i_word(9);

end core_iw_extend_arch;
