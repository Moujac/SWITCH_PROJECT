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
        out_p0 : out std_logic_vector(1 downto 0);
        ack_p0 : out std_logic;
        
        -- Port 1
        mac_src_p1 : in std_logic_vector(47 downto 0);
        mac_dst_p1 : in std_logic_vector(47 downto 0);
        req_p1 : in std_logic;
        out_p1 : out std_logic_vector(1 downto 0);
        ack_p1 : out std_logic;

        -- Port 2
        mac_src_p2 : in std_logic_vector(47 downto 0);
        mac_dst_p2 : in std_logic_vector(47 downto 0);
        req_p2 : in std_logic;
        out_p2 : out std_logic_vector(1 downto 0);
        ack_p2 : out std_logic;

         -- Port 3
        mac_src_p3 : in std_logic_vector(47 downto 0);
        mac_dst_p3 : in std_logic_vector(47 downto 0);
        req_p3 : in std_logic;
        out_p3 : out std_logic_vector(1 downto 0);
        ack_p3 : out std_logic;
    );
end mac_controller;

architecture mac_controller_arch of mac_controller is

    -- BRAM for MAC table, 8k entries, should be able to read/write in a single cycle by use of duel port
    type mem is array (8191 downto 0) of std_logic_vector(1 downto 0);
    signal mac_table : mem := (others => (others => '0'));

    -- Maybe state machine?

begin
    -- Combinate logic
    process(all) -- VHDL 2008 or above
    begin
        -- Handle who has access

        -- Handle hashing, depends on who has access

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