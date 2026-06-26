----------------------------------------------------------------------------------
-- Company: ENSIL-ENSCI
-- Engineer: Vahid Meghdadi
-- https://github.com/amc18/VHDL-TestingTool/blob/master/Int_Pmod_DA2.vhd
-- Create Date:    11:08:28 10/01/2019 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This interface is used to control PMOD DA2
-- The signals CS, D1, D2 and SCLK are the outputs that go directly to PMOD
-- The user should put the two 12-bit data on the line data1 and data2 and
-- then give a strobe signal on strb
-- the SCLK frequency is 100MHz/8 = 12.5 MHz, it means that the writing
-- operation takes about 1/12.5MHz*18 = 1.44 Micro sec
-- therefore the sampling frequency should be less than 690 kHz.
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Int_Pmod_DA2 is
    Port ( CLK : in  STD_LOGIC;
           CS : out  STD_LOGIC;
		   D1 : out std_logic;
		   D2 : out std_logic;
           SCLK : out  STD_LOGIC;
           IDLEX : out STD_LOGIC;
           DATA1 : in  STD_LOGIC_VECTOR (11 downto 0);
           DATA2 : in  STD_LOGIC_VECTOR (11 downto 0);
		   STRB : IN STD_LOGIC);
end Int_Pmod_DA2;

architecture Behavioral of Int_Pmod_DA2 is

	type t_state is (idle, count);
	signal counter_state : t_state := idle;
	signal	reg1, reg2 : STD_LOGIC_VECTOR (15 downto 0);
	signal cnt : std_logic_vector(7 downto 0);

begin

	process(clk)
	begin
		if clk'event and clk='1' then
			case counter_state is
			when idle =>
				cnt <= "10001000";
				idlex <= '1';
				if STRB = '1' then
					reg1 <= "0000" & DATA1;
					reg2 <= "0000" & DATA2;
					counter_state <= count;
					idlex <= '0';
				end if;
			when count =>
				cnt <= cnt - 2;
				if cnt = "00000000" then
					counter_state <= idle;
				end if;
			when others =>
				counter_state <= idle;
				idlex <= '1';
			end case;				
		end if;
	end process;
	
	SCLK <= cnt(2);
	D1 <= reg1(conv_integer (cnt(6 downto 3)));
	D2 <= reg2(conv_integer(cnt(6 downto 3)));
	CS <= '1' when cnt(7 downto 2)="100000" else '0';
	
end Behavioral;