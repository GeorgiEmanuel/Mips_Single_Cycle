

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--HEX-to-seven-segment decoder
--   HEX:   in    STD_LOGIC_VECTOR (3 downto 0);
--   LED:   out   STD_LOGIC_VECTOR (6 downto 0);
--
-- segment encoinputg
--      0
--     ---
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3



entity SSD is
  Port (
        clk : in STD_LOGIC;
        digits:in STD_LOGIC_VECTOR(31 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0);
        an : out STD_LOGIC_VECTOR(7 downto 0) 
         );
end SSD;

architecture Behavioral of SSD is

signal cnt: STD_LOGIC_VECTOR(16 downto 0) := (others => '0');
signal hex: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal sel: STD_LOGIC_VECTOR(2 downto 0);

begin

   with hex select
  cat <= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0

counter:process(clk)
begin
    if rising_edge(clk) then
        cnt <= cnt + 1;
    end if;
    sel <= cnt(16 downto 14);

end process;

muxAN:process(sel)
begin
    case sel is
         when "000" => an <= "11111110";
         when "001" => an <= "11111101";
         when "010" => an <= "11111011";
         when "011" => an <= "11110111";
         when "100" => an <= "11101111";
         when "101" => an <= "11011111";
         when "110" => an <= "10111111";
         when "111" => an <= "01111111";
         when others => an <= "11111110";
    end case;  
end process;

muxCAT:process(sel)
begin
    
    case sel is
        when "000" => hex <= digits(3 downto 0);
        when "001" => hex <= digits(7 downto 4);
        when "010" => hex <= digits(11 downto 8);
        when "011" => hex <= digits(15 downto 12);
        when "100" => hex <= digits(19 downto 16);
        when "101" => hex <= digits(23 downto 20);
        when "110" => hex <= digits(27 downto 24);
        when "111" => hex <= digits(31 downto 28);
        when others => hex <= "0000";
    end case;
end process;

end Behavioral;
