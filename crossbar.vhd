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


-- need buffer for lengths as well 
-- CHECK DEST MATCH??? how???
-- Create entity for each output port, to know what dst is what... 
begin
    -- create buffer here!!!
    -- need to be 4x max ethernet frame size (1518 bytes) = 6072 bytes
    -- 4048 bytes buffer!!!
    BUFFER : entity work.crossbar_buffer
        port map(
            -- later
            clock => clk,
            data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            rdreq		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            empty		: OUT STD_LOGIC ;
            full		: OUT STD_LOGIC ; 
            q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- Data out
            usedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0) -- Size
        );

    -- Combinational logic
    process(all) -- VHDL 2008 or above
    begin
    
    end process;

    -- Sequential logic
    process(clk, reset) -- VHDL 2008 or above
    begin
        if reset = '1' then

        elsif rising_edge(clk) then

        end if;
    end process;
 end architecture;