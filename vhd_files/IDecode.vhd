
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity I_Decode is
  Port ( clk : in std_logic;
         en : in std_logic;
         Instr : in std_logic_vector(25 downto 0);
         WD: in std_logic_vector(31 downto 0);
         RegWrite : in std_logic;
         RegDst : in std_logic;
         ExtOp : in std_logic;
         RD1 : out std_logic_vector(31 downto 0);
         RD2 : out std_logic_vector(31 downto 0);
         Ext_Imm :  out std_logic_vector(31 downto 0);
         func : out std_logic_vector(5 downto 0);
         sa : out std_logic_vector(4 downto 0)
   );
end I_Decode;

architecture Behavioral of I_Decode is

type mem_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal reg_file_signal: mem_type := ( others  => X"00000000");

signal RA1: std_logic_vector(4 downto 0);
signal RA2: std_logic_vector(4 downto 0);
signal WA: std_logic_vector(4 downto 0);



begin 

RA1 <= Instr(25  downto 21); 
RA2 <= Instr(20  downto 16); 


RD1 <= reg_file_signal(conv_integer(RA1));
RD2 <= reg_file_signal(conv_integer(RA2));
WA <=  Instr(20 downto 16) when RegDst = '0' else Instr(15 downto 11); 


Ext_Imm(15 downto 0) <= Instr(15 downto 0);
Ext_Imm(31  downto 16) <= (others => Instr(15)) when ExtOp = '1' else 
                          (others => '0');
func <= Instr(5 downto 0);
sa <= Instr(10 downto 6);


Reg_file_proc:process(clk)
begin
    if rising_edge(clk) then
        if RegWrite = '1' and en = '1' then
            reg_file_signal(conv_integer(wa)) <= wd;
        end if;
   end if;

end process Reg_file_proc;



end Behavioral;
