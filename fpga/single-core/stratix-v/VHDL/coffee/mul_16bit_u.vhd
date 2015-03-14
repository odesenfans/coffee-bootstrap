------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : mul_16bit_u.vhd
-- Design : mul_16bit_u
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mul_16bit_u IS
   PORT( 
      clk       : IN     std_logic;
      enable1st : IN     std_logic;
      opa       : IN     std_logic_vector (15 DOWNTO 0);
      opb       : IN     std_logic_vector (15 DOWNTO 0);
      rst_x     : IN     std_logic;
      uprod_hi  : OUT    std_logic_vector (15 DOWNTO 0);  -- lower halfword of the unsigned product
      uprod_lo  : OUT    std_logic_vector (15 DOWNTO 0)   -- upper halfword of the unsigned product
   );

-- Declarations

END mul_16bit_u ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : mul_16bit_u.vhd
-- Design : mul_16bit_u
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ARCHITECTURE struct_opt OF mul_16bit_u IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL isum_w0  : std_logic_vector(15 DOWNTO 0);
   SIGNAL isum_w16 : std_logic_vector(15 DOWNTO 0);
   SIGNAL isum_w8  : std_logic_vector(16 DOWNTO 0);


   -- Component Declarations
   COMPONENT m16b_uns_s1
   PORT (
      clk       : IN     std_logic ;
      enable1st : IN     std_logic ;
      opa       : IN     std_logic_vector (15 DOWNTO 0);
      opb       : IN     std_logic_vector (15 DOWNTO 0);
      rst_x     : IN     std_logic ;
      isum_w0   : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w16  : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w8   : OUT    std_logic_vector (16 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT m16b_uns_s2
   PORT (
      isum_w0  : IN     std_logic_vector (15 DOWNTO 0);
      isum_w16 : IN     std_logic_vector (15 DOWNTO 0);
      isum_w8  : IN     std_logic_vector (16 DOWNTO 0);
      uprod_hi : OUT    std_logic_vector (15 DOWNTO 0);
      uprod_lo : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Instance port mappings.
   I0 : m16b_uns_s1
      PORT MAP (
         clk       => clk,
         enable1st => enable1st,
         opa       => opa,
         opb       => opb,
         rst_x     => rst_x,
         isum_w0   => isum_w0,
         isum_w16  => isum_w16,
         isum_w8   => isum_w8
      );
   I3 : m16b_uns_s2
      PORT MAP (
         isum_w0  => isum_w0,
         isum_w16 => isum_w16,
         isum_w8  => isum_w8,
         uprod_hi => uprod_hi,
         uprod_lo => uprod_lo
      );

END struct_opt;
