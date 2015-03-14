------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : core_cntxt_stack.vhd
-- Design : core_cntxt_stack
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_cntxt_stack IS
   PORT( 
      rst_x        : IN     std_logic;
      push         : IN     std_logic;
      pop          : IN     std_logic;
      clk          : IN     std_logic;
      psr_in       : IN     std_logic_vector (7 DOWNTO 0);
      pc_in        : IN     std_logic_vector (31 DOWNTO 0);
      psr_o        : OUT    std_logic_vector (7 DOWNTO 0);
      pc_out       : OUT    std_logic_vector (31 DOWNTO 0);
      cr0_in       : IN     std_logic_vector (2 DOWNTO 0);
      cr0_out      : OUT    std_logic_vector (2 DOWNTO 0);
      flush        : IN     std_logic;
      new_tos_addr : IN     std_logic_vector (31 DOWNTO 0);
      new_tos_psr  : IN     std_logic_vector (7 DOWNTO 0);
      new_tos_cr0  : IN     std_logic_vector (2 DOWNTO 0)
   );

-- Declarations

END core_cntxt_stack ;
library coffee;
use coffee.core_constants_pkg.all;

architecture core_cntxt_stack_arch of core_cntxt_stack is
    type stack_type is array (1 to 12) of std_logic_vector(42 downto 0);
    signal d_out  : stack_type;
    signal d_in   : stack_type;
	constant rval_c : std_logic_vector(42 downto 0) := 
	RETI_CR0_RVAL(2 downto 0) & RETI_PSR_RVAL(7 downto 0) & RETI_ADDR_RVAL;
begin

    pc_out  <= d_out(1)(31 downto 0);    -- top of the stack is always
    psr_o   <= d_out(1)(39 downto 32);   -- visible in outputs.
	cr0_out <= d_out(1)(42 downto 40);

	-----------------------------------------------------------------
	-- routing logic
	-----------------------------------------------------------------
	-- In this implementation, push and pop cannot take place on
	-- the same clock cycle! The stack is used only with interrupts
	-- and simultaneous push and pop implies a situation where stack
	-- should preserve its contents(right data is already on top of
	-- the stack).
	-- New feature: Top of context stack can be written by software
	-- via CCB. This can be used to implement pre-emptive OS
	-----------------------------------------------------------------
    process(push, pop, pc_in, psr_in, d_out, cr0_in, flush, new_tos_cr0, 
	        new_tos_psr, new_tos_addr)
    begin
        if push = '1' and pop = '0' then  -- push
            d_in(1)  <= cr0_in & psr_in & pc_in;
            d_in(2)  <= d_out(1);
            d_in(3)  <= d_out(2);
            d_in(4)  <= d_out(3);
            d_in(5)  <= d_out(4);
            d_in(6)  <= d_out(5);
            d_in(7)  <= d_out(6);
            d_in(8)  <= d_out(7);
            d_in(9)  <= d_out(8);
            d_in(10) <= d_out(9);
            d_in(11) <= d_out(10);
            d_in(12) <= d_out(11);
        elsif pop = '1' and push = '0' and flush = '0' then -- pop
            d_in(1)  <= d_out(2);
            d_in(2)  <= d_out(3);
            d_in(3)  <= d_out(4);
            d_in(4)  <= d_out(5);
            d_in(5)  <= d_out(6);
            d_in(6)  <= d_out(7);
            d_in(7)  <= d_out(8);
            d_in(8)  <= d_out(9);
            d_in(9)  <= d_out(10);
            d_in(10) <= d_out(11);
			d_in(11) <= d_out(12);
            d_in(12) <= rval_c;
        else -- do nothing or update via CCB
            d_in(1)  <= new_tos_cr0 & new_tos_psr & new_tos_addr;
            d_in(2)  <= d_out(2);
            d_in(3)  <= d_out(3);
            d_in(4)  <= d_out(4);
            d_in(5)  <= d_out(5);
            d_in(6)  <= d_out(6);
            d_in(7)  <= d_out(7);
            d_in(8)  <= d_out(8);
            d_in(9)  <= d_out(9);
            d_in(10) <= d_out(10);
            d_in(11) <= d_out(11);
            d_in(12) <= d_out(12);
        end if;								
    end process;

	process(rst_x, clk)	-- clocking
	begin
		if rst_x = '0' then
			d_out <= (others => rval_c);
		elsif clk'event and clk = '1' then
			d_out(1)  <= d_in(1);
			d_out(2)  <= d_in(2);
			d_out(3)  <= d_in(3);
			d_out(4)  <= d_in(4);
			d_out(5)  <= d_in(5);
			d_out(6)  <= d_in(6);
			d_out(7)  <= d_in(7);
			d_out(8)  <= d_in(8);
			d_out(9)  <= d_in(9);
			d_out(10) <= d_in(10);
			d_out(11) <= d_in(11);
			d_out(12) <= d_in(12);
		end if;
	end process;
    
end core_cntxt_stack_arch;
