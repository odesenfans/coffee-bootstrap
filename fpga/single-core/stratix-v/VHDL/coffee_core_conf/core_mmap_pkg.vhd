------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 11:53:05 01/20/05
-- File : fpga_demo_pkg.vhd
-- Design : fpga_demo_pkg
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package core_mmap_pkg is

	constant alternative_boot_address : std_logic_vector(31 downto 0) := "00000000000000000001111100000000";

	--------------------------------------------------------------------------
	-- Address mapping of the shared data bus
	--------------------------------------------------------------------------
	-- Peripheral device address space seen by COFFEE core
	--------------------------------------------------------------------------
	constant pda_imem_beg : std_logic_vector(31 downto 0)  := "00000000000001000000000000000000";
	constant pda_imem_end : std_logic_vector(31 downto 0)  := "00000000000001111111111111111111";
	--constant pda_uart_beg : std_logic_vector(31 downto 0)  := "00000000000000010000000000000000";
	--constant pda_uart_end : std_logic_vector(31 downto 0)  := "00000000000000010000000000001111";
	--constant pda_nocif_beg : std_logic_vector(31 downto 0) := "00000000000000011000000000000000";
	--constant pda_nocif_end : std_logic_vector(31 downto 0) := "00000000000000011000000000001111";
	--constant pda_arb_beg : std_logic_vector(31 downto 0)   := "00000000000000100000000000000000";
	--constant pda_arb_end : std_logic_vector(31 downto 0)   := "00000000000000100000000000001111";
	--constant pda_prf_beg : std_logic_vector(31 downto 0)   := "00000000000000101000000000000000";
	--constant pda_prf_end : std_logic_vector(31 downto 0)   := "00000000000000101000000000111111";

	--------------------------------------------------------------------------
	-- Memory device address space seen by UART and network interface
	--------------------------------------------------------------------------
	constant mda_imem_beg : std_logic_vector(31 downto 0) := "00000000000001000000000000000000";
	constant mda_imem_end : std_logic_vector(31 downto 0) := "00000000000001111111111111111111";
	constant mda_dmem_beg : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	constant mda_dmem_end : std_logic_vector(31 downto 0) := "00000000000000111111111111111111";

	--------------------------------------------------------------------------
	-- Settings for 'optimal' address decoding. 
	-- IF YOU CHANGE ADDRESSES ABOVE, UPDATE THIS SECTION ALSO!!
	--------------------------------------------------------------------------
	constant pda_cs_hi_bnd : integer := 19;
	constant pda_cs_lo_bnd : integer := 19;
	constant pda_cs_length : integer := (pda_cs_hi_bnd-pda_cs_lo_bnd+1);

	constant mda_cs_hi_bnd : integer := 18;
	constant mda_cs_lo_bnd : integer := 18;
	constant mda_cs_length : integer := (mda_cs_hi_bnd-mda_cs_lo_bnd+1);

	--------------------------------------------------------------------------
	-- Coprocessor IDs (devices on coprocessor bus)
	--------------------------------------------------------------------------
	--constant SSEGA    : integer := 0;
	--constant SSEGB    : integer := 1;
	--constant VGAIF    : integer := 2;
	--constant LEDS_ID  : integer := 3;

end core_mmap_pkg;

