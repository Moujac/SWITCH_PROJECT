library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity testbench_mac_controller is
end testbench_mac_controller;

architecture testbench_mac_controller_arch of testbench_mac_controller is
    component mac_controller
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
    end component;

    constant CLOCK : time := 10 ns;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    signal macc_in_p0 : mac_input := (
        mac_src => (others => '0'),
        mac_dst => (others => '0'),
        req => '0');
    signal macc_out_p0 : mac_output := (
        outt => (others => '0'),
        ack => '0');

    signal macc_in_p1 : mac_input := (
        mac_src => (others => '0'),
        mac_dst => (others => '0'),
        req => '0');
    signal macc_out_p1 : mac_output := (
        outt => (others => '0'),
        ack => '0');

    signal macc_in_p2 : mac_input := (
        mac_src => (others => '0'),
        mac_dst => (others => '0'),
        req => '0');
    signal macc_out_p2 : mac_output := (
        outt => (others => '0'),
        ack => '0');

    signal macc_in_p3 : mac_input := (
        mac_src => (others => '0'),
        mac_dst => (others => '0'),
        req => '0');
    signal macc_out_p3 : mac_output := (
        outt => (others => '0'),
        ack => '0');

begin
    uut : mac_controller
        port map(
            clk => clk,
            reset => reset,

            macc_in_p0 => macc_in_p0,
            macc_out_p0 => macc_out_p0,

            macc_in_p1 => macc_in_p1,
            macc_out_p1 => macc_out_p1,

            macc_in_p2 => macc_in_p2,
            macc_out_p2 => macc_out_p2,

            macc_in_p3 => macc_in_p3,
            macc_out_p3 => macc_out_p3
        );

    process
    begin
        clk <= '1'; wait for CLOCK / 2;
        clk <= '0'; wait for CLOCK / 2;
    end process;

    process
    begin
        -- Start with reset
        reset <= '1';
        wait for CLOCK * 2;
        reset <= '0';
        wait for CLOCK * 2;

        -- Test case 1: Request from port 0, simple
        macc_in_p0.mac_src <= x"100000000000";
        macc_in_p0.mac_dst <= x"010000000000";
        macc_in_p0.req <= '1';
        wait for CLOCK * 2;
        macc_in_p0.req <= '0';
        wait for CLOCK * 10;

        -- Test case 2: Request from all input ports
        -- Verify round robin scheduling
        macc_in_p0.mac_src <= x"100000000000";
        macc_in_p0.mac_dst <= x"010000000000";
        macc_in_p0.req <= '1';
        macc_in_p1.mac_src <= x"010000000000";
        macc_in_p1.mac_dst <= x"100000000000";
        macc_in_p1.req <= '1';
        macc_in_p2.mac_src <= x"001000000000";
        macc_in_p2.mac_dst <= x"100000000000";
        macc_in_p2.req <= '1';
        macc_in_p3.mac_src <= x"000100000000";
        macc_in_p3.mac_dst <= x"100000000000";
        macc_in_p3.req <= '1';
        wait for CLOCK * 100;

        wait;

    end process;
end architecture;