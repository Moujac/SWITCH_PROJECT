---------------------------------------------------------------------------------------------------------------
-- Description: 
-- Handles mac table access for the four switch input ports
-- Uses Round Robin to handle multiple requests priority
-- Uses a simple hash function (XOR's) to get the address for the mac table
-- Input signals (MAC DST/SRC & req) should be active until ack/out is received, since request may not have highest priority
-- While memory access is idle, the mac table is checked for old entries and deleted if older than 5 minutes (at 125 MHz)
--
-- Related files / Dependencies:
-- custom package switch_pkg.vhd 
--
-- Revision 2.02 - File Created: May 10, 2025
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity mac_controller is
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- Port 0
        macc_in_p0 : in mac_input;
        macc_out_p0 : out mac_output;
        
        -- Port 1
        macc_in_p1 : in mac_input;
        macc_out_p1 : out mac_output;

        -- Port 2
        macc_in_p2 : in mac_input;
        macc_out_p2 : out mac_output;

        -- Port 3
        macc_in_p3 : in mac_input;
        macc_out_p3 : out mac_output
    );
end mac_controller;

architecture mac_controller_arch of mac_controller is

    -- BRAM for MAC table, 8k entries, should be able to read/write in a single cycle by use of duel port
    -- 000 = no port, 001 = port 0 ...
    type mem is array (8191 downto 0) of std_logic_vector(7 downto 0);
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
     -- Should be enough for 125 MHz clock? 
    signal time_count : std_logic_vector(31 downto 0) := (others => '0');
    signal time_stamp : std_logic_vector(4 downto 0) := (others => '0');

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
                if macc_in_p0.req = '1' then
                    state_rr_next <= P1;
                    state_access_next <= P0;
                    mac_dst_temp <= macc_in_p0.mac_dst;
                    mac_src_temp <= macc_in_p0.mac_src;
                elsif macc_in_p1.req = '1' then
                    state_access_next <= P1;
                    mac_dst_temp <= macc_in_p1.mac_dst;
                    mac_src_temp <= macc_in_p1.mac_src;
                elsif macc_in_p2.req = '1' then
                    state_access_next <= P2;
                    mac_dst_temp <= macc_in_p2.mac_dst;
                    mac_src_temp <= macc_in_p2.mac_src;
                elsif macc_in_p3.req = '1' then
                    state_access_next <= P3;
                    mac_dst_temp <= macc_in_p3.mac_dst;
                    mac_src_temp <= macc_in_p3.mac_src;
                else 
                    state_access_next <= NONE;
                end if;
            when P1 =>
                if macc_in_p1.req = '1' then
                    state_rr_next <= P2;
                    state_access_next <= P1;
                    mac_dst_temp <= macc_in_p1.mac_dst;
                    mac_src_temp <= macc_in_p1.mac_src;
                elsif macc_in_p2.req = '1' then
                    state_access_next <= P2;
                    mac_dst_temp <= macc_in_p2.mac_dst;
                    mac_src_temp <= macc_in_p2.mac_src;
                elsif macc_in_p3.req = '1' then
                    state_access_next <= P3;
                    mac_dst_temp <= macc_in_p3.mac_dst;
                    mac_src_temp <= macc_in_p3.mac_src;
                elsif macc_in_p0.req = '1' then
                    state_access_next <= P0;
                    mac_dst_temp <= macc_in_p0.mac_dst;
                    mac_src_temp <= macc_in_p0.mac_src;
                else 
                    state_access_next <= NONE;
                end if;
            when P2 =>
                if macc_in_p2.req = '1' then
                    state_rr_next <= P3;
                    state_access_next <= P2;
                    mac_dst_temp <= macc_in_p2.mac_dst;
                    mac_src_temp <= macc_in_p2.mac_src;
                elsif macc_in_p3.req = '1' then
                    state_access_next <= P3;
                    mac_dst_temp <= macc_in_p3.mac_dst;
                    mac_src_temp <= macc_in_p3.mac_src;
                elsif macc_in_p0.req = '1' then
                    state_access_next <= P0;
                    mac_dst_temp <= macc_in_p0.mac_dst;
                    mac_src_temp <= macc_in_p0.mac_src;
                elsif macc_in_p1.req = '1' then
                    state_access_next <= P1;
                    mac_dst_temp <= macc_in_p1.mac_dst;
                    mac_src_temp <= macc_in_p1.mac_src;
                else 
                    state_access_next <= NONE;
                end if;
            when P3 =>
                if macc_in_p3.req = '1' then
                    state_rr_next <= P0;
                    state_access_next <= P3;
                    mac_dst_temp <= macc_in_p3.mac_dst;
                    mac_src_temp <= macc_in_p3.mac_src;
                elsif macc_in_p0.req = '1' then
                    state_access_next <= P0;
                    mac_dst_temp <= macc_in_p0.mac_dst;
                    mac_src_temp <= macc_in_p0.mac_src;
                elsif macc_in_p1.req = '1' then
                    state_access_next <= P1;
                    mac_dst_temp <= macc_in_p1.mac_dst;
                    mac_src_temp <= macc_in_p1.mac_src;
                elsif macc_in_p2.req = '1' then
                    state_access_next <= P2;
                    mac_dst_temp <= macc_in_p2.mac_dst;
                    mac_src_temp <= macc_in_p2.mac_src;
                else 
                    state_access_next <= NONE;
                end if;
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
        variable read_temp : std_logic_vector(7 downto 0);
    begin
        if reset = '1' then
            state_access <= NONE;
            state_rr <= P0;
            addr_dst <= (others => '0');
            addr_src <= (others => '0');
            addr_count <= (others => '0');
            time_count <= (others => '0');
            time_stamp <= (others => '0');
        elsif rising_edge(clk) then
            --  Reg update
            state_access <= state_access_next;
            state_rr <= state_rr_next;
            addr_dst <= addr_dst_next;
            addr_src <= addr_src_next;
            -- Handle timeout logic
            -- Should ++ time stamp approx every 30secs at 125 MHz
            if time_count = x"DFDC1C00" then
                time_count <= (others => '0');
                time_stamp <= time_stamp + 1;
            else
                time_count <= time_count + 1;
            end if;
            -- Default output vals
            macc_out_p0.ack <= '0';
            macc_out_p1.ack <= '0';
            macc_out_p2.ack <= '0';
            macc_out_p3.ack <= '0';
            macc_out_p0.outt <= (others => '0');
            macc_out_p1.outt <= (others => '0');
            macc_out_p2.outt <= (others => '0');
            macc_out_p3.outt <= (others => '0');
            -- Handle mem access logic
            case state_access is
                when P0 =>
                    macc_out_p0.outt <= mac_table(to_integer(unsigned(addr_dst)))(7 downto 5);
                    macc_out_p0.ack <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "001" & time_stamp;
                when P1 =>
                    macc_out_p1.outt <= mac_table(to_integer(unsigned(addr_dst)))(7 downto 5);
                    macc_out_p1.ack <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "010" & time_stamp;
                when P2 =>
                    macc_out_p2.outt <= mac_table(to_integer(unsigned(addr_dst)))(7 downto 5);
                    macc_out_p2.ack <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "011" & time_stamp;
                when P3 =>
                    macc_out_p3.outt <= mac_table(to_integer(unsigned(addr_dst)))(7 downto 5);
                    macc_out_p3.ack <= '1';
                    mac_table(to_integer(unsigned(addr_src))) <= "100" & time_stamp;
                when NONE =>
                    -- Reworked with variables to fix memory access problems
                    -- Need to verify variable correctness
                    read_temp := mac_table(to_integer(unsigned(addr_dst)));
                    -- Delete old entries, while memory access is idle
                    addr_count <= addr_count + 1;
                    -- Check if entry is older than approx 5 minutes at 125 MHz
                    if (time_stamp - read_temp(4 downto 0)) > 10 then
                        mac_table(to_integer(unsigned(addr_count))) <= (others => '0');
                    end if;
            end case;
        end if;
    end process;
end architecture; 