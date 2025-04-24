library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.switch_pkg.all;

entity fabric is
    port(
        clk : in std_logic;
        reset : in std_logic;

        -- Data input / output
        RX_D0 : in std_logic_vector(7 downto 0);
        RX_D1 : in std_logic_vector(7 downto 0);
        RX_D2 : in std_logic_vector(7 downto 0);
        RX_D3 : in std_logic_vector(7 downto 0);

        TX_D0 : out std_logic_vector(7 downto 0);
        TX_D1 : out std_logic_vector(7 downto 0);
        TX_D2 : out std_logic_vector(7 downto 0);
        TX_D3 : out std_logic_vector(7 downto 0);

        -- Scheduler input / output
        sch_in_p0 : in schedular_output;
        sch_out_p0 : out schedular_input;

        sch_in_p1 : in schedular_output;
        sch_out_p1 : out schedular_input;

        sch_in_p2 : in schedular_output;
        sch_out_p2 : out schedular_input;

        sch_in_p3 : in schedular_output;
        sch_out_p3 : out schedular_input
    );
end fabric;

architecture fabric_arch of fabric is
-- Sanity check signal connections ...

begin 
    CROSSBAR_BUFFER_0 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D0,
            TX_D => TX_D0,

            -- Scheduler input / output
            req => sch_in_p0.req_b0,
            len => sch_in_p0.len_b0,
            ack => sch_out_p0.ack_b0
        );
    
    CROSSBAR_BUFFER_1 : entity work.crossbar
        port map (
            clk => clk,
            reset => reset,

            -- Data input / output
            RX_D => RX_D1,
            TX_D => TX_D1,

            -- Scheduler input / output
            req => sch_in_p1.req_b1,
            len => sch_in_p1.len_b1,
            ack => sch_out_p1.ack_b1
        );

end architecture;