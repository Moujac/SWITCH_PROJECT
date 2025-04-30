LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.switch_pkg.all;

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

signal port_reqeust_macadr_1, port_reqeust_macadr_2	: std_logic_vector(47 downto 0);
signal port_reqeust_srcadr_1, port_reqeust_srcadr_2	: std_logic_vector(47 downto 0);
signal port_reqeust_valid_1, port_reqeust_valid_2		: std_logic;
signal port_respond_port_1, port_respond_port_2 		: std_logic_vector(2 downto 0);
signal port_respond_valid_1,port_respond_valid_2 	: std_logic;
signal meta_1, meta_2					: inputGate_metaIO;

signal gate_1_mac_input, gate_2_mac_input, gate_3_mac_input, gate_4_mac_input : mac_input := (
	mac_src => x"000000000000",
	mac_dst => x"000000000000",
	req => '0'
);

signal gate_1_mac_output, gate_2_mac_output, gate_3_mac_output, gate_4_mac_output : mac_output := (
		outt => "000",
		ack => '0'
);

BEGIN

INST_INPUT_GATE_1: entity work.inputGate
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		
		--GMII interface
		rx_data_i		=> rx_data(31 downto 24),
		rx_ctrl_i		=> rx_ctrl(3),
		
		--MAC controller
		port_reqeust_macadr_o	=> port_reqeust_macadr_1,
		port_reqeust_scradr_o	=> port_reqeust_srcadr_1,
		port_reqeust_valid_o	=> port_reqeust_valid_1,
		port_respond_port_i 	=> port_respond_port_1,
		port_respond_valid_i 	=> port_respond_valid_1,
		
		--SwitchFabric
		meta_o			=> meta_1
    );
	
INST_INPUT_GATE_2: entity work.inputGate
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		
		--GMII interface
		rx_data_i		=> rx_data(23 downto 16),
		rx_ctrl_i		=> rx_ctrl(2),
		
		--MAC controller
		port_reqeust_macadr_o	=> port_reqeust_macadr_2,
		port_reqeust_scradr_o	=> port_reqeust_srcadr_2,
		port_reqeust_valid_o	=> port_reqeust_valid_2,
		port_respond_port_i 	=> port_respond_port_2,
		port_respond_valid_i 	=> port_respond_valid_2,
		
		--SwitchFabric
		meta_o			=> meta_2
    );

gate_1_mac_input.mac_src <= port_reqeust_srcadr_1;
gate_1_mac_input.mac_dst <= port_reqeust_macadr_1;
gate_1_mac_input.req <= port_reqeust_valid_1;
port_respond_port_1 <= gate_1_mac_output.outt;
port_respond_valid_1 <= gate_1_mac_output.ack;

gate_2_mac_input.mac_src <= port_reqeust_srcadr_2;
gate_2_mac_input.mac_dst <= port_reqeust_macadr_2;
gate_2_mac_input.req <= port_reqeust_valid_2;
port_respond_port_2 <= gate_2_mac_output.outt;
port_respond_valid_2 <= gate_2_mac_output.ack;

INST_MAC_CONTROLLER: entity work.mac_controller
    PORT MAP(
        clk 			=> clk,
        reset		 	=> reset,

        -- Port 0
        macc_in_p0 		=> gate_1_mac_input,
        macc_out_p0 	=> gate_1_mac_output,
        
        -- Port 1
        macc_in_p1 		=> gate_2_mac_input,
        macc_out_p1 	=> gate_2_mac_output,

        -- Port 2
        macc_in_p2 		=> gate_3_mac_input,
        macc_out_p2 	=> gate_3_mac_output,

        -- Port 3
        macc_in_p3 		=> gate_4_mac_input,
        macc_out_p3 	=> gate_4_mac_output
    );

END arch;

