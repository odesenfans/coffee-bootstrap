------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:14 01/03/06
-- File : mu_csa_typ_f.vhd
-- Design : mu_csa_typ_f
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mu_csa_typ_f IS
   PORT( 
      opa : IN     std_logic_vector (31 DOWNTO 0);
      opb : IN     std_logic_vector (31 DOWNTO 0);
      opc : IN     std_logic_vector (1 DOWNTO 0);   -- lsb position 16
      s   : OUT    std_logic_vector (31 DOWNTO 0);
      c   : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END mu_csa_typ_f ;
architecture mu_csa_typ_f_arch of mu_csa_typ_f is
begin

	process(opa, opb, opc)
	begin

		c(0) <= '0';

		for i in 0 to 15 loop
			s(i)   <= opa(i) xor opb(i);
			c(i+1) <= opa(i) and opb(i);
		end loop;

		s(16)   <= opa(16) xor opb(16) xor opc(0);
		s(17)   <= opa(17) xor opb(17) xor opc(1);
		c(17)   <= (opa(16) and opb(16)) or (opa(16) and opc(0)) or
		           (opb(16) and opc(0));
		c(18)   <= (opa(17) and opb(17)) or (opa(17) and opc(1)) or
		           (opb(17) and opc(1));

		for i in 18 to 30 loop
			s(i)   <= opa(i) xor opb(i);
			c(i+1) <= opa(i) and opb(i);
		end loop;

		s(31) <= opa(31) xor opb(31);

	end process;

end mu_csa_typ_f_arch;
