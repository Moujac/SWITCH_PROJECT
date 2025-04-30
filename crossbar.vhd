---------------------------------------------------------------------------------------------------------------
-- Description: 
-- TEMP 
--
-- Related files / Dependencies:
-- custom package switch_pkg.vhd 
--
-- Revision 1.01 - File Created: Apr 24, 2025
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------

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
        data_in : in fabric_input;
        data_out : out fabric_output;

        -- Scheduler input / output
        req : out std_logic;
		len : out std_logic_vector(11 downto 0);
        ack : in std_logic
    );
end crossbar;

architecture crossbar_arch of crossbar is
-- create buffer here!!!
-- need to be 4x max ethernet frame size (1518 bytes) = 6072 bytes
-- need buffer for lengths as well 
-- CHECK DEST MATCH???
begin

 end architecture;