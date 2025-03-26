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
        ack_p3 : out std_logic;
    );
end mac_controller;

architecture mac_controller_arch of mac_controller is

    -- BRAM for MAC table, 8k entries, should be able to read/write in a single cycle by use of duel port
    -- 000 = no port, 001 = port 0 ...
    type mem is array (8191 downto 0) of std_logic_vector(2 downto 0);
    signal mac_table : mem := (others => (others => '0'));
    signal addr_dst, addr_dst_next, addr_src, addr_src_next : std_logic_vector(12 downto 0) := (others => '0');

    -- State machine, who has mem access
    type state_type1 is (P0, P1, P2, P3, NONE);
    signal state_access, state_access_next : state_type1 := NONE;

    -- State machine, who has priority
    type state_type2 is (P0, P1, P2, P3);
    signal state_rr, state_rr_next : state_type2 := P0;

    -- Temp value for hashing, depends on who has access
    mac_dst_temp, mac_src_temp : std_logic_vector(47 downto 0);

begin
    -- Combinate logic
    process(all) -- VHDL 2008 or above
    begin
        -- Handle rr prio
        case state_rr is
            when P0 =>
                state_rr_next <= P1;
            when P1 =>
                state_rr_next <= P2;
            when P2 =>
                state_rr_next <= P3;
            when P3 =>
                state_rr_next <= P0;
            when others => -- Should not happen
                state_rr_next <= P0;
        end case;
        -- Handle who has access, RR based
        case state_rr is
            when P0 =>
                if req_p0 = '1' then
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
                    -- Maybe not needed?
                    mac_dst_temp <= (others => '0');
                    mac_src_temp <= (others => '0');
                end if;
            when others => -- Should not happen
                state_access_next <= NONE;
        end case;
        -- Handle hashing, depends on who has access
        -- Simple XOR hashing, maybe not good enough spread
        addr_dst_next <=    mac_dst_temp(47 downto 40) xor mac_dst_temp(39 downto 32) xor 
                            mac_dst_temp(31 downto 24) xor mac_dst_temp(23 downto 16) xor 
                            mac_dst_temp(15 downto 8) xor mac_dst_temp(7 downto 0) (12 downto 0);
        addr_src_next <=    mac_src_temp(47 downto 40) xor mac_src_temp(39 downto 32) xor 
                            mac_src_temp(31 downto 24) xor mac_src_temp(23 downto 16) xor 
                            mac_src_temp(15 downto 8) xor mac_src_temp(7 downto 0) (12 downto 0);
    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then
            state_access <= NONE;
            state_rr <= P0;
            addr_dst <= (others => '0');
            addr_src <= (others => '0');
            --mac_table <= (others => (others => '0')); -- maybe?
        elsif rising_edge(clk) then
            --  Reg update
            state_access <= state_access_next;
            state_rr <= state_rr_next;
            addr_dst <= addr_dst_next;
            addr_src <= addr_src_next;
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
                    mac_table(to_integer(unsigned(addr_src))) <= "001";
                when P1 =>
                    out_p1 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p1 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "010";
                when P2 =>
                    out_p2 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p2 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "011";
                when P3 =>
                    out_p3 <= mac_table(to_integer(unsigned(addr_dst)));
                    ack_p3 <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "100";
                when NONE =>
                    -- Do nothing
            end case;
        end if;
    end process;
end architecture; 