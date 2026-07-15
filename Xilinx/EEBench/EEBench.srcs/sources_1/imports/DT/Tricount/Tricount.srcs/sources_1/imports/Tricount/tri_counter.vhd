-- Triangle counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity tri_counter is
   generic(
      N: integer := 16     -- number of bits
  );
   port(
      clk, reset: in std_logic;
      start, stop, step: in std_logic_vector(N-1 downto 0);
      repeat: in std_logic_vector(2*N-1 downto 0);
      q: out std_logic_vector(N-1 downto 0)
   );
end tri_counter;

architecture arch of tri_counter is
   signal r_reg, r_regp, r_regm, r_regpl, r_regml: signed(N + 3 downto 0);
   signal flag: std_logic_vector(1 downto 0);
   signal en: std_logic;
   signal r_cnt: unsigned(2*N-1 downto 0);
begin

   -- repeat count generates en
   process(clk,reset)
   begin
      if (reset='1') then
		 r_cnt <= (others => '0');
		 en <= '0';
      elsif (clk'event and clk='1') then
         if (r_cnt >= unsigned(repeat)) then
           r_cnt <= (others=>'0'); 
           en <= '1';
         else
           r_cnt <= r_cnt + 1;
           en <= '0';
         end if;        
	  end if;
   end process;
     
   r_regp <= r_reg + signed(step);
   r_regm <= r_reg - signed(step);
   r_regpl <= signed(stop&'0') - r_regp;   -- multiply stop with 2: stop - (reg - stop) = 2 stop - reg
   r_regml <= signed(start&'0') - r_regm;  -- multiply start with 2
   
   -- register
   process(clk,reset, en, start,stop)
   begin
      if (reset='1') then
         r_reg <= signed("0000"&start);
         if (start = stop) then
           flag <= "11";
         else 
           flag <= "00";
         end if;  
      elsif (clk'event and clk='1' and en='1') then -- only when enable with repeat
         if (flag = "00") then -- up until stop
           if (r_regp > signed(stop)) then         -- overflow
		     flag <= "01";
		     r_reg <= r_regpl; 
		   else 
		     r_reg <= r_regp;
		   end if; 
		 elsif (flag = "01") then -- down until start
	       if (r_regm < signed(start)) then
		       r_reg <= r_regml;
		       flag <= "00";
		   else 
		       r_reg <= r_regm;   
		   end if;
		 elsif (flag = "11") then        -- DC value
		   r_reg <= signed("0000"&start);
		 end if;
         -- if (unsigned(start) = unsigned(stop)) then -- DC value
         --  flag <= "11";  -- no counting
         -- elsif (r_reg >= unsigned(stop) - 1 ) then
         --  flag <= "01";  -- change between up and down
         -- elsif  (r_reg <= unsigned(start) + 1 ) then
         --  flag <= "00";
         -- end if;		   
      end if;
   end process;
   -- output logic
   q <= std_logic_vector(r_reg(N-2 downto 0)&'0');
end arch;