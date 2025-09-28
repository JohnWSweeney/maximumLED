library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm is
	port(
		i_clk : in std_logic;
		i_dutyCycle : in std_logic_vector(7 downto 0);
		o_pwm : out std_logic
	);
end pwm;

architecture Behavioral of pwm is
	signal  clk         : std_logic;
	signal	state		: integer range 0 to 1:= 0;
	signal	en			: std_logic;
	signal	period		: integer range 0 to 125000:= 0;
	signal	periodMAX	: integer:= 125000;
	signal	pulseWidth	: integer range 0 to 125000:= 0;
	signal	dutyCycle	: integer range 0 to 100:= 0;
	signal	prevDuty	: integer range 0 to 100:= 0;
	signal	pwm			: std_logic;

begin
	----------------------------------------------------------------------------
	clk <= i_clk;
	dutyCycle <= to_integer(unsigned(i_dutyCycle));
	o_pwm <= pwm;
	----------------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if dutyCycle /= prevDuty then
				----------------------------------------------------------------
				-- enable PWM, calc pulsewidth at turn on. Else, turn off.
				----------------------------------------------------------------
				if dutyCycle > 0 then
					en <= '1';
					pulseWidth <= periodMAX * dutyCycle / 100;
				elsif dutyCycle = 0 then
					en <= '0';
				end if;			
				----------------------------------------------------------------
			end if;
			--------------------------------------------------------------------
			-- save current dutyCycle for next time.
			--------------------------------------------------------------------
			prevDuty <= dutyCycle;
			--------------------------------------------------------------------
		end if;
	end process;
	----------------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			case state is
				----------------------------------------------------------------
				when 0 =>
					if en = '1' then
						state <= 1;
					end if;
					period <= 0;
					pwm <= '0';
				----------------------------------------------------------------
				when 1 =>
					------------------------------------------------------------
					-- continuously cycle period.
					------------------------------------------------------------
					if period < periodMAX - 1 then
						period <= period + 1;
					else
						period <= 0;
					end if;
					------------------------------------------------------------
					-- pulse high for the pulsewidth duration, low remainder.
					------------------------------------------------------------
					if period < pulseWidth - 1 then
						pwm <= '1';
					else
						pwm <= '0';
					------------------------------------------------------------
					end if;
					------------------------------------------------------------
					-- reset state machine when PWM disabled.
					------------------------------------------------------------
					if en = '0' then						
						state <= 0;
					end if;
				----------------------------------------------------------------	
			end case;			
		end if;
	end process;
	
end Behavioral;
