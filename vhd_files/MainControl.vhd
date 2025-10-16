

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_Unsigned.ALL;

entity Main_Control is
 Port (Instruction : in std_logic_vector(5 downto 0);--Opcode
       RegDst : out std_logic;
       ExtOp : out std_logic;
       ALUSrc : out std_logic;
       Branch : out std_logic;
       BranchNe : out std_logic;
       Jump : out std_logic;
       ALUOp : out std_logic_vector(2 downto 0);
       MemWrite : out std_logic;
       MemtoReg : out std_logic;
       RegWrite : out std_logic
       );
end Main_Control;

architecture Behavioral of Main_Control is


begin

control:process(Instruction)
variable reg_var:std_logic;
begin
       RegDst <= '0';
       ExtOp <= '0';
       ALUSrc <= '0';
       Branch <= '0';
       BranchNe <= '0';
       Jump <= '0';
       ALUOp <= "000";
       MemWrite <= '0';
       MemtoReg <= '0';
       RegWrite <= '0';
    case Instruction is
         when "000000" => --R type
                ALUOp <= "000";
                RegDst <= '1';
                RegWrite <= '1';
         when "001000" => --addi
                ALUOp <= "001";
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';  
         when "100011" => --lw
                ALUOp <= "001";
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
         when "101011" => --sw
                ALUOp <= "001";
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';     
         when "000100" => --beq
                ALUOp <= "010";
                ExtOp <= '1';
                Branch <= '1';
         when "001100" => --andi
                ALUOp <= "101";
                ALUSrc <= '1';
                RegWrite <= '1';
         when "000101" => --bne
                AluOp <= "010";
                ExtOp <= '1';
                BranchNe <= '1';
        
         when "000010" => --jump
               Jump <= '1';             
         when others => 
               ExtOp <= '0';
               ALUSrc <= '0';
               Branch <= '0';
               Jump <= '0';
               ALUOp <= "000";
               MemWrite <= '0';
               MemtoReg <= '0';
               RegWrite <= '0';         
    end case;            
        
              
end process control;

end Behavioral;
