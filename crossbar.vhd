library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity crossbar is
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- Data input / output
        RX_D : in std_logic_vector(7 downto 0);
        TX_D : out std_logic_vector(7 downto 0);

        -- Scheduler input / output
        req : out std_logic;
		len : out std_logic_vector(11 downto 0);
        ack : in std_logic
    );
end crossbar;

architecture crossbar_arch of crossbar is
-- create buffer here!!!

 end architecture;