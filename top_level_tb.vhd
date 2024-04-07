-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 5.4.2024 21:44:19 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_alu is
end tb_alu;

architecture tb of tb_alu is

    component alu
        port (addr            : in std_logic_vector (4 downto 0);
              data_out        : out std_logic_vector (7 downto 0);
              data_bus        : in std_logic_vector (7 downto 0);
              input_or_output : in std_logic;
              data_load : in std_logic;
              data_send : in std_logic;
              clk             : in std_logic);
    end component;

    signal addr            : std_logic_vector (4 downto 0);
    signal data_out        : std_logic_vector (7 downto 0);
    signal data_bus        : std_logic_vector (7 downto 0);
    signal input_or_output : std_logic;
    signal data_load       : std_logic;
    signal data_send       : std_logic;
    signal clk             : std_logic;

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : alu
    port map (addr            => addr,
              data_out        => data_out,
              data_bus        => data_bus,
              input_or_output => input_or_output,
              data_load       => data_load,
              data_send       => data_send,
              clk             => clk);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
            -- Put initialisation code here
    --First integer
    data_bus <= x"FF"; addr <= b"00001";
    data_load <= '1'; --input
    wait for 10ns;
    data_bus <= x"00"; addr <= b"00010";
    wait for 10ns;
    data_bus <= x"00"; addr <= b"00011";
    wait for 10ns;
    data_bus <= x"00"; addr <= b"00100";
    wait for 10ns;
    
    --Second integer
    data_bus <= x"02"; addr <= b"00101";
    wait for 10ns;
    data_bus <= x"00"; addr <= b"00110";
    wait for 10ns;
    data_bus <= x"00"; addr <= b"00111";
    wait for 10ns;
    data_bus <= x"00"; addr <= b"01000";
    wait for 10ns;
    
    --Disable data_send
    data_load <= '0';
    
    --Enable ALU
    input_or_output <= '1';
    data_bus <= (others => 'Z'); -- You need to set the bus to Z before the simulation can read the output that is set by the circuit.
    wait for 10ns;
    
    --Disable ALU
    input_or_output <= '0'; --output
    wait for 10ns;
    
    --Enable output
    data_send <= '1';
    --Read output
    addr <= b"10001";
    wait for 10ns;
    addr <= b"10010";
    wait for 10ns;
    addr <= b"10011";
    wait for 10ns;
    addr <= b"10100";
    wait for 10ns;
    
    
    wait for 10ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
