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

--GMII input
signal isreading : std_logic := '0';

--Instance Helper Signal
signal fcs_input_i : std_logic_vector(7 downto 0) := x"00";
signal fcs_ctl_start_i, fcs_ctl_end_i, fcs_error_o, fcs_error_valid_o : std_logic := '0';

signal fifo_data_i, fifo_data_o : std_logic_vector(7 downto 0) := x"00";
signal fifo_usedcnt_o: std_logic_vector(11 downto 0) := x"000";
signal fifo_almost_full_o, fifo_empty_o, fifo_full_o, fifo_read_i, fifo_write_i : std_logic := '0';

--stolen
signal CRC                 :   std_logic_vector(7 downto 0);
signal CRC_REG             :   std_logic_vector(31 downto 0);
signal CRC_VALID           :   std_logic;


type firewall_state_type is (ERROR_STOP, S0_IDLE, S1_DROP, S2_FORWARD);
signal state : firewall_state_type := S0_IDLE; 

begin

MAIN_PS : process(clk)
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

            when others =>
                state <= ERROR_STOP;
        end case;
	
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

INST_STOLEN_FCS: entity work.CRC
    port map (
			CLOCK => clk,
            RESET => reset,
            DATA                => meta_i.data,
            LOAD_INIT           => meta_i.data_start,
            CALC                => meta_i.data_end,
            D_VALID             => meta_i.data_valid,
            CRC                 => CRC,
            CRC_REG             => CRC_REG,
            CRC_VALID           => CRC_VALID 
    );
	
INST_FIFO: entity work.fifo_bus11
    port map (
		aclr			=> reset,
		clock			=> clk,
		data			=> meta_i.data, --& meta_i.data_valid & meta_i.data_start & meta_i.data_end,
		rdreq			=> fifo_read_i,
		wrreq			=> meta_i.data_valid,
		almost_full		=> fifo_almost_full_o,
		empty			=> fifo_empty_o, 
		full			=> fifo_full_o,
		q				=> fifo_data_o,
		usedw			=> fifo_usedcnt_o
    );

end architecture;