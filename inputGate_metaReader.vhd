---------------------------------------------------------------------------------------------------------------
-- Description: 
-- STEP 1: INST_META_READER
-- Interprets GMII input and outputs meta values (like end and start flag also MACDST) timed together with the data.
-- The metaReader.vhd file is difficult to read because it uses a buffer to correct the end flag timing. 
--
-- Related files / Dependencies:
--
-- Revision 0.01 - File Created
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.switch_pkg.all;

entity inputGate_metaReader is
	port( 
		clk 	      	: in std_logic;
		reset 	      	: in std_logic;
		
		--GMII interface in
		rx_data_i		: in std_logic_vector(7 downto 0);
		rx_ctrl_i		: in std_logic;
		
		--Meta Interface out
		meta_o 			: out inputGate_metaIO
	);
end entity;

architecture RTL of inputGate_metaReader is

signal delay_data : std_logic_vector(7 downto 0) := x"00";
signal bytecnt : std_logic_vector(11 downto 0) := x"000";
signal delay_ctrl, delay_start, toggle_start, toggle_end : std_logic := '0';

signal MAC_DST_ADR, MAC_SRC_ADR: std_logic_vector(47 downto 0) := x"000000000000";

signal complementToggle : std_logic := '0';
signal complementToggleCnt : integer range 0 to 3;

signal meta, meta_delay1, meta_delay2, meta_delay3, meta_delay4 : inputGate_metaIO;

signal dont_end_high_on_first_clock : std_logic := '0';

begin

meta_o		<= meta ;

READ_PS : process(clk)
begin
	if (reset = '1') then
	
		delay_data <= x"00";
		bytecnt <= x"000";
		delay_ctrl <= '0';

	elsif (clk'event and clk = '1') then
	
		--delay logic
		delay_data <= rx_data_i;
		delay_ctrl <= rx_ctrl_i;
		
		--length
		if(rx_ctrl_i = '1') then
			bytecnt <= bytecnt + 1;
		end if;
		
		--start flag
		if (rx_ctrl_i = '1' and toggle_start = '0') then
			toggle_start <= '1';
			delay_start <= '1';
		elsif (rx_ctrl_i = '1' and toggle_start = '1') then
			delay_start <= '0';
		elsif (rx_ctrl_i = '0' and toggle_start = '1') then
			toggle_start <= '0';
		end if;
		
		--output logic
		meta.data 			<= delay_data;
		meta.data_valid 	<= delay_ctrl;
		meta.data_start 	<= delay_start;
		meta.lenght 		<= bytecnt;
		
		--Complement (used for fcs)
		if (complementToggle = '0' and (toggle_start = '0' and rx_ctrl_i = '1')) then
			complementToggle <= '1';
			complementToggleCnt <= 0;
		elsif(complementToggle = '1') then
			meta.complement	 <= '1';
			if(complementToggleCnt < 3) then
				complementToggleCnt <= complementToggleCnt + 1;
			elsif(complementToggleCnt = 3) then
				complementToggleCnt <= 0;
				complementToggle <= '0';
			end if;
		elsif(complementToggle = '0') then
			meta.complement	 <= '0';
		end if;
		
		
		--MATCH END SIGNAL
		if(rx_ctrl_i = '0' and toggle_end = '0' and dont_end_high_on_first_clock = '1') then
			meta.data_end <= '1';
			meta.lenght_valid <= '1';
			toggle_end <= '1';
		elsif(rx_ctrl_i = '0' and toggle_end = '1') then
			meta.data_end <= '0';
			meta.lenght_valid <= '0';
		elsif(rx_ctrl_i = '1' and toggle_end = '1') then
			toggle_end <= '0';
			meta.data_end <= '0';
			meta.lenght_valid <= '0';
		end if;
		dont_end_high_on_first_clock <= '1';
		
		
		--READ MAC SOURCE AND DESTINATION
		if(rx_ctrl_i = '1') then
			case to_integer(unsigned(bytecnt)) is
				when 0 => 
					MAC_DST_ADR(47 downto 40) <= rx_data_i;
				when 1 =>
					MAC_DST_ADR(39 downto 32) <= rx_data_i;
				when 2 =>
					MAC_DST_ADR(31 downto 24) <= rx_data_i;
				when 3 =>
					MAC_DST_ADR(23 downto 16) <= rx_data_i;
				when 4 =>
					MAC_DST_ADR(15 downto 8) <= rx_data_i;
				when 5 =>
					MAC_DST_ADR(7 downto 0) <= rx_data_i;
				when 6 =>
					MAC_SRC_ADR(47 downto 40) <= rx_data_i;
				when 7 =>
					MAC_SRC_ADR(39 downto 32) <= rx_data_i;
				when 8 =>
					MAC_SRC_ADR(31 downto 24) <= rx_data_i;
				when 9 =>
					MAC_SRC_ADR(23 downto 16) <= rx_data_i;
				when 10 =>
					MAC_SRC_ADR(15 downto 8) <= rx_data_i;
				when 11 =>
					MAC_SRC_ADR(7 downto 0) <= rx_data_i;
				when others =>
					MAC_DST_ADR <= x"000000000000";
					MAC_SRC_ADR <= x"000000000000";
			end case;
		end if;
		
		if(bytecnt = 6) then
			meta.dstadr <= MAC_DST_ADR;
		elsif(bytecnt = 12) then
			meta.srcadr <= MAC_SRC_ADR;
			meta.macadr_valid <= '1';
		else
			meta.macadr_valid <= '0';
		end if;
	
		
	end if;
end process;


end architecture;