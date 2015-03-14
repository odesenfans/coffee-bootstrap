------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:14 01/03/06
-- File : mu_csa_typ_a.vhd
-- Design : mu_csa_typ_a
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mu_csa_typ_a IS
   PORT( 
      opa_lo : IN     std_logic_vector (15 DOWNTO 0);
      opa_hi : IN     std_logic_vector (15 DOWNTO 0);
      opb_lo : IN     std_logic_vector (15 DOWNTO 0);
      opb_hi : IN     std_logic_vector (15 DOWNTO 0);
      opc_lo : IN     std_logic_vector (15 DOWNTO 0);
      opc_hi : IN     std_logic_vector (15 DOWNTO 0);
      s      : OUT    std_logic_vector (31 DOWNTO 0);
      c      : OUT    std_logic_vector (32 DOWNTO 0)
   );

-- Declarations

END mu_csa_typ_a ;

architecture mu_csa_typ_a_arch of mu_csa_typ_a is
    signal a, b, d : std_logic_vector(31 downto 0);
begin
    a <= opa_hi & opa_lo;
    b <= opb_hi & opb_lo;
    d <= opc_hi & opc_lo;
    process(a, b, d)
    begin
        for i in 31 downto 1 loop
            s(i) <= a(i) xor b(i) xor d(i);
	        c(i) <= (a(i-1) and b(i-1)) or (a(i-1) and d(i-1)) or (b(i-1) and d(i-1));
        end loop;
        c(0) <= '0';
        s(0) <= a(0) xor b(0) xor d(0);
        c(32) <= (a(31) and b(31)) or (a(31) and d(31)) or (b(31) and d(31));
    end process;
end mu_csa_typ_a_arch;
