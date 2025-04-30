---------------------------------------------------------------------------------------------------------------
-- Description: 
-- OUTPUT PORT 0 CROSSBAR BUFFERS!!!
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

signal data : std_logic_vector(7 downto 0) := (others => '0');
signal rdreq : std_logic := '0';
signal wrreq : std_logic := '0';
signal empty : std_logic := '0';
signal full : std_logic := '0';
signal q : std_logic_vector(7 downto 0) := (others => '0');
signal usedw : std_logic_vector(11 downto 0) := (others => '0');

begin
    -- create buffer here!!!
    -- need to be 4x max ethernet frame size (1518 bytes) = 6072 bytes
    -- 4048 bytes buffer!!!
    BUFFER : entity work.crossbar_buffer
        port map(
            -- later
            clock => clk,
            data => data,
            rdreq => rdreq,
            wrreq => wrreq,
            empty => empty,
            full => full,
            q => q, -- Data out
            usedw => usedw -- Size
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
            -- default values
            data <= (others => '0');
            rdreq <= '0';
            wrreq <= '0';

            -- CHECK DEST MATCH AND VALID
            if data_in.val_o = '1' and (data_in.outt = "000" or data_in.outt = "001") then -- Match with all / out port 0
                
            end if;
                
            -- Create entity for each output port, to know what dst is what... 

        end if;
    end process;
 end architecture;