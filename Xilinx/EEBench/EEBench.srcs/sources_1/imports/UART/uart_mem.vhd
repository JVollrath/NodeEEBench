-----------------------------------------
-- UART to and from register memory
-----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_mem is
   generic(
      -- 100MHz, 19200 = 326,  115200 = 54, 230400 = 27, 460800 = 14, 921600 = 7
	  DVSR: integer:= 27;  -- baud rate divisor
                            -- DVSR = 100M/(16*baud rate)
      DVSR_BIT: integer:=10; -- # bits of DVSR
      DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16;  -- # ticks for stop bits
      TX_SIZE: integer := 512 * 128 ;     -- # data bits
      RX_SIZE: integer := 512     -- # data bits
   );
   port(
      clk, reset: in std_logic;
      rx: in std_logic;
      dtx: in std_logic_vector(15 downto 0);             -- data from block memory to send
      dataMax: in std_logic_vector(15 downto 0);         -- block size
      aBuf: out std_logic_vector(15 downto 0);           -- address for block memory
      rx_mem: out std_logic_vector(RX_SIZE-1 downto 0);  -- receive memory
      addr01: out std_logic_vector(11 downto 0);         -- Lookup interface
      we01: out std_logic;
      din01: out std_logic_vector(15 downto 0);
      addr02: out std_logic_vector(11 downto 0);
      we02: out std_logic;
      din02: out std_logic_vector(15 downto 0);
      tx: out std_logic;
      tx_busy: out std_logic
   );
end uart_mem ;

architecture arch of uart_mem is

COMPONENT uart_tx 
   generic(
      DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16  -- # ticks for stop bits
   );
   port(
      clk, reset: in std_logic;
      tx_start: in std_logic;
      s_tick: in std_logic;
      din: in std_logic_vector(7 downto 0);
      tx_done_tick: out std_logic;
      tx: out std_logic
   );
end COMPONENT;

COMPONENT uart_rx is
   generic(
      DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16  -- # ticks for stop bits
   );
   port(
      clk, reset: in std_logic;
      rx: in std_logic;
      s_tick: in std_logic;
      rx_done_tick: out std_logic;
      dout: out std_logic_vector(7 downto 0)
   );
end COMPONENT;

-- Baud rate
COMPONENT mod_m_counter
   generic(
      N: integer := 4;     -- number of bits
      M: integer := 10     -- mod-M
  );
   port(
      clk, reset: in std_logic;
      max_tick: out std_logic;
      q: out std_logic_vector(N-1 downto 0)
   );
end COMPONENT;

-- rx signals
signal rx_done_tick: std_logic;
signal rx_data_out: std_logic_vector(7 downto 0);
signal rn_data_out: std_logic_vector(3 downto 0);
signal data16: std_logic_vector(15 downto 0);

-- tx signals
signal tx_start: std_logic;
signal tx_enable: std_logic;
signal tx_on: std_logic;
signal tx_active: std_logic;
signal dataN: std_logic_vector(3 downto 0); -- 4Bit value
signal tn_data_in: std_logic_vector(7 downto 0); -- 4Bit value
signal tx_data_in: std_logic_vector(7 downto 0); -- ASCII hex value
signal tx_done_tick: std_logic;
signal tma: std_logic_vector(17 downto 0); -- ASCII hex value

signal s_tick: std_logic_vector( 9 downto 0);
signal xtick: std_logic;

signal ucount: std_logic_vector(15 downto 0);
signal bCount: std_logic_vector(15 downto 0);

signal dataMaxU: unsigned(15 downto 0);

signal lut: std_logic;       -- received data to lut = 1 otherwise 0

begin


tx_busy <= tx_active;

 with rx_data_out select                    -- hex ASCII to 4Bit value
	rn_data_out <= "0000" when "00110000",  -- switches
		           "0001" when "00110001",  -- switches
		           "0010" when "00110010",  -- switches
		           "0011" when "00110011",  -- switches
		           "0100" when "00110100",  -- switches
		           "0101" when "00110101",  -- switches
		           "0110" when "00110110",  -- switches
		           "0111" when "00110111",  -- switches
		           "1000" when "00111000",  -- switches
		           "1001" when "00111001",  -- 9
		           "1010" when "01000001",  -- A 
		           "1011" when "01000010",  -- B
		           "1100" when "01000011",  -- C
		           "1101" when "01000100",  -- D
		           "1110" when "01000101",  -- E
		           "1111" when "01000110",  -- F
		           "0000" when others; -- ADC output

 with tn_data_in select                    -- hex ASCII to 4Bit value
	tx_data_in <=  "00110000" when "00000000",  -- 0
		           "00110001" when "00000001",  -- 1
		           "00110010" when "00000010",  -- 2
		           "00110011" when "00000011",  -- 3
		           "00110100" when "00000100",  -- 4
		           "00110101" when "00000101",  -- 5
		           "00110110" when "00000110",  -- 6
		           "00110111" when "00000111",  -- 7
		           "00111000" when "00001000",  -- 8
		           "00111001" when "00001001",  -- 9
		           "01000001" when "00001010",  -- A 
		           "01000010" when "00001011",  -- B
		           "01000011" when "00001100",  -- C
		           "01000100" when "00001101",  -- D
		           "01000101" when "00001110",  -- E
		           "01000110" when "00001111",  -- F
		           tn_data_in when others; -- ADC output
  
   baud_gen_unit: mod_m_counter
      generic map(M=>DVSR, N=>DVSR_BIT)
      port map(clk=>clk, reset=>reset,
               q=>s_tick, max_tick=>xtick);

   uart_rx_unit: uart_rx
      generic map(DBIT=>DBIT, SB_TICK=>SB_TICK)
      port map(clk=>clk, reset=>reset, rx=>rx,
               s_tick=>xtick, rx_done_tick=>rx_done_tick,
               dout=>rx_data_out);

   uart_tx_unit: uart_tx
      generic map(DBIT=>DBIT, SB_TICK=>SB_TICK)
      port map(clk=>clk, reset=>reset,
               tx_start=>tx_start,
               s_tick=>xtick, din=>tx_data_in,
               tx_done_tick=> tx_done_tick, tx=>tx);

   -- FSMD state read to memory register
  getCmd: process(clk,reset,rx_done_tick)
   variable numD: unsigned(15 downto 0):= (others => '0');       -- number of received hex data
   variable rmAddress: unsigned(17 downto 0):= (others => '0');  -- Bit Address for received data  
   begin
      if reset='1' then
         numD := (others => '0');
         rmAddress := (others => '0');
         rx_mem <= (others => '0');
         data16 <= (others => '0');
         we01 <= '0';
         we02 <= '0';
         lut <= '0';
      elsif (clk'event and clk='1') then -- new data
        if  (rx_done_tick='1') then 
         -- tx_enable  <= '0';                       -- this blocks operation completely
         case rx_data_out is
		   when "01011000" =>                     -- ASCII 58 X
              numD := (others => '0');
              rmAddress := (others => '0');
			  rx_mem(7 downto 0) <= rx_data_out; 
			  rx_mem(15 downto 8) <= "01000000"; 
		   when "01001111" =>                     -- ASCII 49 O sine signal
              numD := "0000000000001000";                 -- 8 Hex numbers, (Step, amplitude, offset)x(8x4)
              rmAddress := to_unsigned(276,18);    -- Start at index 276 (272 + 4)
			  rx_mem(7 downto 0) <= rx_data_out; 
		   when "01010001" =>                     -- ASCII 51 Q make LUT active
              numD := (others => '0');
              rmAddress := (others => '0');
			  rx_mem(7 downto 0) <= rx_data_out; 
			  rx_mem(13) <= '1'; 
		   when "01010010" =>                     -- ASCII 52 R load LUT table
              lut <= '1';
              numD := "1000000000000000";           -- numD = 32 k counts hex values 
                                                    -- Value 32k/4(Hex) 8k 16 bit values?
              rmAddress := to_unsigned(0,18);       -- Start at lut address 0
			  rx_mem(7 downto 0) <= rx_data_out; 
		   when "01010000" =>                     -- ASCII 53 P sine signal
              numD := "0000000000100000";          -- 32 Hex numbers, 4x V(4)I(4)
              rmAddress := to_unsigned(308,18);    -- Start at index 304?? (16+4) 308
			  rx_mem(7 downto 0) <= rx_data_out; 
		   when "01010011" =>                     -- ASCII 53 S sine signal
              numD := "0000000000011000";                 -- 24 Hex numbers, (Step, amplitude, offset)x(8x4)
              rmAddress := to_unsigned(20,18);            -- Start at index 20 (16+4)
			  rx_mem(7 downto 0) <= rx_data_out; 
			  rx_mem(15 downto 14) <= "00";  -- Status Sine not active
			  rx_mem(12 downto 8) <= "00001";  -- Status Sine not active
		   when "01010100" =>                     -- ASCII 54 T Triangel
              numD := "0000000000010100";                    -- 20 Hex numbers: 64 Bits 4(Start,Stop,Step,Repeat)x(4x4)
              rmAddress := to_unsigned(180,18);    ---  "10110100";  x"B4"   -- 176 Start at index 
			  rx_mem(7 downto 0) <= rx_data_out; 
			  rx_mem(15 downto 14) <= "00";  -- Not active
			  rx_mem(12 downto 8) <= "00010";  -- Not active
		   when "01010101" =>                     -- ASCII 55 U start sending data
              tx_enable <= ('1' and not(tx_active));  -- send data flag if transfer not ongoing
		   when "01010110" =>                     -- ASCII 56 V sw to output
              rx_mem(15 downto 14) <= "10";  -- sw to output and active
              rx_mem(12 downto 8) <= "00011";  -- sw to output and active
		   when others =>	                      -- Write data
              rx_mem(14) <= '0';      -- active
              if (numD > 1) then
			    numD := numD - 1;
                if (lut = '0') then rx_mem(to_integer(rmAddress) - 1 downto to_integer(rmAddress) - 4) <= rn_data_out;
				elsif (numD >= 8*1024) then -- upper part
				  addr01 <= std_logic_vector(rmAddress(15 downto 4));
				  din01 <= data16(11 downto 0)&rn_data_out;
				  data16 <= data16(11 downto 0)&rn_data_out; 
				  we01 <= '1';
				else -- lower part
				  addr02 <= std_logic_vector(rmAddress(15 downto 4));
				  din02 <= data16(11 downto 0)&rn_data_out;
				  data16 <= data16(11 downto 0)&rn_data_out;
				  we02 <= '1';
				end if;
				rmAddress := rmAddress + 4;
              elsif (numD = 1) then
			    numD := numD - 1;
                if (lut = '0') then rx_mem(to_integer(rmAddress) - 1 downto to_integer(rmAddress) - 4) <= rn_data_out;
				else -- lower part
				  addr02 <= std_logic_vector(rmAddress(15 downto 4));
				  din02 <= data16(11 downto 0)&rn_data_out;
				  data16 <= data16(11 downto 0)&rn_data_out;
				  we02 <= '1';
				end if;
				lut <= '0';
				rmAddress := rmAddress + 4;
				rx_mem(15) <= '1';      -- active
				rx_mem(14) <= '1';      -- active
			  end if;
         end case;
         ucount <= std_logic_vector(numD);
        else -- end tick done
              we01 <= '0';
              we02 <= '0';
              tx_enable  <= '0';                    -- one cycle only at '1'
              rx_mem(14) <= '0';
        end if;
	  end if;
   end process;

dataMaxU <= unsigned(dataMax);   -- Block size adjustment

  -- FSMD state from memory to tx
   process(clk,reset, dtx, tx_enable)
   variable numTStartNr: unsigned(15 downto 0):= x"0015";          -- What initial value is correct? Fix sequence UYX ? 8.12.2022
   variable numT: unsigned(15 downto 0):= x"0015";          -- What initial value is correct? Fix sequence UYX ? 8.12.2022
   variable numB: unsigned(15 downto 0):= (others => '0');  -- X
   variable tmAddress: unsigned(17 downto 0):=(others => '0');   
   begin
      aBuf <= std_logic_vector(tmAddress(17 downto 2));  -- address for buffer
      bCount <= std_logic_vector(numB);  -- buffer counter
      case tmAddress(1 downto 0) is
         when "00" => dataN <= dtx( 15 downto 12); 
         when "01" => dataN <= dtx( 11 downto 8); 
         when "10" => dataN <= dtx( 7 downto 4); 
         when "11" => dataN <= dtx( 3 downto 0); 
         when others => dataN <= "0000"; 
      end case;
      tma <= std_logic_vector(tmAddress);
      if reset='1' then
         numB := x"0000";        -- X Lets start with 1024 data points
         numT := numTStartNr;        -- 2 * (16 Hex data 4 bit each - 256 4 chan + AWG out 4 Hex
         tmAddress := to_unsigned(0, 18);
         tx_on <= '0';
         tx_active <='0';
         tn_data_in <= (others => '0');
      elsif (clk'event and clk='1') then
       if (tx_enable = '1') then  -- start data transfer
         tx_active <='1'; 
         tx_on <= '1';            -- transmission ongoing
		 tx_start <= '1';        -- start first serial out
         numB := x"0000";        -- X Lets start with 1024 data points
	     numT := numT;           -- ?? +1?
	     tmAddress := to_unsigned(0, 18);
         tn_data_in <= x"55";     -- send "U" as block start
       elsif ( (tx_on = '1') and (tx_done_tick='1')) then -- still data last transmit finished
         if (numB = dataMaxU) then  -- last sample value + 513 times 5 values 
			tx_active <= '0';          -- this finishes transmission
		    tx_on <= '0';          -- this finishes transmission
		    tx_start <= '0';       -- no more transmission
            numB := x"0000";        -- 0
            numT := numTStartNr;        -- 2 * (16 Hex data 4 bit each - 256 4 chan + AWG out 4 Hex
            tmAddress := to_unsigned(0, 18);
            tn_data_in <= (others => '0');
         elsif (numT > 1) then          -- regular transfer
		    numT := numT - 1;
			tn_data_in <= "0000" & dataN; 
			tx_start <= '1';
            tmAddress := tmAddress + 1;
         elsif (numT = 1) then
		    tn_data_in <= x"59";  -- send "Y" as end of transmission crlf??
			tx_start <= '1';
            numT := numT - 1;
            numB := numB + 1;       -- X next Block
		 else                      -- finished 
            numT := numTStartNr;          --  ?? 20 HexData for one data point 5 channels 16 bit (4 hex values) each
		    tn_data_in <= x"58";     -- send "X" as start
		    tx_start <= '1';        -- start first serial out
	     end if;
		else                     -- one clock cycle tx_start 
		 tx_start <= '0';
		end if;
	  end if;
   end process;

end arch;