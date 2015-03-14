-- Copyright (C) 1991-2012 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 12.1 Build 177 11/07/2012 SJ Full Version"
-- CREATED		"Mon Jun 03 17:03:44 2013"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

LIBRARY coffee;

ENTITY Single_Core_Stratix5 IS 
	
	PORT
	(
		CPU_RESETn :  IN  STD_LOGIC;
		CLKIN_50 :  IN  STD_LOGIC;
		bus_req :  IN  STD_LOGIC;
		d_cache_miss :  IN  STD_LOGIC;
		ext_handler :  IN  STD_LOGIC;
		i_cache_miss :  IN  STD_LOGIC;
		stall :  IN  STD_LOGIC;
		boot_sel :  IN  STD_LOGIC;
		cop_bus_z :  INOUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		cop_exc :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		ext_interrupt :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		imem_data :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		offset :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		bus_ack :  OUT  STD_LOGIC;
		cop_rd :  OUT  STD_LOGIC;
		cop_wr :  OUT  STD_LOGIC;
		int_ack :  OUT  STD_LOGIC;
		int_done :  OUT  STD_LOGIC;
		pcb_rd :  OUT  STD_LOGIC;
		pcb_wr :  OUT  STD_LOGIC;
		reset_n_out :  OUT  STD_LOGIC;
		wr :  OUT  STD_LOGIC;
		cop_id :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		cop_rgi :  OUT  STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END Single_Core_Stratix5;

ARCHITECTURE bdf_type OF Single_Core_Stratix5 IS 
  
COMPONENT core
	PORT(boot_sel : IN STD_LOGIC;
		 bus_req : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 d_cache_miss : IN STD_LOGIC;
		 ext_handler : IN STD_LOGIC;
		 i_cache_miss : IN STD_LOGIC;
		 rst_n : IN STD_LOGIC;
		 stall : IN STD_LOGIC;
		 cop_bus_z : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 cop_exc : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 d_addr : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 data : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ext_interrupt : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 i_word : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 offset : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    bus_ack : OUT STD_LOGIC;
		 cop_rd : OUT STD_LOGIC;
		 cop_wr : OUT STD_LOGIC;
		 int_ack : OUT STD_LOGIC;
		 int_done : OUT STD_LOGIC;
		 pcb_rd : OUT STD_LOGIC;
		 pcb_wr : OUT STD_LOGIC;
		 rd : OUT STD_LOGIC;
		 reset_n_out : OUT STD_LOGIC;
		 wr : OUT STD_LOGIC;
		 cop_id : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 cop_rgi : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_addr : OUT STD_LOGIC_VECTOR(16 DOWNTO 0)
	);
END COMPONENT;

COMPONENT i_mem
	PORT(wren : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT d_mem
	PORT(wren : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pll
	PORT(refclk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 outclk_0 : OUT STD_LOGIC;
		 outclk_1 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT tristdrv
	PORT(tristate_bus_read : IN STD_LOGIC;
		 non_tristate_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 tristate_bus_data_z : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 non_tristate_in : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	clk :  STD_LOGIC;
SIGNAL	clk_inv :  STD_LOGIC;
SIGNAL	d_addr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	data_a :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	i_addr :  STD_LOGIC_VECTOR(16 DOWNTO 0);
SIGNAL	i_word :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	locked :  STD_LOGIC;
SIGNAL	rd :  STD_LOGIC;
SIGNAL	wr_ALTERA_SYNTHESIZED :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;

-- added by guoqing:
signal base_clk : std_logic := '0';
signal reset_n : std_logic := '0';
signal reset : std_logic := '1';
signal i_cache_miss_s : std_logic := '0'; -- because we have no cache in the system
signal d_cahce_miss_s : std_logic := '0';
signal stall_s : std_logic := '0';  -- don't freeze the whole core
signal bus_req_s : std_logic := '0'; -- disable the bus request
 BEGIN 
SYNTHESIZED_WIRE_0 <= '0';

process
  begin
    -- if (rising_edge(base_clk) or falling_edge(base_clk)) then 
      wait for 10 ns;
      base_clk <= not base_clk ;
    -- end if;
end process;

-- base_clk <= not base_clk after cycle/2;
process 
  begin
wait for 200 ns;
reset_n <= '1';
end process;

process 
  begin
wait for 100 ns;
reset <= '0';
end process;

b2v_inst : core
-- changed by guoqing, it was boot_sel    
PORT MAP(boot_sel => '0',
		 bus_req => bus_req_s, --bus_req,
		 clk => clk,
		 d_cache_miss => d_cahce_miss_s, --d_cache_miss,
		 ext_handler => ext_handler,
		 i_cache_miss => i_cache_miss_s,
		 rst_n => reset_n, -- CPU_RESETn,
		 stall => stall_s, --stall,
		 cop_bus_z => cop_bus_z,
		 cop_exc => cop_exc,
		 d_addr => d_addr,
		 data => data,
		 ext_interrupt => ext_interrupt,
		 i_word => i_word,
		 offset => offset,
		 bus_ack => bus_ack,
		 cop_rd => cop_rd,
		 cop_wr => cop_wr,
		 int_ack => int_ack,
		 int_done => int_done,
		 pcb_rd => pcb_rd,
		 pcb_wr => pcb_wr,
		 rd => rd,
		 reset_n_out => reset_n_out,
		 wr => wr_ALTERA_SYNTHESIZED,
		 cop_id => cop_id,
		 cop_rgi => cop_rgi,
		 i_addr => i_addr);


b2v_inst1 : i_mem
-- changed by guoqing
PORT MAP(wren => '0', --SYNTHESIZED_WIRE_0,
		 clock => clk_inv,
		 address(14 DOWNTO 0) => i_addr(16 DOWNTO 2),
		 address (15) => '0',
		 data => imem_data,
		 q => i_word);


clk_inv <= SYNTHESIZED_WIRE_1 AND locked;


b2v_inst16 : d_mem
PORT MAP(wren => wr_ALTERA_SYNTHESIZED,
		 clock => clk_inv,
		 address => d_addr(17 DOWNTO 2),
		 data => data_a,
		 q => SYNTHESIZED_WIRE_2);


b2v_inst19 : pll
-- changed by guoqing: it was CLKIN_50
PORT MAP(refclk => base_clk,
		 rst => reset, -- CPU_RESETn,
		 outclk_0 => SYNTHESIZED_WIRE_3,
		 outclk_1 => SYNTHESIZED_WIRE_1,
		 locked => locked);


b2v_inst2 : tristdrv
PORT MAP(tristate_bus_read => rd,
		 non_tristate_out => SYNTHESIZED_WIRE_2,
		 tristate_bus_data_z => data,
		 non_tristate_in => data_a);


clk <= SYNTHESIZED_WIRE_3 AND locked;


wr <= wr_ALTERA_SYNTHESIZED;

END bdf_type;