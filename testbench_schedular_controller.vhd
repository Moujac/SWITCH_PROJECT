---------------------------------------------------------------------------------------------------------------
-- Description: 
-- Simple testbench for the schedular_controller
-- Tests a simple requests and a more complex one with requests from all buffers related to a output port for RR scheduling testing
--
-- Related files / Dependencies:
-- custom package switch_pkg.vhd 
--
-- Revision 1.00 - File Created: Apr 23, 2025
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity testbench_schedular_controller is
end testbench_schedular_controller;

architecture testbench_schedular_controller_arch of testbench_schedular_controller is
    component schedular_controller
        port(
            clk : in std_logic;
            reset : in std_logic;
    
            -- Output 0 control signals
            sch_in_p0 : in schedular_input;
            sch_out_p0 : out schedular_output;
    
            -- Output 1 control signals
            sch_in_p1 : in schedular_input;
            sch_out_p1 : out schedular_output;
    
            -- Output 2 control signals
            sch_in_p2 : in schedular_input;
            sch_out_p2 : out schedular_output;
    
            -- Output 3 control signals
            sch_in_p3 : in schedular_input;
            sch_out_p3 : out schedular_output
        );
    end component;

    constant CLOCK : time := 10 ns;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    signal sch_in_p0 : schedular_input := (
        req_b0 => '0',
        req_b1 => '0',
        req_b2 => '0',
        req_b3 => '0',
        len_b0 => (others => '0'),
        len_b1 => (others => '0'),
        len_b2 => (others => '0'),
        len_b3 => (others => '0'));
    signal sch_out_p0 : schedular_output := (
        ack_b0 => '0',
        ack_b1 => '0',
        ack_b2 => '0',
        ack_b3 => '0');
    
    signal sch_in_p1 : schedular_input := (
        req_b0 => '0',
        req_b1 => '0',
        req_b2 => '0',
        req_b3 => '0',
        len_b0 => (others => '0'),
        len_b1 => (others => '0'),
        len_b2 => (others => '0'),
        len_b3 => (others => '0'));
    signal sch_out_p1 : schedular_output := (
        ack_b0 => '0',
        ack_b1 => '0',
        ack_b2 => '0',
        ack_b3 => '0');

    signal sch_in_p2 : schedular_input := (
        req_b0 => '0',
        req_b1 => '0',
        req_b2 => '0',
        req_b3 => '0',
        len_b0 => (others => '0'),
        len_b1 => (others => '0'),
        len_b2 => (others => '0'),
        len_b3 => (others => '0'));
    signal sch_out_p2 : schedular_output := (
        ack_b0 => '0',
        ack_b1 => '0',
        ack_b2 => '0',
        ack_b3 => '0');

    signal sch_in_p3 : schedular_input := (
        req_b0 => '0',
        req_b1 => '0',
        req_b2 => '0',
        req_b3 => '0',
        len_b0 => (others => '0'),
        len_b1 => (others => '0'),
        len_b2 => (others => '0'),
        len_b3 => (others => '0'));
    signal sch_out_p3 : schedular_output := (
        ack_b0 => '0',
        ack_b1 => '0',
        ack_b2 => '0',
        ack_b3 => '0');

begin
    uut : schedular_controller
        port map(
            clk => clk,
            reset => reset,

            sch_in_p0=> sch_in_p0,
            sch_out_p0 => sch_out_p0,

            sch_in_p1 => sch_in_p1,
            sch_out_p1 => sch_out_p1,

            sch_in_p2 => sch_in_p2,
            sch_out_p2 => sch_out_p2,

            sch_in_p3 => sch_in_p3,
            sch_out_p3 => sch_out_p3
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

        -- Test case 1: Request from input port0 for output port0, simple
        sch_in_p0.req_b0 <= '1';
        sch_in_p0.len_b0 <= "000000000001"; -- 1 byte
        wait for CLOCK * 2;
        sch_in_p0.req_b0 <= '0';
        sch_in_p0.len_b0 <= "000000000000";
        wait for CLOCK * 10;

        -- Test case 2: See how it handles request from all to all, complex
        -- Verifies round robin and priority
        -- Spam output port 0 requests
        sch_in_p0.req_b0 <= '1';
        sch_in_p0.len_b0 <= "000000000001"; -- 1 byte
        sch_in_p0.req_b1 <= '1';
        sch_in_p0.len_b1 <= "000000000010"; -- 2 byte
        sch_in_p0.req_b2 <= '1';
        sch_in_p0.len_b2 <= "000000000100"; -- 4 byte
        sch_in_p0.req_b3 <= '1';
        sch_in_p0.len_b3 <= "000000000010"; -- 2 byte
        wait for CLOCK * 100;

        wait;

    end process;
end architecture;