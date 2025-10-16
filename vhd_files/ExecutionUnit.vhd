library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity ExecutionUnit is
  Port ( PCinc : in std_logic_vector(31 downto 0);
         RD1 : in std_logic_vector(31 downto 0);
         RD2 : in std_logic_vector(31 downto 0);
         Ext_Imm : in std_logic_vector(31 downto 0);
         func : in std_logic_vector(5 downto 0);
         sa : in std_logic_vector(4 downto 0);
         ALUSrc : in std_logic;
         ALUOp : in std_logic_vector(2 downto 0);
         branch_address : out std_logic_vector(31 downto 0);
         ALURes : out std_logic_vector(31 downto 0);
         Zero : out std_logic
         );
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

signal ALUIn2 : std_logic_vector(31 downto 0);
signal ALUCtrl : std_logic_vector(2 downto 0);
signal ALUResSignal : std_logic_vector(31 downto 0);
signal Ext_Imm_shift : std_logic_vector(31 downto 0);

begin

--MUX for ALU input 2

with ALUSrc select
    ALUIn2 <= RD2 when '0',
              Ext_Imm when '1',
              (others => 'X') when others;


--ALU Control

ALURes <= ALUResSignal;
Zero <= '1' when ALUResSignal = X"00000000" else '0';
branch_address <= Ext_Imm + PCinc;

ALUCTRL_process:process(ALUOp, func)
begin
    case ALUOp is
           when "000" => --R type
            case func is 
                   when "100000" => ALUCtrl <= "000"; -- ADD
                   when "100010" => ALUCtrl <= "001"; -- SUB
                   when "000000" => ALUCtrl <= "010"; -- SLL
                   when "000010" => ALUCtrl <= "011"; -- SRL 
                   when "100100" => ALUCtrl <= "100"; -- AND
                   when "100101" => ALUCtrl <= "101"; -- OR
                   when "100110" => ALUCtrl <= "110"; -- XOR
                   when "000011" => ALUCtrl <= "111"; -- SRA
                   when others => ALUCtrl <= (others => 'X');
            end case;
            when "001" => ALUCtrl <= "000"; -- + addi, lw, sw
            when "010" => ALUCtrl <= "001"; -- - beq, bne
            when "101" => ALUCtrl <= "100"; -- & andi
            when others => ALUCtrl <= (others => 'X');         
     end case;
end process ALUCTRL_process;

process(ALUCtrl, RD1, ALUIn2, sa)
begin
    case ALUCtrl is
        when "000" => ALUResSignal <= RD1 + ALUIn2;
        when "001" => ALUResSignal <= RD1 - ALUIn2;
        when "010" => ALUResSignal <= to_stdlogicvector(to_bitvector(RD1) sll conv_integer(sa));
        when "011" => ALUResSignal <= to_stdlogicvector(to_bitvector(RD1) srl conv_integer(sa));
        when "100" => ALUResSignal <= RD1 and ALUIn2;
        when "101" => ALUResSignal <= RD1 or ALUIn2;
        when "110" => ALUResSignal <= RD1 xor ALUIn2;
        when "111" => ALUResSignal <= to_stdlogicvector(to_bitvector(RD1) sra conv_integer(sa)); 
        when others => ALUResSignal <= (others => 'X');

    end case;
end process;
end Behavioral;
