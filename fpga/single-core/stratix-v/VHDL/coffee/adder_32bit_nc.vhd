------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:14 01/03/06
-- File : adder_32bit_nc.vhd
-- Design : adder_32bit_nc
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY adder_32bit_nc IS
   PORT( 
      opa : IN     std_logic_vector (31 DOWNTO 0);
      opb : IN     std_logic_vector (31 DOWNTO 0);
      sum : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END adder_32bit_nc ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 22:10:03 06/10/05
-- File : adder_32bit_nc.vhd
-- Design : adder_32bit_nc
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned."+";

architecture adder_32bit_nc_arch of adder_32bit_nc is
begin
	sum <= opa + opb;
end adder_32bit_nc_arch;
