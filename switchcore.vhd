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

-- WIRE FROM INPUTGATES 1-4 TO MAC CONTROLLER
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

--WIRE FABRIC
signal fabric_input_1, fabric_input_2, fabric_input_3, fabric_input_4 : fabric_input := (
		RX  	=> x"00",
		val_d 	=> '0',
		len 	=> x"000",
		val_l 	=> '0',
		outt 	=> "000",
		val_o 	=> '0'
);

signal fabric_output_1, fabric_output_2, fabric_output_3, fabric_output_4 : fabric_output := (
		TX 	=> x"00",
		val => '0'
);


-- WIRE SCHEDULAR; b = buffer
signal schedular_input_1, schedular_input_2, schedular_input_3, schedular_input_4 : schedular_input := (
		req_b0 => '0',
		len_b0 => x"000",
		req_b1 => '0',
		len_b1 => x"000",
		req_b2 => '0',
		len_b2 => x"000",
		req_b3 => '0',
		len_b3 => x"000"
);

signal schedular_output_1, schedular_output_2, schedular_output_3, schedular_output_4 : schedular_output := (
		ack_b0 => '0',
		ack_b1 => '0',
		ack_b2 => '0',
		ack_b3 => '0'
);

BEGIN

-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###

-- INPUT GATE 1-4

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
		fabric_input_o			=> fabric_input_1
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
		fabric_input_o			=> fabric_input_2
    );

--WIRE MAC CONTROLLER 
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
	

INST_SCHEDULAR: entity work.schedular_controller
    port map(
        clk 			=> clk,
        reset		 	=> reset,

        -- Output 0 control signals
        sch_in_p0 		=> schedular_input_1,
        sch_out_p0 		=> schedular_output_1,

        -- Output 1 control signals
        sch_in_p1 		=> schedular_input_2,
        sch_out_p1 		=> schedular_output_2,

        -- Output 2 control signals
        sch_in_p2 		=> schedular_input_3,
        sch_out_p2 		=> schedular_output_3,

        -- Output 3 control signals
        sch_in_p3 		=> schedular_input_4,
        sch_out_p3 		=> schedular_output_4
    );

	
INST_FABRIC: entity work.fabric
    port map(
        clk 		=> clk,
        reset 		=> reset,

        -- Input 0 
        in_p0 		=> fabric_input_1,
        out_p0 		=> fabric_output_1,

        -- Input 1
        in_p1 		=> fabric_input_2,
        out_p1 		=> fabric_output_2,

        -- Input 3
        in_p2 		=> fabric_input_3,
        out_p2 		=> fabric_output_3,

        -- Input 4
        in_p3 		=> fabric_input_4,
        out_p3 		=> fabric_output_4,


        -- Scheduler input / output
        -- In relation to the different output ports
        sch_in_p0 	=> schedular_output_1,
        sch_out_p0 	=> schedular_input_1,

        sch_in_p1 	=> schedular_output_2,
        sch_out_p1 	=> schedular_input_2,

        sch_in_p2 	=> schedular_output_3,
        sch_out_p2 	=> schedular_input_3,

        sch_in_p3 	=> schedular_output_4,
        sch_out_p3 	=> schedular_input_4
    );


END arch;

