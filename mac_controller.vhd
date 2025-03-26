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
    signal addr_dst, addr_src : std_logic_vector(12 downto 0) := (others => '0');

    -- State machine, who has mem access
    type state_type1 is (P0, P1, P2, P3, NONE);
    signal state_access, state_access_next : state_type1 := NONE;

    -- State machine, who has priority
    type state_type2 is (P0, P1, P2, P3);
    signal state_rr, state_rr_next : state_type2 := P0;

    -- Temp value depends on who has access
    mac_dst_temp, mac_src_temp : std_logic_vector(47 downto 0);

begin
    -- Combinate logic
    process(all) -- VHDL 2008 or above
    begin
        -- Handle who has access
        case state_rr is
            when P0 =>
                if req_p0 = '1' then
                    state_access <= P0;
                    mac_dst_temp <= mac_dst_p0;
                    mac_src_temp <= mac_src_p0;
                elsif req_p1 = '1' then
                    state_access <= P1;
                    mac_dst_temp <= mac_dst_p1;
                    mac_src_temp <= mac_src_p1;
                elsif req_p2 = '1' then
                    state_access <= P2;
                    mac_dst_temp <= mac_dst_p2;
                    mac_src_temp <= mac_src_p2;
                elsif req_p3 = '1' then
                    state_access <= P3;
                    mac_dst_temp <= mac_dst_p3;
                    mac_src_temp <= mac_src_p3;
                else 
                    state_access <= NONE;
                end if;
            when P2 =>

            when P3 =>

            when P4 =>

            when others =>
                -- Should not happen
        end case;
        -- Handle hashing, depends on who has access
        -- Simple XOR hashing?
        -- maybe
        addr_dst <= mac_temp(11 downto 0) xor mac_temp(23 downto 12) xor mac_temp(35 downto 24) xor mac_temp(47 downto 36);

    end process;

    -- Sequential logic, reg update
    process(clk, reset)
    begin
        if reset = '1' then
            mac_table <= (others => (others => '0')); -- maybe?
        elsif rising_edge(clk) then
            -- Handle MAC controller logic
            -- add switch to handle each ports mem access
            -- maybe round robing to give each port a chance to access mem, if not needed skip?
            -- mem(to_integer(unsigned(wptr(3 downto 0)))) <= write_data_in;
            -- read_data_out <= mem(to_integer(unsigned(rptr(3 downto 0))));
        end if;
    end process;
end architecture; 