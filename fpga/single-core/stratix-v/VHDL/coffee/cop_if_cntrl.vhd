------------------------------------------------------------------------------
-- Project : COFFEE
-- Author : Juha Kylliainen
-- Date : 16:26:10 01/03/06
-- File : cop_if_cntrl.vhd
-- Design : cop_if_cntrl
------------------------------------------------------------------------------
-- Description :
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cop_if_cntrl IS
   PORT( 
      clk                     : IN     std_logic;
      cop_indx                : IN     std_logic_vector (1 DOWNTO 0);
      enable                  : IN     std_logic;
      flush                   : IN     std_logic;
      rd_cop                  : IN     std_logic;
      reg_indx                : IN     std_logic_vector (4 DOWNTO 0);
      rst_x                   : IN     std_logic;
      wr_cop                  : IN     std_logic;
      cop_indx_q              : OUT    std_logic_vector (1 DOWNTO 0);
      keep_old_data           : OUT    std_logic;
      latch_data_from_bus     : OUT    std_logic;
      latch_data_from_core    : OUT    std_logic;
      not_keep_old_data       : OUT    std_logic;
      not_latch_data_from_bus : OUT    std_logic;
      rd_cop_q                : OUT    std_logic;
      reg_indx_q              : OUT    std_logic_vector (4 DOWNTO 0);
      wr_cop_q                : OUT    std_logic
   );

-- Declarations

END cop_if_cntrl ;
architecture cop_if_cntrl_arch of cop_if_cntrl is

	signal active_read_access : std_logic;
	signal new_read_access    : std_logic;
	signal new_write_access   : std_logic;
	signal rd_cop_q_s         : std_logic;
	signal wr_cop_q_s         : std_logic;
	signal float              : std_logic;
	signal go_idle            : std_logic;
	signal reg_indx_s         : std_logic_vector(4 downto 0);
	signal cop_indx_s        : std_logic_vector(1 downto 0);

begin
	-- 'helper' signals
	new_read_access     <= rd_cop and not flush;
	new_write_access    <= wr_cop and not flush;
	active_read_access  <= rd_cop_q_s;

	float               <= new_read_access;
	go_idle             <= not(new_read_access or new_write_access);

	process(rst_x, clk)
	begin
		if rst_x = '0' then
			-- float the bus...
			not_keep_old_data <= '0';
			keep_old_data     <= '0';
			reg_indx_s        <= "00000";
			cop_indx_s        <= "00";
			rd_cop_q_s         <= '0';
			wr_cop_q_s         <= '0';
		elsif clk'event and clk = '1' then
			if enable = '1' then
				keep_old_data      <= go_idle and not float;
				not_keep_old_data  <= not go_idle and not float;
				rd_cop_q_s         <= new_read_access;
				wr_cop_q_s         <= new_write_access;
				-- keep old values when idling
				if go_idle = '1' then
					reg_indx_s         <= reg_indx_s;
					cop_indx_s         <= cop_indx_s;
				else
					reg_indx_s         <= reg_indx;
					cop_indx_s         <= cop_indx;
				end if;
			end if;
		end if;
	end process;

	rd_cop_q   <= rd_cop_q_s;
	wr_cop_q   <= wr_cop_q_s;
	reg_indx_q <= reg_indx_s;
	cop_indx_q <= cop_indx_s;

	-- control data flow from and to bus.
	latch_data_from_bus     <= active_read_access and enable;
	not_latch_data_from_bus <= not(active_read_access and enable);
	latch_data_from_core    <= new_write_access and enable;

end cop_if_cntrl_arch;
