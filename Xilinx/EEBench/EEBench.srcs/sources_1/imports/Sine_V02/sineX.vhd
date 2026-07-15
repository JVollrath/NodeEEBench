----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2022 10:42:40
-- Design Name: 
-- Module Name: sineX - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sineX is
   Port (
       CLK : in STD_LOGIC;
       RST: in STD_LOGIC;
       step: in STD_LOGIC_Vector(31 downto 0);   -- increment
       amplitude: in STD_LOGIC_Vector(31 downto 0);   -- signal amplitude
       offset: in STD_LOGIC_Vector(31 downto 0);   -- signal offset
       mySine: out STD_LOGIC_Vector(31 downto 0) 
   );
end sineX;

architecture Behavioral of sineX is

Component phi_export  --  For 32 Bit values gives back 32 complex numbers sin, cos
port (
    CLK: in STD_LOGIC;
    sel: in STD_LOGIC_VECTOR(4 downto 0);  --  32 bits  32 combinations
    StepRe: out STD_LOGIC_VECTOR(31 downto 0); -- (31 downto 0)    32bits
    StepIm: out STD_LOGIC_VECTOR(31 downto 0)  -- (31 downto 0)    32bits
    );
end component;

component mul_com
port ( 
  CLK : in  std_logic;
  RST : in  std_logic;
  ReA : in  std_logic_vector(31 downto 0);
  ImA : in  std_logic_vector(31 downto 0);
  ReB : in  std_logic_vector(31 downto 0);
  ImB : in  std_logic_vector(31 downto 0);
  ReC : out std_logic_vector(31 downto 0);
  ImC : out std_logic_vector(31 downto 0)
  );
end component;

COMPONENT pipe_mul 
generic(
    width: natural := 26;
    width_plus: natural := 6
);
PORT(
    CLK : in  std_logic;
    RST : in  std_logic;
    A : in  std_logic_vector(width+width_plus-1 downto 0);
    B : in  std_logic_vector(width+width_plus-1 downto 0);
    C : out signed((width+width_plus)*2-1 downto 0)
);
END COMPONENT;

signal curr_Re, curr_Im: STD_LOGIC_Vector(31 downto 0); -- current value
signal step_Re, step_Im: STD_LOGIC_Vector(31 downto 0); -- step value
signal next_Re, next_Im: STD_LOGIC_Vector(31 downto 0); -- step value
signal nextS_Re, nextS_Im: STD_LOGIC_Vector(31 downto 0); -- step value
signal nextB_Re, nextB_Im: STD_LOGIC_Vector(31 downto 0); -- step value
signal currB_Re, currB_Im: STD_LOGIC_Vector(31 downto 0); -- real value
signal phi1_Re, phi1_Im: STD_LOGIC_Vector(31 downto 0); -- current angle values
signal phi2_Re, phi2_Im: STD_LOGIC_Vector(31 downto 0); -- current angle values
signal stepX: STD_LOGIC_Vector(31 downto 0); -- current values
signal val: STD_LOGIC_Vector(29 downto 0); -- current values
signal state: STD_LOGIC_Vector(1 downto 0); -- 00 create step, 01 run
signal cnt,pipe: STD_LOGIC_Vector(4 downto 0); -- count value
signal sel: STD_LOGIC_Vector(4 downto 0); -- count value
signal cntN: natural := 0;
signal iSine: STD_LOGIC_Vector(63 downto 0); -- current angle values
signal scale_multi : signed(63 downto 0);
signal scale_trunc : signed(31 downto 0);
signal mysineXV: signed(31 downto 0);  -- (31 downto 0)
signal en: STD_LOGIC;  -- (31 downto 0)

begin

phi1: phi_export   -- for small step complex calc
port map(
    CLK => CLK,
    sel=> sel,
    StepRe =>  phi1_Re, -- (31 downto 0)    32bits
    StepIm => phi1_Im   -- (31 downto 0)    32bits
);

mul1: mul_com    -- for step complex calculation
port map( 
  CLK => CLK,
  RST => RST,
  ReA => step_Re,
  ImA => step_Im,
  ReB => phi1_Re,
  ImB => phi1_Im,
  ReC => next_Re,
  ImC => next_Im
  );

mul2: mul_com  -- next value after small step
port map( 
  CLK => CLK,
  RST => RST,
  ReA => curr_Re,
  ImA => curr_Im,
  ReB => step_Re,
  ImB => step_Im,
  ReC => nextS_Re,
  ImC => nextS_Im
  );

mul3: mul_com  -- next value after big step
port map( 
  CLK => CLK,
  RST => RST,
  ReA => currB_Re,
  ImA => currB_Im,
  ReB => phi1_Re,
  ImB => phi1_Im,
  ReC => nextB_Re,
  ImC => nextB_Im
  );


stepX <= step(26 downto 0)&"00000";  -- Bigger step for exact calculation

process(clk, RST)
begin
  if (RST = '1') then
     en <= '0';
  elsif rising_edge(CLK) then
    en <= not(en);
  end if;
end process;

process(clk, EN, RST)
   
begin
  if (RST = '1') then
     -- current output maxvalue complex
     --           33222222222211111111110000000000
     --           10987654321098765432109876543210 
     curr_Re <=  "01000000000000000000000000000000";
     curr_Im <=  "00000000000000000000000000000000";
     step_Re <=  "01000000000000000000000000000000";
     step_Im <=  "00000000000000000000000000000000";
     currB_Re <= "01000000000000000000000000000000";
     currB_Im <= "00000000000000000000000000000000";
     val <= stepX(29 downto 0);
     state <= "00";
     cnt <= "00001";
     pipe <= "00000";
     cntN <= 0;
     sel <= "00000";
     -- create step complex number
  elsif rising_edge(CLK) then
     -- verify step * phi1 = next after 2 clkcycles 
     if (state = "00") then    -- create step
       if (pipe ="00011") then
         if (cntN = 0) then -- initialize step
           -- step_Re <= "01000000000000000000000000000000";
           -- step_Im <= "00000000000000000000000000000000";
           cnt <= cnt + 1;
           cntN <= cntN + 1;
           sel <= cnt; 
         elsif (cntN = 31) then -- step finished now run
           state <= "01"; 
           cnt <= "00001"; 
           cntN <= 0;
           sel <= "00000";
         else       
           if (step(cntN) = '1') then 
             step_Re <= next_Re;
             step_Im <= next_Im;
           end if;  
           sel <= cnt; 
           cnt <= cnt + 1;
           cntN <= cntN + 1;
         end if; 
         pipe <= "00000";
       else 
         pipe <= pipe + 1;
       end if;
     elsif (state = "01") then  -- running here enable??
        -- currB = cos(val)  nextS = curr * step
        -- divide by 13 to get 130ns sampling time.
       if (pipe ="01100") then     -- divide clock by 13 set 12 to get 130ns per sample 
                                   -- XADC 8.32 us = 64 * 130 ns for sampling 4 channels synchronous.
         if (cnt = "00000") then  -- after 32 steps update with CurrB
           curr_Re <= currB_Re;
           curr_Im <= currB_Im;
           cnt <= cnt + 1;         
           cntN <= 0;
           val <= val + stepX(29 downto 0);  -- new value to claculate
           sel <= "00000";
           currB_Re <= "01000000000000000000000000000000";  -- start again
           currB_Im <= "00000000000000000000000000000000";
         else 
           -- update curr_Re, CurrIm with step
           curr_Re <= nextS_Re;
           curr_Im <= nextS_Im;         
           -- update Big calculation
           if (cntN < 30) then
             if (val(cntN) = '1') then 
               currB_Re <= nextB_Re;
               currB_Im <= nextB_Im;         
             end if;
           end if;
           sel <= cnt;
           cnt <= cnt + 1;
           cntN <= cntN + 1;
         end if;
         pipe <= "00000";
       else 
         pipe <= pipe + 1;
       end if;
     end if;
  end if;
end process;

myScale: pipe_mul 
PORT Map(
    CLK => CLK,
    RST => RST,
    A => curr_Re,
    B => amplitude,
    C => scale_multi
);

process(clk,scale_multi,scale_trunc,offset,RST)

-- variable scale_multi : signed(31 downto 0);
-- variable scale_trunc : signed(31 downto 0);
variable mysineXV: signed(31 downto 0);  -- (31 downto 0)
   
begin
--  scale_multi := signed(curr_Re) * signed(amplitude);
  scale_trunc <= scale_multi(61 downto 30);
  mysineXV := signed(scale_trunc) + signed(offset); 
  mysine <= std_logic_vector(mysineXV(31 downto 0));
end process;

end Behavioral;
