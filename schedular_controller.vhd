library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity schedular_controller is 
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- CONNECT THIS TO THE SWITCHCORE
        -- ACK IS ONLY HIGH FOR 1 CLOCK, DONT MISS IT!!!
        
        -- <XXX>_<Output port>_<Input buffer>

        -- Output 0 control signals
        req_p0_b0 : in std_logic;
        len_p0_b0 : in std_logic_vector(11 downto 0);
        ack_p0_b0 : out std_logic;
        req_p0_b1 : in std_logic;
        len_p0_b1 : in std_logic_vector(11 downto 0);
        ack_p0_b1 : out std_logic;
        req_p0_b2 : in std_logic;
        len_p0_b2 : in std_logic_vector(11 downto 0);
        ack_p0_b2 : out std_logic;
        req_p0_b3 : in std_logic;
        len_p0_b3 : in std_logic_vector(11 downto 0);
        ack_p0_b3 : out std_logic;

        -- Output 1 control signals
        req_p1_b0 : in std_logic;
        len_p1_b0 : in std_logic_vector(11 downto 0);
        ack_p1_b0 : out std_logic;
        req_p1_b1 : in std_logic;
        len_p1_b1 : in std_logic_vector(11 downto 0);
        ack_p1_b1 : out std_logic;
        req_p1_b2 : in std_logic;
        len_p1_b2 : in std_logic_vector(11 downto 0);
        ack_p1_b2 : out std_logic;
        req_p1_b3 : in std_logic;
        len_p1_b3 : in std_logic_vector(11 downto 0);
        ack_p1_b3 : out std_logic;

        -- Output 2 control signals
        req_p2_b0 : in std_logic;
        len_p2_b0 : in std_logic_vector(11 downto 0);
        ack_p2_b0 : out std_logic;
        req_p2_b1 : in std_logic;
        len_p2_b1 : in std_logic_vector(11 downto 0);
        ack_p2_b1 : out std_logic;
        req_p2_b2 : in std_logic;
        len_p2_b2 : in std_logic_vector(11 downto 0);
        ack_p2_b2 : out std_logic;
        req_p2_b3 : in std_logic;
        len_p2_b3 : in std_logic_vector(11 downto 0);
        ack_p2_b3 : out std_logic;

        -- Output 3 control signals
        req_p3_b0 : in std_logic;
        len_p3_b0 : in std_logic_vector(11 downto 0);
        ack_p3_b0 : out std_logic;
        req_p3_b1 : in std_logic;
        len_p3_b1 : in std_logic_vector(11 downto 0);
        ack_p3_b1 : out std_logic;
        req_p3_b2 : in std_logic;
        len_p3_b2 : in std_logic_vector(11 downto 0);
        ack_p3_b2 : out std_logic;
        req_p3_b3 : in std_logic;
        len_p3_b3 : in std_logic_vector(11 downto 0);
        ack_p3_b3 : out std_logic
    );
end schedular_controller;

architecture schedular_controller_arch of schedular_controller is

-- Maybe rework most of logic into sequential logic, to reduce combinational logic and make it easier to read
-- Divide into four instances

-- State machine, who has prio for output access
type state_type1 is (P0, P1, P2, P3);
signal state_rr0, state_rr0_next, state_rr1, state_rr1_next, state_rr2, state_rr2_next, state_rr3, state_rr3_next : state_type1 := P0;

-- Counters for len for each output port, keeps track of remaing bytes
signal len_out0, len_out0_next, len_out1, len_out1_next, len_out2, len_out2_next, len_out3, len_out3_next : std_logic_vector(11 downto 0) := (others => '0');

-- Ack next signals for each output port
signal ack_p0_b0_next, ack_p0_b1_next, ack_p0_b2_next, ack_p0_b3_next : std_logic := '0';
signal ack_p1_b0_next, ack_p1_b1_next, ack_p1_b2_next, ack_p1_b3_next : std_logic := '0';
signal ack_p2_b0_next, ack_p2_b1_next, ack_p2_b2_next, ack_p2_b3_next : std_logic := '0';
signal ack_p3_b0_next, ack_p3_b1_next, ack_p3_b2_next, ack_p3_b3_next : std_logic := '0';

begin
    -- Combinational logic
    process(all) -- VHDL 2008 or above
    begin
        -- Keep val if no change
        state_rr0_next <= state_rr0;
        state_rr1_next <= state_rr1;
        state_rr2_next <= state_rr2;
        state_rr3_next <= state_rr3;
        -- Possibly redundant
        ack_p0_b0_next <= '0'; ack_p0_b1_next <= '0'; ack_p0_b2_next <= '0'; ack_p0_b3_next <= '0';
        ack_p1_b0_next <= '0'; ack_p1_b1_next <= '0'; ack_p1_b2_next <= '0'; ack_p1_b3_next <= '0';
        ack_p2_b0_next <= '0'; ack_p2_b1_next <= '0'; ack_p2_b2_next <= '0'; ack_p2_b3_next <= '0';
        ack_p3_b0_next <= '0'; ack_p3_b1_next <= '0'; ack_p3_b2_next <= '0'; ack_p3_b3_next <= '0';
        -- Reduce count representing the number of bytes left to send for each output port
        if len_out0 = "000000000000" then
            len_out0_next <= len_out0;
        else
            len_out0_next <= len_out0 - 1;
        end if;
        if len_out1 = "000000000000" then
            len_out1_next <= len_out1;
        else
            len_out1_next <= len_out1 - 1;
        end if;
        if len_out2 = "000000000000" then
            len_out2_next <= len_out2;
        else
            len_out2_next <= len_out2 - 1;
        end if;
        if len_out3 = "000000000000" then
            len_out3_next <= len_out3;
        else
            len_out3_next <= len_out3 - 1;
        end if;
        -- Handle who has PORT access, RR based, for output port 0
        -- Prio only changes if highest prio gets its FULL turn!!!
        case state_rr0 is
            when P0 => -- BUFFER 0 PRIO
                if len_out0 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p0_b0 = '1' then
                        state_rr0_next <= P1;
                        len_out0_next <= len_p0_b0;
                        ack_p0_b0_next <= '1';
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
        -- Handle who has PORT access, RR based, for output port 1
        -- Prio only changes if highest prio gets its FULL turn!!!
        case state_rr1 is
            when P0 => -- BUFFER 0 PRIO
                if len_out1 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p1_b0 = '1' then
                        state_rr1_next <= P1;
                        len_out1_next <= len_p1_b0;
                        ack_p1_b0_next <= '1';
                    elsif req_p1_b1 = '1' then
                        len_out1_next <= len_p1_b1;
                        ack_p1_b1_next <= '1';
                    elsif req_p1_b2 = '1' then
                        len_out1_next <= len_p1_b2;
                        ack_p1_b2_next <= '1';
                    elsif req_p1_b3 = '1' then
                        len_out1_next <= len_p1_b3;
                        ack_p1_b3_next <= '1';
                    end if;
                end if;
            when P1 => -- BUFFER 1 PRIO
                if len_out1 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p1_b1 = '1' then
                        state_rr1_next <= P2;
                        len_out1_next <= len_p1_b1;
                        ack_p1_b1_next <= '1';
                    elsif req_p1_b2 = '1' then
                        len_out1_next <= len_p1_b2;
                        ack_p1_b2_next <= '1';
                    elsif req_p1_b3 = '1' then
                        len_out1_next <= len_p1_b3;
                        ack_p1_b3_next <= '1';
                    elsif req_p1_b0 = '1' then
                        len_out1_next <= len_p1_b0;
                        ack_p1_b0_next <= '1';
                    end if;
                end if;
            when P2 => -- BUFFER 2 PRIO
                if len_out1 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p1_b2 = '1' then
                        state_rr1_next <= P3;
                        len_out1_next <= len_p1_b2;
                        ack_p1_b2_next <= '1';
                    elsif req_p1_b3 = '1' then
                        len_out1_next <= len_p1_b3;
                        ack_p1_b3_next <= '1';
                    elsif req_p1_b0 = '1' then
                        len_out1_next <= len_p1_b0;
                        ack_p1_b0_next <= '1';
                    elsif req_p1_b1 = '1' then
                        len_out1_next <= len_p1_b1;
                        ack_p1_b1_next <= '1';
                    end if;
                end if;
            when P3 => -- BUFFER 3 PRIO
                if len_out1 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p1_b3 = '1' then
                        state_rr1_next <= P0;
                        len_out1_next <= len_p1_b3;
                        ack_p1_b3_next <= '1';
                    elsif req_p1_b0 = '1' then
                        len_out1_next <= len_p1_b0;
                        ack_p1_b0_next <= '1';
                    elsif req_p1_b2 = '1' then
                        len_out1_next <= len_p1_b2;
                        ack_p1_b2_next <= '1';
                    elsif req_p0_b2 = '0' then
                        len_out0_next <= len_p0_b2;
                        ack_p0_b2_next <= '0';
                    end if;
                end if;
        end case;
        -- Handle who has PORT access, RR based, for output port 2
        -- Prio only changes if highest prio gets its FULL turn!!!
        case state_rr2 is
            when P0 => -- BUFFER 0 PRIO
                if len_out2 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p2_b0 = '1' then
                        state_rr2_next <= P1;
                        len_out2_next <= len_p2_b0;
                        ack_p2_b0_next <= '1';
                    elsif req_p2_b1 = '1' then
                        len_out2_next <= len_p2_b1;
                        ack_p2_b1_next <= '1';
                    elsif req_p2_b2 = '1' then
                        len_out2_next <= len_p2_b2;
                        ack_p2_b2_next <= '1';
                    elsif req_p2_b3 = '1' then
                        len_out2_next <= len_p2_b3;
                        ack_p2_b3_next <= '1';
                    end if;
                end if;
            when P1 => -- BUFFER 1 PRIO
                if len_out2 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p2_b1 = '1' then
                        state_rr2_next <= P2;
                        len_out2_next <= len_p2_b1;
                        ack_p2_b1_next <= '1';
                    elsif req_p2_b2 = '1' then
                        len_out2_next <= len_p2_b2;
                        ack_p2_b2_next <= '1';
                    elsif req_p2_b3 = '1' then
                        len_out2_next <= len_p2_b3;
                        ack_p2_b3_next <= '1';
                    elsif req_p2_b0 = '1' then
                        len_out2_next <= len_p2_b0;
                        ack_p2_b0_next <= '1';
                    end if;
                end if;
            when P2 => -- BUFFER 2 PRIO
                if len_out2 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p2_b2 = '1' then
                        state_rr2_next <= P3;
                        len_out2_next <= len_p2_b2;
                        ack_p2_b2_next <= '1';
                    elsif req_p2_b3 = '1' then
                        len_out2_next <= len_p2_b3;
                        ack_p2_b3_next <= '1';
                    elsif req_p2_b0 = '1' then
                        len_out2_next <= len_p2_b0;
                        ack_p2_b0_next <= '1';
                    elsif req_p2_b1 = '1' then
                        len_out2_next <= len_p2_b1;
                        ack_p2_b1_next <= '1';
                    end if;
                end if;
            when P3 => -- BUFFER 3 PRIO
                if len_out2 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p2_b3 = '1' then
                        state_rr2_next <= P0;
                        len_out2_next <= len_p2_b3;
                        ack_p2_b3_next <= '1';
                    elsif req_p2_b0 = '1' then
                        len_out2_next <= len_p2_b0;
                        ack_p2_b0_next <= '1';
                    elsif req_p2_b1 = '1' then
                        len_out2_next <= len_p2_b1;
                        ack_p2_b1_next <= '1';
                    elsif req_p2_b2 = '1' then
                        len_out2_next <= len_p2_b2;
                        ack_p2_b2_next <= '1';
                    end if;
                end if;
        end case;
        -- Handle who has PORT access, RR based, for output port 3
        -- Prio only changes if highest prio gets its FULL turn!!!
        case state_rr3 is
            when P0 => -- BUFFER 0 PRIO
                if len_out3 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p3_b0 = '1' then
                        state_rr3_next <= P1;
                        len_out3_next <= len_p3_b0;
                        ack_p3_b0_next <= '1';
                    elsif req_p3_b1 = '1' then
                        len_out3_next <= len_p3_b1;
                        ack_p3_b1_next <= '1';
                    elsif req_p3_b2 = '1' then
                        len_out3_next <= len_p3_b2;
                        ack_p3_b2_next <= '1';
                    elsif req_p3_b3 = '1' then
                        len_out3_next <= len_p3_b3;
                        ack_p3_b3_next <= '1';
                    end if;
                end if;
            when P1 => -- BUFFER 1 PRIO
                if len_out3 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p3_b1 = '1' then
                        state_rr3_next <= P2;
                        len_out3_next <= len_p3_b1;
                        ack_p3_b1_next <= '1';
                    elsif req_p3_b2 = '1' then
                        len_out3_next <= len_p3_b2;
                        ack_p3_b2_next <= '1';
                    elsif req_p3_b0 = '1' then
                        len_out3_next <= len_p3_b0;
                        ack_p3_b0_next <= '1';
                    elsif req_p3_b2 = '1' then
                        len_out3_next <= len_p3_b2;
                        ack_p3_b2_next <= '1';
                    end if;
                end if;
            when P2 => -- BUFFER 2 PRIO
                if len_out3 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p3_b2 = '1' then
                        state_rr3_next <= P3;
                        len_out3_next <= len_p3_b2;
                        ack_p3_b2_next <= '1';
                    elsif req_p3_b3 = '1' then
                        len_out3_next <= len_p3_b3;
                        ack_p3_b3_next <= '1';
                    elsif req_p3_b0 = '1' then
                        len_out3_next <= len_p3_b0;
                        ack_p3_b0_next <= '1';
                    elsif req_p3_b1 = '1' then
                        len_out3_next <= len_p3_b1;
                        ack_p3_b1_next <= '1';
                    end if;
                end if;
            when P3 => -- BUFFER 3 PRIO
                if len_out3 = "000000000000" then -- Check if the output port is free, i.e no more bytes to send.
                    if req_p3_b3 = '1' then
                        state_rr3_next <= P0;
                        len_out3_next <= len_p3_b3;
                        ack_p3_b3_next <= '1';
                    elsif req_p3_b0 = '1' then
                        len_out3_next <= len_p3_b0;
                        ack_p3_b0_next <= '1';
                    elsif req_p3_b1 = '1' then
                        len_out3_next <= len_p3_b1;
                        ack_p3_b1_next <= '1';
                    elsif req_p3_b2 = '1' then
                        len_out3_next <= len_p3_b2;
                        ack_p3_b2_next <= '1';
                    end if;
                end if;
        end case;
    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then
            state_rr0 <= P0;
            state_rr1 <= P0;
            state_rr2 <= P0;
            state_rr3 <= P0;
            len_out0 <= (others => '0');
            len_out1 <= (others => '0');
            len_out2 <= (others => '0');
            len_out3 <= (others => '0');
        elsif rising_edge(clk) then
            --  Reg update
            state_rr0 <= state_rr0_next;
            state_rr1 <= state_rr1_next;
            state_rr2 <= state_rr2_next;
            state_rr3 <= state_rr3_next;
            len_out0 <= len_out0_next;
            len_out1 <= len_out1_next;
            len_out2 <= len_out2_next;
            len_out3 <= len_out3_next;
            -- Define outputs, maybe set in combinational logic???
            ack_p0_b0 <= ack_p0_b0_next;
            ack_p0_b1 <= ack_p0_b1_next;
            ack_p0_b2 <= ack_p0_b2_next;
            ack_p0_b3 <= ack_p0_b3_next;
            ack_p1_b0 <= ack_p1_b0_next;
            ack_p1_b1 <= ack_p1_b1_next;
            ack_p1_b2 <= ack_p1_b2_next;
            ack_p1_b3 <= ack_p1_b3_next;
            ack_p2_b0 <= ack_p2_b0_next;
            ack_p2_b1 <= ack_p2_b1_next;
            ack_p2_b2 <= ack_p2_b2_next;
            ack_p2_b3 <= ack_p2_b3_next;
            ack_p3_b0 <= ack_p3_b0_next;
            ack_p3_b1 <= ack_p3_b1_next;
            ack_p3_b2 <= ack_p3_b2_next;
            ack_p3_b3 <= ack_p3_b3_next;
        end if;
    end process;
end architecture;