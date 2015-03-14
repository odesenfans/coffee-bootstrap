--------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 
-- File : 
-- Design : 
--------------------------------------------------------------------
-- Description :
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package core_constants_pkg is

type array_12x32_stdl is array (0 to 11) of std_logic_vector(31 downto 0);
-----------------------------------------
-- reset values of internal CCB registers
-----------------------------------------
constant CCB_BASE_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000010000000000000000";
constant PCB_BASE_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000010000000100000000"; --
constant PCB_END_RVAL       : std_logic_vector(31 downto 0)  := "00000000000000010000000111111111"; --
constant PCB_AMASK_RVAL     : std_logic_vector(31 downto 0)  := "00000000000000000000000011111111"; --
constant COP0_INT_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant COP1_INT_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant COP2_INT_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant COP3_INT_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT0_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT1_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT2_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT3_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT4_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT5_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT6_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant EXT_INT7_VEC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant INT_MODE_IL_RVAL   : std_logic_vector(31 downto 0)  := "00000000000000000000111111111111";
constant INT_MODE_UM_RVAL   : std_logic_vector(31 downto 0)  := "00000000000000000000111111111111";
constant INT_MASK_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant INT_SERV_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant INT_PEND_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant EXT_INT_PRI_RVAL   : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant COP_INT_PRI_RVAL   : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant EXCEPTION_CS_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant EXCEPTION_PC_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant EXCEPTION_PSR_RVAL : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant DMEM_BOUND_LO_RVAL : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant DMEM_BOUND_HI_RVAL : std_logic_vector(31 downto 0)  := "11111111111111111111111111111111";
constant IMEM_BOUND_LO_RVAL : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant IMEM_BOUND_HI_RVAL : std_logic_vector(31 downto 0)  := "11111111111111111111111111111111";
constant MEM_CONF_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000011";
constant SYSTEM_ADDR_RVAL   : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant EXCEP_ADDR_RVAL    : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant BUS_CONF_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000111111111111";
constant COP_CONF_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant TMR0_CNT_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant TMR0_MAX_CNT_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant TMR1_CNT_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant TMR1_MAX_CNT_RVAL  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant TMR_CONF_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
constant RETI_ADDR_RVAL     : std_logic_vector(31 downto 0)  := "00000000000000000000000000000001";
constant RETI_PSR_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000001001";
constant RETI_CR0_RVAL      : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";

-----------------------------------------
-- offsets of internal CCB registers
-----------------------------------------
constant CCB_BASE_INDX      : integer range 0 to 255  := 0;
constant PCB_BASE_INDX      : integer range 0 to 255  := 1;
constant PCB_END_INDX       : integer range 0 to 255  := 2;
constant PCB_AMASK_INDX     : integer range 0 to 255  := 3;
constant COP0_INT_VEC_INDX  : integer range 0 to 255  := 4;
constant COP1_INT_VEC_INDX  : integer range 0 to 255  := 5;
constant COP2_INT_VEC_INDX  : integer range 0 to 255  := 6;
constant COP3_INT_VEC_INDX  : integer range 0 to 255  := 7;
constant EXT_INT0_VEC_INDX  : integer range 0 to 255  := 8;
constant EXT_INT1_VEC_INDX  : integer range 0 to 255  := 9;
constant EXT_INT2_VEC_INDX  : integer range 0 to 255  := 10;
constant EXT_INT3_VEC_INDX  : integer range 0 to 255  := 11;
constant EXT_INT4_VEC_INDX  : integer range 0 to 255  := 12;
constant EXT_INT5_VEC_INDX  : integer range 0 to 255  := 13;
constant EXT_INT6_VEC_INDX  : integer range 0 to 255  := 14;
constant EXT_INT7_VEC_INDX  : integer range 0 to 255  := 15;
constant INT_MODE_IL_INDX   : integer range 0 to 255  := 16;
constant INT_MODE_UM_INDX   : integer range 0 to 255  := 17;
constant INT_MASK_INDX      : integer range 0 to 255  := 18;
constant INT_SERV_INDX      : integer range 0 to 255  := 19;
constant INT_PEND_INDX      : integer range 0 to 255  := 20;
constant EXT_INT_PRI_INDX   : integer range 0 to 255  := 21;
constant COP_INT_PRI_INDX   : integer range 0 to 255  := 22;
constant EXCEPTION_CS_INDX  : integer range 0 to 255  := 23;
constant EXCEPTION_PC_INDX  : integer range 0 to 255  := 24;
constant EXCEPTION_PSR_INDX : integer range 0 to 255  := 25;
constant DMEM_BOUND_LO_INDX : integer range 0 to 255  := 26;
constant DMEM_BOUND_HI_INDX : integer range 0 to 255  := 27;
constant IMEM_BOUND_LO_INDX : integer range 0 to 255  := 28;
constant IMEM_BOUND_HI_INDX : integer range 0 to 255  := 29;
constant MEM_CONF_INDX      : integer range 0 to 255  := 30;
constant SYSTEM_ADDR_INDX   : integer range 0 to 255  := 31;
constant EXCEP_ADDR_INDX    : integer range 0 to 255  := 32;
constant BUS_CONF_INDX      : integer range 0 to 255  := 33;
constant COP_CONF_INDX      : integer range 0 to 255  := 34;
constant TMR0_CNT_INDX      : integer range 0 to 255  := 35;
constant TMR0_MAX_CNT_INDX  : integer range 0 to 255  := 36;
constant TMR1_CNT_INDX      : integer range 0 to 255  := 37;
constant TMR1_MAX_CNT_INDX  : integer range 0 to 255  := 38;
constant TMR_CONF_INDX      : integer range 0 to 255  := 39;
constant RETI_ADDR_INDX     : integer range 0 to 255  := 40;
constant RETI_PSR_INDX      : integer range 0 to 255  := 41;
constant RETI_CR0_INDX      : integer range 0 to 255  := 42;

constant number_of_ccb_registers_c : integer range 0 to 255 := 43;

-----------------------------------------
-- Other reset values
-----------------------------------------
constant PSR_R  : std_logic_vector(7 downto 0)    := "00001110";
constant SPSR_R  : std_logic_vector(31 downto 0)  := "00000000000000000000000000001001";

-----------------------------------------
-- alu operations
-----------------------------------------
constant alu_add       : std_logic_vector(4 downto 0) := "00000";
constant alu_and       : std_logic_vector(4 downto 0) := "00001";
constant alu_cmp       : std_logic_vector(4 downto 0) := "00010";
constant alu_conb      : std_logic_vector(4 downto 0) := "00011";
constant alu_conh      : std_logic_vector(4 downto 0) := "00100";
constant alu_exb       : std_logic_vector(4 downto 0) := "00101";
constant alu_exbf      : std_logic_vector(4 downto 0) := "00110";
constant alu_exh       : std_logic_vector(4 downto 0) := "00111";
constant alu_bypass_i  : std_logic_vector(4 downto 0) := "01000";
constant alu_bypass_ii : std_logic_vector(4 downto 0) := "01001";
constant alu_muls      : std_logic_vector(4 downto 0) := "01011";
constant alu_muls_16   : std_logic_vector(4 downto 0) := "01100";
constant alu_mulu      : std_logic_vector(4 downto 0) := "01101";
constant alu_mulu_16   : std_logic_vector(4 downto 0) := "01110";
constant alu_mulus     : std_logic_vector(4 downto 0) := "01111";
constant alu_mulus_16  : std_logic_vector(4 downto 0) := "10000";
constant alu_not       : std_logic_vector(4 downto 0) := "10001";
constant alu_or        : std_logic_vector(4 downto 0) := "10010";
constant alu_sext      : std_logic_vector(4 downto 0) := "10011";
constant alu_sll       : std_logic_vector(4 downto 0) := "10100";
constant alu_sra       : std_logic_vector(4 downto 0) := "10101";
constant alu_srl       : std_logic_vector(4 downto 0) := "10110";
constant alu_sub       : std_logic_vector(4 downto 0) := "10111";
constant alu_xor       : std_logic_vector(4 downto 0) := "11000";

-----------------------------------------
-- Operation codes for execution blocks
-----------------------------------------
constant alu_asc_add    : std_logic_vector(1 downto 0) := "01";
constant alu_asc_sub    : std_logic_vector(1 downto 0) := "11";
constant alu_asc_cmp    : std_logic_vector(1 downto 0) := "10";

constant alu_bm_conb    : std_logic_vector(1 downto 0) := "10";
constant alu_bm_conh    : std_logic_vector(1 downto 0) := "11";
constant alu_bm_exb     : std_logic_vector(1 downto 0) := "00";
constant alu_bm_exh     : std_logic_vector(1 downto 0) := "01";

constant alu_bo_xor     : std_logic_vector(1 downto 0) := "11";
constant alu_bo_and     : std_logic_vector(1 downto 0) := "00";
constant alu_bo_not     : std_logic_vector(1 downto 0) := "01";
constant alu_bo_or      : std_logic_vector(1 downto 0) := "10";

constant alu_shift_exbf : std_logic_vector(2 downto 0) := "011";
constant alu_shift_sext : std_logic_vector(2 downto 0) := "100";
constant alu_shift_sll  : std_logic_vector(2 downto 0) := "000";
constant alu_shift_sra  : std_logic_vector(2 downto 0) := "010";
constant alu_shift_srl  : std_logic_vector(2 downto 0) := "001";

-------------------------------------------------------------------------------
-- Opcodes
-- Note that opcodes cannot be changed randomly without changing
-- the existing implementation. Opcodes have dependencies inside one 'class'
-- of instructions (subfields).
-- Note also that some of the opcodes are shared.
-------------------------------------------------------------------------------
constant add_opc      : std_logic_vector(5 downto 0) := "000001";
constant addi_opc     : std_logic_vector(5 downto 0) := "101101";
constant addiu_opc    : std_logic_vector(5 downto 0) := "101000";
constant addu_opc     : std_logic_vector(5 downto 0) := "000000";
constant and_opc      : std_logic_vector(5 downto 0) := "000010";
constant andi_opc     : std_logic_vector(5 downto 0) := "101001";
constant bc_opc       : std_logic_vector(5 downto 0) := "100000";
constant begt_opc     : std_logic_vector(5 downto 0) := "100001";
constant belt_opc     : std_logic_vector(5 downto 0) := "100010";
constant beq_opc      : std_logic_vector(5 downto 0) := "100011";
constant bgt_opc      : std_logic_vector(5 downto 0) := "100100";
constant blt_opc      : std_logic_vector(5 downto 0) := "100101";
constant bne_opc      : std_logic_vector(5 downto 0) := "100110";
constant bnc_opc      : std_logic_vector(5 downto 0) := "100111";
constant chrs_opc     : std_logic_vector(5 downto 0) := "110011";
constant cmp_opc      : std_logic_vector(5 downto 0) := "011001";
constant cmpi_opc     : std_logic_vector(5 downto 0) := "110111";
constant conb_opc     : std_logic_vector(5 downto 0) := "000011";
constant conh_opc     : std_logic_vector(5 downto 0) := "000100";
constant cop_opc      : std_logic_vector(5 downto 0) := "111100";
constant di_opc       : std_logic_vector(5 downto 0) := "010101";
constant ei_opc       : std_logic_vector(5 downto 0) := "010110";
constant exb_opc      : std_logic_vector(5 downto 0) := "110000";
constant exbf_opc     : std_logic_vector(5 downto 0) := "011010";
constant exbfi_opc    : std_logic_vector(5 downto 0) := "111101";
constant exh_opc      : std_logic_vector(5 downto 0) := "110001";
constant jal_opc      : std_logic_vector(5 downto 0) := "111001";
constant jalr_opc     : std_logic_vector(5 downto 0) := "110101";
constant jmp_opc      : std_logic_vector(5 downto 0) := "111000";
constant jmpr_opc     : std_logic_vector(5 downto 0) := "011011";
constant ld_opc       : std_logic_vector(5 downto 0) := "110010";
constant lli_opc      : std_logic_vector(5 downto 0) := "111110";
constant lui_opc      : std_logic_vector(5 downto 0) := "111111";
constant mov_opc      : std_logic_vector(5 downto 0) := "010011";
constant movfc_opc    : std_logic_vector(5 downto 0) := "101100";
constant movtc_opc    : std_logic_vector(5 downto 0) := "110110";
constant mulhi_opc    : std_logic_vector(5 downto 0) := "011101";
constant muli_opc     : std_logic_vector(5 downto 0) := "101110";
constant muls_opc     : std_logic_vector(5 downto 0) := "000101";
constant muls_16_opc  : std_logic_vector(5 downto 0) := "001000";
constant mulu_opc     : std_logic_vector(5 downto 0) := "000110";
constant mulu_16_opc  : std_logic_vector(5 downto 0) := "001001";
constant mulus_opc    : std_logic_vector(5 downto 0) := "000111";
constant mulus_16_opc : std_logic_vector(5 downto 0) := "001010";
constant nop_opc      : std_logic_vector(5 downto 0) := "111010";
constant not_opc      : std_logic_vector(5 downto 0) := "010100";
constant or_opc       : std_logic_vector(5 downto 0) := "001011";
constant ori_opc      : std_logic_vector(5 downto 0) := "101010";
constant rcon_opc     : std_logic_vector(5 downto 0) := "011110";
constant reti_opc     : std_logic_vector(5 downto 0) := "010111";
constant retu_opc     : std_logic_vector(5 downto 0) := "011111";
constant scall_opc    : std_logic_vector(5 downto 0) := "111011";
constant scon_opc     : std_logic_vector(5 downto 0) := "011100";
constant sext_opc     : std_logic_vector(5 downto 0) := "001100";
constant sexti_opc    : std_logic_vector(5 downto 0) := "101011";
constant sll_opc      : std_logic_vector(5 downto 0) := "001101";
constant slli_opc     : std_logic_vector(5 downto 0) := "001101";
constant sra_opc      : std_logic_vector(5 downto 0) := "001110";
constant srai_opc     : std_logic_vector(5 downto 0) := "001110";
constant srl_opc      : std_logic_vector(5 downto 0) := "001111";
constant srli_opc     : std_logic_vector(5 downto 0) := "001111";
constant st_opc       : std_logic_vector(5 downto 0) := "110100";
constant sub_opc      : std_logic_vector(5 downto 0) := "010000";
constant subu_opc     : std_logic_vector(5 downto 0) := "010001";
constant swm_opc      : std_logic_vector(5 downto 0) := "101111";
constant trap_opc     : std_logic_vector(5 downto 0) := "011000";
constant xor_opc      : std_logic_vector(5 downto 0) := "010010";


-- Integer versions
constant add_opc_i      : integer := CONV_INTEGER(add_opc);
constant addi_opc_i     : integer := CONV_INTEGER(addi_opc);
constant addiu_opc_i    : integer := CONV_INTEGER(addiu_opc);
constant addu_opc_i     : integer := CONV_INTEGER(addu_opc);
constant and_opc_i      : integer := CONV_INTEGER(and_opc);
constant andi_opc_i     : integer := CONV_INTEGER(andi_opc);
constant bc_opc_i       : integer := CONV_INTEGER(bc_opc);
constant begt_opc_i     : integer := CONV_INTEGER(begt_opc);
constant belt_opc_i     : integer := CONV_INTEGER(belt_opc);
constant beq_opc_i      : integer := CONV_INTEGER(beq_opc);
constant bgt_opc_i      : integer := CONV_INTEGER(bgt_opc);
constant blt_opc_i      : integer := CONV_INTEGER(blt_opc);
constant bne_opc_i      : integer := CONV_INTEGER(bne_opc);
constant bnc_opc_i       : integer := CONV_INTEGER(bnc_opc);
constant chrs_opc_i     : integer := CONV_INTEGER(chrs_opc);
constant cmp_opc_i      : integer := CONV_INTEGER(cmp_opc);
constant cmpi_opc_i     : integer := CONV_INTEGER(cmpi_opc);
constant conb_opc_i     : integer := CONV_INTEGER(conb_opc);
constant conh_opc_i     : integer := CONV_INTEGER(conh_opc);
constant cop_opc_i      : integer := CONV_INTEGER(cop_opc);
constant di_opc_i       : integer := CONV_INTEGER(di_opc);
constant ei_opc_i       : integer := CONV_INTEGER(ei_opc);
constant exb_opc_i      : integer := CONV_INTEGER(exb_opc);
constant exbf_opc_i     : integer := CONV_INTEGER(exbf_opc);
constant exbfi_opc_i    : integer := CONV_INTEGER(exbfi_opc);
constant exh_opc_i      : integer := CONV_INTEGER(exh_opc);
constant jal_opc_i      : integer := CONV_INTEGER(jal_opc);
constant jalr_opc_i     : integer := CONV_INTEGER(jalr_opc);
constant jmp_opc_i      : integer := CONV_INTEGER(jmp_opc);
constant jmpr_opc_i     : integer := CONV_INTEGER(jmpr_opc);
constant ld_opc_i       : integer := CONV_INTEGER(ld_opc);
constant lli_opc_i      : integer := CONV_INTEGER(lli_opc);
constant lui_opc_i      : integer := CONV_INTEGER(lui_opc);
constant mov_opc_i      : integer := CONV_INTEGER(mov_opc);
constant movfc_opc_i   : integer := CONV_INTEGER(movfc_opc);
constant movtc_opc_i   : integer := CONV_INTEGER(movtc_opc);
constant mulhi_opc_i    : integer := CONV_INTEGER(mulhi_opc);
constant muli_opc_i     : integer := CONV_INTEGER(muli_opc);
constant muls_opc_i     : integer := CONV_INTEGER(muls_opc);
constant muls_16_opc_i  : integer := CONV_INTEGER(muls_16_opc);
constant mulu_opc_i     : integer := CONV_INTEGER(mulu_opc);
constant mulu_16_opc_i  : integer := CONV_INTEGER(mulu_16_opc);
constant mulus_opc_i    : integer := CONV_INTEGER(mulus_opc);
constant mulus_16_opc_i : integer := CONV_INTEGER(mulus_16_opc);
constant nop_opc_i      : integer := CONV_INTEGER(nop_opc);
constant not_opc_i      : integer := CONV_INTEGER(not_opc);
constant or_opc_i       : integer := CONV_INTEGER(or_opc);
constant ori_opc_i      : integer := CONV_INTEGER(ori_opc);
constant rcon_opc_i     : integer := CONV_INTEGER(rcon_opc);
constant reti_opc_i     : integer := CONV_INTEGER(reti_opc);
constant retu_opc_i     : integer := CONV_INTEGER(retu_opc);
constant scall_opc_i    : integer := CONV_INTEGER(scall_opc);
constant scon_opc_i     : integer := CONV_INTEGER(scon_opc);
constant sext_opc_i     : integer := CONV_INTEGER(sext_opc);
constant sexti_opc_i    : integer := CONV_INTEGER(sexti_opc);
constant sll_opc_i      : integer := CONV_INTEGER(sll_opc);
constant slli_opc_i     : integer := CONV_INTEGER(slli_opc);
constant sra_opc_i      : integer := CONV_INTEGER(sra_opc);
constant srai_opc_i     : integer := CONV_INTEGER(srai_opc);
constant srl_opc_i      : integer := CONV_INTEGER(srl_opc);
constant srli_opc_i     : integer := CONV_INTEGER(srli_opc);
constant st_opc_i       : integer := CONV_INTEGER(st_opc);
constant sub_opc_i      : integer := CONV_INTEGER(sub_opc);
constant subu_opc_i     : integer := CONV_INTEGER(subu_opc);
constant swm_opc_i      : integer := CONV_INTEGER(swm_opc);
constant trap_opc_i     : integer := CONV_INTEGER(trap_opc);
constant xor_opc_i      : integer := CONV_INTEGER(xor_opc);

-------------------------------------------------
-- Condition codes
-------------------------------------------------
constant cc_c   : std_logic_vector(2 downto 0) := "000";
constant cc_eq  : std_logic_vector(2 downto 0) := "011";
constant cc_gt  : std_logic_vector(2 downto 0) := "100";
constant cc_lt  : std_logic_vector(2 downto 0) := "101";
constant cc_ne  : std_logic_vector(2 downto 0) := "110";
constant cc_elt : std_logic_vector(2 downto 0) := "010";
constant cc_egt : std_logic_vector(2 downto 0) := "001";
constant cc_nc  : std_logic_vector(2 downto 0) := "111";

constant cc_c_i   : integer := 0;
constant cc_eq_i  : integer := 3;
constant cc_gt_i  : integer := 4;
constant cc_lt_i  : integer := 5;
constant cc_ne_i  : integer := 6;
constant cc_elt_i : integer := 2;
constant cc_egt_i : integer := 1;
constant cc_nc_i  : integer := 7;

-------------------------------------------------
-- Exception codes
-------------------------------------------------
constant ec_inst_addr_viol    : std_logic_vector(7 downto 0) := "00000000";
constant ec_unknown_opcode    : std_logic_vector(7 downto 0) := "00000001";
constant ec_illegal_instr     : std_logic_vector(7 downto 0) := "00000010";
constant ec_miss_aligned_jmp  : std_logic_vector(7 downto 0) := "00000011";
constant ec_jmp_addr_overflw  : std_logic_vector(7 downto 0) := "00000100";
constant ec_iaddr_miss_alignd : std_logic_vector(7 downto 0) := "00000101";
constant ec_arith_overflow    : std_logic_vector(7 downto 0) := "00000110";
constant ec_data_addr_viol    : std_logic_vector(7 downto 0) := "00000111";
constant ec_data_addr_overflw : std_logic_vector(7 downto 0) := "00001000";
constant ec_illegal_jmp       : std_logic_vector(7 downto 0) := "00001001";
constant ec_trace             : std_logic_vector(7 downto 0) := "00001010"; -- not implemented


-----------------------------------------
-- some constants
-----------------------------------------
constant EXCEPTION_PSR   : std_logic_vector(7 downto 0) := "00001110";
constant SYSTEM_PSR      : std_logic_vector(7 downto 0) := "00001110";
constant PSR_INDX        : std_logic_vector(5 downto 0) := "111101";
constant SPSR_INDX       : std_logic_vector(5 downto 0) := "111110";
-- Thanks s_y_n_o_p_s_y_s for all the headaches
constant nop_pattern_c   : std_logic_vector(31 downto 0)  := nop_opc & "0000000000" & nop_opc & "0000000000";


end core_constants_pkg;


