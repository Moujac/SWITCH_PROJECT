LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

package switch_pkg is

	type inputGate_metaIO is record
		data			: std_logic_vector(7 downto 0);
		data_valid		: std_logic;
		data_start		: std_logic;
		data_end		: std_logic;
		lenght			: std_logic_vector(11 downto 0);
		lenght_valid	: std_logic;
		macadr			: std_logic_vector(47 downto 0);
		macadr_valid	: std_logic;
		srcadr			: std_logic_vector(47 downto 0);
		srcadr_valid	: std_logic;
	end record;

end package;

package body switch_pkg is

end package body;