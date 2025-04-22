library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity schedular_controller is 
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- CONNECT THIS TO THE SWITCHCORE
        -- ACK IS ONLY HIGH FOR 1 CLOCK, DONT MISS IT!!!
        
        -- <XXX>_<Output port>_<Input buffer>

        -- Output 0 control signals
        sch_in_p0 : in schedular_input;
        sch_out_p0 : out schedular_output;

        -- Output 1 control signals
        sch_in_p1 : in schedular_input;
        sch_out_p1 : out schedular_output;

        -- Output 2 control signals
        sch_in_p2 : in schedular_input;
        sch_out_p2 : out schedular_output;

        -- Output 3 control signals
        sch_in_p3 : in schedular_input;
        sch_out_p3 : out schedular_output
    );
end schedular_controller;

architecture schedular_controller_arch of schedular_controller is

begin
    -- Instantiate the round robin scheduler for output port 0
    SCHEDULAR_OUTPUT_PORT_0: entity work.schedular_rr
        port map (
            clk => clk,
            reset => reset,

            sch_in => sch_in_p0,
            sch_out => sch_out_p0
        );
    
    -- Instantiate the round robin scheduler for output port 1
    SCHEDULAR_OUTPUT_PORT_1: entity work.schedular_rr
        port map (
            clk => clk,
            reset => reset,

            sch_in => sch_in_p1,
            sch_out => sch_out_p1
        );

    -- Instantiate the round robin scheduler for output port 2
    SCHEDULAR_OUTPUT_PORT_2: entity work.schedular_rr
        port map (
            clk => clk,
            reset => reset,

            sch_in => sch_in_p2,
            sch_out => sch_out_p2
        );

    -- Instantiate the round robin scheduler for output port 3
    SCHEDULAR_OUTPUT_PORT_3: entity work.schedular_rr
        port map (
            clk => clk,
            reset => reset,

            sch_in => sch_in_p3,
            sch_out => sch_out_p3
        );
end architecture;