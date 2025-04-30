---------------------------------------------------------------------------------------------------------------
-- Description: 
-- STEP 2: INST_FIREWALL_SM
-- Store the data in a FIFO until it have computed the FCS value, if correct it fowards to next step, if there is an error it drops the packet.
-- This contains a SM, a FIFO and a FCS_calc. It forwards the last meta data (length) to front of packet by skipping the fifo
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

entity inputGate_firewallSM is
	port( 
		clk 	      	: in std_logic;
		reset 	      	: in std_logic;
		
		--Input Interface
		meta_i 			: in inputGate_metaIO;
		
		--Output Interface
		meta_o 			: out inputGate_metaIO
	);
end entity;

architecture RTL of inputGate_firewallSM is

-- FAST FORWARD
signal lenght		: std_logic_vector(11 downto 0);
signal lenght_valid	: std_logic;
signal dstadr		: std_logic_vector(47 downto 0);
signal srcadr		: std_logic_vector(47 downto 0);
signal macadr_valid	: std_logic;

-- ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ### SIGNALS FOR WIRING ###
--FCS INST
signal fcs_input_i : std_logic_vector(7 downto 0) := x"00";
signal fcs_ctl_start_i, fcs_ctl_end_i, fcs_error_o, fcs_error_valid_o : std_logic := '0';

--FIFO INST
signal fifo_input, fifo_output : std_logic_vector(9 downto 0);
signal fifo_usedcnt_o: std_logic_vector(7 downto 0) := x"00";
signal fifo_almost_full_o, fifo_empty_o, fifo_full_o, fifo_read_i, fifo_write_i : std_logic := '0';

-- #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE #### STATE MACHINE ###
type firewall_state_type is (ERROR_STOP, S0_IDLE, S1_DROP, S2_FORWARD);
signal state : firewall_state_type := S0_IDLE; 

begin

MAIN_SM_PS : process(clk)
variable S0_IDLE_to_S1_DROP, S0_IDLE_to_S2_FORWARD, S1_DROP_to_S0_IDLE, S2_FORWARD_to_S0_IDLE : boolean;
variable fifo_end_flag : std_logic;
begin
	if (reset = '1') then
		--reset all signals
	elsif (clk'event and clk = '1') then
		
		--Variable preperation
		S0_IDLE_to_S1_DROP 		:= false;
		S0_IDLE_to_S2_FORWARD	:= false;
		S1_DROP_to_S0_IDLE		:= false;
		S2_FORWARD_to_S0_IDLE	:= false;
		fifo_end_flag := meta_i.data_end;
		
		--Transition computing
		S0_IDLE_to_S1_DROP 		:= (state = S0_IDLE) and (fcs_error_o = '1' and fcs_error_valid_o = '1');
		S0_IDLE_to_S2_FORWARD	:= (state = S0_IDLE) and (fcs_error_o = '0' and fcs_error_valid_o = '1');
		S1_DROP_to_S0_IDLE		:= (state = S1_DROP) and (fifo_end_flag = '1');
		S2_FORWARD_to_S0_IDLE	:= (state = S2_FORWARD) and (fifo_end_flag = '1');
		
		case state is
            when S0_IDLE =>
                if S0_IDLE_to_S1_DROP then
                    state <= S1_DROP;
					fifo_read_i <= '1';
                elsif S0_IDLE_to_S2_FORWARD then
                    state <= S2_FORWARD;
					fifo_read_i <= '1';
				else
					fifo_read_i <= '0';
                end if;
            when S1_DROP =>
                if S1_DROP_to_S0_IDLE then
                    state <= S0_IDLE;
                end if;
				fifo_read_i <= '1';

            when S2_FORWARD =>
                if S2_FORWARD_to_S0_IDLE then
                    state <= S0_IDLE;
                end if;
				fifo_read_i <= '1';
				
			when ERROR_STOP =>
				state <= S0_IDLE;
				
            when others =>
                state <= ERROR_STOP;
        end case;
	
	end if;
end process;

--Skip fifo jump to front
FAST_FORWARD_PS : process(clk)
begin
	if (reset = '1') then
		--reset all signals
	elsif (clk'event and clk = '1') then
	
		if(meta_i.lenght_valid = '1') then
			lenght			<= meta_i.lenght;
			lenght_valid	<= meta_i.lenght_valid;
		end if;
		
		if (meta_i.macadr_valid = '1') then
			dstadr			<= meta_i.dstadr;
			srcadr			<= meta_i.srcadr;
			macadr_valid	<= meta_i.macadr_valid;
		end if;
		
		if (state = S2_FORWARD and fifo_output(1) = '1') then
			meta_o.lenght <= lenght;
			meta_o.lenght_valid <= lenght_valid;
			meta_o.dstadr <= dstadr;
			meta_o.srcadr <= srcadr;
			meta_o.macadr_valid <= macadr_valid;
		else
			meta_o.lenght <= x"000";
			meta_o.lenght_valid <= '0';
			meta_o.dstadr <= x"000000000000";
			meta_o.srcadr <= x"000000000000";
			meta_o.macadr_valid <= '0';
		end if;
	end if;
end process;


-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###
-- ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ### COMPONENT INSTANCES ###

INST_FCS: entity work.inputGate_firewallSM_fcs
    port map (
		clk            		=> clk,
		reset          		=> reset,
		start_of_frame 		=> meta_i.data_start,
		valid				=> meta_i.data_valid,
		complement			=> meta_i.complement,
		end_of_frame   		=> meta_i.data_end,
		m  					=> meta_i.data,
		fcs_error     		=> fcs_error_o,
		fcs_error_valid   	=> fcs_error_valid_o
    );

fifo_input <= meta_i.data & meta_i.data_start & meta_i.data_end;

INST_FIFO: entity work.fifo_bus10_word256
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

-- ### FORWARD ### FORWARD ### FORWARD ### FORWARD ### FORWARD ### FORWARD ### FORWARD ### FORWARD ### FORWARD ### FORWARD ###

meta_o.data 		<= fifo_output(9 downto 2);
meta_o.data_valid 	<= fifo_read_i;
meta_o.complement 	<= '0'; -- no longer needed
meta_o.data_start 	<= fifo_output(1);
meta_o.data_end 	<= fifo_output(0);



end architecture;