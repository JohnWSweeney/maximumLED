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
		jcCH1_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jcCH2_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jdCH1_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jdCH2_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jeCH1_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		jeCH2_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
		FCLK0_RESETn : out STD_LOGIC;
		FCLK0 : out STD_LOGIC
		);
	end component bdMaxLED;
	----------------------------------------------------------------------------
	component dbgBlink is
	port (
		i_clk : in std_logic;
		o_led : out std_logic
	);
	end component dbgBlink;
	----------------------------------------------------------------------------
	component rgbDriver is
	port (
		i_clk : in std_logic;
		i_rgbDutyCycle : in std_logic_vector(23 downto 0);
		o_rgb : out std_logic_vector(2 downto 0)
	);
	end component rgbDriver;
	----------------------------------------------------------------------------
	component pmod8LD is
	port (
		i_clk : in std_logic;
		i_ch1 : in std_logic_vector(31 downto 0);
		i_ch2 : in std_logic_vector(31 downto 0);
		o_out : out std_logic_vector(7 downto 0)
	);
	end component pmod8LD;
	----------------------------------------------------------------------------
    signal	plClk			: std_logic; -- 125MHz sysclk.
    signal  psClk			: std_logic; -- 125MHz PS clk.
    signal  psRSTn			: std_logic;
	signal	plBlink			: std_logic;
	signal	psBlink			: std_logic;
	----------------------------------------------------------------------------
	-- PS signals
	----------------------------------------------------------------------------
    signal  psRGB5          : std_logic_vector(31 downto 0);
    signal  psRGB6          : std_logic_vector(31 downto 0);
    signal  psJBCH1			: std_logic_vector(31 downto 0);
    signal  psJBCH2			: std_logic_vector(31 downto 0);
	signal  psJCCH1			: std_logic_vector(31 downto 0);
    signal  psJCCH2			: std_logic_vector(31 downto 0);
	signal  psJDCH1			: std_logic_vector(31 downto 0);
    signal  psJDCH2			: std_logic_vector(31 downto 0);
	signal  psJECH1			: std_logic_vector(31 downto 0);
    signal  psJECH2			: std_logic_vector(31 downto 0);
	----------------------------------------------------------------------------
	-- PS signal registers
	----------------------------------------------------------------------------
    signal  regRGB5			: std_logic_vector(31 downto 0);
    signal  regRGB6			: std_logic_vector(31 downto 0);
    signal  regJBCH1		: std_logic_vector(31 downto 0);
    signal  regJBCH2		: std_logic_vector(31 downto 0);
	signal  regJCCH1		: std_logic_vector(31 downto 0);
    signal  regJCCH2		: std_logic_vector(31 downto 0);
	signal  regJDCH1		: std_logic_vector(31 downto 0);
    signal  regJDCH2		: std_logic_vector(31 downto 0);
	signal  regJECH1		: std_logic_vector(31 downto 0);
    signal  regJECH2		: std_logic_vector(31 downto 0);
	----------------------------------------------------------------------------
	-- PL signals
	----------------------------------------------------------------------------
	signal  wLED	   		: std_logic_vector(3 downto 0);
	signal	wRGB5			: std_logic_vector(2 downto 0);
	signal	wRGB6			: std_logic_vector(2 downto 0);
	signal  wJb				: std_logic_vector(7 downto 0);
	signal  wJc				: std_logic_vector(7 downto 0);
	signal  wJd				: std_logic_vector(7 downto 0);
	signal  wJe				: std_logic_vector(7 downto 0);
	----------------------------------------------------------------------------
    
begin
	psBdMaxLED: component bdMaxLED
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
		jcCH1_tri_o(31 downto 0) => psJCCH1,
		jcCH2_tri_o(31 downto 0) => psJCCH2,
		jdCH1_tri_o(31 downto 0) => psJDCH1,
		jdCH2_tri_o(31 downto 0) => psJDCH2,
		jeCH1_tri_o(31 downto 0) => psJECH1,
		jeCH2_tri_o(31 downto 0) => psJECH2,
		FCLK0_RESETn => psRSTn,
		FCLK0 => psClk
	);
	----------------------------------------------------------------------------
	plCheck: component dbgBlink
	port map (
		i_clk => plClk,
		o_led => plBlink
	);
		
	psCheck: component dbgBlink
	port map (
		i_clk => psClk,
		o_led => psBlink
	);
	----------------------------------------------------------------------------
	plRGB5: component rgbDriver
	port map (
		i_clk => psClk,
		i_rgbDutyCycle => regRGB5(23 downto 0),
		o_rgb => wRGB5
	);
	
	plRGB6: component rgbDriver
	port map (
		i_clk => psClk,
		i_rgbDutyCycle => regRGB6(23 downto 0),
		o_rgb => wRGB6
	);
	----------------------------------------------------------------------------
	jb8LD: component pmod8LD
	port map (
		i_clk => psClk,
		i_ch1 => regJBCH1,
		i_ch2 => regJBCH2,
		o_out => wJb
	);

	jc8LD: component pmod8LD
	port map (
		i_clk => psClk,
		i_ch1 => regJCCH1,
		i_ch2 => regJCCH2,
		o_out => wJc
	);
	
	jd8LD: component pmod8LD
	port map (
		i_clk => psClk,
		i_ch1 => regJDCH1,
		i_ch2 => regJDCH2,
		o_out => wJd
	);
	
	je8LD: component pmod8LD
	port map (
		i_clk => psClk,
		i_ch1 => regJECH1,
		i_ch2 => regJECH2,
		o_out => wJe
	);
	----------------------------------------------------------------------------
	plClk <= sysclk;
	----------------------------------------------------------------------------
	wLED(1) <= psBlink;
	wLED(0) <= plBlink;
	----------------------------------------------------------------------------
	led <= wLED;
	rgb5 <= wRGB5;
	rgb6 <= wRGB6;
	jb <= wJb;
	jc <= wJc;
	jd <= wJd;
	je <= wJe;
	----------------------------------------------------------------------------
	-- register/reset AXI GPIO data.
	----------------------------------------------------------------------------
	process(psClk)
	begin
		if rising_edge(psClk) then
			if psRSTn = '0' then
				regRGB5 <= (others => '0');
				regRGB6 <= (others => '0');				
				regJBCH1 <= (others => '0');
				regJBCH2 <= (others => '0');
				regJCCH1 <= (others => '0');
				regJCCH2 <= (others => '0');				
				regJDCH1 <= (others => '0');
				regJDCH2 <= (others => '0');
				regJECH1 <= (others => '0');
				regJECH2 <= (others => '0');
			else
				regRGB5 <= psRGB5;
				regRGB6 <= psRGB6;				
				regJBCH1 <= psJBCH1;
				regJBCH2 <= psJBCH2;
				regJCCH1 <= psJCCH1;
				regJCCH2 <= psJCCH2;				
				regJDCH1 <= psJDCH1;
				regJDCH2 <= psJDCH2;
				regJECH1 <= psJECH1;
				regJECH2 <= psJECH2;
			end if;
		end if;
	end process;
	----------------------------------------------------------------------------

end Behavioral;
