------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : m16b_uns_s1.vhd
-- Design : m16b_uns_s1
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY m16b_uns_s1 IS
   PORT( 
      clk       : IN     std_logic;
      enable1st : IN     std_logic;
      opa       : IN     std_logic_vector (15 DOWNTO 0);
      opb       : IN     std_logic_vector (15 DOWNTO 0);
      rst_x     : IN     std_logic;
      isum_w0   : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w16  : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w8   : OUT    std_logic_vector (16 DOWNTO 0)
   );

-- Declarations

END m16b_uns_s1 ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 00:52:26 06/11/05
-- File : m16b_uns_s1.vhd
-- Design : m16b_uns_s1
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";
use ieee.std_logic_unsigned."*";

architecture m16b_uns_s1_arch of m16b_uns_s1 is
	signal alo, ahi, blo, bhi   : std_logic_vector(7 downto 0);
	signal intrm1, intrm2       : std_logic_vector(15 downto 0);
	signal intrm3, intrm4       : std_logic_vector(15 downto 0);
begin
	alo <= opa(7 downto 0);
	ahi <= opa(15 downto 8);
	blo <= opb(7 downto 0);
	bhi <= opb(15 downto 8);
	intrm1 <= alo * blo;
	intrm2 <= alo * bhi;
	intrm3 <= ahi * blo;
	intrm4 <= ahi * bhi;

	-- no need for reset here, remove later
	process(clk, rst_x)
	begin
		if rst_x = '0' then
			isum_w0      <= (others => '0');
			isum_w8      <= (others => '0');
			isum_w16     <= (others => '0');
		elsif clk'event and clk = '1' then
			if enable1st = '1' then
				-- intermediate values
				isum_w0      <= intrm1;
				isum_w8      <= ('0' & intrm2) + ('0' & intrm3);
				isum_w16     <= intrm4;
			end if;
		end if;
	end process;

end m16b_uns_s1_arch;
