------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:19 01/03/06
-- File : dbif_control.vhd
-- Design : dbif_control
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY dbif_control IS
   PORT( 
      access_complete         : IN     std_logic;
      addr                    : IN     std_logic_vector (31 DOWNTO 0);
      clk                     : IN     std_logic;
      float_bus               : IN     std_logic;
      mask                    : IN     std_logic_vector (31 DOWNTO 0);
      rd_en_dmem              : IN     std_logic;
      rd_en_pcb               : IN     std_logic;
      rst_n                   : IN     std_logic;
      start_access            : IN     std_logic;
      use_mask                : IN     std_logic;
      use_prev_data           : IN     std_logic;
      wr_en_dmem              : IN     std_logic;
      wr_en_pcb               : IN     std_logic;
      disable_sampling_n      : OUT    std_logic;
      keep_old_addr           : OUT    std_logic;
      keep_old_data           : OUT    std_logic;
      latch_data_from_bus     : OUT    std_logic;
      latch_data_from_core    : OUT    std_logic;
      masked_addr             : OUT    std_logic_vector (31 DOWNTO 0);
      not_keep_old_addr       : OUT    std_logic;
      not_keep_old_data       : OUT    std_logic;
      not_latch_data_from_bus : OUT    std_logic;
      read_mem_q              : OUT    std_logic;
      read_pcb_q              : OUT    std_logic;
      write_mem_q             : OUT    std_logic;
      write_pcb_q             : OUT    std_logic
   );

-- Declarations

END dbif_control ;
architecture dbif_control_arch of dbif_control is

	signal end_read_access  : std_logic;
	signal read_mem_s       : std_logic;
	signal read_pcb_s       : std_logic;
	signal read_access      : std_logic;
	signal get_boot_address : std_logic;
	signal latch_data_from_bus_i : std_logic;
	
begin
	read_access <= rd_en_dmem or rd_en_pcb;
	--------------------------------------------
	-- Controlling state according to bus status
	--------------------------------------------
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			read_mem_s         <= '0';
			read_pcb_s         <= '0';
			write_mem_q        <= '0';
			write_pcb_q        <= '0';
			-- data bus floats
			keep_old_data      <= '0';
			not_keep_old_data  <= '0';
			keep_old_addr      <= '0';
			not_keep_old_addr  <= '0';
		elsif clk'event and clk = '1' then
			if float_bus = '1' then
				read_mem_s         <= '0';
				read_pcb_s         <= '0';
				write_mem_q        <= '0';
				write_pcb_q        <= '0';
				keep_old_data      <= '0';
				not_keep_old_data  <= '0';
				keep_old_addr      <= '0';
				not_keep_old_addr  <= '0';
			elsif start_access = '1' then
				read_mem_s        <= rd_en_dmem;
				read_pcb_s        <= rd_en_pcb;
				write_mem_q       <= wr_en_dmem;
				write_pcb_q       <= wr_en_pcb;
				keep_old_data     <= use_prev_data and not read_access;
				not_keep_old_data <= not(use_prev_data) and not read_access;
				keep_old_addr     <= '0';
				not_keep_old_addr <= '1';
			elsif access_complete = '1' then
				read_mem_s         <= '0';
				read_pcb_s         <= '0';
				write_mem_q        <= '0';
				write_pcb_q        <= '0';
				keep_old_data      <= '1';
				not_keep_old_data  <= '0';
				keep_old_addr      <= '1';
				not_keep_old_addr  <= '0';
			end if;
		end if;
	end process;
	read_mem_q  <= read_mem_s;
	read_pcb_q  <= read_pcb_s;

	---------------------------------------------------------
	-- Controlling the moment when data should be clocked in
	---------------------------------------------------------
		
	-- end_read_access is high during the last cycle of the read access.
	end_read_access <= (read_mem_s or read_pcb_s) and access_complete;
	-- reset is expected to be synchronized
	get_boot_address        <= not rst_n;
	latch_data_from_bus_i   <=     end_read_access or get_boot_address;
	latch_data_from_bus     <= latch_data_from_bus_i;
	not_latch_data_from_bus <= not(end_read_access or get_boot_address);

	-- Sampling registers, which are used to save power by means of driving
	-- last values on bus when idling, must be disabled when they are
	-- used to forward data between consecutive ld and st instructions
	-- having a data dependency. Note active low signal...
	disable_sampling_n <= not(use_prev_data and not latch_data_from_bus_i);

	---------------------------------------------------------
	-- Controlling the moment when data should latched
	---------------------------------------------------------
	-- the latched value is not driven to bus until new access commences.
	latch_data_from_core <= start_access;

	---------------------------------------------------------
	-- Applying address mask if needed
	---------------------------------------------------------
	masked_addr <= addr and mask when use_mask = '1' else addr;

end dbif_control_arch;
