---------------------------------------------------------------------------------------------------------------
-- Description: 
-- Input Gate, it takes the GMII port inputs, checks for errors with FCS, requests MAC and forwards data to switch fabric.
--
-- STEP 1: INST_META_READER
-- Interprets GMII input and outputs meta values (like end and start flag also MACDST) timed together with the data.
-- The metaReader.vhd file is difficult to read because it uses a buffer to correct the end flag timing. 
--
-- STEP 2: INST_FIREWALL_SM
-- Store the data in a FIFO until it have computed the FCS value, if correct it fowards to next step, if there is an error it drops the packet.
-- This contains a SM, a FIFO and a FCS_calc. It forwards the last meta data (length) to front of packet by skipping the fifo
--
-- STEP 3: INST_MACTOPORT_SM
-- Store the data in a FIFO, request the corresponding port by sending the macadr to controller. Then forwards to switch fabric using that port.
-- Uses a state machine
--
-- Related files / Dependencies:
-- inputGate_metaReader.vhd, inputGate_firewallSM.vhd, inputGate_mactoport_sm
--
-- Revision 0.01 - File Created
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.switch_pkg.all;

entity inputGate is
	port( 
		clk 	      	: in std_logic;
		reset 	      	: in std_logic;
		
		--GMII interface
		rx_data_i		: in std_logic_vector(7 downto 0);
		rx_ctrl_i		: in std_logic;
		
		--MAC controller
		port_reqeust_macadr_o	: out std_logic_vector(47 downto 0);
		port_reqeust_scradr_o	: out std_logic_vector(47 downto 0);
		port_reqeust_valid_o	: out std_logic;
		port_respond_port_i 	: in std_logic_vector(2 downto 0);
		port_respond_valid_i 	: in std_logic;
		
		--SwitchFabric
		meta_o			: out inputGate_metaIO
	);
end entity;

architecture RTL of inputGate is

-- ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ###
--Init Instance wires, set everything to zero when starting the system.
signal metareader_meta_wire, firewall_meta_wire, mactoport_meta_wire : inputGate_metaIO := (
		data			=> x"00",
		data_valid		=> '0',
		complement		=> '0',
		data_start		=> '0',
		data_end		=> '0',
		lenght			=> x"000",
		lenght_valid	=> '0',
		dstadr			=> x"000000000000",
		srcadr			=> x"000000000000",
		macadr_valid	=> '0'
);

--MAC controller WIRING
signal port_reqeust_macadr_wire	: std_logic_vector(47 downto 0) := x"000000000000";
signal port_reqeust_scradr_wire	: std_logic_vector(47 downto 0) := x"000000000000";
signal port_reqeust_valid_wire	: std_logic := '0';
signal port_respond_port_wire	: std_logic_vector(2 downto 0) := "000";
signal port_respond_valid_wire 	: std_logic := '0';

begin

-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
	
INST_META_READER: entity work.inputGate_metaReader --STEP 1
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		--Input Interface
		rx_data_i		=> rx_data_i,
		rx_ctrl_i		=> rx_ctrl_i,
		--Output Interface
		meta_o 			=> metareader_meta_wire
    );
	
INST_FIREWALL_SM: entity work.inputGate_firewallSM --STEP 2
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		--Input Interface
		meta_i 			=> metareader_meta_wire,
		--Output Interface
		meta_o 			=> firewall_meta_wire
    );

INST_MACTOPORT_SM: entity work.inputGate_mactoportSM --STEP 3
	port map ( 
		clk 	      	=> clk,
		reset 	      	=> reset,
		
		--Input Interface
		meta_i 			=> firewall_meta_wire,
		
		--Output Interface
		meta_o 			=> mactoport_meta_wire,
		
		--MAC controller Interface
		port_reqeust_macadr_o	=> port_reqeust_macadr_wire,
		port_reqeust_scradr_o	=> port_reqeust_scradr_wire,
		port_reqeust_valid_o	=> port_reqeust_valid_wire,
		port_respond_port_i 	=> port_respond_port_wire,
		port_respond_valid_i 	=> port_respond_valid_wire
	);
	
-- ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ### WIRING ###

--MAC controller
port_reqeust_macadr_o	<= port_reqeust_macadr_wire;
port_reqeust_scradr_o	<= port_reqeust_scradr_wire;
port_reqeust_valid_o	<= port_reqeust_valid_wire;

port_respond_port_wire <= port_respond_port_i;
port_respond_valid_wire <= port_respond_valid_i;
		
--SwitchFabric
meta_o			<= mactoport_meta_wire;

end architecture;