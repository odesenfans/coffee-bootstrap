------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:20 01/03/06
-- File : cla_8bit.vhd
-- Design : cla_8bit
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
--  8 bit cla with carry out, carry in and additional carry propagate output.
-- -------------------------------------------------------------------------------------------
-- 
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cla_8bit IS
   PORT( 
      a  : IN     std_logic_vector (7 DOWNTO 0);
      b  : IN     std_logic_vector (7 DOWNTO 0);
      ci : IN     std_logic;
      s  : OUT    std_logic_vector (7 DOWNTO 0);
      co : OUT    std_logic;
      pr : OUT    std_logic                       --  pr high indicates that incoming carry will propagate through
   );

-- Declarations

END cla_8bit ;

architecture cla_8bit_arch of cla_8bit is
	-- propagate, generate & carry
    signal c, p, g : std_logic_vector(7 downto 0);
begin
    process(g, p, ci) -- for loop would have been neater
    begin
		c(0) <= ci;
		c(1) <= (ci and p(0)) or g(0);
		c(2) <= (ci and p(0) and p(1)) or (g(0) and p(1)) or g(1);
		c(3) <= (ci and p(0) and p(1) and p(2)) or (g(0) and p(1) and p(2)) or (g(1) and p(2)) or g(2);
		c(4) <= (ci and p(0) and p(1) and p(2) and p(3)) or (g(0) and p(1) and p(2) and p(3)) or (g(1) and p(2) and p(3)) or (g(2) and p(3)) or g(3);
		c(5) <= (ci and p(0) and p(1) and p(2) and p(3) and p(4)) or (g(0) and p(1) and p(2) and p(3) and p(4)) or (g(1) and p(2) and p(3) and p(4)) or (g(2) and p(3) and p(4)) or (g(3) and p(4)) or g(4);
		c(6) <= (ci and p(0) and p(1) and p(2) and p(3) and p(4) and p(5)) or (g(0) and p(1) and p(2) and p(3) and p(4) and p(5)) or (g(1) and p(2) and p(3) and p(4) and p(5)) or (g(2) and p(3) and p(4) and p(5)) or (g(3) and p(4) and p(5)) or (g(4) and p(5)) or g(5);
		c(7) <= (ci and p(0) and p(1) and p(2) and p(3) and p(4) and p(5) and p(6)) or (g(0) and p(1) and p(2) and p(3) and p(4) and p(5) and p(6)) or (g(1) and p(2) and p(3) and p(4) and p(5) and p(6)) or (g(2) and p(3) and p(4) and p(5) and p(6)) or (g(3) and p(4) and p(5) and p(6)) or (g(4) and p(5) and p(6)) or (g(5) and p(6)) or g(6);
    end process;

    process(a, b) -- propagate and generate signals
    begin
		for i in 0 to 7 loop
			g(i) <= a(i) and b(i);
			p(i) <= a(i) or b(i);
		end loop;
	end process;

	process(a, b, c, p) -- sum bits, co and pr
	begin
		for i in 0 to 7 loop
			s(i) <= a(i) xor b(i) xor c(i);
		end loop;
		co <= (a(7) and b(7)) or (a(7) and c(7)) or (b(7) and c(7));
		pr <= p(7) and p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and p(0);			
	end process;

end cla_8bit_arch;
