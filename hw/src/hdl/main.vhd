library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
	port(
		sysclk	: in std_logic;
		rgb5	: out std_logic_vector(2 downto 0);
		rgb6	: out std_logic_vector(2 downto 0);
		led		: out std_logic_vector(3 downto 0);
		jb		: out std_logic_vector(7 downto 0);
		jc		: out std_logic_vector(7 downto 0);
		jd		: out std_logic_vector(7 downto 0);
		je		: out std_logic_vector(7 downto 0);
		------------------------------------------------------------------------
		DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_cas_n : inout STD_LOGIC;
		DDR_ck_n : inout STD_LOGIC;
		DDR_ck_p : inout STD_LOGIC;
		DDR_cke : inout STD_LOGIC;
		DDR_cs_n : inout STD_LOGIC;
		DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_odt : inout STD_LOGIC;
		DDR_ras_n : inout STD_LOGIC;
		DDR_reset_n : inout STD_LOGIC;
		DDR_we_n : inout STD_LOGIC;
		FIXED_IO_ddr_vrn : inout STD_LOGIC;
		FIXED_IO_ddr_vrp : inout STD_LOGIC;
		FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ps_clk : inout STD_LOGIC;
		FIXED_IO_ps_porb : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC
	);
end main;

architecture Behavioral of main is
	component bdMaxLED is
	port (
		DDR_cas_n : inout STD_LOGIC;
		DDR_cke : inout STD_LOGIC;
		DDR_ck_n : inout STD_LOGIC;
		DDR_ck_p : inout STD_LOGIC;
		DDR_cs_n : inout STD_LOGIC;
		DDR_reset_n : inout STD_LOGIC;
		DDR_odt : inout STD_LOGIC;
		DDR_ras_n : inout STD_LOGIC;
		DDR_we_n : inout STD_LOGIC;
		DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ddr_vrn : inout STD_LOGIC;
		FIXED_IO_ddr_vrp : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC;
		FIXED_IO_ps_clk : inout STD_LOGIC;
		FIXED_IO_ps_porb : inout STD_LOGIC;
		RGB5_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		RGB6_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jbCH1_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jbCH2_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		FCLK0 : out STD_LOGIC
		);
	end component bdMaxLED;
	----------------------------------------------------------------------------
	component dbgBlink is
	port (
		i_clk : in std_logic;
		o_blink : out std_logic
	);
	end component dbgBlink;
	----------------------------------------------------------------------------
	component pwm is
	port (
		i_clk : in std_logic;
		i_dutyCycle : in std_logic_vector(7 downto 0);
		o_pwm : out std_logic
	);
	end component pwm;
	----------------------------------------------------------------------------
    signal  clkPl			: std_logic;
    signal  clkPs			: std_logic;
	signal	plBlink			: std_logic;
	signal	psBlink			: std_logic;
    signal  gpioLED   		: std_logic_vector(3 downto 0):=(others=> '0');
	----------------------------------------------------------------------------
	-- Ps signals
	----------------------------------------------------------------------------
    signal  psRGB5          : std_logic_vector(31 downto 0):=(others=> '0');
    signal  psRGB6          : std_logic_vector(31 downto 0):=(others=> '0');
    signal  psJBCH1			: std_logic_vector(31 downto 0):=(others=> '0');
    signal  psJBCH2			: std_logic_vector(31 downto 0):=(others=> '0');
	----------------------------------------------------------------------------
	signal	wRGB5r			: std_logic:= '0';
	signal	wRGB5g			: std_logic:= '0';
	signal	wRGB5b			: std_logic:= '0';
	signal	wRGB6r			: std_logic:= '0';
	signal	wRGB6g			: std_logic:= '0';
	signal	wRGB6b			: std_logic:= '0';
	----------------------------------------------------------------------------
	-- Pmod connector signals
	----------------------------------------------------------------------------
	signal  wJb				: std_logic_vector(7 downto 0):=(others=> '0');
	signal  wJc				: std_logic_vector(7 downto 0):=(others=> '0');
	signal  wJd				: std_logic_vector(7 downto 0):=(others=> '0');
	signal  wJe				: std_logic_vector(7 downto 0):=(others=> '0');
	----------------------------------------------------------------------------
    
begin
newbdMaxLED: component bdMaxLED
	port map (
		DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
		DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
		DDR_cas_n => DDR_cas_n,
		DDR_ck_n => DDR_ck_n,
		DDR_ck_p => DDR_ck_p,
		DDR_cke => DDR_cke,
		DDR_cs_n => DDR_cs_n,
		DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
		DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
		DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
		DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
		DDR_odt => DDR_odt,
		DDR_ras_n => DDR_ras_n,
		DDR_reset_n => DDR_reset_n,
		DDR_we_n => DDR_we_n,
		FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
		FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
		FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
		FIXED_IO_ps_clk => FIXED_IO_ps_clk,
		FIXED_IO_ps_porb => FIXED_IO_ps_porb,
		FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
		RGB5_tri_o(31 downto 0) => psRGB5,
		RGB6_tri_o(31 downto 0) => psRGB6,
		jbCH1_tri_o(31 downto 0) => psJBCH1,
		jbCH2_tri_o(31 downto 0) => psJBCH2,
		FCLK0 => clkPs
	);
	----------------------------------------------------------------------------
	plCheck: component dbgBlink
		port map (
			i_clk => clkPl,
			o_blink => plBlink
		);
		
	psCheck: component dbgBlink
		port map (
			i_clk => clkPs,
			o_blink => psBlink
		);
	----------------------------------------------------------------------------
	red5_i: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psRGB5(7 downto 0),
			o_pwm => wRGB5r
		);

	green5_i: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psRGB5(15 downto 8),
			o_pwm => wRGB5g
		);

	blue5_i: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psRGB5(23 downto 16),
			o_pwm =>wRGB5b
		);
	----------------------------------------------------------------------------
	red6_i: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psRGB6(7 downto 0),
			o_pwm => wRGB6r
		);

	green6_i: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psRGB6(15 downto 8),
			o_pwm => wRGB6g
		);

	blue6_i: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psRGB6(23 downto 16),
			o_pwm => wRGB6b
		);
	----------------------------------------------------------------------------
	-- 
	----------------------------------------------------------------------------
	jb8LD1: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH1(7 downto 0),
			o_pwm => wJb(0)
		);
		
	jb8LD2: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH1(15 downto 8),
			o_pwm => wJb(1)
		);
	
	jb8LD3: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH1(23 downto 16),
			o_pwm => wJb(2)
		);
	
	jb8LD4: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH1(31 downto 24),
			o_pwm => wJb(3)
		);
	----------------------------------------------------------------------------
	jb8LD5: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH2(7 downto 0),
			o_pwm => wJb(4)
		);
		
	jb8LD6: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH2(15 downto 8),
			o_pwm => wJb(5)
		);
	
	jb8LD7: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH2(23 downto 16),
			o_pwm => wJb(6)
		);
	
	jb8LD8: component pwm
		port map (
			i_clk => clkPs,
			i_dutyCycle => psJBCH2(31 downto 24),
			o_pwm => wJb(7)
		);
	----------------------------------------------------------------------------
	clkPl <= sysclk;

	rgb5(0) <= wRGB5r;
	rgb5(1) <= wRGB5g;
	rgb5(2) <= wRGB5b;
	rgb6(0) <= wRGB6r;
	rgb6(1) <= wRGB6g;
	rgb6(2) <= wRGB6b;
	
	led <= gpioLED;
	gpioLED(1) <= psBlink;
	gpioLED(0) <= plBlink;
	----------------------------------------------------------------------------
	jb <= wJb;
	jc <= wJc;
	jd <= wJd;
	je <= wJe;
	----------------------------------------------------------------------------

end Behavioral;
