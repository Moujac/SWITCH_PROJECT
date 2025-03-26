library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity testbench_mac_controller is
end testbench_mac_controller;

architecture testbench_mac_controller_arch of testbench_mac_controller is
    component mac_controller
        port(
            clk : in std_logic;
            reset : in std_logic;

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
    end component;

    constant CLOCK : time := 10 ns;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    signal mac_src_p0, mac_dst_p0 : std_logic_vector(47 downto 0) := (others => '0');
    signal req_p0 : std_logic := '0';
    signal out_p0 : std_logic_vector(2 downto 0) := (others => '0');
    signal ack_p0 : std_logic := '0';

    signal mac_src_p1, mac_dst_p1 : std_logic_vector(47 downto 0) := (others => '0');
    signal req_p1 : std_logic := '0';
    signal out_p1 : std_logic_vector(2 downto 0) := (others => '0');
    signal ack_p1 : std_logic := '0';

    signal mac_src_p2, mac_dst_p2 : std_logic_vector(47 downto 0) := (others => '0');
    signal req_p2 : std_logic := '0';
    signal out_p2 : std_logic_vector(2 downto 0) := (others => '0');
    signal ack_p2 : std_logic := '0';

    signal mac_src_p3, mac_dst_p3 : std_logic_vector(47 downto 0) := (others => '0');
    signal req_p3 : std_logic := '0';
    signal out_p3 : std_logic_vector(2 downto 0) := (others => '0');
    signal ack_p3 : std_logic := '0';

begin
    uut : mac_controller
        port map(
            clk => clk,
            reset => reset,

            mac_src_p0 => mac_src_p0,
            mac_dst_p0 => mac_dst_p0,
            req_p0 => req_p0,
            out_p0 => out_p0,
            ack_p0 => ack_p0,

            mac_src_p1 => mac_src_p1,
            mac_dst_p1 => mac_dst_p1,
            req_p1 => req_p1,
            out_p1 => out_p1,
            ack_p1 => ack_p1,

            mac_src_p2 => mac_src_p2,
            mac_dst_p2 => mac_dst_p2,
            req_p2 => req_p2,
            out_p2 => out_p2,
            ack_p2 => ack_p2,

            mac_src_p3 => mac_src_p3,
            mac_dst_p3 => mac_dst_p3,
            req_p3 => req_p3,
            out_p3 => out_p3,
            ack_p3 => ack_p3
        );

    process
    begin
        clk <= '1'; wait for CLOCK / 2;
        clk <= '0'; wait for CLOCK / 2;
    end process;

    process
    begin
        reset <= '1';
        wait for CLOCK * 2;
        reset <= '0';
        wait for CLOCK * 2;

        mac_src_p0 <= x"100000000000";
        mac_dst_p0 <= x"010000000000";
        req_p0 <= '1';
        wait;


    end process;

end architecture;