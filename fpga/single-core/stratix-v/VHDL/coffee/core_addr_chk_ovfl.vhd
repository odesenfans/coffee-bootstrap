------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:18 01/03/06
-- File : core_addr_chk_ovfl.vhd
-- Design : core_addr_chk_ovfl
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_addr_chk_ovfl IS
   PORT( 
      carry      : IN     std_logic;
      base_msb   : IN     std_logic;
      offset_msb : IN     std_logic;
      addr_msb   : IN     std_logic;
      addr_ovfl  : OUT    std_logic;
      chk        : IN     std_logic
   );

-- Declarations

END core_addr_chk_ovfl ;

architecture core_addr_chk_ovfl_arch of core_addr_chk_ovfl is

    signal overflow_i, overflow_ii      : std_logic;

begin
-- Two cases of address overflow can be detected:
-- case 1: Carry out generated when MSB of the base is one
-- and the offset is positive(msb of the offset is 0) that
-- is indexing forward from end of the memory
-- case 2: msb of the result address is one when msb
-- of the base is zero before adding and the offset is negative.
-- that means indexing backward from the beginning of the memory

    overflow_i  <= carry and base_msb and not(offset_msb) and chk;
    overflow_ii <= addr_msb and not(base_msb) and offset_msb and chk;

    addr_ovfl   <= overflow_i or overflow_ii;

end core_addr_chk_ovfl_arch;
