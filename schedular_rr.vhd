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
signal ack_b0_next, ack_b1_next, ack_b2_next, ack_b3_next : std_logic := '0';

begin
    -- Combinational logic
    process(all) -- VHDL 2008 or above
    begin
        -- Keep val if no change
        state_rr_next <= state_rr;

        -- Possibly redundant
        ack_b0_next <= '0'; ack_b1_next <= '0'; ack_b2_next <= '0'; ack_b3_next <= '0';

        -- Reduce count representing the number of bytes left to send for each output port
        if len_out = "000000000000" then
            len_out_next <= len_out;
        else
            len_out_next <= len_out - 1;
        end if;

        -- Handle who has PORT access, RR based, for current output port
        -- Prio only changes if highest prio gets its FULL turn!!!
        case state_rr is
            when P0 => -- BUFFER 0 PRIO
                if len_out = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_b0 = '1' then
                        state_rr_next <= P1;
                        len_out_next <= len_p0_b0;
                        ack_b0_next <= '1';
                    elsif req_p0_b1 = '1' then
                        len_out0_next <= len_p0_b1;
                        ack_p0_b1_next <= '1';
                    elsif req_p0_b2 = '1' then
                        len_out0_next <= len_p0_b2;
                        ack_p0_b2_next <= '1';
                    elsif req_p0_b3 = '1' then
                        len_out0_next <= len_p0_b3;
                        ack_p0_b3_next <= '1';
                    end if;
                end if;
            when P1 => -- BUFFER 1 PRIO
                if len_out0 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p0_b1 = '1' then
                        state_rr0_next <= P2;
                        len_out0_next <= len_p0_b1;
                        ack_p0_b1_next <= '1';
                    elsif req_p0_b2 = '1' then
                        len_out0_next <= len_p0_b2;
                        ack_p0_b2_next <= '1';
                    elsif req_p0_b3 = '1' then
                        len_out0_next <= len_p0_b3;
                        ack_p0_b3_next <= '1';
                    elsif req_p0_b0 = '1' then
                        len_out0_next <= len_p0_b0;
                        ack_p0_b0_next <= '1';
                    end if;
                end if;
            when P2 => -- BUFFER 2 PRIO
                if len_out0 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p0_b2 = '1' then
                        state_rr0_next <= P3;
                        len_out0_next <= len_p0_b2;
                        ack_p0_b2_next <= '1';
                    elsif req_p0_b3 = '1' then
                        len_out0_next <= len_p0_b3;
                        ack_p0_b3_next <= '1';
                    elsif req_p0_b0 = '1' then
                        len_out0_next <= len_p0_b0;
                        ack_p0_b0_next <= '1';
                    elsif req_p0_b1 = '1' then
                        len_out0_next <= len_p0_b1;
                        ack_p0_b1_next <= '1';
                    end if;
                end if;
            when P3 => -- BUFFER 3 PRIO
                if len_out0 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p0_b3 = '1' then
                        state_rr0_next <= P0;
                        len_out0_next <= len_p0_b3;
                        ack_p0_b3_next <= '1';
                    elsif req_p0_b0 = '1' then
                        len_out0_next <= len_p0_b0;
                        ack_p0_b0_next <= '1';
                    elsif req_p0_b1 = '1' then
                        len_out0_next <= len_p0_b1;
                        ack_p0_b1_next <= '1';
                    elsif req_p0_b2 = '1' then
                        len_out0_next <= len_p0_b2;
                        ack_p0_b2_next <= '1';
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
        elsif rising_edge(clk) then
            --  Reg update
            state_rr <= state_rr_next;
            len_out <= len_out_next;
            -- Define outputs, maybe set in combinational logic???
            ack_b0 <= ack_b0_next;
            ack_b1 <= ack_b1_next;
            ack_b2 <= ack_b2_next;
            ack_b3 <= ack_b3_next;
        end if;
    end process;
end architecture;