------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:14 01/03/06
-- File : core_mu.vhd
-- Design : core_mu
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY core_mu IS
   PORT( 
      clk             : IN     std_logic;
      enable1st       : IN     std_logic;
      enable2nd       : IN     std_logic;
      enable3rd       : IN     std_logic;
      op_i_type       : IN     std_logic;
      op_ii_type      : IN     std_logic;
      operand_i       : IN     std_logic_vector (31 DOWNTO 0);
      operand_ii      : IN     std_logic_vector (31 DOWNTO 0);
      rst_x           : IN     std_logic;
      sel16or32       : IN     std_logic;
      result16x16full : OUT    std_logic_vector (31 DOWNTO 0);
      result32x32hi   : OUT    std_logic_vector (31 DOWNTO 0);
      result32x32lo   : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END core_mu ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : core_mu.vhd
-- Design : core_mu
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------


ARCHITECTURE struct OF core_mu IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL c                : std_logic_vector(32 DOWNTO 0);
   SIGNAL c1               : std_logic_vector(31 DOWNTO 0);
   SIGNAL co               : std_logic;
   SIGNAL corr_term        : std_logic_vector(31 DOWNTO 0);
   SIGNAL intermediate_sum : std_logic_vector(31 DOWNTO 0);
   SIGNAL opa              : std_logic_vector(31 DOWNTO 0);
   SIGNAL opc              : std_logic_vector(1 DOWNTO 0);
   SIGNAL prod_hi          : std_logic_vector(15 DOWNTO 0);
   SIGNAL prod_lo          : std_logic_vector(15 DOWNTO 0);
   SIGNAL q                : std_logic_vector(15 DOWNTO 0);
   SIGNAL q1               : std_logic_vector(15 DOWNTO 0);
   SIGNAL q10              : std_logic;
   SIGNAL q11              : std_logic_vector(31 DOWNTO 0);
   SIGNAL q2               : std_logic_vector(15 DOWNTO 0);
   SIGNAL q3               : std_logic_vector(15 DOWNTO 0);
   SIGNAL q4               : std_logic_vector(15 DOWNTO 0);
   SIGNAL q5               : std_logic_vector(15 DOWNTO 0);
   SIGNAL q7               : std_logic_vector(15 DOWNTO 0);
   SIGNAL q8               : std_logic_vector(31 DOWNTO 0);
   SIGNAL q9               : std_logic;
   SIGNAL result32x32lo_s  : std_logic_vector(15 DOWNTO 0);
   SIGNAL s                : std_logic_vector(31 DOWNTO 0);
   SIGNAL s1               : std_logic_vector(31 DOWNTO 0);
   SIGNAL uprod_hi         : std_logic_vector(15 DOWNTO 0);
   SIGNAL uprod_hi1        : std_logic_vector(15 DOWNTO 0);
   SIGNAL uprod_hi2        : std_logic_vector(15 DOWNTO 0);
   SIGNAL uprod_lo         : std_logic_vector(15 DOWNTO 0);
   SIGNAL uprod_lo1        : std_logic_vector(15 DOWNTO 0);
   SIGNAL uprod_lo2        : std_logic_vector(15 DOWNTO 0);
   SIGNAL zero             : std_logic;


   -- Component Declarations
   COMPONENT adder_32bit
   PORT (
      cin  : IN     std_logic ;
      opa  : IN     std_logic_vector (31 DOWNTO 0);
      opb  : IN     std_logic_vector (31 DOWNTO 0);
      cout : OUT    std_logic ;
      sum  : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT adder_32bit_nc
   PORT (
      opa : IN     std_logic_vector (31 DOWNTO 0);
      opb : IN     std_logic_vector (31 DOWNTO 0);
      sum : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT dff_we
   PORT (
      d     : IN     std_logic ;
      clk   : IN     std_logic ;
      en    : IN     std_logic ;
      q     : OUT    std_logic ;
      rst_x : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT half_adder
   PORT (
      a : IN     std_logic ;
      b : IN     std_logic ;
      s : OUT    std_logic ;
      c : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT mu_csa_typ_a
   PORT (
      opa_lo : IN     std_logic_vector (15 DOWNTO 0);
      opa_hi : IN     std_logic_vector (15 DOWNTO 0);
      opb_lo : IN     std_logic_vector (15 DOWNTO 0);
      opb_hi : IN     std_logic_vector (15 DOWNTO 0);
      opc_lo : IN     std_logic_vector (15 DOWNTO 0);
      opc_hi : IN     std_logic_vector (15 DOWNTO 0);
      s      : OUT    std_logic_vector (31 DOWNTO 0);
      c      : OUT    std_logic_vector (32 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT mu_csa_typ_f
   PORT (
      opa : IN     std_logic_vector (31 DOWNTO 0);
      opb : IN     std_logic_vector (31 DOWNTO 0);
      opc : IN     std_logic_vector (1 DOWNTO 0); -- lsb position 16
      s   : OUT    std_logic_vector (31 DOWNTO 0);
      c   : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT mul_16bit_2c
   PORT (
      clk        : IN     std_logic ;
      enable1st  : IN     std_logic ;                     -- Enable step 1
      op_i_type  : IN     std_logic ;
      op_ii_type : IN     std_logic ;
      opa        : IN     std_logic_vector (15 DOWNTO 0);
      opb        : IN     std_logic_vector (15 DOWNTO 0);
      rst_x      : IN     std_logic ;
      sel16or32  : IN     std_logic ;
      prod_full  : OUT    std_logic_vector (31 DOWNTO 0); -- 32 bit product
      prod_hi    : OUT    std_logic_vector (15 DOWNTO 0); -- Upper halfword of the product
      prod_lo    : OUT    std_logic_vector (15 DOWNTO 0)  -- Lower halfword of the product
   );
   END COMPONENT;
   COMPONENT mul_16bit_u
   PORT (
      clk       : IN     std_logic ;
      enable1st : IN     std_logic ;
      opa       : IN     std_logic_vector (15 DOWNTO 0);
      opb       : IN     std_logic_vector (15 DOWNTO 0);
      rst_x     : IN     std_logic ;
      uprod_hi  : OUT    std_logic_vector (15 DOWNTO 0); -- lower halfword of the unsigned product
      uprod_lo  : OUT    std_logic_vector (15 DOWNTO 0)  -- upper halfword of the unsigned product
   );
   END COMPONENT;
   COMPONENT mul_32bit_sign_logic
   PORT (
      op_i_type  : IN     std_logic ;
      op_ii_type : IN     std_logic ;
      corr_term  : OUT    std_logic_vector (31 DOWNTO 0);
      operand_i  : IN     std_logic_vector (31 DOWNTO 0);
      operand_ii : IN     std_logic_vector (31 DOWNTO 0);
      enable     : IN     std_logic ;
      clk        : IN     std_logic ;
      rst_x      : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT r16b_we
   PORT (
      d     : IN     std_logic_vector (15 DOWNTO 0);
      clk   : IN     std_logic ;
      en    : IN     std_logic ;
      q     : OUT    std_logic_vector (15 DOWNTO 0);
      rst_x : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT r32b_we
   PORT (
      d     : IN     std_logic_vector (31 DOWNTO 0);
      clk   : IN     std_logic ;
      en    : IN     std_logic ;
      rst_x : IN     std_logic ;
      q     : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   zero <= '0';

   -- HDL Embedded Text Block 2 eb2
   result32x32lo <= intermediate_sum(15 downto 0) & result32x32lo_s;

   -- Instance port mappings.
   I6 : adder_32bit
      PORT MAP (
         cin  => zero,
         opa  => s,
         opb  => c(31 DOWNTO 0),
         cout => co,
         sum  => intermediate_sum
      );
   I13 : adder_32bit_nc
      PORT MAP (
         opa => s1,
         opb => c1,
         sum => result32x32hi
      );
   I8 : dff_we
      PORT MAP (
         d     => co,
         clk   => clk,
         en    => enable3rd,
         q     => q9,
         rst_x => rst_x
      );
   I7 : dff_we
      PORT MAP (
         d     => c(32),
         clk   => clk,
         en    => enable3rd,
         q     => q10,
         rst_x => rst_x
      );
   I10 : half_adder
      PORT MAP (
         a => q9,
         b => q10,
         s => opc(0),
         c => opc(1)
      );
   I5 : mu_csa_typ_a
      PORT MAP (
         opa_lo => q,
         opa_hi => q2,
         opb_lo => q1,
         opb_hi => q4,
         opc_lo => q3,
         opc_hi => q5,
         s      => s,
         c      => c
      );
   I11 : mu_csa_typ_f
      PORT MAP (
         opa => opa,
         opb => q11,
         opc => opc,
         s   => s1,
         c   => c1
      );
   I15 : mul_16bit_2c
      PORT MAP (
         clk        => clk,
         enable1st  => enable1st,
         op_i_type  => op_i_type,
         op_ii_type => op_ii_type,
         opa        => operand_i(15 DOWNTO 0),
         opb        => operand_ii(15 DOWNTO 0),
         rst_x      => rst_x,
         sel16or32  => sel16or32,
         prod_full  => result16x16full,
         prod_hi    => prod_hi,
         prod_lo    => prod_lo
      );
   I1 : mul_16bit_u
      PORT MAP (
         clk       => clk,
         enable1st => enable1st,
         opa       => operand_i(15 DOWNTO 0),
         opb       => operand_ii(31 DOWNTO 16),
         rst_x     => rst_x,
         uprod_hi  => uprod_hi,
         uprod_lo  => uprod_lo
      );
   I2 : mul_16bit_u
      PORT MAP (
         clk       => clk,
         enable1st => enable1st,
         opa       => operand_i(31 DOWNTO 16),
         opb       => operand_ii(15 DOWNTO 0),
         rst_x     => rst_x,
         uprod_hi  => uprod_hi1,
         uprod_lo  => uprod_lo1
      );
   I3 : mul_16bit_u
      PORT MAP (
         clk       => clk,
         enable1st => enable1st,
         opa       => operand_i(31 DOWNTO 16),
         opb       => operand_ii(31 DOWNTO 16),
         rst_x     => rst_x,
         uprod_hi  => uprod_hi2,
         uprod_lo  => uprod_lo2
      );
   I4 : mul_32bit_sign_logic
      PORT MAP (
         op_i_type  => op_i_type,
         op_ii_type => op_ii_type,
         corr_term  => corr_term,
         operand_i  => operand_i,
         operand_ii => operand_ii,
         enable     => enable1st,
         clk        => clk,
         rst_x      => rst_x
      );
   I36 : r16b_we
      PORT MAP (
         d     => intermediate_sum(31 DOWNTO 16),
         clk   => clk,
         en    => enable3rd,
         q     => opa(15 DOWNTO 0),
         rst_x => rst_x
      );
   I35 : r16b_we
      PORT MAP (
         d     => q7,
         clk   => clk,
         en    => enable3rd,
         q     => opa(31 DOWNTO 16),
         rst_x => rst_x
      );
   I25 : r16b_we
      PORT MAP (
         d     => prod_lo,
         clk   => clk,
         en    => enable2nd,
         q     => result32x32lo_s,
         rst_x => rst_x
      );
   I32 : r16b_we
      PORT MAP (
         d     => uprod_hi2,
         clk   => clk,
         en    => enable2nd,
         q     => q7,
         rst_x => rst_x
      );
   I31 : r16b_we
      PORT MAP (
         d     => uprod_lo2,
         clk   => clk,
         en    => enable2nd,
         q     => q5,
         rst_x => rst_x
      );
   I30 : r16b_we
      PORT MAP (
         d     => uprod_hi1,
         clk   => clk,
         en    => enable2nd,
         q     => q4,
         rst_x => rst_x
      );
   I29 : r16b_we
      PORT MAP (
         d     => uprod_lo1,
         clk   => clk,
         en    => enable2nd,
         q     => q3,
         rst_x => rst_x
      );
   I28 : r16b_we
      PORT MAP (
         d     => uprod_hi,
         clk   => clk,
         en    => enable2nd,
         q     => q2,
         rst_x => rst_x
      );
   I27 : r16b_we
      PORT MAP (
         d     => uprod_lo,
         clk   => clk,
         en    => enable2nd,
         q     => q1,
         rst_x => rst_x
      );
   I26 : r16b_we
      PORT MAP (
         d     => prod_hi,
         clk   => clk,
         en    => enable2nd,
         q     => q,
         rst_x => rst_x
      );
   I0 : r32b_we
      PORT MAP (
         d     => corr_term,
         clk   => clk,
         en    => enable2nd,
         rst_x => rst_x,
         q     => q8
      );
   I9 : r32b_we
      PORT MAP (
         d     => q8,
         clk   => clk,
         en    => enable3rd,
         rst_x => rst_x,
         q     => q11
      );

END struct;
