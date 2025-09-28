library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pmod8LD is
	port(
		i_clk : in std_logic;
		i_ch1 : in std_logic_vector(31 downto 0);
		i_ch2 : in std_logic_vector(31 downto 0);
		o_out : out std_logic_vector(7 downto 0)
	);
end pmod8LD;

architecture Behavioral of pmod8LD is
	component pwm is
	port (
		i_clk : in std_logic;
		i_dutyCycle : in std_logic_vector(7 downto 0);
		o_pwm : out std_logic
	);
	end component pwm;
	----------------------------------------------------------------------------
    signal  clk			: std_logic;
	signal  wCH1		: std_logic_vector(31 downto 0):=(others=> '0');
	signal  wCH2		: std_logic_vector(31 downto 0):=(others=> '0');
	signal  wout		: std_logic_vector(7 downto 0):=(others=> '0');
	----------------------------------------------------------------------------
	
begin

	----------------------------------------------------------------------------
	-- 
	----------------------------------------------------------------------------
	LD1: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH1(7 downto 0),
			o_pwm => wout(0)
		);
		
	LD2: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH1(15 downto 8),
			o_pwm => wout(1)
		);
	
	LD3: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH1(23 downto 16),
			o_pwm => wout(2)
		);
	
	LD4: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH1(31 downto 24),
			o_pwm => wout(3)
		);
	----------------------------------------------------------------------------
	LD5: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH2(7 downto 0),
			o_pwm => wout(4)
		);
		
	LD6: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH2(15 downto 8),
			o_pwm => wout(5)
		);
	
	LD7: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH2(23 downto 16),
			o_pwm => wout(6)
		);
	
	LD8: component pwm
		port map (
			i_clk => clk,
			i_dutyCycle => wCH2(31 downto 24),
			o_pwm => wout(7)
		);
	----------------------------------------------------------------------------
	clk <= i_clk;
	wCH1 <= i_ch1;
	wCH2 <= i_ch2;
	o_out <= wout;
	----------------------------------------------------------------------------

end Behavioral;
