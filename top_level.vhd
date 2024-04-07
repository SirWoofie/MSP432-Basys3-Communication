
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity alu is

  generic (constant N : natural := 1); -- The number of shifted or rotated bits for ALU. I'm choosing to leave it at 1.
    
  Port ( 
  addr : in std_logic_vector (4 downto 0);
  data_out : out std_logic_vector (7 downto 0);
  data_bus : in std_logic_vector (7 downto 0);
  input_or_output : in std_logic; -- HIGH: Input. LOW: Output.
  data_load : in std_logic; -- HIGH: Load data. LOW: Process data.
  data_send : in std_logic; -- HIGH: Send data. LOW: Process data.
  clk : in std_logic

  );
end alu;

architecture Behavioral of alu is
    -- Place results of operations in the s_result register
    -- 8 bytes plus a carry bit (overflow detection not supported)
    signal s_result : std_logic_vector(65 downto 0);

    -- Signals for the data used by ALU
    signal data1 : std_logic_vector(31 downto 0);-- := data_bus;
    signal data2 : std_logic_vector(31 downto 0);-- := x"0A";
    -- Signal used for operation used by ALU
    signal alu_op : std_logic_vector (4 downto 0) := (others => '0');
    
    -- Signals for combination of registers
    signal reg_sel : std_logic; -- Determine which register to store to from the address bus
    
    signal output : std_logic_vector(7 downto 0); -- Will be data_out

begin
    
    -- Register process for loading data to be processed
    process(clk)
    begin
        if rising_edge(clk) and data_load = '1' then
            case addr is -- This could likely be integrated into the ALU process, but I really don't want to do that as it'd be hard to debug.
				when "00001" => data1(7 downto 0)		<= data_bus; -- Select reg1a
                when "00010" => data1(15 downto 8)		<= data_bus; -- Select reg1b
                when "00011" => data1(23 downto 16)	    <= data_bus; -- Select reg1c
                when "00100" => data1(31 downto 24)	    <= data_bus; -- Select reg1d
                when "00101" => data2(7 downto 0)		<= data_bus; -- Select reg2a
                when "00110" => data2(15 downto 8)		<= data_bus; -- Select reg2b
                when "00111" => data2(23 downto 16)	    <= data_bus; -- Select reg2c
                when "01000" => data2(31 downto 24)	    <= data_bus; -- Select reg2d
                
                when others => reg_sel <= 'Z'; -- Set the output to undefined
            end case;
        end if;
    end process;
    
    -- Register process for sending data
    process(clk) -- data_send is not in the sensitivity list as we only want this process to trigger when the clock triggers. Otherwise, this would technically be asynchronous.
    begin
        if rising_edge(clk) and data_send = '1' then
            case addr is -- This could likely be integrated into the ALU process, but I really don't want to do that as it'd be hard to debug.
                -- Don't use "00000" so the addr lines can be left low.
                when "10001" => output(7 downto 0) <= s_result(7 downto 0); -- Send first byte
                when "10010" => output(7 downto 0) <= s_result(15 downto 8); -- Send second byte
                when "10011" => output(7 downto 0) <= s_result(23 downto 16); -- Send third byte
                when "10100" => output(7 downto 0) <= s_result(31 downto 24); -- Send fourth byte
                -- Making the first bit '1' means there's no potential overlap with the data_load either.
                
                when others =>
--                    data_bus(7 downto 0) <= x"00"; -- Reset the data_bus
                    reg_sel <= 'Z'; -- Set data_bus to all 'Z' so it can be read from.
            end case;
        end if;
    end process;
    
    -- ALU Process
    process(clk) -- note: removed en from sensitivity list
    begin
        if rising_edge(clk) and input_or_output = '1' then
            case alu_op (4 downto 1) is
                when "0000" => -- Addition
                    if alu_op(0) = '0' then
                        s_result (32 downto 0) <= std_logic_vector(unsigned('0' & data1) + unsigned('0' & data2));
                    else
                        s_result(32 downto 0) <= std_logic_vector(signed(data1(31) & data1) + signed(data2(31) & data2));
                    end if;
                
                when "0001" => -- Subtraction
                    if alu_op(0) = '0' then
                        s_result (32 downto 0) <= std_logic_vector(unsigned('0' & data1) - unsigned('0' & data2));
                    else
                        s_result (32 downto 0) <= std_logic_vector(signed(data1(31) & data1) - signed(data2(31) & data2));
                    end if;
                    
                when "0010" => -- Multiplication
                    if alu_op(0) = '0' then
                        s_result (65 downto 0) <= std_logic_vector(unsigned('0' & data1) * unsigned('0' & data2));
                    else
                        s_result (65 downto 0) <= std_logic_vector(signed(data1(31) & data1) * signed(data2(31) & data2));
                    end if;
                when "0011" => -- Division
                    if alu_op(0) = '0' then
                        s_result (32 downto 0) <= std_logic_vector(unsigned('0' & data1) / unsigned('0' & data2));
                    else
                        s_result (32 downto 0) <= std_logic_vector(signed(data1(31) & data1) / signed(data2(31) & data2));
                    end if;
                when "0100" => -- Logical shift left
                    s_result (31 downto 0) <= std_logic_vector(unsigned(data1) sll N);
                when "0101" => -- Logical shift right
                    s_result (31 downto 0) <= std_logic_vector(unsigned(data1) srl N);
                when "0110" => --  Rotate left
                    s_result (31 downto 0) <= std_logic_vector(unsigned(data1) rol N);
                when "0111" => -- Rotate right
                    s_result (31 downto 0) <= std_logic_vector(unsigned(data1) ror N);
                when "1000" => -- Logical and 
                    s_result (31 downto 0) <= data1 and data2;
                when "1001" => -- Logical or
                    s_result (31 downto 0) <= data1 or data2;
                when "1010" => -- Logical xor 
                    s_result (31 downto 0) <= data1 xor data2;
                when "1011" => -- Logical nor
                    s_result (31 downto 0) <= data1 nor data2;
                when "1100" => -- Logical nand 
                    s_result (31 downto 0) <= data1 nand data2;
                when "1101" => -- Logical xnor
                    s_result (31 downto 0) <= data1 xnor data2;
                when "1110" => -- Greater comparison
                    if(data1>data2) then
                        s_result (7 downto 0) <= (0 => '1', others => '0');
                    else
                        s_result (7 downto 0) <= (others => '0');
                    end if; 
                when "1111" => -- Equal comparison   
                    if(data1=data2) then
                        s_result (7 downto 0) <= (0 => '1', others => '0');
                    else
                        s_result (7 downto 0) <= (others => '0');
                    end if;
                    
                    
                when others =>
                    s_result <= (0 => '0',1 => '1', 2 => '1', 3 => '1', 4 => '1',5 => '1', 6 => '1', 7 => '1', 8 => '0', 9 => '1', 10 => '1', 11 => '1',12 => '1', 13 => '1', 14 => '1', 15 => '1', others => 'Z');
            end case;
        end if;
    end process;
    
    alu_op <= addr;
--    data1 <= data_bus; --always read the value to data1 as input
    data_out <= output;
--    data_out <= s_result(7 downto 0);
end Behavioral;
