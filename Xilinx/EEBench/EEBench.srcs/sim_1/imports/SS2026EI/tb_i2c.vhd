library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_i2c_master is
end entity;

architecture sim of tb_i2c_master is

    constant CLK_FREQ : integer := 100_000_000; -- Basys 3: 100 MHz
    constant BUS_FREQ : integer := 100_000;     -- für Simulation erstmal 100 kHz

    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal ena       : std_logic := '0';
    signal addr      : std_logic_vector(6 downto 0) := (others => '0');
    signal rw        : std_logic := '0';
    signal data_wr   : std_logic_vector(7 downto 0) := (others => '0');
    signal busy      : std_logic;
    signal data_rd   : std_logic_vector(7 downto 0);
    signal ack_error : std_logic;
    signal sda       : std_logic := 'H';
    signal scl       : std_logic := 'H';

    -- einfacher "Slave-Treiber" für ACK
    signal slave_sda_low : std_logic := '0';

    type byte_array_t is array (0 to 3) of std_logic_vector(7 downto 0);
    signal rx_bytes : byte_array_t := (others => (others => '0'));

    signal capture_done : std_logic := '0';

    procedure wait_scl_falling(
        signal scl_sig : in std_logic;
        constant n     : in integer
    ) is
    begin
        for i in 1 to n loop
            wait until falling_edge(scl_sig);
        end loop;
    end procedure;

begin

    --------------------------------------------------------------------
    -- Pull-ups für den I2C-Bus in der Simulation
    --------------------------------------------------------------------
    scl <= 'H';
    sda <= 'H';

    -- Slave zieht SDA für ACK auf Low
    sda <= '0' when slave_sda_low = '1' else 'Z';

    --------------------------------------------------------------------
    -- 100 MHz Takt
    --------------------------------------------------------------------
    clk <= not clk after 5 ns;

    --------------------------------------------------------------------
    -- DUT: dein I2C-Master
    --------------------------------------------------------------------
    uut : entity work.i2c_master
        generic map (
            input_clk => CLK_FREQ,
            bus_clk   => BUS_FREQ
        )
        port map (
            clk       => clk,
            reset_n   => reset_n,
            ena       => ena,
            addr      => addr,
            rw        => rw,
            data_wr   => data_wr,
            busy      => busy,
            data_rd   => data_rd,
            ack_error => ack_error,
            sda       => sda,
            scl       => scl
        );

    --------------------------------------------------------------------
    -- Stimulus:
    -- Wir senden an den MCP4728:
    -- Adresse 0x60 + Write
    -- Datenbytes 0x40, 0x08, 0x00
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- Reset
        reset_n <= '0';
        ena     <= '0';
        addr    <= (others => '0');
        rw      <= '0';
        data_wr <= (others => '0');

        wait for 200 ns;
        reset_n <= '1';

        -- Warten bis Master bereit ist
        wait until busy = '0';
        wait until rising_edge(clk);

        -- Slave-Adresse MCP4728 = 0x60
        addr <= "1100000";
        rw   <= '0';

        -- Erstes Datenbyte für MCP4728
        data_wr <= x"40";
        ena <= '1';

        -- Warten bis Transaktion sicher gestartet hat
        wait until busy = '1';

        -- Nächstes Byte früh genug vorbereiten,
        -- damit der Master es bei slv_ack2 übernehmen kann
        wait_scl_falling(scl, 12);
        data_wr <= x"08";

        -- Drittes Byte vorbereiten
        wait_scl_falling(scl, 9);
        data_wr <= x"00";

        -- Nach dem dritten Byte Transaktion beenden
        wait_scl_falling(scl, 9);
        ena <= '0';

        -- noch etwas laufen lassen
        wait until capture_done = '1';
        wait for 50 us;

        -- Simulation beenden
        assert false report "Simulation fertig." severity failure;
    end process;

    --------------------------------------------------------------------
    -- Einfaches MCP4728-Slave-Modell:
    -- - erkennt Start
    -- - liest 4 Bytes mit
    -- - gibt nach jedem Byte ACK
    --------------------------------------------------------------------
    slave_proc : process
        variable temp_byte : std_logic_vector(7 downto 0);
    begin
        slave_sda_low <= '0';
        capture_done <= '0';

        -- Startbedingung erkennen:
        -- SDA fällt, während SCL high ist
        wait until (sda'event and sda = '0' and scl /= '0');

        for byte_index in 0 to 3 loop
            -- 8 Bits lesen
            for bit_index in 7 downto 0 loop
                wait until rising_edge(scl);

                if sda = '0' then
                    temp_byte(bit_index) := '0';
                else
                    temp_byte(bit_index) := '1';
                end if;
            end loop;

            rx_bytes(byte_index) <= temp_byte;

            -- ACK-Zyklus
            wait until falling_edge(scl);
            slave_sda_low <= '1';  -- ACK = Low

            wait until rising_edge(scl);
            wait until falling_edge(scl);
            slave_sda_low <= '0';
        end loop;

        capture_done <= '1';
        wait;
    end process;

    --------------------------------------------------------------------
    -- Prüfen, ob wirklich die erwarteten Bytes gesendet wurden
    --------------------------------------------------------------------
    check_proc : process
    begin
        wait until capture_done = '1';
        wait for 1 us;

        assert ack_error = '0'
            report "ACK_ERROR wurde gesetzt -> Slave wurde nicht korrekt bestätigt."
            severity error;

        assert rx_bytes(0) = x"C0"
            report "Byte 0 falsch. Erwartet: C0, empfangen: nicht C0"
            severity error;

        assert rx_bytes(1) = x"40"
            report "Byte 1 falsch. Erwartet: 40"
            severity error;

        assert rx_bytes(2) = x"08"
            report "Byte 2 falsch. Erwartet: 08"
            severity error;

        assert rx_bytes(3) = x"00"
            report "Byte 3 falsch. Erwartet: 00"
            severity error;

        report "I2C-Test erfolgreich: Gesendet wurde C0 40 08 00." severity note;

        wait;
    end process;

end architecture;