------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 15:05:57 01/03/06
-- File : core_conf_pkg.vhd
-- Design : core_conf_pkg
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
package core_conf_pkg is

-----------------------------------------
-- Address bus settings
-----------------------------------------
--constant dbus_abits_c    : integer := 20; -- data bus address bits
constant dbus_abits_c    : integer := 32; -- data bus address bits
constant imem_abits_c    : integer := 17; -- instruction memory address bits
constant dmem_abits_c    : integer := 18; -- data memory address bits
-- extract bits (imem_abit_lsb_c-1 downto 0) from instruction memory address bus
constant imem_abit_lsb_c : integer := 0;  
-------------------------------------------------------------------------------

---------------------------------------------------------------
-- Debug interface signal definitions. Feel free to add more... 
--------------------------------------------------------------
constant n_debug_bits_out : natural := 33;
constant n_debug_bits_in  : natural := 2;
-------------------------------------------------------------------------------------------------------
-- Debug signals
-------------------------------------------------------------------------------------------------------
constant DEBUG_COP_STALL_INDX   : natural := 0;
constant DEBUG_DMEM_STALL_INDX  : natural := 1;
constant DEBUG_IMEM_STALL_INDX  : natural := 2;
constant DEBUG_EXT_STALL_INDX   : natural := 3;
constant DEBUG_DBUS_STALL_INDX  : natural := 4;
constant DEBUG_CFLAG_STALL_INDX : natural := 5;
constant DEBUG_JADDR_STALL_INDX : natural := 6;
constant DEBUG_IMISS_STALL_INDX : natural := 7;
constant DEBUG_DMISS_STALL_INDX : natural := 8;
constant DEBUG_ATOM_STALL_INDX  : natural := 9;
constant DEBUG_DATA_STALL_INDX  : natural := 10;

constant DEBUG_ENABLE_STG0_INDX : natural := 11;
constant DEBUG_ENABLE_STG1_INDX : natural := 12;
constant DEBUG_ENABLE_STG2_INDX : natural := 13;
constant DEBUG_ENABLE_STG3_INDX : natural := 14;
constant DEBUG_ENABLE_STG4_INDX : natural := 15;
constant DEBUG_ENABLE_STG5_INDX : natural := 16;

constant DEBUG_FLUSH_STG0_INDX  : natural := 17;
constant DEBUG_FLUSH_STG1_INDX  : natural := 18;
constant DEBUG_FLUSH_STG2_INDX  : natural := 19;
constant DEBUG_FLUSH_STG3_INDX  : natural := 20;

constant DEBUG_COP0_SERV_INDX    : natural := 21;
constant DEBUG_COP1_SERV_INDX    : natural := 22;
constant DEBUG_COP2_SERV_INDX    : natural := 23;
constant DEBUG_COP3_SERV_INDX    : natural := 24;

constant DEBUG_EINT0_SERV_INDX   : natural := 25;
constant DEBUG_EINT1_SERV_INDX   : natural := 26;
constant DEBUG_EINT2_SERV_INDX   : natural := 27;
constant DEBUG_EINT3_SERV_INDX   : natural := 28;
constant DEBUG_EINT4_SERV_INDX   : natural := 29;
constant DEBUG_EINT5_SERV_INDX   : natural := 30;
constant DEBUG_EINT6_SERV_INDX   : natural := 31;
constant DEBUG_EINT7_SERV_INDX   : natural := 32;

end core_conf_pkg;
