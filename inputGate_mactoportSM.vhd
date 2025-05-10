---------------------------------------------------------------------------------------------------------------
-- Description: 
-- STEP 3: INST_MACTOPORT_SM
-- Store the data in a FIFO, request the corresponding port by sending the macadr to controller. Then forwards to switch fabric using that port.
-- Uses a state machine
--
-- burde nok lave fifo til meta length mac og src address
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

entity inputGate_mactoportSM is
	port( 
		clk 	      	: in std_logic;
		reset 	      	: in std_logic;
		
		--Input Interface
		meta_i 			: in inputGate_metaIO;
		
		--Output Interface
		--meta_o 			: out inputGate_metaIO;
		fabric_o 		: out fabric_input;
		
		--MAC controller Interface
		port_reqeust_macadr_o	: out std_logic_vector(47 downto 0);
		port_reqeust_scradr_o	: out std_logic_vector(47 downto 0);
		port_reqeust_valid_o	: out std_logic;
		port_respond_port_i 	: in std_logic_vector(2 downto 0);
		port_respond_valid_i 	: in std_logic
	);
end entity;

architecture RTL of inputGate_mactoportSM is

-- ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ###
--FIFO data INST
signal fifo_input, fifo_output : std_logic_vector(9 downto 0);
signal fifo_usedcnt_o: std_logic_vector(7 downto 0) := x"00";
signal fifo_almost_full_o, fifo_empty_o, fifo_full_o, fifo_read_i, fifo_write_i : std_logic := '0';

--FIFO meta INST
signal fifo_meta_input, fifo_meta_output : std_logic_vector(107 downto 0);
signal fifo_meta_usedcnt_o: std_logic_vector(4 downto 0) := "00000";
signal fifo_meta_almost_full_o, fifo_meta_empty_o, fifo_meta_full_o, fifo_meta_read_i, fifo_meta_write_i : std_logic := '0';

-- #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE ###
type mactoport_state_type is (ERROR_STOP, S0_IDLE, S1_PORT_REQUEST, S2_FORWARD);
signal state : mactoport_state_type := S0_IDLE; 



signal fabric_wire : fabric_input := (
		RX  	=> x"00",
		val_d 	=> '0',
		len 	=> x"000",
		val_l 	=> '0',
		outt 	=> "000",
		val_o 	=> '0'
);

signal init_forward_toggle : std_logic := '0';

signal save_port_respond	: std_logic_vector(2 downto 0);

begin

MAIN_PS : process(clk)
variable S0_IDLE_to_S1_PORT_REQUEST, S1_PORT_REQUEST_to_S2_FORWARD, S2_FORWARD_to_S0_IDLE, S2_FORWARD_to_S1_PORT_REQUEST : boolean;
variable fifo_end_flag : std_logic;
begin
	if (reset = '1') then
		--reset all signals
	elsif (clk'event and clk = '1') then
		
		--Variable preperation
		S0_IDLE_to_S1_PORT_REQUEST 		:= false;
		S1_PORT_REQUEST_to_S2_FORWARD	:= false;
		S2_FORWARD_to_S0_IDLE			:= false;
		S2_FORWARD_to_S1_PORT_REQUEST	:= false;
		fifo_end_flag := meta_i.data_end;
		
		--Transition computing
		S0_IDLE_to_S1_PORT_REQUEST 		:= (state = S0_IDLE) and (fifo_output(1) = '1');
		S1_PORT_REQUEST_to_S2_FORWARD	:= (state = S1_PORT_REQUEST) and (port_respond_valid_i = '1');
		S2_FORWARD_to_S0_IDLE			:= (state = S2_FORWARD) and (fifo_output(0) = '1');
		S2_FORWARD_to_S1_PORT_REQUEST	:= (state = S2_FORWARD) and (fifo_output(1) = '1') and FALSE;
		
		--Decide on state using transitions
		if(S0_IDLE_to_S1_PORT_REQUEST) then
			state <= S1_PORT_REQUEST;
		elsif(S1_PORT_REQUEST_to_S2_FORWARD) then
			state <= S2_FORWARD;
		elsif(S2_FORWARD_to_S0_IDLE) then
			state <= S0_IDLE;
		elsif(S2_FORWARD_to_S1_PORT_REQUEST) then
			state <= S1_PORT_REQUEST;
		end if;
		
		--State logic
		case state is
            when S0_IDLE =>
			
				port_reqeust_macadr_o	<= x"000000000000";
				port_reqeust_scradr_o	<= x"000000000000";
				port_reqeust_valid_o	<= '0';
				
				fabric_wire.RX  	<= x"00";
				fabric_wire.val_d 	<= '0';
			
			when S1_PORT_REQUEST =>
				
				port_reqeust_macadr_o	<= fifo_meta_output(107 downto 60);
				port_reqeust_scradr_o	<= fifo_meta_output(59 downto 12);
				port_reqeust_valid_o	<= '1';
				
			when S2_FORWARD =>
				
				port_reqeust_macadr_o	<= x"000000000000";
				port_reqeust_scradr_o	<= x"000000000000";
				port_reqeust_valid_o	<= '0';
				fifo_read_i <= '1';
				
				if init_forward_toggle = '0' then
					init_forward_toggle <= '1';
				
					fabric_wire.RX  	<= fifo_output(9 downto 2);
					fabric_wire.val_d 	<= '1';
					fabric_wire.len 	<= fifo_meta_output(11 downto 0);
					fabric_wire.val_l 	<= '1';
					fabric_wire.outt 	<= save_port_respond;
					fabric_wire.val_o 	<= '1';
				else
					fabric_wire.RX  	<= fifo_output(9 downto 2);
					fabric_wire.val_d 	<= '1';
					fabric_wire.len 	<= x"000";
					fabric_wire.val_l 	<= '0';
					fabric_wire.outt 	<= "000";
					fabric_wire.val_o 	<= '0';
				end if;
				
            when others =>
                
        end case;
		
		
		
		--ADDITONAL logic
		if (port_respond_valid_i = '1') then
			save_port_respond <= port_respond_port_i;
		end if;
	
	end if;
end process;

fifo_input <= meta_i.data & meta_i.data_start & meta_i.data_end;

INST_FIFO_DATA: entity work.fifo_bus10_word256
	PORT MAP(
		aclr		=> reset,
		clock		=> clk,
		data		=> fifo_input,
		rdreq		=> fifo_read_i,
		wrreq		=> meta_i.data_valid,
		empty		=> fifo_empty_o, 
		full		=> fifo_full_o,
		q			=> fifo_output,
		usedw		=> fifo_usedcnt_o
	);

fifo_meta_input <= meta_i.dstadr & meta_i.srcadr & meta_i.lenght;

INST_FIFO_META: entity work.fifo_bus108_word32
	PORT MAP(
		aclr		=> reset,
		clock		=> clk,
		data		=> fifo_meta_input,
		rdreq		=> fifo_meta_read_i,
		wrreq		=> meta_i.lenght_valid,
		empty		=> fifo_meta_empty_o, 
		full		=> fifo_meta_full_o,
		q			=> fifo_meta_output,
		usedw		=> fifo_meta_usedcnt_o
	);

fabric_o <= fabric_wire;



end architecture;