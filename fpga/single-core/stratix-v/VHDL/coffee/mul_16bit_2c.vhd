------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : mul_16bit_2c.vhd
-- Design : mul_16bit_2c
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY mul_16bit_2c IS
   PORT( 
      clk        : IN     std_logic;
      enable1st  : IN     std_logic;                       -- Enable step 1
      op_i_type  : IN     std_logic;
      op_ii_type : IN     std_logic;
      opa        : IN     std_logic_vector (15 DOWNTO 0);
      opb        : IN     std_logic_vector (15 DOWNTO 0);
      rst_x      : IN     std_logic;
      sel16or32  : IN     std_logic;
      prod_full  : OUT    std_logic_vector (31 DOWNTO 0);  -- 32 bit product
      prod_hi    : OUT    std_logic_vector (15 DOWNTO 0);  -- Upper halfword of the product
      prod_lo    : OUT    std_logic_vector (15 DOWNTO 0)   -- Lower halfword of the product
   );

-- Declarations

END mul_16bit_2c ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:13 01/03/06
-- File : mul_16bit_2c.vhd
-- Design : mul_16bit_2c
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ARCHITECTURE struct_opt OF mul_16bit_2c IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL isum_w0      : std_logic_vector(15 DOWNTO 0);
   SIGNAL isum_w16     : std_logic_vector(15 DOWNTO 0);
   SIGNAL isum_w16_uns : std_logic_vector(15 DOWNTO 0);
   SIGNAL isum_w8      : std_logic_vector(16 DOWNTO 0);
   SIGNAL uns          : std_logic;


   -- Component Declarations
   COMPONENT m16b_opt_s1
   PORT (
      clk          : IN     std_logic ;
      enable1st    : IN     std_logic ;
      op_i_type    : IN     std_logic ;
      op_ii_type   : IN     std_logic ;
      opa          : IN     std_logic_vector (15 DOWNTO 0);
      opb          : IN     std_logic_vector (15 DOWNTO 0);
      rst_x        : IN     std_logic ;
      sel16or32    : IN     std_logic ;
      isum_w0      : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w16     : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w16_uns : OUT    std_logic_vector (15 DOWNTO 0);
      isum_w8      : OUT    std_logic_vector (16 DOWNTO 0);
      uns          : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT m16b_opt_s2
   PORT (
      isum_w0      : IN     std_logic_vector (15 DOWNTO 0);
      isum_w16     : IN     std_logic_vector (15 DOWNTO 0);
      isum_w16_uns : IN     std_logic_vector (15 DOWNTO 0);
      isum_w8      : IN     std_logic_vector (16 DOWNTO 0);
      uns          : IN     std_logic ;
      prod_full    : OUT    std_logic_vector (31 DOWNTO 0);
      prod_hi      : OUT    std_logic_vector (15 DOWNTO 0);
      prod_lo      : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Instance port mappings.
   I0 : m16b_opt_s1
      PORT MAP (
         clk          => clk,
         enable1st    => enable1st,
         op_i_type    => op_i_type,
         op_ii_type   => op_ii_type,
         opa          => opa,
         opb          => opb,
         rst_x        => rst_x,
         sel16or32    => sel16or32,
         isum_w0      => isum_w0,
         isum_w16     => isum_w16,
         isum_w16_uns => isum_w16_uns,
         isum_w8      => isum_w8,
         uns          => uns
      );
   I1 : m16b_opt_s2
      PORT MAP (
         isum_w0      => isum_w0,
         isum_w16     => isum_w16,
         isum_w16_uns => isum_w16_uns,
         isum_w8      => isum_w8,
         uns          => uns,
         prod_full    => prod_full,
         prod_hi      => prod_hi,
         prod_lo      => prod_lo
      );

END struct_opt;
