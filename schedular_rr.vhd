library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity schedular_rr is
    port(
        clk : in std_logic;
        reset : in std_logic;

        state_rr : in state_type1;

    );
end schedular_rr;

architecture schedular_rr_arch of schedular_rr is

    -- Define your signals and types here

begin
    -- Combinational logic
    process(all)
    begin

    end process;

    -- Sequential logic
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset logic here
        elsif rising_edge(clk) then

        end if;
    end process;
end architecture;