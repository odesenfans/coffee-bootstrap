------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : m16b_uns_s2.vhd
-- Design : m16b_uns_s2
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY m16b_uns_s2 IS
   PORT( 
      isum_w0  : IN     std_logic_vector (15 DOWNTO 0);
      isum_w16 : IN     std_logic_vector (15 DOWNTO 0);
      isum_w8  : IN     std_logic_vector (16 DOWNTO 0);
      uprod_hi : OUT    std_logic_vector (15 DOWNTO 0);
      uprod_lo : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END m16b_uns_s2 ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 00:55:36 06/11/05
-- File : m16b_uns_s2.vhd
-- Design : m16b_uns_s2
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";

architecture m16b_uns_s2_arch of m16b_uns_s2 is
	signal sum : std_logic_vector(31 downto 0);
begin
	sum <= (isum_w16 & "0000000000000000") + 
	       ("0000000" & isum_w8 & "00000000") + 
	       isum_w0;

	uprod_lo   <= sum(15 downto 0);
	uprod_hi   <= sum(31 downto 16);

end m16b_uns_s2_arch;
