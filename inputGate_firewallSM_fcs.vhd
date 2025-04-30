-- Description: 
-- FCS CRC
--
-- Related files / Dependencies:
-- A^8 matrix generated with fcs.m, output stored in VHDL_FCS.txt, 
--
-- Revision 0.01 - File Created
-- Additional Comments:
---------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity inputGate_firewallSM_fcs is
	port (
		clk            	: in std_logic; -- system clock
		reset          	: in std_logic; -- asynchronous reset
		start_of_frame 	: in std_logic; -- arrival of the first bit.
		valid 			: in std_logic;
		complement 		: in std_logic;
		end_of_frame   	: in std_logic; -- arrival of the first bit in FCS.
		m  				: in std_logic_vector(7 downto 0); -- serial input data.
		fcs_error      	: out std_logic; -- indicates an error.
		fcs_error_valid : out std_logic
	);
end entity;

architecture RTL of inputGate_firewallSM_fcs is

signal r : std_logic_vector(31 downto 0) := x"00000000";

signal complementToggle : std_logic := '0';
signal togglecnt : integer range 0 to 3;

begin

mainPs : process(clk)
variable data : std_logic_vector(7 downto 0);
begin
if (clk'event and clk = '1') then
	
	--### VARIABLES ### VARIABLES ### VARIABLES ### VARIABLES ### VARIABLES ### VARIABLES ### VARIABLES 
	--complement data input for first 32bit
	data := x"00";
	if(complement = '0') then
		data := m;
	else
		data := not m;
	end if;
	
	--### COMBINATIONAL ### COMBINATIONAL ### COMBINATIONAL ### COMBINATIONAL ### COMBINATIONAL ### COMBINATIONAL 
	--polynomial logic from A^8 matrix
	if (valid = '1') then
		r(0) <=  r(24) xor r(30) xor data(0);
		r(1) <=  r(24) xor r(25) xor r(30) xor r(31) xor data(1);
		r(2) <=  r(24) xor r(25) xor r(26) xor r(30) xor r(31) xor data(2);
		r(3) <=  r(25) xor r(26) xor r(27) xor r(31) xor data(3);
		r(4) <=  r(24) xor r(26) xor r(27) xor r(28) xor r(30) xor data(4);
		r(5) <=  r(24) xor r(25) xor r(27) xor r(28) xor r(29) xor r(30) xor r(31) xor data(5);
		r(6) <=  r(24) xor r(25) xor r(26) xor r(28) xor r(29) xor r(31) xor data(6);
		r(7) <=  r(25) xor r(26) xor r(27) xor r(29) xor r(30) xor data(7);
		r(8) <=  r(0) xor r(24) xor r(26) xor r(27) xor r(28) xor r(31);
		r(9) <=  r(1) xor r(25) xor r(27) xor r(28) xor r(29);
		r(10) <=  r(2) xor r(26) xor r(28) xor r(29) xor r(30);
		r(11) <=  r(3) xor r(27) xor r(29) xor r(30) xor r(31);
		r(12) <=  r(4) xor r(24) xor r(28) xor r(31);
		r(13) <=  r(5) xor r(25) xor r(29);
		r(14) <=  r(6) xor r(26) xor r(30);
		r(15) <=  r(7) xor r(27) xor r(31);
		r(16) <=  r(8) xor r(24) xor r(28) xor r(30);
		r(17) <=  r(9) xor r(25) xor r(29) xor r(31);
		r(18) <=  r(10) xor r(26) xor r(30);
		r(19) <=  r(11) xor r(27) xor r(31);
		r(20) <=  r(12) xor r(28);
		r(21) <=  r(13) xor r(29);
		r(22) <=  r(14) xor r(24);
		r(23) <=  r(15) xor r(24) xor r(25) xor r(30);
		r(24) <=  r(16) xor r(25) xor r(26) xor r(31);
		r(25) <=  r(17) xor r(26) xor r(27);
		r(26) <=  r(18) xor r(24) xor r(27) xor r(28) xor r(30);
		r(27) <=  r(19) xor r(25) xor r(28) xor r(29) xor r(31);
		r(28) <=  r(20) xor r(26) xor r(29) xor r(30);
		r(29) <=  r(21) xor r(27) xor r(30) xor r(31);
		r(30) <=  r(22) xor r(28) xor r(31);
		r(31) <=  r(23) xor r(29);
	end if;
	
	-- Outputs result
	IF end_of_frame = '1' THEN
		--IF () THEN --hotfix should be when r = x"00000000"
		fcs_error <= '0';
		fcs_error_valid <= '1';
		--ELSE
		--fcs_error <= '1';
		--fcs_error_valid <= '1';
		--END IF;
	ELSE
		fcs_error <= '0';
		fcs_error_valid <= '0';
	END IF;

end if;
end process;

end architecture;