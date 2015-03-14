------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:12 01/03/06
-- File : core_decode.vhd
-- Design : core_decode
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY core_decode IS
   PORT( 
      rst_x        : IN     std_logic;
      i_word       : IN     std_logic_vector (31 DOWNTO 0);
      current_psr  : IN     std_logic_vector (7 DOWNTO 0);
      clk          : IN     std_logic;
      new_psr      : OUT    std_logic_vector (7 DOWNTO 0);
      extended_imm : OUT    std_logic_vector (31 DOWNTO 0);
      exception_q  : OUT    std_logic_vector (2 DOWNTO 0);
      en           : IN     std_logic;
      sel_op_i     : OUT    std_logic;
      sel_op_ii    : OUT    std_logic;
      flush        : IN     std_logic;
      lui_imm_msb  : IN     std_logic;
      rs_to_read   : OUT    std_logic
   );

-- Declarations

END core_decode ;
-- Extend immediate operands
-- Check for instruction violations
-- Calculate new status flags
-- drive operand select multiplexers
------------------------------------------------------------------------------

architecture core_decode_arch of core_decode is

	-- Info extracted from instruction word
	signal opcode : std_logic_vector(5 downto 0);
	signal cex    : std_logic; -- conditional execution bit
	signal ishift : std_logic; -- bit to differentiate imm shift

	-- status flags
	signal IE     : std_logic;	-- bit to enable interrupts
	signal IL     : std_logic;	-- instruction length (encoding mode) bit
	signal RSWR   : std_logic;	-- select bit for register set to write
	signal RSRD   : std_logic;	-- select bit for register set to read from
	signal UM     : std_logic;	-- mode bit

	-- Aliases for making life easier
	signal scall : std_logic;
	signal swm   : std_logic;
	signal di    : std_logic;
	signal ei    : std_logic;
	signal trap  : std_logic;
	signal chrs  : std_logic;
	signal retu  : std_logic;
	signal lli   : std_logic;
	signal lui   : std_logic;
	signal exbfi : std_logic;
	signal addi  : std_logic;
	signal ld    : std_logic;
	signal muli  : std_logic;
	signal addiu : std_logic;
	signal andi  : std_logic;
	signal ori   : std_logic;
	signal cmpi  : std_logic;
	signal cop   : std_logic;
	signal st    : std_logic;
	signal exb   : std_logic;
	signal exh   : std_logic;
	signal sexti : std_logic;
	signal slli  : std_logic;
	signal srai  : std_logic;
	signal srli  : std_logic;
	signal jal   : std_logic;
	signal jalr  : std_logic;


begin
    opcode <= i_word(31 downto 26);
    cex    <= i_word(25);
	ishift <= not i_word(18);

	new_psr <= "000" & IE & IL & RSWR & RSRD & UM;

	---------------------------------------------------
	-- A few signals to make code readable (for whom?)
	---------------------------------------------------
	scall	<= '1' when opcode = scall_opc else '0';
	swm     <= '1' when opcode = swm_opc else '0';
	di      <= '1' when opcode = di_opc else '0';
	ei      <= '1' when opcode = ei_opc else '0';
	trap    <= '1' when opcode = trap_opc else '0';
	chrs    <= '1' when opcode = chrs_opc else '0';
	retu    <= '1' when opcode = retu_opc else '0';
	lli     <= '1' when opcode = lli_opc else '0';
	lui     <= '1' when opcode = lui_opc else '0';
	exbfi   <= '1' when opcode = exbfi_opc else '0';
	cop     <= '1' when opcode = cop_opc else '0';
	addi    <= '1' when opcode = addi_opc else '0';
	ld      <= '1' when opcode = ld_opc else '0';
	muli    <= '1' when opcode = muli_opc else '0';
	addiu   <= '1' when opcode = addiu_opc else '0';
	andi    <= '1' when opcode = andi_opc else '0';
	ori     <= '1' when opcode = ori_opc else '0';
	cmpi    <= '1' when opcode = cmpi_opc else '0';
	st      <= '1' when opcode = st_opc else '0';
	exb     <= '1' when opcode = exb_opc else '0';
	exh     <= '1' when opcode = exh_opc else '0';
	sexti   <= '1' when opcode = sexti_opc else '0';
	slli    <= '1' when opcode = slli_opc and ishift = '1' else '0';
	srai    <= '1' when opcode = srai_opc and ishift = '1' else '0';
	srli    <= '1' when opcode = srli_opc and ishift = '1' else '0';
	jal     <= '1' when opcode = jal_opc else '0';
	jalr    <= '1' when opcode = jalr_opc else '0';

	-------------------------------------------------------------
	-- Calculating new status (PSR)
	-------------------------------------------------------------
	process(scall, swm, di, ei, chrs, current_psr, i_word)
	begin

		-- Note, that di and ei are allowed in superuser mode only
		if (di = '1' and current_psr(0) = '0') or scall = '1' then
			IE <= '0';
		elsif ei = '1' and current_psr(0) = '0' then
			IE <= '1';
		else
			IE <= current_psr(4); -- preserve old value
		end if;

		if swm = '1' then
			IL <= i_word(15);	-- using the msb of immediate
		elsif scall = '1' then
			IL <= '1';	-- default is 32 bit mode
		else
			IL <= current_psr(3); -- preserve old value
		end if;

		-- Note, that chrs is allowed only in superuser mode
		if chrs = '1' and current_psr(0) = '0' then 
			RSWR <= i_word(11);
			RSRD <= i_word(10);
		elsif scall = '1' then
			RSWR <= '1';
			RSRD <= '1';
		else 
			RSWR <= current_psr(2); -- preserve old values
			RSRD <= current_psr(1);
		end if;

		if scall = '1' then -- default super user mode
			UM <= '0';
		else
			UM <= current_psr(0);
		end if;

	end process;

	-------------------------------------------------------------
	-- Exception logic
	-------------------------------------------------------------
	process(rst_x, clk)
		variable il_violation, um_violation, unknown_opcode : std_logic;
	begin
		if rst_x = '0' then
			exception_q <= "000";
		elsif clk'event and clk = '1' then
			if en = '1' then
			-- While in 16 bit mode, an opcode valid only in 32 bit mode,
			-- is encountered.
				il_violation := (lui or lli or exbfi or cop) and not(current_psr(3));

			-- Trying to execute an instruction not allowed in user mode
				um_violation := (chrs or retu or di or ei) and current_psr(0);

			-- Currently all opcodes are used.
				unknown_opcode := '0';

				exception_q(2) <= trap and not(flush);
				exception_q(1) <= (il_violation or um_violation) and not(flush);
				exception_q(0) <= unknown_opcode and not(flush);

			end if;
		end if;
	end process;

	-------------------------------------------------------------
	-- Extending immediates. Should not be so time critical...
	-- Note that immediate offset needed for PC relative jumps
	-- is extended before decode -block and routed directly to
	-- instruction address calculation unit.
	-------------------------------------------------------------

	process(i_word, addiu, andi, ori, cex, addi, ld, muli, cmpi, lui, lli, 
	        cop, st, lui_imm_msb)

	begin
		if addiu = '1' or andi = '1' or ori = '1' then
		-- zero extending
			if cex = '1' then
				extended_imm(31 downto 9) <= (others => '0');
				extended_imm(8 downto 0)  <= i_word(18 downto 10);
			else
				extended_imm(31 downto 15) <= (others => '0');
				extended_imm(14 downto 0)  <= i_word(24 downto 10);
			end if;
		elsif addi = '1' or ld = '1' or muli = '1' then
		-- sign extending
			if cex = '1' then
				extended_imm(31 downto 9) <= (others => i_word(18));
				extended_imm(8 downto 0)  <= i_word(18 downto 10);
			else
				extended_imm(31 downto 15) <= (others => i_word(24));
				extended_imm(14 downto 0)  <= i_word(24 downto 10);
			end if;
		elsif cmpi = '1' then
		-- special case 1
			extended_imm(31 downto 17) <= (others => i_word(4));
			extended_imm(16 downto 0) <= i_word(4 downto 0) & i_word(21 downto 10);
		elsif lui = '1' or lli = '1' then
		-- special case 2
			extended_imm(31 downto 16) <= (others => '0');	-- don't care
			extended_imm(15 downto 0) <= lui_imm_msb & i_word(24 downto 10);
		elsif st = '1' then
		-- special case 3
			if cex = '1' then
				extended_imm(31 downto 9) <= (others => i_word(4));
				extended_imm(8 downto 0)  <= i_word(4 downto 0) & i_word(18 downto 15);
			else
				extended_imm(31 downto 15) <= (others => i_word(4));
				extended_imm(14 downto 0)  <= i_word(4 downto 0) & i_word(24 downto 15);
			end if;
		elsif cop = '1' then
		-- special case 4
			extended_imm <= "00000000" & i_word(23 downto 0);
		else -- all the others (exbfi has the longest immediate of 11 bits)
			extended_imm(10 downto 0) <= i_word(20 downto 10);
			extended_imm(31 downto 11) <= (others => '0');	-- don't care
		end if;

	end process;


	-------------------------------------------------------------
	-- Selecting the right operands to ALU or cop interface
	-------------------------------------------------------------
	process(addi, addiu, andi, cmpi, cop, exb,
	        exbfi, exh, ld, lli, lui, muli,
	        ori, sexti, slli, srai, srli, st,
	        scall, jal, jalr, current_psr, retu)

		variable immediate_operand : std_logic;
	begin
		immediate_operand := addi or addiu or andi or cmpi or cop or exb or
		                     exbfi or exh or ld or lli or lui or muli or
		                     ori or sexti or slli or srai or srli or st;

		-- Multiplexer for 2nd operand
		if immediate_operand = '1' then
			sel_op_ii <= '1';
		else
			sel_op_ii <= '0';
		end if;

		-- Multiplexer for 1st operand (route link address or not)
		if scall = '1' or jal = '1' or jalr = '1' then
			sel_op_i <= '1';
		else
			sel_op_i <= '0';
		end if;

		-- lui must read it's implicit source register from the register set
		-- which is selected as the target!. retu must read PR31 instead of
		-- R31
		if lui = '1' then
			rs_to_read <= current_psr(2);
		elsif retu = '1' then
			rs_to_read <= '1';
		else
			rs_to_read <= current_psr(1);
		end if;
	
	end process;


end core_decode_arch;
