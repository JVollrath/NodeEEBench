----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.10.2022 20:42:00
-- Design Name: 
-- Module Name: tb_EEBench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
library work;
use work.txt_util.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_EEBench is
--  Port ( );
end tb_EEBench;

architecture Behavioral of tb_EEBench is

COMPONENT EEBench
    Port ( SW 			: in  STD_LOGIC_VECTOR (15 downto 0);  -- 16 switches
           BTN 			: in  STD_LOGIC_VECTOR (4 downto 0);   -- 5 Buttons
           CLK			: in  STD_LOGIC;
           vn_in		: in  STD_LOGIC;
           vp_in		: in  STD_LOGIC;
           RX		    : in  STD_LOGIC;                       -- UART RX
           TX    		: out  STD_LOGIC;                      -- UART TX
           LED 			: out  STD_LOGIC_VECTOR (15 downto 0); -- 16 LEDs next to switches 
           JXA 			: in   STD_LOGIC_VECTOR (7 downto 0);  -- Analog Diff Inputs
           JA 			: inout  STD_LOGIC_VECTOR (7 downto 0);  -- PMOD lower 8bit DAC
           JB 			: out  STD_LOGIC_VECTOR (7 downto 0);  -- PMOD lower 8bit DAC
           JC 			: inout  STD_LOGIC_VECTOR (7 downto 0);  -- PMOD upper 8bit DAC
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);  -- 7 segment + dp
           SSEG_AN 		: out  STD_LOGIC_VECTOR (3 downto 0)   -- 4 digits 
			  );
end COMPONENT;

-- outputs
signal     TX    		: STD_LOGIC;                      -- UART TX
signal     LED 			: STD_LOGIC_VECTOR (15 downto 0); -- 16 LEDs next to switches 
signal     JA 			: STD_LOGIC_VECTOR (7 downto 0);  -- PMOD lower 8bit DAC
signal     JB 			: STD_LOGIC_VECTOR (7 downto 0);  -- PMOD lower 8bit DAC
signal     JC 			: STD_LOGIC_VECTOR (7 downto 0);  -- PMOD upper 8bit DAC
signal     SSEG_CA 		: STD_LOGIC_VECTOR (7 downto 0);  -- 7 segment + dp
signal     SSEG_AN 		: STD_LOGIC_VECTOR (3 downto 0);   -- 4 digits 
-- inputs
signal SW 			: STD_LOGIC_VECTOR (15 downto 0);  -- 16 switches
signal BTN 			: STD_LOGIC_VECTOR (4 downto 0);   -- 5 Buttons
signal  CLK			: STD_LOGIC;
signal     vn_in		: STD_LOGIC;
signal     vp_in		: STD_LOGIC;
signal     RX		    : STD_LOGIC;                       -- UART RX
signal     JXA 			: STD_LOGIC_VECTOR (7 downto 0);  -- Analog Diff Inputs
signal     SEND 		: STD_LOGIC_VECTOR (7 downto 0);  -- Analog Diff Inputs

-- data logging output
signal export_cnt: integer :=-2;
signal export_dac: integer := 0;
signal export_adc: integer := 0;
signal mysine0 		: STD_LOGIC_VECTOR (15 downto 0);  -- Analog Diff Inputs
constant div : real := 8.0;
constant cycleB: real := 13.0 * 64;
constant cycle: real := 13.0;

constant CLK_period : time := 10 ns;
-- constant baud : time := 52 us;   -- 1/19200
constant baud : time := 4340 ns;   -- 1/230400

begin

my_dut: EEBench
    Port map ( SW => SW,  -- 16 switches
           BTN => BTN,   -- 5 Buttons
           CLK => CLK,
           vn_in => vn_in,
           vp_in => vp_in,
           RX	=> RX,      -- UART RX
           TX   => TX,                     -- UART TX
           LED 	=> LED, -- 16 LEDs next to switches 
           JXA 	=> JXA,  -- Analog Diff Inputs
           JA 	=> JA,  -- Debugging signal
           JB 	=> JB,  -- PMOD lower 8bit DAC
           JC 	=> JC,  -- PMOD upper 8bit DAC
           SSEG_CA => SSEG_CA,  -- 7 segment + dp
           SSEG_AN => SSEG_AN   -- 4 digits 
			  );


CLK_gen : process
begin
CLK <= '1';
wait for CLK_PERIOD / 2;
CLK <= '0';
wait for CLK_PERIOD / 2;
end process CLK_gen;

mysine0 <= JC&JB;

Export : process(clk,mysine0)
variable line_v0 : line;
variable line_v1 : line;
file out_file0 : text open write_mode is "mysine0_everysteps_out.txt";
file out_file1 : text open write_mode is "mysine0_out.txt";

begin
if (clk'event and (clk='1')) then
    export_cnt <= export_cnt + 1;
    if ((export_cnt rem integer(cycleB)) = 0) then   -- 832 cycles sampling ADC
       export_adc <= export_adc + 1;
       write(line_v1,"x"&hstr(mysine0));
       writeline(out_file1, line_v1);
    end if;
    if ((export_cnt rem integer(cycle)) = 0) then   -- 13 cycles update DAC
        export_dac <= export_dac + 1;
        write(line_v0,"x"&hstr(mysine0));
        writeline(out_file0, line_v0);
    end if;
end if;
end process Export;


simulation : process
-- simulate for 30 ms
begin		

SW <= (others=>'0');
BTN <= (others=>'0');
wait for 50 ns;
SW <= "0000101000110110";

-- Total simulation time:
-- 200ns   Reset
-- 520us   10*baud send "V" sw at output
-- 520us   10*baud send "0"
-- 10920us 21*10*baud send Triangle T1234CDEF000100012300
-- 12600us 25*10*baud Sine S002200004000000020000000
-- 2000us  wait
-- 520us   10*baud send "U" start data transfer some U values
-- 520us   10*baud send "0"
-- 12600us 25*10*baud Sine S000220004000000020000000
-- 12600us 25*10*baud Sine S000220004000000020000000

-- Reset
RX <= '1';
BTN(4) <= '1';
wait for 200 ns;
BTN(4) <= '0';

SEND <= "01010110";  -- V 56 show sw at output
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- send O command for block size and sampling
-----------------------------------------------
SEND <= "01001111";  -- O 4F show sw at output
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 
-- block size
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 
--- sampling

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 


-- Triangle  Sta Sto StepRepeat..	
-- Triangle T1234CDEF000100012300
-- S=53 0..9 30..9 A..F 41..6

SEND <= "01010100";  -- T x54
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110001";  -- 1
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110011";  -- 3
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110100";  -- 4
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000011";  -- C
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000100";  -- D
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000101";  -- E
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000110";  -- F
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110001";  -- 1
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0 Repeat start
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 
-- Repeat
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110001";  -- 1
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110011";  -- 3
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

--       step....AmplitudOffset..
-- Sine S002200002000000020000000
-- S=53 0..9 30..9 A..F 41..6
--     step <=  x"00220000";
-- amplitude <= x"40000000";
--   offset <= x"20000000";
-- 512 FFT values in range of 400000000..000000000 with 17 periods 50kHz 20us per period
         
SEND <= "01010011";  -- S 53
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

--step
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- amplitude
SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- offset
SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- Extra
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

wait for 2 ms;

--       step....AmplitudOffset..
-- Sine S000220004000000020000000
-- S=53 0..9 30..9 A..F 41..6
--     step <=  x"00022000";
-- amplitude <= x"40000000";
--   offset <= x"20000000";
-- 128k? FFT values in range of 400000000..000000000 with 17 periods
         
SEND <= "01010011";  -- S 53
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

--step
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110010";  -- 2
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- amplitude
SEND <= "00110100";  -- 4
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- offset
SEND <= "00110100";  -- 4
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

wait for 8 ms;

SEND <= "01010101";  -- U send data lok at TX uart.mem: tx_enable tx_on tx_done_tick
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

wait for 2 ms;

--       step....AmplitudOffset..  1.40851 kHz signal
-- Sine S000220004000000020000000
-- S=53 0..9 30..9 A..F 41..6
--     step <=  x"00022000";
-- amplitude <= x"40000000";
--   offset <= x"20000000";
-- 128k? FFT values in range of 400000000..000000000 with 17 periods
         
SEND <= "01010011";  -- S 53
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

--step
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110011";  -- 3
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0   
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- amplitude
SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000110";  -- F
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00111000";  -- 8
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110011";  -- 3
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000101";  -- E
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110000";  -- 0
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000110";  -- F
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00111000";  -- 8
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

-- offset
SEND <= "00110001";  -- 1
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110011";  -- 3
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110110";  -- 6
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110100";  -- 4
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "01000100";  -- D
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00111001";  -- 9
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110011";  -- 3
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

SEND <= "00110110";  -- 6
RX<='0'; wait for baud; RX <= SEND(0);wait for baud; RX <= SEND(1);wait for baud; RX <= SEND(2);wait for baud; RX <= SEND(3); wait for baud; 
RX <= SEND(4);wait for baud; RX <= SEND(5);wait for baud; RX <= SEND(6);wait for baud; RX <= SEND(7); wait for baud; RX <= '1';wait for baud; 

wait for 10 ms;

wait;
end process simulation;


end Behavioral;
