library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dbgBlink is
	port(
		i_clk	: in std_logic;
		o_blink	: out std_logic
	);
end dbgBlink;

architecture Behavioral of dbgBlink is
	component pwm is
		port (
			i_clk : in std_logic;
			i_dutyCycle : in std_logic_vector(7 downto 0);
			o_pwm : out std_logic
		);
	end component pwm;
	----------------------------------------------------------------------------
	signal  clk				: std_logic:= '0';
	constant blinkCntMAX	: integer:= 31250000;
	signal	blinkCnt		: integer range 0 to 125000000:=0;
	signal 	blinkDuty		: std_logic_vector(7 downto 0):=(others => '0');
	signal	blinkPWM		: std_logic;
	----------------------------------------------------------------------------
begin

blink: component pwm
	port map (
		i_clk => clk,
		i_dutyCycle => blinkDuty,
		o_pwm => blinkPWM
	);
	
	clk <= i_clk;
	o_blink <= blinkPWM;
	----------------------------------------------------------------------------
	-- blink PL LED to indicate firmware status.
	----------------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if blinkCnt < blinkCntMAX - 1 then
				blinkCnt <= blinkCnt + 1;
			else
				if blinkDuty = "00000000" then
					blinkDuty <= "00001010";
				elsif blinkDuty = "00001010" then
					blinkDuty <= "00000000";
				end if;
				blinkCnt <= 0;
			end if;
		end if;
	end process;
	--------------------------------------------------------------------------

end Behavioral;
