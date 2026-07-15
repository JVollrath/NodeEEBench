----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.07.2026 08:38:08
-- Design Name: 
-- Module Name: EEBenchCA7 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EEBenchCA7 is
    Port ( --- .xdc names are case sensitive!!
           CLK			: in  STD_LOGIC;
           vn_in		: in  STD_LOGIC;
           vp_in		: in  STD_LOGIC;

           LED		    : out  STD_LOGIC_VECTOR (1 downto 0);    -- 

           RGB0_Red		: out  STD_LOGIC;
           RGB0_Green   : out  STD_LOGIC;
           RGB0_Blue    : out  STD_LOGIC;

           BTN		    : in  STD_LOGIC_VECTOR (1 downto 0);    -- 

           SW_0        : in STD_LOGIC;

           CS_1		        : inout  STD_LOGIC;    -- PMOD DA2 
           D1		        : inout  STD_LOGIC;    -- 
           D2		        : inout  STD_LOGIC;    -- 
           CLK_1		    : inout  STD_LOGIC;    -- 

           RDY		        : inout  STD_LOGIC;    -- MCP4728
           LDAC		        : inout  STD_LOGIC;    -- 
           SDA_0		    : inout  STD_LOGIC;    -- 
           SCL_0		    : inout  STD_LOGIC;    -- 

           SCL_1		    : inout  STD_LOGIC;    -- PMOD AD2
           SDA_1		    : inout  STD_LOGIC;    -- 

           JB		    : inout  STD_LOGIC_VECTOR (7 downto 0);    -- PMOD
           JA		    : out  STD_LOGIC_VECTOR (3 downto 0);    -- PMOD

           ain_p1      : in STD_LOGIC;             -- XADC
           ain_n1      : in STD_LOGIC;
           ain_p2      : in STD_LOGIC;             -- XADC
           ain_n2      : in STD_LOGIC;
           ain_p3      : in STD_LOGIC;             -- XADC
           ain_n3      : in STD_LOGIC;
           ain_p4      : in STD_LOGIC;             -- XADC
           ain_n4      : in STD_LOGIC;
           
           -- PIOA		    : in  STD_LOGIC_VECTOR (23 downto 1);    -- 
           -- PIOB	        : out  STD_LOGIC_VECTOR (48 downto 24);    -- 

           UART_TXD 	: out  STD_LOGIC; -- J18 out transmit 
           UART_RXD 	: in  STD_LOGIC; -- J17 in receive
           TX_0 	    : out  STD_LOGIC; -- J18 out transmit 
           RX_0 	    : out  STD_LOGIC -- J17 in receive
           
           -- QSPI_CS : out STD_LOGIC;
           -- QSPI_DQ : inout STD_LOGIC_VECTOR(3 downto 0); -- MOSI(0) DIN(1)
           -- MEMADR : out STD_LOGIC_VECTOR (18 downto 0);
           -- MemDB : inout STD_LOGIC_VECTOR (7 downto 0);
           -- RAMOEN : out STD_LOGIC;
           -- RAMWEN : out STD_LOGIC;
           -- RAMCEN : out STD_LOGIC;
           
			  );
end EEBenchCA7;

architecture Behavioral of EEBenchCA7 is

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
           JB 			: out  STD_LOGIC_VECTOR (7 downto 0);    -- PMOD upper 8bit DAC
           JC 			: inout  STD_LOGIC_VECTOR (7 downto 0);  -- PMOD DA2, MCP4728 DAC
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);  -- 7 segment + dp
           SSEG_AN 		: out  STD_LOGIC_VECTOR (3 downto 0)   -- 4 digits 
			  );
end COMPONENT;

COMPONENT clk_wiz_0
    Port ( clk_out1: out  STD_LOGIC;  -- 
           reset: in STD_LOGIC;
           locked: out STD_LOGIC;
           clk_in1: in STD_LOGIC
			  );
end COMPONENT;

-- outputs
signal     TX    		: STD_LOGIC;                      -- UART TX
signal     LEDx 			: STD_LOGIC_VECTOR (15 downto 0); -- 16 LEDs next to switches 
signal     JAx 			: STD_LOGIC_VECTOR (7 downto 0);  -- PMOD lower 8bit DAC
signal     JCx 			: STD_LOGIC_VECTOR (7 downto 0);  -- PMOD upper 8bit DAC
signal     SSEG_CA 		: STD_LOGIC_VECTOR (7 downto 0);  -- 7 segment + dp
signal     SSEG_AN 		: STD_LOGIC_VECTOR (3 downto 0);   -- 4 digits 
-- inputs
signal     SW 			: STD_LOGIC_VECTOR (15 downto 0);  -- 16 switches
signal     BTNx 			: STD_LOGIC_VECTOR (4 downto 0);   -- 5 Buttons
signal     CLKx			: STD_LOGIC;
--signal     vn_in		: STD_LOGIC;
--signal     vp_in		: STD_LOGIC;
signal     RX		    : STD_LOGIC;                       -- UART RX
signal     JXA 			: STD_LOGIC_VECTOR (7 downto 0);  -- Analog Diff Inputs
signal     SEND 		: STD_LOGIC_VECTOR (7 downto 0);  -- Analog Diff Inputs

begin


my_dut: EEBench
    Port map ( SW => SW,  -- 16 switches
           BTN => BTNx,   -- 5 Buttons
           CLK => CLKx,
           vn_in => vn_in,
           vp_in => vp_in,
           RX	=> RX,      -- UART RX
           TX   => TX,                     -- UART TX
           LED 	=> LEDx, -- 16 LEDs next to switches 
           JXA 	=> JXA,  -- Analog Diff Inputs
           JA 	=> JAx,  -- Debugging signal
           JB 	=> JB,  -- PMOD upper 8bit DAC
           JC 	=> JCx,  -- PMOD DA2, MCP4728 DAC
           SSEG_CA => SSEG_CA,  -- 7 segment + dp
           SSEG_AN => SSEG_AN   -- 4 digits 
			  );

-- Clock wizard map CLK 12.5 MHz to 100MHz CLKx
clk_wiz_0_0: clk_wiz_0
  Port map (
          clk_out1 => CLKx,  -- 
          reset => '0',
          locked => LED(1), 
           clk_in1 => CLK
  );


RGB0_Red <= TX;
RGB0_Green <= UART_RXD;
RGB0_Blue <= BTN(0);

-- UART
UART_TXD <= TX;
TX_0 <= TX;
RX <= UART_RXD;
RX_0 <= UART_RXD;

--- BTN
BTNx(4) <= BTN(0);  --- reset signal
BTNx(1) <= BTN(1);

-- SW
SW(0) <= SW_0; -- ??

-- XADC mapping JXA from 
JXA(0) <= ain_p1; -- ain_p(1) pio(10)
JXA(1) <= ain_p2; -- ain_p(2) pioa(02)
JXA(2) <= ain_p3; -- ain_p(3) pioa(20)
JXA(3) <= ain_p4; -- ain_p(4) pioa(22)
JXA(4) <= ain_n1; -- ain_n(1) pio(4)
JXA(5) <= ain_n2; -- ain_n(2) pioa(01)
JXA(6) <= ain_n3; -- ain_n(3) pioa(17)
JXA(7) <= ain_n4; -- ain_n(4) pioa(21)

-- I2C MCP4278
SCL_0 <= JCx(3); --?
SDA_0 <= JCx(2); --?
LDAC <= JCx(1); --?
RDY <= JCx(0); --?

-- I2C PMOD AD2 BASYS3 JA3,4
SCL_1 <= JAx(2);  -- SCL  --?
SDA_1 <= JAx(3);  -- SDA  --?

JA(0) <= JAx(0);
JA(1) <= JAx(1);
JA(2) <= JAx(2);
JA(3) <= CLK;

-- SPI PMOD DA2
CLK_1 <= JCx(7); --?
D2 <= JCx(6); --?
D1 <= JCx(5); --?
CS_1 <= JCx(4); --?

-- Digital IO  JB 

-- Rest pio 
 
 
 
end Behavioral;
