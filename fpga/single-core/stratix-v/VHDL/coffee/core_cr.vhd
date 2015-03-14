------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : core_cr.vhd
-- Design : core_cr
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_cr IS
   PORT( 
      rst_x   : IN     std_logic;
      creg_wr : IN     std_logic_vector (2 DOWNTO 0);
      wrcr    : IN     std_logic;
      clk     : IN     std_logic;
      creg_rd : IN     std_logic_vector (2 DOWNTO 0);
      wr_all  : IN     std_logic;
      znc_in  : IN     std_logic_vector (2 DOWNTO 0);
      all_in  : IN     std_logic_vector (23 DOWNTO 0);
      znc_o   : OUT    std_logic_vector (2 DOWNTO 0);
      flush   : IN     std_logic;
      cr0_out : OUT    std_logic_vector (2 DOWNTO 0);
      all_out : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core_cr ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 18:29:47 06/10/05
-- File : core_cr.vhd
-- Design : core_cr
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned.CONV_INTEGER;

architecture core_cr_opt of core_cr is
    type regs is array (0 to 7) of std_logic_vector(2 downto 0);
    signal d_in        : regs;
    signal d_out       : regs;
begin

	 -- routing input data
    process(wr_all, znc_in, all_in) 
    begin
        if wr_all = '1' then
            d_in(7)  <= all_in(23 downto 21);
            d_in(6)  <= all_in(20 downto 18);
            d_in(5)  <= all_in(17 downto 15);
            d_in(4)  <= all_in(14 downto 12);
            d_in(3)  <= all_in(11 downto 9);
            d_in(2)  <= all_in(8 downto 6);
            d_in(1)  <= all_in(5 downto 3);
            d_in(0)  <= all_in(2 downto 0);
        else
            d_in(7)  <= znc_in;
            d_in(6)  <= znc_in;
            d_in(5)  <= znc_in;
            d_in(4)  <= znc_in;
            d_in(3)  <= znc_in;
            d_in(2)  <= znc_in;
            d_in(1)  <= znc_in;
            d_in(0)  <= znc_in;
        end if;
    end process;

    -- If reading and writing the same register, data
    -- is routed directly from input to output(internal forward).
	process(creg_rd, d_out, d_in, creg_wr, wrcr, wr_all)
		variable forward : boolean;
		variable indx    : integer range 0 to 7;
	begin
		forward := (creg_wr = creg_rd and wrcr = '1') or wr_all = '1';
		indx    := CONV_INTEGER(creg_rd);
		if forward then
			znc_o <= d_in(indx);
		else
			znc_o <= d_out(indx);
		end if;
	end process;

    -- contents of the bank driven to all_out
	-- Forward logic is not needed since
	-- this is for scon (save condition registers).
	all_out(31 downto 24) <= (others => '0');
	all_out(23 downto 21) <= d_out(7);
	all_out(20 downto 18) <= d_out(6);
	all_out(17 downto 15) <= d_out(5);
	all_out(14 downto 12) <= d_out(4);
	all_out(11 downto 9)  <= d_out(3);
	all_out(8 downto 6)   <= d_out(2);
	all_out(5 downto 3)   <= d_out(1);
	all_out(2 downto 0)   <= d_out(0);


	-- CR0 has a separate output, forward control
	process(d_in, d_out, creg_wr, wrcr, wr_all)
	begin
		if (creg_wr = "000" and wrcr = '1') or wr_all = '1' then
			cr0_out <=  d_in(0);
		else
			cr0_out <=  d_out(0);
		end if;
	end process;

	-- registers
	process(rst_x, clk)
		variable indx    : integer range 0 to 7;
	begin
		if rst_x = '0' then
			d_out <= (others => (others => '0'));
		elsif clk'event and clk = '1' then
			if wrcr = '1' and flush = '0' then
				indx := CONV_INTEGER(creg_wr);
				d_out(indx) <= d_in(indx);
			elsif wr_all = '1' and flush = '0' then
				d_out <= d_in;
			end if;
		end if;
	end process;

end core_cr_opt;

