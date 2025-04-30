---------------------------------------------------------------------------------------------------------------
-- Description: 
-- Instances the crossbar buffers for each input port and connects them to the scheduler output ports.
--
-- Related files / Dependencies:
-- custom package switch_pkg.vhd 
--
-- Revision 2.00 - File Created: Apr 24, 2025
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
        in_p2 : in fabric_input;
        out_p2 : out fabric_output;

        -- Input 4
        in_p3 : in fabric_input;
        out_p3 : out fabric_output;


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

-- Signals to drive outputs
signal d_out0_in0, d_out0_in1, d_out0_in2, d_out0_in3 : fabric_output;
signal d_out1_in0, d_out1_in1, d_out1_in2, d_out1_in3 : fabric_output;
signal d_out2_in0, d_out2_in1, d_out2_in2, d_out2_in3 : fabric_output;
signal d_out3_in0, d_out3_in1, d_out3_in2, d_out3_in3 : fabric_output;

-- State machine, to keep track of who has access to the output port
type state_type1 is (P0, P1, P2, P3);
signal state_out0, state_out2, state_out2, state_out3 : state_type1 := P0;

begin 
    -- Input port 0 instances !!!
    CROSSBAR_BUFFER_0 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            data_in => in_p0,
            --data_out => out_p0,
            data_out => d_out0_in0,

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
            data_in => in_p0,
            --data_out => out_p1,
            data_out => d_out1_in0,

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
            data_in => in_p0,
            --data_out => out_p2,
            data_out => d_out2_in0,

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
            data_in => in_p0,
            --data_out => out_p3,
            data_out => d_out3_in0,

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
            data_in => in_p1,
            --data_out => out_p0,
            data_out => d_out0_in1,

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
            data_in => in_p1,
            --data_out => out_p1,
            data_out => d_out1_in1

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
            data_in => in_p1,
            --data_out => out_p2,
            data_out => d_out2_in1,

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
            data_in => in_p1,
            --data_out => out_p3,
            data_out => d_out3_in1,

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
            data_in => in_p2,
            --data_out => out_p0,
            data_out => d_out0_in2,

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
            data_in => in_p2,
            --data_out => out_p1,
            data_out => d_out1_in2,

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
            data_in => in_p2,
            --data_out => out_p2,
            data_out => d_out2_in2,

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
            data_in => in_p2,
            --data_out => out_p3,
            data_out => d_out3_in2,

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
            data_in => in_p3,
            --data_out => out_p0,
            data_out => d_out0_in3,

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
            data_in => in_p3,
            --data_out => out_p1,
            data_out => d_out1_in3,

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
            data_in => in_p3,
            --data_out => out_p2,
            data_out => d_out2_in3,

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
            data_in => in_p3,
            --data_out => out_p3,
            data_out => d_out3_in3,

            -- Scheduler input / output
            req => sch_in_p3.req_b3,
            len => sch_in_p3.len_b3,
            ack => sch_out_p3.ack_b3
        );

    -- Combinational logic to drive the output ports
    process(all)
    begin
        -- Default values
        out_p0 <= (others => '0');
        out_p1 <= (others => '0');
        out_p2 <= (others => '0');
        out_p3 <= (others => '0');

        -- Drive output ports based on state machine
        case state_out0 is
            when P0 =>
                out_p0 <= d_out0_in0;
            when P1 =>
                out_p0 <= d_out0_in1;
            when P2 =>
                out_p0 <= d_out0_in2;
            when P3 =>
                out_p0 <= d_out0_in3;
        end case;

        case state_out1 is
            when P0 =>
                out_p1 <= d_out1_in0;
            when P1 =>
                out_p1 <= d_out1_in1;
            when P2 =>
                out_p1 <= d_out1_in2;
            when P3 =>
                out_p1 <= d_out1_in3;
        end case;

        case state_out2 is
            when P0 =>
                out_p2 <= d_out2_in0;
            when P1 =>
                out_p2 <= d_out2_in1;
            when P2 =>
                out_p2 <= d_out2_in2;
            when P3 =>
                out_p2 <= d_out2_in3;
        end case;

        case state_out3 is
            when P0 =>
                out_p3 <= d_out3_in0;
            when P1 =>
                out_p3 <= d_out3_in1;
            when P2 =>
                out_p3 <= d_out3_in2;
            when P3 =>
                out_p3 <= d_out3_in3;
        end case;
    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset state machine
            state_out0 <= P0;
            state_out1 <= P0;
            state_out2 <= P0;
            state_out3 <= P0;
        elsif rising_edge(clk) then
            -- create logic to drive the outputs, to mitigate multiple signals driving the same output!!!
            -- Not pretty, but should work for now, since only 1 ack at a time from schedular!!!
            -- Handle output port 0 access
            if sch_out_p0.ack_b0 = '1' then
                state_out0 <= P0;
            elsif sch_out_p0.ack_b1 = '1' then
                state_out0 <= P1;
            elsif sch_out_p0.ack_b2 = '1' then
                state_out0 <= P2;
            elsif sch_out_p0.ack_b3 = '1' then
                state_out0 <= P3;
            end if;
            -- Handle output port 1 access
            if sch_out_p1.ack_b0 = '1' then
                state_out1 <= P0;
            elsif sch_out_p1.ack_b1 = '1' then
                state_out1 <= P1;
            elsif sch_out_p1.ack_b2 = '1' then
                state_out1 <= P2;
            elsif sch_out_p1.ack_b3 = '1' then
                state_out1 <= P3;
            end if;
            -- Handle output port 2 access
            if sch_out_p2.ack_b0 = '1' then
                state_out2 <= P0;
            elsif sch_out_p2.ack_b1 = '1' then
                state_out2 <= P1;
            elsif sch_out_p2.ack_b2 = '1' then
                state_out2 <= P2;
            elsif sch_out_p2.ack_b3 = '1' then
                state_out2 <= P3;
            end if;
            -- Handle output port 3 access
            if sch_out_p3.ack_b0 = '1' then
                state_out3 <= P0;
            elsif sch_out_p3.ack_b1 = '1' then
                state_out3 <= P1;
            elsif sch_out_p3.ack_b2 = '1' then
                state_out3 <= P2;
            elsif sch_out_p3.ack_b3 = '1' then
                state_out3 <= P3;
            end if;
        end if;
    end process;
end architecture;