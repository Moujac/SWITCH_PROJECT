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

	type schedular_input is record
		req_b0 : std_logic;
		len_b0 : std_logic_vector(11 downto 0);
		req_b1 : std_logic;
		len_b1 : std_logic_vector(11 downto 0);
		req_b2 : std_logic;
		len_b2 : std_logic_vector(11 downto 0);
		req_b3 : std_logic;
		len_b3 : std_logic_vector(11 downto 0);
	end record;

	type schedular_output is record
		ack_b0 : std_logic;
		ack_b1 : std_logic;
		ack_b2 : std_logic;
		ack_b3 : std_logic;
	end record;

	type mac_input is record
		mac_src : std_logic_vector(47 downto 0);
		mac_dst : std_logic_vector(47 downto 0);
		req : std_logic;
	end record;

	type mac_output is record
		outt : std_logic_vector(2 downto 0);
		ack : std_logic;
	end record;

end package;

package body switch_pkg is

end package body;