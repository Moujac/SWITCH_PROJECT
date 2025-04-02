library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity switchcore_TB is
end entity;

architecture arch of switchcore_TB is

signal test_pass : std_logic_vector(511 downto 0) := x"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
signal test_fail : std_logic_vector(511 downto 0) := x"123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123E6C53DB2";

signal tx_data_hold, rx_data_serve : std_logic_vector(31 downto 0) := x"00000000";
signal tx_ctrl_hold, rx_ctrl_serve : std_logic_vector(3 downto 0) := "0000";

signal clk : std_logic;
constant clk_period: time:=10 ns;

signal pointer : integer range 0 to 64 := 64;

BEGIN

CLOCK_PROGRESS : process
	begin
		clk <='0';
		wait for clk_period/2;
		clk <='1';
		wait for clk_period/2;
end process;


SERVE_DATA : process(clk)
begin
if (clk'event and clk = '1') then

	--DECREMENT POINTER FROM 64 DOWN TO 0
	if(pointer > 0) then
		pointer <= pointer - 1;
	end if;

	if(pointer > 0) then
		rx_data_serve(31 downto 24) <= test_pass(pointer*8-1 downto pointer*8-8);
		rx_ctrl_serve <= "1000";
	else
		rx_data_serve(31 downto 24) <= x"00";
		rx_ctrl_serve <= "0000";
	end if;

end if;
end process;

-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###

SWITCHCORE_INST: entity work.switchcore
    port map (
		clk 	=> clk, 		--in	std_logic;
		reset 	=> '0',			--in	std_logic;

		--Activity indicators
		link_sync => "1000",	--in	std_logic_vector(3 downto 0);	--High indicates a peer connection at the physical layer. 

		--Four GMII interfaces
		tx_data => tx_data_hold,		--out	std_logic_vector(31 downto 0);	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
		tx_ctrl => tx_ctrl_hold,		--out	std_logic_vector(3 downto 0);	--(0)=TXC0...(3=TXC3)
		rx_data => rx_data_serve,		--in	std_logic_vector(31 downto 0);	--(7 downto 0)=RXD0...(31 downto 24=RXD3)
		rx_ctrl => rx_ctrl_serve		--in	std_logic_vector(3 downto 0)	--(0)=RXC0...(3=RXC3)
    );

end architecture;

