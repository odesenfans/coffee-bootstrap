------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:20 01/03/06
-- File : adder_32bit_cla.vhd
-- Design : adder_32bit_cla
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY adder_32bit_cla IS
   PORT( 
      cin  : IN     std_logic;
      opa  : IN     std_logic_vector (31 DOWNTO 0);
      opb  : IN     std_logic_vector (31 DOWNTO 0);
      cout : OUT    std_logic;
      sum  : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END adder_32bit_cla ;

architecture cla_adder_32bit_arch of adder_32bit_cla is

	component cla_8bit 
		port (
				a:  in  std_logic_vector(7 downto 0);
				b:  in  std_logic_vector(7 downto 0);
				ci: in  std_logic;
				s:  out std_logic_vector(7 downto 0);
				co: out std_logic;
				pr: out std_logic
				);
	end component;


	type array_4x8 is array (3 downto 0) of std_logic_vector(7 downto 0);

	signal sum_slice : array_4x8;
	signal c         : std_logic_vector(3 downto 0); -- 2nd level carry
	signal g         : std_logic_vector(3 downto 0); -- 2nd level generate
	signal p         : std_logic_vector(3 downto 0); -- 2nd level propagate

begin
	clas :	for i in 3 downto 0 generate
		cla : cla_8bit
			port map (
				a  => opa(i * 8 + 7 downto i * 8),
				b  => opb(i * 8 + 7 downto i * 8),
				ci => c(i),
				s  => sum_slice(i),
				co => g(i),
				pr => p(i)
			);
	end generate clas;

	-- carry in for each cla block
	process(g, p, cin)
		begin
			c(0) <= cin;
			c(1) <= (cin and p(0)) or g(0);
			c(2) <= (cin and p(0) and p(1)) or (g(0) and p(1)) or g(1);
			c(3) <= (cin and p(0) and p(1) and p(2)) or (g(0) and p(1) and p(2)) or (g(1) and p(2)) or g(2);
	end process;

	sum <= sum_slice(3) & sum_slice(2) & sum_slice(1) & sum_slice(0);
	cout <= g(3);

end cla_adder_32bit_arch;
