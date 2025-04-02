LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity switchcore is
	port (
		clk:			in	std_logic;
		reset:			in	std_logic;
		
		--Activity indicators
		link_sync:		in	std_logic_vector(3 downto 0);	--High indicates a peer connection at the physical layer. 
		
		--Four GMII interfaces
		tx_data:			out	std_logic_vector(31 downto 0);	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
		tx_ctrl:			out	std_logic_vector(3 downto 0);	--(0)=TXC0...(3=TXC3)
		rx_data:			in	std_logic_vector(31 downto 0);	--(7 downto 0)=RXD0...(31 downto 24=RXD3)
		rx_ctrl:			in	std_logic_vector(3 downto 0)	--(0)=RXC0...(3=RXC3)
	);
end switchcore;

architecture arch of switchcore is

signal	port_reqeust_macadr_1	: std_logic_vector(47 downto 0);
signal	port_reqeust_valid_1	: std_logic;
signal	port_respond_port_1 	: std_logic_vector(1 downto 0);
signal	port_respond_valid_1 	: std_logic;
		
signal	data_1			: std_logic_vector(7 downto 0);
signal	ctrl_1			: std_logic;

BEGIN

INST_INPUT_GATE_1: entity work.input_gate
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		
		--GMII interface
		rx_data_i		=> rx_data(31 downto 24),
		rx_ctrl_i		=> rx_ctrl(3),
		
		--MAC controller
		port_reqeust_macadr_o	=> port_reqeust_macadr_1,
		port_reqeust_valid_o	=> port_reqeust_valid_1,
		port_respond_port_i 	=> port_respond_port_1,
		port_respond_valid_i 	=> port_respond_valid_1,
		
		--SwitchFabric
		data_o			=> data_1,
		ctrl_o			=> ctrl_1
    );

END arch;
