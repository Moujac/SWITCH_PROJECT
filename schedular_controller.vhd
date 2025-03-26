library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity schedular_controller is 
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- CONNECT THIS TO THE SWITCHCORE
        
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

signal temp : std_logic;

begin
    -- Combinational logic
    process(all) -- VHDL 2008 or above
    begin

    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then

        elsif rising_edge(clk) then

        end if;
    end process;
end architecture;