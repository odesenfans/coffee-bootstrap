------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : alu_add_sub_unit.vhd
-- Design : alu_add_sub_unit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY alu_add_sub_unit IS
   PORT( 
      rst_x       : IN     std_logic;
      opa         : IN     std_logic_vector (31 DOWNTO 0);
      opb         : IN     std_logic_vector (31 DOWNTO 0);
      add_sub_cmp : IN     std_logic_vector (1 DOWNTO 0);   -- 01 = add, 11 = sub, cmp = 10
      chk_ovfl    : IN     std_logic;
      clk         : IN     std_logic;
      enable      : IN     std_logic;
      uf_q        : OUT    std_logic;
      of_q        : OUT    std_logic;
      znc         : OUT    std_logic_vector (2 DOWNTO 0);
      result      : OUT    std_logic_vector (31 DOWNTO 0);
      flush       : IN     std_logic
   );

-- Declarations

END alu_add_sub_unit ;
architecture alu_add_sub_unit_arch of alu_add_sub_unit is

	COMPONENT adder_32bit_alu
		PORT( 
			inv   : IN     std_logic;
			opa   : IN     std_logic_vector (31 DOWNTO 0);
			opb   : IN     std_logic_vector (31 DOWNTO 0);
			cout  : OUT    std_logic;
			sum   : OUT    std_logic_vector (31 DOWNTO 0);
			zflag : OUT    std_logic
		);
	END COMPONENT;

	signal sum_s                 : std_logic_vector(31 downto 0);
	signal zero, carry, negative : std_logic;
	signal sign                  : std_logic;

begin
	-------------------------------------------------------
	-- Two level carry look ahead with carry in and carry
	-- out -inputs is used.
	-------------------------------------------------------
	adder : adder_32bit_alu
		port map
		(
			inv   => add_sub_cmp(1),
			opa   => opa,
			opb   => opb,
			cout  => carry,
			sum   => sum_s,
			zflag => zero
		);

    result <= sum_s;
	-- sign of the inverted operand
	sign   <= opb(31) xor add_sub_cmp(1);

	-------------------------------------------------------
	-- Overflow logic and clocked outputs
	-------------------------------------------------------

    process(rst_x, clk)
    begin
        if rst_x = '0' then
            uf_q <= '0';
            of_q <= '0';
        elsif clk'event and clk = '1' then
            if enable = '1' then
                -- both addends negative, but sum positive          
                uf_q  <= opa(31) and sign and not(sum_s(31)) and chk_ovfl and not(flush);
                -- addends positive, but sum negative           
                of_q  <= not(opa(31)) and not(sign) and sum_s(31) and chk_ovfl and not(flush);
            end if;
        end if;
    end process;
	---------------------------------------------------------------------------
	-- Flag logic

	-- When adding or subtracting signed or unsigned integers the
	-- flags are set as is customary for two's complement arithmetic:
	-- C = result(32), N = result(31) and Z = 1 when bits 31 downto 0 are zero.
	-- When comparing operands by subtracting them, some extra logic is needed
	-- since comparison should succeed even if the result underflows.
	---------------------------------------------------------------------------
	-- Decreased delay with fast zero flag logic embedded in adder

    process(opa, opb, sum_s, add_sub_cmp)
        variable n : std_logic_vector(1 downto 0);
    begin
		--------------------------------------------------
        -- N Flag logic when COMPARING operands.
        -- operands positive: n is the sign of the result.
        -- operands negative: n is the sign of the result.
        -- opa < 0 and opb > 0, n = '1'. (n(0))
		-- opa > 0 and opb < 0, n = '0'. (n(1))
		--------------------------------------------------
        n(0) := opa(31) and not(opb(31)) and not(add_sub_cmp(0));
        n(1) := opa(31) or not(opb(31)) or add_sub_cmp(0); -- POS term
        -- Combining
        -- n(0) or sum(31) sets N flag, n(1) clears it.
        -- n(1) and n(0) are mutually exclusive.
        negative <= n(0) or (n(1) and sum_s(31));
    end process;
	
	znc <= zero & negative & carry;

end alu_add_sub_unit_arch;

