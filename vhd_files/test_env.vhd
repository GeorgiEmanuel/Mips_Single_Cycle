----------------------------------------------------------------------------------
-- Company: TUCN
-- Student: Emanuel Georgi
-- 
-- Create Date: 02/21/2025 01:18:12 PM
-- Module Name: test_env - Behavioral
-- Description: MIPS 32, single-cycle

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity test_env is

    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

signal cnt : std_logic_vector(15 downto 0);
signal digits : std_logic_vector(31 downto 0);
signal Instruction, Pcinc, RD1, RD2, WD, sum, Ext_imm : std_logic_vector(31 downto 0);
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : std_logic_vector(31 downto 0);
signal func : std_logic_vector(5 downto 0);
signal sa : std_logic_vector(4 downto 0);
signal enable : std_logic;
signal enableWrite : std_logic;
signal reset : std_logic;
signal Zero : std_logic;
signal PCSrc : std_logic;


--main controls
signal RegDst, ExtOp, ALUSrc, Branch, BranchNe, Jump, MemWrite, MemtoReg, RegWrite : std_logic;
signal AluOp : std_logic_vector(2 downto 0);

Component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end Component MPG;

Component SSD is
  Port (
        clk : in STD_LOGIC;
        digits:in STD_LOGIC_VECTOR(31 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0);
        an : out STD_LOGIC_VECTOR(7 downto 0) 
         );
end Component SSD;

Component reg_file is
  Port ( ra1 : in std_logic_vector(4 downto 0);
         ra2 : in std_logic_vector(4 downto 0);
         wa  : in std_logic_vector(4 downto 0);
         wd  : in std_logic_vector(31 downto 0);
         rd1 : out std_logic_vector(31 downto 0);
         rd2 : out std_logic_vector(31 downto 0);
         regwr : in std_logic;
         clk : in std_logic
   );
end Component reg_file;      


Component I_Fetch is
  Port (clk : in std_logic;
        rst : in std_logic;    
        en : in std_logic;
        jump_address : in std_logic_vector(31 downto 0);
        branch_address : in std_logic_vector(31 downto 0);
        jump : in std_logic;
        PCSrc: in std_logic;
        current_instruction : out std_logic_vector(31 downto 0);
        next_instruction : out std_logic_vector(31 downto 0)
        );
end Component I_Fetch;


Component I_Decode is
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
end Component I_Decode;

Component Main_Control is
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
end Component Main_Control;

Component ExecutionUnit is
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
end Component ExecutionUnit;

Component MEM is
 Port ( clk : in std_logic;
        en : in std_logic;
        ALUResIn : in std_logic_vector(31 downto 0);
        RD2 :  in std_logic_vector(31 downto 0);    
        MemWrite : in std_logic;
        MemData : out std_logic_vector(31 downto 0);    
        ALUResOut : out std_logic_vector(31 downto 0)
        );
        
end Component MEM;

begin


mpg1: MPG port map(enable => enable,btn => btn(0),clk => clk);
mpg2: MPG port map(enable => reset, btn => btn(1),clk => clk);

ssd1: SSD port map(clk => clk, digits => digits, cat => cat,an => an);
I_Fetch1 : I_Fetch port map(clk => clk,
                            rst => reset, 
                            en => enable, 
                            jump_address => JumpAddress, 
                            branch_address => BranchAddress, 
                            jump => Jump,
                            PCSrc => PCSrc,
                            current_instruction => Instruction, 
                            next_instruction => Pcinc);

I_Decode1 : I_Decode port map( clk => clk,
                               en => enable,
                               Instr => Instruction(25 downto 0),
                               WD => WD,
                               RegWrite => RegWrite, 
                               RegDst => RegDst, 
                               ExtOp  => ExtOp,
                               RD1 => RD1,
                               RD2 => RD2,
                               Ext_Imm => Ext_Imm, 
                               func => func,
                               sa => sa);
                               
Main_Control1:Main_Control port map (Instruction => Instruction(31 downto 26),
                                     RegDst => RegDst,
                                     ExtOp => ExtOp,
                                     ALUSrc => ALUSrc,
                                     Branch => Branch,
                                     BranchNe => BranchNe,
                                     Jump => Jump,
                                     ALUOp => ALUOp,
                                     MemWrite => MemWrite,
                                     MemtoReg => MemtoReg,
                                     RegWrite => RegWrite);
                                     

inst_Exec: ExecutionUnit port map( 
            PCinc => PCinc,
            RD1 => RD1, 
            RD2 => RD2, 
            Ext_Imm => Ext_Imm, 
            func => func, 
            sa => sa,
            ALUSrc => ALUSrc, 
            ALUOp => ALUOp, 
            branch_address => BranchAddress, 
            ALURes => ALURes, 
            Zero => Zero 
         );
         
inst_Mem: MEM port map(
            clk => clk,
            en => enable,
            ALUResIn => ALURes,
            RD2  => RD2,
            MemWrite  => MemWrite,
            MemData   => MemData,
            ALUResOut  => ALURes1
        );

        


        

WD <= MemData when MemtoReg = '1' else ALURes1;
PCSrc <= (Zero and Branch) or ((not Zero) and BranchNe);
JumpAddress <= PCinc(31 downto 28) & Instruction(27 downto 0);


with sw(7 downto 5) select
    digits <= Instruction when "000",
              PCinc when "001",
              RD1 when "010",
              RD2 when "011",
              Ext_Imm when "100",
              ALURes when "101",
              MemData when "110",
              WD when "111",
              (others => 'X') when others;

led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;  

end Behavioral;
