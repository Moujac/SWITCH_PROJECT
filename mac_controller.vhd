library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity mac_controller is
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- Input signals should be active until ack/out is received

        -- Port 0
        mac_src_p0 : in std_logic_vector(47 downto 0);
        mac_dst_p0 : in std_logic_vector(47 downto 0);
        req_p0 : in std_logic;
        out_p0 : out std_logic_vector(2 downto 0);
        ack_p0 : out std_logic;
        
        -- Port 1
        mac_src_p1 : in std_logic_vector(47 downto 0);
        mac_dst_p1 : in std_logic_vector(47 downto 0);
        req_p1 : in std_logic;
        out_p1 : out std_logic_vector(2 downto 0);
        ack_p1 : out std_logic;

        -- Port 2
        mac_src_p2 : in std_logic_vector(47 downto 0);
        mac_dst_p2 : in std_logic_vector(47 downto 0);
        req_p2 : in std_logic;
        out_p2 : out std_logic_vector(2 downto 0);
        ack_p2 : out std_logic;

         -- Port 3
        mac_src_p3 : in std_logic_vector(47 downto 0);
        mac_dst_p3 : in std_logic_vector(47 downto 0);
        req_p3 : in std_logic;
        out_p3 : out std_logic_vector(2 downto 0);
        ack_p3 : out std_logic
    );
end mac_controller;

architecture mac_controller_arch of mac_controller is

    -- Make sure multiple requests dont get throught when only one is made in reality
    -- Need to cleate a timeout for mac table

    -- BRAM for MAC table, 8k entries, should be able to read/write in a single cycle by use of duel port
    -- 000 = no port, 001 = port 0 ...
    type mem is array (8191 downto 0) of std_logic_vector(42 downto 0);
    signal mac_table : mem := (others => (others => '0'));
    signal addr_dst, addr_dst_next, addr_src, addr_src_next : std_logic_vector(12 downto 0) := (others => '0');

    -- State machine, who has mem access
    type state_type1 is (P0, P1, P2, P3, NONE);
    signal state_access, state_access_next : state_type1 := NONE;

    -- State machine, who has priority
    type state_type2 is (P0, P1, P2, P3);
    signal state_rr, state_rr_next : state_type2 := P0;

    -- Temp value for hashing, depends on who has access
    signal mac_dst_temp, mac_src_temp : std_logic_vector(47 downto 0);
    signal mac_dst_temp16, mac_src_temp16 : std_logic_vector(15 downto 0);

    -- Counters for timeout
    signal addr_count : std_logic_vector(12 downto 0) := (others => '0');
    signal time_count : std_logic_vector(39 downto 0) := (others => '0'); -- Should be enough for 100 MHz clock

begin
    -- Combinational logic
    -- Can maybe rework so more logic is in combinational part
    process(all) -- VHDL 2008 or above
    begin
        -- Keep val if no change
        state_rr_next <= state_rr;
        state_access_next <= state_access;
        addr_dst_next <= addr_dst;
        addr_src_next <= addr_src;
        -- Maybe redundant
        mac_dst_temp <= (others => '0');
        mac_src_temp <= (others => '0');
        -- Handle who has access, RR based
        -- Prio only changes if highest prio gets its turn!!!
        case state_rr is
            when P0 =>
                if req_p0 = '1' then
                    state_rr_next <= P1;
                    state_access_next <= P0;
                    mac_dst_temp <= mac_dst_p0;
                    mac_src_temp <= mac_src_p0;
                elsif req_p1 = '1' then
                    state_access_next <= P1;
                    mac_dst_temp <= mac_dst_p1;
                    mac_src_temp <= mac_src_p1;
                elsif req_p2 = '1' then
                    state_access_next <= P2;
                    mac_dst_temp <= mac_dst_p2;
                    mac_src_temp <= mac_src_p2;
                elsif req_p3 = '1' then
                    state_access_next <= P3;
                    mac_dst_temp <= mac_dst_p3;
                    mac_src_temp <= mac_src_p3;
                else 
                    state_access_next <= NONE;
                end if;
            when P1 =>
                if req_p1 = '1' then
                    state_rr_next <= P2;
                    state_access_next <= P1;
                    mac_dst_temp <= mac_dst_p1;
                    mac_src_temp <= mac_src_p1;
                elsif req_p2 = '1' then
                    state_access_next <= P2;
                    mac_dst_temp <= mac_dst_p2;
                    mac_src_temp <= mac_src_p2;
                elsif req_p3 = '1' then
                    state_access_next <= P3;
                    mac_dst_temp <= mac_dst_p3;
                    mac_src_temp <= mac_src_p3;
                elsif req_p0 = '1' then
                    state_access_next <= P0;
                    mac_dst_temp <= mac_dst_p0;
                    mac_src_temp <= mac_src_p0;
                else 
                    state_access_next <= NONE;
                end if;
            when P2 =>
                if req_p2 = '1' then
                    state_rr_next <= P3;
                    state_access_next <= P2;
                    mac_dst_temp <= mac_dst_p2;
                    mac_src_temp <= mac_src_p2;
                elsif req_p3 = '1' then
                    state_access_next <= P3;
                    mac_dst_temp <= mac_dst_p3;
                    mac_src_temp <= mac_src_p3;
                elsif req_p0 = '1' then
                    state_access_next <= P0;
                    mac_dst_temp <= mac_dst_p0;
                    mac_src_temp <= mac_src_p0;
                elsif req_p1 = '1' then
                    state_access_next <= P1;
                    mac_dst_temp <= mac_dst_p1;
                    mac_src_temp <= mac_src_p1;
                else 
                    state_access_next <= NONE;
                end if;
            when P3 =>
                if req_p3 = '1' then
                    state_rr_next <= P0;
                    state_access_next <= P3;
                    mac_dst_temp <= mac_dst_p3;
                    mac_src_temp <= mac_src_p3;
                elsif req_p0 = '1' then
                    state_access_next <= P0;
                    mac_dst_temp <= mac_dst_p0;
                    mac_src_temp <= mac_src_p0;
                elsif req_p1 = '1' then
                    state_access_next <= P1;
                    mac_dst_temp <= mac_dst_p1;
                    mac_src_temp <= mac_src_p1;
                elsif req_p2 = '1' then
                    state_access_next <= P2;
                    mac_dst_temp <= mac_dst_p2;
                    mac_src_temp <= mac_src_p2;
                else 
                    state_access_next <= NONE;
                end if;
            when others => -- Should not happen
                state_rr_next <= P0;
                state_access_next <= NONE;
        end case;
        -- Handle hashing, depends on who has access
        -- Simple XOR hashing, maybe not good enough spread
        mac_dst_temp16 <=   mac_dst_temp(47 downto 32) xor mac_dst_temp(31 downto 16) xor 
                            mac_dst_temp(15 downto 0);
        addr_dst_next <=    mac_dst_temp16(12 downto 0);
        mac_src_temp16 <=   mac_src_temp(47 downto 32) xor mac_src_temp(31 downto 16) xor 
                            mac_src_temp(15 downto 0);
        addr_src_next <=    mac_src_temp16(12 downto 0);
    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then
            state_access <= NONE;
            state_rr <= P0;
            addr_dst <= (others => '0');
            addr_src <= (others => '0');
            addr_count <= (others => '0');
            time_count <= (others => '0');
        elsif rising_edge(clk) then
            --  Reg update
            state_access <= state_access_next;
            state_rr <= state_rr_next;
            addr_dst <= addr_dst_next;
            addr_src <= addr_src_next;
            time_count <= time_count + 1;
            -- Default output vals
            ack_p0 <= '0';
            ack_p1 <= '0';
            ack_p2 <= '0';
            ack_p3 <= '0';
            out_p0 <= (others => '0');
            out_p1 <= (others => '0');
            out_p2 <= (others => '0');
            out_p3 <= (others => '0');
            -- Handle mem access logic
            case state_access is
                when P0 =>
                    out_p0 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p0 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "001" & time_count;
                when P1 =>
                    out_p1 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p1 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "010" & time_count;
                when P2 =>
                    out_p2 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p2 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "011" & time_count;
                when P3 =>
                    out_p3 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p3 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "100" & time_count;
                when NONE =>
                    -- Delete old entries, while memory access is idle
                    addr_count <= addr_count + 1;
                    -- Check if entry is older than 5 minutes at 100 MHz
                    -- 5 minutes = 3000000000 cycles
                    if time_count - mac_table(to_integer(unsigned(addr_count)))(39 downto 0) > x"B2D0000000" then
                        mac_table(to_integer(unsigned(addr_count))) <= (others => '0');
                    end if;
            end case;
        end if;
    end process;
end architecture; 