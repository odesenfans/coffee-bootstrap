------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:22 01/03/06
-- File : inth_dmux.vhd
-- Design : inth_dmux
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY inth_dmux IS
   PORT( 
      data0  : IN     std_logic_vector (15 DOWNTO 0);
      data1  : IN     std_logic_vector (15 DOWNTO 0);
      data2  : IN     std_logic_vector (15 DOWNTO 0);
      data3  : IN     std_logic_vector (15 DOWNTO 0);
      data4  : IN     std_logic_vector (15 DOWNTO 0);
      data5  : IN     std_logic_vector (15 DOWNTO 0);
      data6  : IN     std_logic_vector (15 DOWNTO 0);
      data7  : IN     std_logic_vector (15 DOWNTO 0);
      data8  : IN     std_logic_vector (15 DOWNTO 0);
      data9  : IN     std_logic_vector (15 DOWNTO 0);
      data10 : IN     std_logic_vector (15 DOWNTO 0);
      data11 : IN     std_logic_vector (15 DOWNTO 0);
      data12 : IN     std_logic_vector (15 DOWNTO 0);
      data13 : IN     std_logic_vector (15 DOWNTO 0);
      data14 : IN     std_logic_vector (15 DOWNTO 0);
      data15 : IN     std_logic_vector (15 DOWNTO 0);
      sel    : IN     std_logic_vector (3 DOWNTO 0);
      dout   : OUT    std_logic_vector (15 DOWNTO 0);
      dec    : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END inth_dmux ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 19:01:56 06/10/05
-- File : inth_dmux.vhd
-- Design : inth_dmux
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned.CONV_INTEGER;

architecture inth_dmux_opt of inth_dmux is
	type array_16x16 is array (0 to 15) of std_logic_vector(15 downto 0);

	signal d : array_16x16;
	signal e : std_logic_vector(15 downto 0);
	signal s : std_logic_vector(3 downto 0);
begin

	d(0)  <= data0;
	d(1)  <= data1;
	d(2)  <= data2;
	d(3)  <= data3;
	d(4)  <= data4;
	d(5)  <= data5;
	d(6)  <= data6;
	d(7)  <= data7;
	d(8)  <= data8;
	d(9)  <= data9;
	d(10) <= data10;
	d(11) <= data11;
	d(12) <= data12;
	d(13) <= data13;
	d(14) <= data14;
	d(15) <= data15;

	dout  <= d(CONV_INTEGER(sel));
   
	s     <= sel;
	e(0)  <= not(s(3)) and not(s(2)) and not(s(1)) and not(s(0));
	e(1)  <= not(s(3)) and not(s(2)) and not(s(1)) and     s(0);
	e(2)  <= not(s(3)) and not(s(2)) and     s(1)  and not(s(0));
	e(3)  <= not(s(3)) and not(s(2)) and     s(1)  and     s(0);
	e(4)  <= not(s(3)) and     s(2)  and not(s(1)) and not(s(0));
	e(5)  <= not(s(3)) and     s(2)  and not(s(1)) and     s(0);
	e(6)  <= not(s(3)) and     s(2)  and     s(1)  and not(s(0));
	e(7)  <= not(s(3)) and     s(2)  and     s(1)  and     s(0);
	e(8)  <=     s(3)  and not(s(2)) and not(s(1)) and not(s(0));
	e(9)  <=     s(3)  and not(s(2)) and not(s(1)) and     s(0);
	e(10) <=     s(3)  and not(s(2)) and     s(1)  and not(s(0));
	e(11) <=     s(3)  and not(s(2)) and     s(1)  and     s(0);
	e(12) <=     s(3)  and     s(2)  and not(s(1)) and not(s(0));
	e(13) <=     s(3)  and     s(2)  and not(s(1)) and     s(0);
	e(14) <=     s(3)  and     s(2)  and     s(1)  and not(s(0));
	e(15) <=     s(3)  and     s(2)  and     s(1)  and     s(0);

	dec <= e;
	       

end inth_dmux_opt;

