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

--Instance wires
signal metareader_meta_wire : inputGate_metaIO := (
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

signal firewall_meta_wire : inputGate_metaIO;

begin


-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
	
INST_META_READER: entity work.inputGate_metaReader 
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		--Input Interface
		rx_data_i		=> rx_data_i,
		rx_ctrl_i		=> rx_ctrl_i,
		--Output Interface
		meta_o 			=> metareader_meta_wire
    );
	
INST_FIREWALL_SM: entity work.inputGate_firewallSM
    port map (
		clk 	      	=> clk,
		reset 	      	=> reset,
		--Input Interface
		meta_i 			=> metareader_meta_wire,
		--Output Interface
		meta_o 			=> firewall_meta_wire
    );

end architecture;