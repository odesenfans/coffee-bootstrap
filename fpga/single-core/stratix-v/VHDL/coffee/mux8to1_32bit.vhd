------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:21 01/03/06
-- File : mux8to1_32bit.vhd
-- Design : mux8to1_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux8to1_32bit IS
   PORT( 
      d0  : IN     std_logic_vector (31 DOWNTO 0);
      d1  : IN     std_logic_vector (31 DOWNTO 0);
      d2  : IN     std_logic_vector (31 DOWNTO 0);
      d3  : IN     std_logic_vector (31 DOWNTO 0);
      d4  : IN     std_logic_vector (31 DOWNTO 0);
      d5  : IN     std_logic_vector (31 DOWNTO 0);
      d6  : IN     std_logic_vector (31 DOWNTO 0);
      d7  : IN     std_logic_vector (31 DOWNTO 0);
      o   : OUT    std_logic_vector (31 DOWNTO 0);
      sel : IN     std_logic_vector (2 DOWNTO 0)
   );

-- Declarations

END mux8to1_32bit ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 20:49:46 06/10/05
-- File : mux8to1_32bit.vhd
-- Design : mux8to1_32bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_UNSIGNED.CONV_INTEGER;

architecture mux8to1_32bit_opt of mux8to1_32bit is
	type array_8x32_stdl is array (0 to 7) of std_logic_vector(31 downto 0);
	signal data : array_8x32_stdl;
begin
	data(0) <= d0;
	data(1) <= d1;
	data(2) <= d2;
	data(3) <= d3;
	data(4) <= d4;
	data(5) <= d5;
	data(6) <= d6;
	data(7) <= d7;

	o <= data(CONV_INTEGER(sel));

end mux8to1_32bit_opt;

