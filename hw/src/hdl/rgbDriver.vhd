library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity rgbDriver is
	port(
		i_clk : in std_logic;
		i_data : in std_logic_vector(23 downto 0);
		o_out : out std_logic_vector(2 downto 0)
	);
end rgbDriver;

architecture Behavioral of rgbDriver is
	component pwm is
	port (
		i_clk : in std_logic;
		i_dutyCycle : in std_logic_vector(7 downto 0);
		o_pwm : out std_logic
	);
	end component pwm;
	----------------------------------------------------------------------------
    signal  clk			: std_logic;
	signal  wData		: std_logic_vector(23 downto 0):=(others=> '0');
	signal  wout		: std_logic_vector(2 downto 0):=(others=> '0');
	----------------------------------------------------------------------------
	
begin
	----------------------------------------------------------------------------
	-- 
	----------------------------------------------------------------------------
	red: component pwm
	port map (
		i_clk => clk,
		i_dutyCycle => wData(7 downto 0),
		o_pwm => wout(0)
	);
	
	green: component pwm
	port map (
		i_clk => clk,
		i_dutyCycle => wData(15 downto 8),
		o_pwm => wout(1)
	);
	
	blue: component pwm
	port map (
		i_clk => clk,
		i_dutyCycle => wData(23 downto 16),
		o_pwm => wout(2)
	);
	----------------------------------------------------------------------------
	clk <= i_clk;
	wData <= i_data;
	o_out <= wout;
	----------------------------------------------------------------------------
	
end Behavioral;
