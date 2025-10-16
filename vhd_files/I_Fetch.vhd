
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity I_Fetch is
  Port (clk : in std_logic;
        rst : in std_logic;    
        en : in std_logic;
        jump_address : in std_logic_vector(31 downto 0);
        branch_address : in std_logic_vector(31 downto 0);
        jump : in std_logic;
        PCSrc: in std_logic;
        current_instruction : out std_logic_vector(31 downto 0);
        next_instruction: out std_logic_vector(31 downto 0)
        );
end I_Fetch;

architecture Behavioral of I_Fetch is

signal PC : std_logic_vector(31 downto 0);
type mem_type is array(0 to 255) of std_logic_vector(31 downto 0);
signal Rom : mem_type := (
    B"000000_00000_00000_00001_00000_100000", -- add $1, $0, $0   0000 0820    -- 01, initializare contor bucla
    B"001000_00000_00100_0000000000001011",   -- addi $4, $0, 11  2004 000B    -- 02, initializare numar de iteratii
    B"000000_00000_00000_00010_00000_100000", -- add $2, $0, $0   0000 1020    -- 03, initializare registru folosit pe post de index pentru a face load din memorie
    B"000000_00000_00000_00101_00000_100000", -- add $5, $0, $0   0000 2820    -- 04, initializare registru pentru rezultat
    B"100011_00010_00011_0000000000000000",   -- lw $3, 0($2)     8C43 0000    -- 05, aducerea pe rand a numerelor din RAM in RF
    B"000100_00001_00100_0000000000000111",   -- beq $1, $4, 7    1024 0007    -- 06, verificam daca nu am ajuns la ultima iteratie, daca am ajuns sarim la linia 14, operatie de store word
    B"100011_00010_00011_0000000000000000",   -- lw $3, 0($2)     8C43 0000    -- 07, aducerea pe rand a numerelor din RAM in RF
    B"001100_00011_00110_0000000000000001",   -- andi $6, $3, 1   3066 0001    -- 08, verificam daca numarul este impar
    B"000100_00110_00000_0000000000000001",   -- beq $6, $0, 1    10C0 0001    -- 09, daca numarul este par sarim peste adaugarea acestuia in suma
    B"000000_00101_00011_00101_00000_100000", -- add $5, $5, $3   00A3 2820    -- 10, daca este  impar il adaugam in suma
    B"001000_00010_00010_0000000000000001",   -- addi $2, $2, 1   2042 0001    -- 11, crestem valoarea registrului 2 pentru a incarca urmatorul numar
    B"001000_00001_00001_0000000000000001",   -- addi $1, $1, 1   2021 0001    -- 12, crestem contorul pentru bucla
    B"000010_00000000000000000000000100",     -- j 4              0800 0004    -- 13, ne intoarcem la linia 5 pentru urmatoarea iteratie
    B"101011_00000_00101_0000000000111000",   -- sw $5, 56($0)    AC05 0038    -- 14, stocam rezultatul in memorie
    others => x"11111111"
   
);

signal mux1_out : std_logic_vector(31 downto 0);
signal mux2_out : std_logic_vector(31 downto 0);
signal sum : std_logic_vector(31 downto 0);
begin

sum <= PC + 1;
current_instruction <= Rom(conv_integer(PC));

next_instruction <= sum;

mux1_out <= sum when PCSrc='0' else Branch_Address;
mux2_out <= jump_address when jump = '1' else mux1_out;

Counter:process(clk, rst)
begin
    if rst = '1' then PC <= X"00000000";
      elsif rising_edge(clk) then
             if en ='1' then 
                 PC <= mux2_out;
             end if;
    end if;

end process Counter;

end Behavioral;
