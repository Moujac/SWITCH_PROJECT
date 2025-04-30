---------------------------------------------------------------------------------------------------------------
-- Description: 
-- Instances the crossbar buffers for each input port and connects them to the scheduler output ports.
--
-- Related files / Dependencies:
-- custom package switch_pkg.vhd 
--
-- Revision 1.00 - File Created: Apr 24, 2025
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity fabric is
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- Input 0 
        in_p0 : in fabric_input;
        out_p0 : out fabric_output;

        -- Input 1
        in_p1 : in fabric_input;
        out_p1 : out fabric_output;

        -- Input 3
        in_p1 : in fabric_input;
        out_p1 : out fabric_output;

        -- Input 4
        in_p1 : in fabric_input;
        out_p1 : out fabric_output;


        -- Scheduler input / output
        -- In relation to the different output ports
        sch_in_p0 : in schedular_output;
        sch_out_p0 : out schedular_input;

        sch_in_p1 : in schedular_output;
        sch_out_p1 : out schedular_input;

        sch_in_p2 : in schedular_output;
        sch_out_p2 : out schedular_input;

        sch_in_p3 : in schedular_output;
        sch_out_p3 : out schedular_input
    );
end fabric;

architecture fabric_arch of fabric is

-- maybe problem with driving outputs with multiple signals???
-- maybe create crossbar buffers as 4 components instead???
-- create logic to drive the outputs, to mitigate multiple signals driving the same output!!!

begin 
    -- Input port 0 instances !!!
    CROSSBAR_BUFFER_0 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D0,
            TX_D => TX_D0,

            -- Scheduler input / output
            req => sch_in_p0.req_b0,
            len => sch_in_p0.len_b0,
            ack => sch_out_p0.ack_b0
        );
    
    CROSSBAR_BUFFER_1 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D0,
            TX_D => TX_D1,

            -- Scheduler input / output
            req => sch_in_p1.req_b0,
            len => sch_in_p1.len_b0,
            ack => sch_out_p1.ack_b0
        );

    CROSSBAR_BUFFER_2 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D0,
            TX_D => TX_D2,

            -- Scheduler input / output
            req => sch_in_p2.req_b0,
            len => sch_in_p2.len_b0,
            ack => sch_out_p2.ack_b0
        );
    
    CROSSBAR_BUFFER_3 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D0,
            TX_D => TX_D3,

            -- Scheduler input / output
            req => sch_in_p3.req_b0,
            len => sch_in_p3.len_b0,
            ack => sch_out_p3.ack_b0
        );

    -- Input port 1 instances !!!
    CROSSBAR_BUFFER_4 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D1,
            TX_D => TX_D0,

            -- Scheduler input / output
            req => sch_in_p0.req_b1,
            len => sch_in_p0.len_b1,
            ack => sch_out_p0.ack_b1
        );
    
    CROSSBAR_BUFFER_5 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D1,
            TX_D => TX_D1,

            -- Scheduler input / output
            req => sch_in_p1.req_b1,
            len => sch_in_p1.len_b1,
            ack => sch_out_p1.ack_b1
        );
    
    CROSSBAR_BUFFER_6 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D1,
            TX_D => TX_D2,

            -- Scheduler input / output
            req => sch_in_p2.req_b1,
            len => sch_in_p2.len_b1,
            ack => sch_out_p2.ack_b1
        );
    
    CROSSBAR_BUFFER_7 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D1,
            TX_D => TX_D3,

            -- Scheduler input / output
            req => sch_in_p3.req_b1,
            len => sch_in_p3.len_b1,
            ack => sch_out_p3.ack_b1
        );
    
    -- Input port 2 instances !!!
    CROSSBAR_BUFFER_8 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D2,
            TX_D => TX_D0,

            -- Scheduler input / output
            req => sch_in_p0.req_b2,
            len => sch_in_p0.len_b2,
            ack => sch_out_p0.ack_b2
        );
    
    CROSSBAR_BUFFER_9 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D2,
            TX_D => TX_D1,

            -- Scheduler input / output
            req => sch_in_p1.req_b2,
            len => sch_in_p1.len_b2,
            ack => sch_out_p1.ack_b2
        );

    CROSSBAR_BUFFER_10 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D2,
            TX_D => TX_D2,

            -- Scheduler input / output
            req => sch_in_p2.req_b2,
            len => sch_in_p2.len_b2,
            ack => sch_out_p2.ack_b2
        );

    CROSSBAR_BUFFER_11 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D2,
            TX_D => TX_D3,

            -- Scheduler input / output
            req => sch_in_p3.req_b2,
            len => sch_in_p3.len_b2,
            ack => sch_out_p3.ack_b2
        );

    -- Input port 3 instances !!!
    CROSSBAR_BUFFER_12 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D3,
            TX_D => TX_D0,

            -- Scheduler input / output
            req => sch_in_p0.req_b3,
            len => sch_in_p0.len_b3,
            ack => sch_out_p0.ack_b3
        );
    
    CROSSBAR_BUFFER_13 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D3,
            TX_D => TX_D1,

            -- Scheduler input / output
            req => sch_in_p1.req_b3,
            len => sch_in_p1.len_b3,
            ack => sch_out_p1.ack_b3
        );
    
    CROSSBAR_BUFFER_14 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D3,
            TX_D => TX_D2,

            -- Scheduler input / output
            req => sch_in_p2.req_b3,
            len => sch_in_p2.len_b3,
            ack => sch_out_p2.ack_b3
        );
    
    CROSSBAR_BUFFER_15 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D3,
            TX_D => TX_D3,

            -- Scheduler input / output
            req => sch_in_p3.req_b3,
            len => sch_in_p3.len_b3,
            ack => sch_out_p3.ack_b3
        );

end architecture;