------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:16 01/03/06
-- File : alu_shifter.vhd
-- Design : alu_shifter
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY coffee;
USE coffee.core_constants_pkg.all;

ENTITY alu_shifter IS
   PORT( 
      operation : IN     std_logic_vector (2 DOWNTO 0);
      operand   : IN     std_logic_vector (31 DOWNTO 0);
      control   : IN     std_logic_vector (10 DOWNTO 0);
      result    : OUT    std_logic_vector (31 DOWNTO 0);
      znc       : OUT    std_logic_vector (2 DOWNTO 0)
   );

-- Declarations

END alu_shifter ;
------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 20:33:04 06/09/05
-- File : alu_shifter.vhd
-- Design : alu_shifter
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_unsigned.SHL;
use ieee.std_logic_unsigned.CONV_INTEGER;

architecture alu_shifter_opt of alu_shifter is
	signal shifted_data    : std_logic_vector(31 downto 0);
	signal shifted_mask    : std_logic_vector(31 downto 0);
	signal shift_amnt_data : std_logic_vector(5 downto 0);
	signal shift_amnt_mask : std_logic_vector(5 downto 0);
	signal shift_dir_mask  : std_logic;
	signal shift_dir_data  : std_logic;
begin
    ----------------------------------------------------------
    --decoding controls for shifters
    ----------------------------------------------------------
    process(operation, control, operand)
    begin
        case operation is
            when alu_shift_sll  =>    -- logical shift left
				shift_amnt_data <= control(5 downto 0);
				shift_amnt_mask <= "000000";
				shift_dir_data  <= '0'; -- left
				shift_dir_mask  <= '0';
            when alu_shift_srl  =>    -- logical shift right
				shift_amnt_data <= control(5 downto 0);
				shift_amnt_mask <= "000000";
				shift_dir_data  <= '1'; -- right
				shift_dir_mask  <= '0';
            when alu_shift_sra  =>    -- arithmetic shift right
				shift_amnt_data <= control(5 downto 0);
				shift_amnt_mask <= control(5 downto 0);
				shift_dir_data  <= '1'; -- right
				shift_dir_mask  <= '1'; -- right
            when alu_shift_exbf  =>   -- extract bitfield
				shift_amnt_data <= '0' & control(4 downto 0);
				shift_amnt_mask <= control(10 downto 5);
				shift_dir_data  <= '1'; -- right
				shift_dir_mask  <= '0'; -- left
            when others =>            -- sign extend
				shift_amnt_data <= "000000";
				shift_amnt_mask <= '0' & control(4 downto 0);
				shift_dir_data  <= '0';
				shift_dir_mask  <= '0'; -- left
        end case;
    end process;

	--------------------------------------------------------------
	-- shifter for data
	--------------------------------------------------------------
	process(shift_dir_data, operand, shift_amnt_data)
		variable data_in  : std_logic_vector(32 downto 0);
		variable data_out : std_logic_vector(32 downto 0);
	begin
		if shift_dir_data = '1' then
			for i in 0 to 31 loop
				data_in(i) := operand(31-i);
			end loop;
		else
			data_in(31 downto 0) := operand;
		end if;

		data_in(32) := '0';
		data_out := SHL(data_in, shift_amnt_data);

		if shift_dir_data = '1' then
			for i in 0 to 31 loop
				shifted_data(i) <= data_out(31-i);
			end loop;
		else
			shifted_data <= data_out(31 downto 0);
		end if;
		-- flags (valid for shift left only)
		znc(0) <= data_out(32); -- carry
		znc(1) <= data_out(31); -- negative

		if data_out(31 downto 0) = "00000000000000000000000000000000" then
			znc(2) <= '1';
		else
			znc(2) <= '0';
		end if;

	end process;

	--------------------------------------------------------------
	-- shifter for mask
	--------------------------------------------------------------
	process(shift_dir_mask, shift_amnt_mask)
		variable mask_in  : std_logic_vector(31 downto 0);
		variable mask_out : std_logic_vector(31 downto 0);
	begin
		mask_in  := (others => '1');
		mask_out := SHL(mask_in, shift_amnt_mask);

		if shift_dir_mask = '1' then -- shift right instead of left
			for i in 0 to 31 loop
				shifted_mask(i) <= mask_out(31-i);
			end loop;
		else
			shifted_mask <= mask_out;
		end if;
	end process;


	--------------------------------------------------------------
	-- masking
	--------------------------------------------------------------
	process(shifted_data, shifted_mask, operation, operand, shift_amnt_mask)
	begin
		case operation is
		when alu_shift_sra =>
			if operand(31) = '1' then
				result <= not shifted_mask or shifted_data;
			else
				result <= shifted_data;
			end if;
		when alu_shift_exbf =>
			result <= not shifted_mask and shifted_data;
		when alu_shift_sext =>
			if operand(CONV_INTEGER(shift_amnt_mask)) = '1' then
				result <= shifted_mask or shifted_data;
			else
				result <= not shifted_mask and shifted_data;
			end if;
		when others => -- no masking
			result <= shifted_data;
		end case;
	end process;

end alu_shifter_opt;
