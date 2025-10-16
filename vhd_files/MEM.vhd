


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity MEM is
 Port ( clk : in std_logic;
        en : in std_logic;
        ALUResIn : in std_logic_vector(31 downto 0);
        RD2 :  in std_logic_vector(31 downto 0);    
        MemWrite : in std_logic;
        MemData : out std_logic_vector(31 downto 0);    
        ALUResOut : out std_logic_vector(31 downto 0)
        );
        
end MEM;



architecture Behavioral of MEM is

type ram_type is array(0 to 63) of std_logic_vector(31 downto 0);
signal ram : ram_type := ( X"0000000A",
                           X"0000000B",
                           X"0000000C",
                           X"0000000D",
                           X"0000000E",
                           X"0000000F",
                           X"00000010",
                           X"00000011",
                           X"00000012",
                           X"00000013",
                           X"00000014",
                           others => X"FFFFFFFF");
    
begin

ALUResOut <= ALUResIn;

RAM_p:process(clk)
begin
    if rising_edge(clk) then
       if en ='1' then
          if MemWrite = '1' then
             ram(conv_integer(ALUResIn)) <= RD2;
          end if;
       end if;
    end if;
end process;
 MemData <= ram(conv_integer(ALUResIn));
 ALUResOut <= ALUResIn;
end Behavioral;
