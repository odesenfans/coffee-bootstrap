------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:23 01/03/06
-- File : core_addr_chk_align.vhd
-- Design : core_addr_chk_align
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_addr_chk_align IS
   PORT( 
      addr              : IN     std_logic_vector (31 DOWNTO 0);
      il                : IN     std_logic;                       -- processor mode (16/32 bits)
      miss_aligned_addr : OUT    std_logic;
      check_enable      : IN     std_logic
   );

-- Declarations

END core_addr_chk_align ;

architecture core_addr_chk_align_arch of core_addr_chk_align is

begin

	miss_aligned_addr <= (addr(0) or (il and addr(1))) and check_enable;

end core_addr_chk_align_arch;
