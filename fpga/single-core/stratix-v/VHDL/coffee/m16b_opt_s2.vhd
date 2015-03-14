------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:12 01/03/06
-- File : m16b_opt_s2.vhd
-- Design : m16b_opt_s2
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY m16b_opt_s2 IS
   PORT( 
      isum_w0      : IN     std_logic_vector (15 DOWNTO 0);
      isum_w16     : IN     std_logic_vector (15 DOWNTO 0);
      isum_w16_uns : IN     std_logic_vector (15 DOWNTO 0);
      isum_w8      : IN     std_logic_vector (16 DOWNTO 0);
      uns          : IN     std_logic;
      prod_full    : OUT    std_logic_vector (31 DOWNTO 0);
      prod_hi      : OUT    std_logic_vector (15 DOWNTO 0);
      prod_lo      : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END m16b_opt_s2 ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 00:31:07 06/11/05
-- File : m16b_opt_s2.vhd
-- Design : m16b_opt_s2
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";

architecture m16b_opt_s2_arch of m16b_opt_s2 is
	signal hi_term : std_logic_vector(15 downto 0);
	signal sum     : std_logic_vector(31 downto 0);
begin
	hi_term <= isum_w16_uns when uns = '1' else isum_w16;
	sum <= (hi_term & "0000000000000000") + 
	       ("0000000" & isum_w8 & "00000000") + 
	       isum_w0;
	prod_full <= sum;
	prod_lo   <= sum(15 downto 0);
	prod_hi   <= sum(31 downto 16);

end m16b_opt_s2_arch;
