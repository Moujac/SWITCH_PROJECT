---------------------------------------------------------------------------------------------------------------
-- Description: 
-- Schedules the output port access for the four cross bar buffers, using a round robin approach.
-- The round robin scheduler is implemented as a state machine with four states, one for each input buffer.
-- The scheduler checks the request signals from the input buffers and grants access to the output port based on the round robin priority.
-- The scheduler also keeps track of the number of bytes left to send for each output port and generates acknowledgment signals for the input buffers.
-- ACK is high as long as ACCESS is granted to the output port.
--
-- Related files / Dependencies:
-- custom package switch_pkg.vhd 
--
-- Revision 1.01 - File Created: Apr 9, 2025
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity schedular_rr is
    port(
        clk : in std_logic;
        reset : in std_logic;

        sch_in : in schedular_input;
        sch_out : out schedular_output
    );
end schedular_rr;

architecture schedular_rr_arch of schedular_rr is

-- State machine, who has prio for output access
type state_type1 is (P0, P1, P2, P3);
signal state_rr, state_rr_next : state_type1 := P0;

-- Counters for len for each output port, keeps track of remaing bytes
signal len_out, len_out_next : std_logic_vector(11 downto 0) := (others => '0');

-- Ack next signals for each output port
signal ack_b0, ack_b1, ack_b2, ack_b3 : std_logic := '0';
signal ack_b0_next, ack_b1_next, ack_b2_next, ack_b3_next : std_logic := '0';

begin
    -- Combinational logic
    process(all) -- VHDL 2008 or above
    begin
        -- Keep val if no change
        state_rr_next <= state_rr;
        ack_b0_next <= ack_b0;
        ack_b1_next <= ack_b1;
        ack_b2_next <= ack_b2;
        ack_b3_next <= ack_b3;

        -- Reduce count representing the number of bytes left to send for each output port
        -- Handle byte count update
        if len_out = "000000000001" then
            -- Last byte: reset len and ack signals
            -- Reset acks to avoid ack being high 1 clock cycle too long
            ack_b0_next <= '0';
            ack_b1_next <= '0';
            ack_b2_next <= '0';
            ack_b3_next <= '0';
            len_out_next <= len_out - 1;
        elsif len_out = "000000000000" then
            -- No bytes left, do nothing
            len_out_next <= len_out;
        else
            -- Decrement byte count
            len_out_next <= len_out - 1;
        end if;

        -- Handle who has output PORT access, RR based
        -- Prio only changes if highest prio gets its FULL turn!!!
        -- Maybe change for more fair access, weighted RR
        case state_rr is
            when P0 => -- Input BUFFER 0 PRIO
                if len_out = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if sch_in.req_b0 = '1' then
                        state_rr_next <= P1;
                        len_out_next <= sch_in.len_b0;
                        ack_b0_next <= '1';
                    elsif sch_in.req_b1 = '1' then
                        len_out_next <= sch_in.len_b1;
                        ack_b1_next <= '1';
                    elsif sch_in.req_b2 = '1' then
                        len_out_next <= sch_in.len_b2;
                        ack_b2_next <= '1';
                    elsif sch_in.req_b3 = '1' then
                        len_out_next <= sch_in.len_b3;
                        ack_b3_next <= '1';
                    end if;
                end if;
            when P1 => -- Input BUFFER 1 PRIO
                if len_out = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if sch_in.req_b1 = '1' then
                        state_rr_next <= P2;
                        len_out_next <= sch_in.len_b1;
                        ack_b1_next <= '1';
                    elsif sch_in.req_b2 = '1' then
                        len_out_next <= sch_in.len_b2;
                        ack_b2_next <= '1';
                    elsif sch_in.req_b3 = '1' then
                        len_out_next <= sch_in.len_b3;
                        ack_b3_next <= '1';
                    elsif sch_in.req_b0 = '1' then
                        len_out_next <= sch_in.len_b0;
                        ack_b0_next <= '1';
                    end if;
                end if;
            when P2 => -- BUFFER 2 PRIO
                if len_out = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if sch_in.req_b2 = '1' then
                        state_rr_next <= P3;
                        len_out_next <= sch_in.len_b2;
                        ack_b2_next <= '1';
                    elsif sch_in.req_b3 = '1' then
                        len_out_next <= sch_in.len_b3;
                        ack_b3_next <= '1';
                    elsif sch_in.req_b0 = '1' then
                        len_out_next <= sch_in.len_b0;
                        ack_b0_next <= '1';
                    elsif sch_in.req_b1 = '1' then
                        len_out_next <= sch_in.len_b1;
                        ack_b1_next <= '1';
                    end if;
                end if;
            when P3 => -- BUFFER 3 PRIO
                if len_out = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if sch_in.req_b3 = '1' then
                        state_rr_next <= P0;
                        len_out_next <= sch_in.len_b3;
                        ack_b3_next <= '1';
                    elsif sch_in.req_b0 = '1' then
                        len_out_next <= sch_in.len_b0;
                        ack_b0_next <= '1';
                    elsif sch_in.req_b1 = '1' then
                        len_out_next <= sch_in.len_b1;
                        ack_b1_next <= '1';
                    elsif sch_in.req_b2 = '1' then
                        len_out_next <= sch_in.len_b2;
                        ack_b2_next <= '1';
                    end if;
                end if;
        end case;
    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset logic here
            state_rr <= P0;
            len_out <= (others => '0');
            ack_b0 <= '0';
            ack_b1 <= '0';
            ack_b2 <= '0';
            ack_b3 <= '0';
        elsif rising_edge(clk) then
            --  Reg update
            state_rr <= state_rr_next;
            len_out <= len_out_next;
            ack_b0 <= ack_b0_next;
            ack_b1 <= ack_b1_next;
            ack_b2 <= ack_b2_next;
            ack_b3 <= ack_b3_next;
            -- Define outputs
            sch_out.ack_b0 <= ack_b0;
            sch_out.ack_b1 <= ack_b1;
            sch_out.ack_b2 <= ack_b2;
            sch_out.ack_b3 <= ack_b3;
        end if;
    end process;
end architecture;