------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:12 01/03/06
-- File : core_rf.vhd
-- Design : core_rf
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY core_rf IS
   PORT( 
      clk         : IN     std_logic;
      rst_x       : IN     std_logic;
      rs_to_read  : IN     std_logic;                       -- -- Which register set to read from
      rs_to_write : IN     std_logic;                       -- -- Which register set to write to
      wr_en_spsr  : IN     std_logic;
      wr_en_data  : IN     std_logic;
      reg_indx1   : IN     std_logic_vector (4 DOWNTO 0);   -- -- index to register operand1
      reg_indx2   : IN     std_logic_vector (4 DOWNTO 0);   -- -- index to register operand2
      reg_indx3   : IN     std_logic_vector (4 DOWNTO 0);   -- -- index to result register
      psr_data_in : IN     std_logic_vector (7 DOWNTO 0);
      data_in     : IN     std_logic_vector (31 DOWNTO 0);  -- -- Data to be written to result register if enabled
      psr_o_q     : OUT    std_logic_vector  (7 DOWNTO 0);  -- -- Processor status flag output
      spsr_o_q    : OUT    std_logic_vector  (7 DOWNTO 0);  -- -- Output of saved status flags
      data_out1   : OUT    std_logic_vector (31 DOWNTO 0);
      data_out2   : OUT    std_logic_vector (31 DOWNTO 0);
      wr_en_psr   : IN     std_logic
   );

-- Declarations

END core_rf ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 19:15:22 06/10/05
-- File : core_rf.vhd
-- Design : core_rf
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_UNSIGNED.CONV_INTEGER;

architecture core_rf_opt of core_rf is
    type reg_bank is array (0 to 31) of std_logic_vector(31 downto 0);

    -- set one, the user set reserves registers 0 to 31
    -- set two, the priviledged user set reserves registers 32 to 63
	signal set1_regs_out : reg_bank := (others => (others => '0'));
	signal set2_regs_out : reg_bank := (others => (others => '0'));
	signal set1_regs_in  : reg_bank;
	signal set2_regs_in  : reg_bank;

	signal w           : std_logic_vector(4 downto 0);
	signal wri_decoded : std_logic_vector(31 downto 0);
	signal user_write  : std_logic_vector(31 downto 0);
	signal wren        : std_logic_vector(31 downto 0);
	
begin
	w          <= reg_indx3;
	-- Decoding write index
    wri_decoded(0)  <= not w(4) and not w(3) and not w(2) and not w(1) and not w(0);  --00000
    wri_decoded(1)  <= not w(4) and not w(3) and not w(2) and not w(1) and     w(0);  --00001
    wri_decoded(2)  <= not w(4) and not w(3) and not w(2) and     w(1) and not w(0);  --00010
    wri_decoded(3)  <= not w(4) and not w(3) and not w(2) and     w(1) and     w(0);  --00011
    wri_decoded(4)  <= not w(4) and not w(3) and     w(2) and not w(1) and not w(0);  --00100
    wri_decoded(5)  <= not w(4) and not w(3) and     w(2) and not w(1) and     w(0);  --00101
    wri_decoded(6)  <= not w(4) and not w(3) and     w(2) and     w(1) and not w(0);  --00110
    wri_decoded(7)  <= not w(4) and not w(3) and     w(2) and     w(1) and     w(0);  --00111
    wri_decoded(8)  <= not w(4) and     w(3) and not w(2) and not w(1) and not w(0);  --01000
    wri_decoded(9)  <= not w(4) and     w(3) and not w(2) and not w(1) and     w(0);  --01001
    wri_decoded(10) <= not w(4) and     w(3) and not w(2) and     w(1) and not w(0);  --01010
    wri_decoded(11) <= not w(4) and     w(3) and not w(2) and     w(1) and     w(0);  --01011
    wri_decoded(12) <= not w(4) and     w(3) and     w(2) and not w(1) and not w(0);  --01100
    wri_decoded(13) <= not w(4) and     w(3) and     w(2) and not w(1) and     w(0);  --01101
    wri_decoded(14) <= not w(4) and     w(3) and     w(2) and     w(1) and not w(0);  --01110
    wri_decoded(15) <= not w(4) and     w(3) and     w(2) and     w(1) and     w(0);  --01111
    wri_decoded(16) <=     w(4) and not w(3) and not w(2) and not w(1) and not w(0);  --10000
    wri_decoded(17) <=     w(4) and not w(3) and not w(2) and not w(1) and     w(0);  --10001
    wri_decoded(18) <=     w(4) and not w(3) and not w(2) and     w(1) and not w(0);  --10010
    wri_decoded(19) <=     w(4) and not w(3) and not w(2) and     w(1) and     w(0);  --10011
    wri_decoded(20) <=     w(4) and not w(3) and     w(2) and not w(1) and not w(0);  --10100
    wri_decoded(21) <=     w(4) and not w(3) and     w(2) and not w(1) and     w(0);  --10101
    wri_decoded(22) <=     w(4) and not w(3) and     w(2) and     w(1) and not w(0);  --10110
    wri_decoded(23) <=     w(4) and not w(3) and     w(2) and     w(1) and     w(0);  --10111
    wri_decoded(24) <=     w(4) and     w(3) and not w(2) and not w(1) and not w(0);  --11000
    wri_decoded(25) <=     w(4) and     w(3) and not w(2) and not w(1) and     w(0);  --11001
    wri_decoded(26) <=     w(4) and     w(3) and not w(2) and     w(1) and not w(0);  --11010
    wri_decoded(27) <=     w(4) and     w(3) and not w(2) and     w(1) and     w(0);  --11011
    wri_decoded(28) <=     w(4) and     w(3) and     w(2) and not w(1) and not w(0);  --11100
    wri_decoded(29) <=     w(4) and     w(3) and     w(2) and not w(1) and     w(0);  --11101
    wri_decoded(30) <=     w(4) and     w(3) and     w(2) and     w(1) and not w(0);  --11110
    wri_decoded(31) <=     w(4) and     w(3) and     w(2) and     w(1) and     w(0);  --11111

	user_write <= (others => wr_en_data);
	wren       <= user_write and wri_decoded;

----------------------------------------------------
-- for debug only
----------------------------------------------------
--	process(reg_out)
--	begin
--		for i in reg_out'range loop
--			reg_bank_out(i) <= reg_out(i);
--		end loop;
--	end process;

----------------------------------------------------
-- connections
----------------------------------------------------
    
    -- Direct outputs
    psr_o_q   <= set2_regs_out(29)(7 downto 0);
    spsr_o_q  <= set2_regs_out(30)(7 downto 0);

--	bank <= reg_out; -- for debug only!

----------------------------------------------------
-- Routing input data to register inputs
----------------------------------------------------    
    process(wr_en_spsr, psr_data_in, data_in, set2_regs_out)
    begin
        -- registers connected to general data input
		set1_regs_in(0 to 31) <= (others => data_in);
		set2_regs_in(0 to 28) <= (others => data_in);
		set2_regs_in(31)      <= data_in;

		-- special registers. 
        -- Updating SPSR internally from PSR if enabled.
		-- Overrides updating through write port.
		if wr_en_spsr = '1' then
        	set2_regs_in(30) <= set2_regs_out(29);
		else
			set2_regs_in(30) <= data_in;
		end if;

		-- special input for PSR (cannot be written by programmer)
		set2_regs_in(29)(31 downto 8) <= (others => '0');
		set2_regs_in(29)(7 downto 0)  <= psr_data_in;

    end process;

-------------------------------------------------------
    -- Registers
-------------------------------------------------------

	process(clk, rst_x)
		variable write_spsr : std_logic;
	begin
		if rst_x = '0' then
			set2_regs_out(29)(31 downto 8) <=(others => '0'); -- PSR unused
			set2_regs_out(29)(7 downto 0)  <= PSR_R; -- PSR
			set2_regs_out(30)              <= SPSR_R; -- SPSR
		elsif clk'event and clk = '1' then
			if rs_to_write = '0' then
				for i in 0 to 31 loop
					if wren(i) = '1' then
						set1_regs_out(i) <= set1_regs_in(i);
					else
						set1_regs_out(i) <= set1_regs_out(i);
					end if;
				end loop;
			else
				for i in 0 to 28 loop
					if wren(i) = '1' then
						set2_regs_out(i) <= set2_regs_in(i);
					else
						set2_regs_out(i) <= set2_regs_out(i);
					end if;
				end loop;
				if wren(31) = '1' then
					set2_regs_out(31) <= set2_regs_in(31);
				else
					set2_regs_out(31) <= set2_regs_out(31);
				end if;
			end if;
			-- processor status register
			if wr_en_psr = '1' then
				set2_regs_out(29) <= set2_regs_in(29);
			else
				set2_regs_out(29) <= set2_regs_out(29);
			end if;
			-- saved processor status register
			write_spsr := wr_en_spsr or (wren(30) and rs_to_write);
			if write_spsr = '1' then
				set2_regs_out(30) <= set2_regs_in(30);
			else
				set2_regs_out(30) <= set2_regs_out(30);
			end if;
		end if;
	end process;

------------------------------------------------------
-- Output select logic with forward control
-------------------------------------------------------

    
    -- outputting data to source port data_out1
	process(wr_en_data, reg_indx3, reg_indx1, rs_to_write, rs_to_read, 
	        set1_regs_in, set1_regs_out, set2_regs_in, set2_regs_out)
		variable forward : boolean;
		variable indx : integer range 0 to 31;
	begin
		indx := CONV_INTEGER(reg_indx1);
		forward := rs_to_read = rs_to_write and reg_indx3 = reg_indx1 and wr_en_data = '1';
		if rs_to_read = '0' then
			if forward then
				data_out1 <= set1_regs_in(indx);
			else
				data_out1 <= set1_regs_out(indx);
			end if;
		else
			if forward then
				data_out1 <= set2_regs_in(indx);
			else
				data_out1 <= set2_regs_out(indx);
			end if;
		end if;
	end process;

    -- outputting data to source port data_out2
	process(wr_en_data, reg_indx3, reg_indx2, rs_to_write, rs_to_read, 
	        set1_regs_in, set1_regs_out, set2_regs_in, set2_regs_out)
		variable forward : boolean;
		variable indx : integer range 0 to 31;
	begin
		indx := CONV_INTEGER(reg_indx2);
		forward := rs_to_read = rs_to_write and reg_indx3 = reg_indx2 and wr_en_data = '1';
		if rs_to_read = '0' then
			if forward then
				data_out2 <= set1_regs_in(indx);
			else
				data_out2 <= set1_regs_out(indx);
			end if;
		else
			if forward then
				data_out2 <= set2_regs_in(indx);
			else
				data_out2 <= set2_regs_out(indx);
			end if;
		end if;
	end process;

end core_rf_opt;

