------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:11 01/03/06
-- File : mux4to1_32b.vhd
-- Design : mux4to1_32b
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux4to1_32b IS
   PORT( 
      d0  : IN     std_logic_vector (31 DOWNTO 0);
      d1  : IN     std_logic_vector (31 DOWNTO 0);
      d2  : IN     std_logic_vector (31 DOWNTO 0);
      d3  : IN     std_logic_vector (31 DOWNTO 0);
      o   : OUT    std_logic_vector (31 DOWNTO 0);
      sel : IN     std_logic_vector (1 DOWNTO 0)
   );

-- Declarations

END mux4to1_32b ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 18:20:58 06/07/05
-- File : mux4to1_32b.vhd
-- Design : mux4to1_32b
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_unsigned.CONV_INTEGER;

architecture mux4to1_32b_asic_arch of mux4to1_32b is
	type array_4x32_stdl is array (0 to 3) of std_logic_vector(31 downto 0);
	signal datain : array_4x32_stdl;
begin
	datain(0) <= d0;
	datain(1) <= d1;
	datain(2) <= d2;
	datain(3) <= d3;
	o <= datain(CONV_INTEGER(sel));

end mux4to1_32b_asic_arch;
