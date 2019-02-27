-- =============================================================
-- |		RISC-V RV32I(M) ISA IMPLEMENTATION             |
-- =============================================================
-- |student:    Deligiannis Nikos			       |
-- |supervisor: Aristides Efthymiou			       |
-- =============================================================
-- |		UNIVERSITY OF IOANNINA - 2019 		       |
-- |  			VCAS LABORATORY 	               |
-- =============================================================


-- *** 2/5: INSTRUCTION DECODE (ID) MODULE DESIGN ***
---------------------------------------------------------
-- PART#1: DECODER
-- " Given specific bit segments from the instruction
--   fetched word, this Decoder "classifies" the command
--   as R/I/S/U/B/J by providing the necessary control
--   signals to the following units (e.g. ALU). "
---------------------------------------------------------

-- TODO:
-- * REPLACE THE SIGNALS' TEST VALUES WITH THE CORRECT ONES.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY ID_DECODER IS
			
	GENERIC ( CTRL_WORD_SIZE : INTEGER := 10 );
	
	PORT(
			MUX_2X1_SEL  : IN  STD_LOGIC;                    -- funct7 bit
			MUX_8X1_SEL  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- funct3
			MUX_32X1_SEL : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); -- opcode
			CONTROL_WORD : OUT STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0)
		);

END ID_DECODER;

ARCHITECTURE STRUCTURAL OF ID_DECODER IS
	
    -- LOAD COMANDS --------------------------------------------    TESTING VALS <= TO BE CHANGED ~ ALU / MEM / WB NEEDS
	SIGNAL L_LB    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000001"; 
	SIGNAL L_LH    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000010";
	SIGNAL L_LW    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000011";
	SIGNAL L_LBU   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000100";
	SIGNAL L_LHU   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000101";
	-- I COMMANDS ----------------------------------------------
	SIGNAL I_ADDI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000110";
	SIGNAL I_SLLI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000000111";
	SIGNAL I_SLTI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001000";
	SIGNAL I_SLTIU : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001001";
	SIGNAL I_XORI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001010";
	SIGNAL I_SRLI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001011";
	SIGNAL I_SRAI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001100";
	SIGNAL I_ORI   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001101";
	SIGNAL I_ANDI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001110";
	-- STORE COMMANDS ------------------------------------------
	SIGNAL S_SB    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000001111"; 
	SIGNAL S_SH    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010000";
	SIGNAL S_SW    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010001";
	-- R COMMANDS ----------------------------------------------
	SIGNAL R_ADD   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010010";
	SIGNAL R_SUB   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010011";
	SIGNAL R_SLL   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010100";
	SIGNAL R_SLT   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010101";
	SIGNAL R_SLTU  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010110";
	SIGNAL R_XOR   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000010111";
	SIGNAL R_SRL   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011000";
	SIGNAL R_SRA   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011001";
	SIGNAL R_OR    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011010";
	SIGNAL R_AND   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011100";
	-- BRANCH COMMANDS -----------------------------------------
	SIGNAL B_BEQ   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011101";
	SIGNAL B_BNE   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011110";
	SIGNAL B_BLT   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000011111";
	SIGNAL B_BGE   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100000";
	SIGNAL B_BLTU  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100001";
	SIGNAL B_BGEU  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100010";
	-- OTHERS --------------------------------------------------
	SIGNAL AUIPC   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100011";
	SIGNAL LUI     : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100100";
	SIGNAL JALR    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100101";
	SIGNAL JAL     : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0000100110";
	-- CARRIERS ------------------------------------------------
	SIGNAL BUF_2A   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	SIGNAL BUF_2B   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	SIGNAL BUF_2C   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	
	SIGNAL BUF_8A   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	SIGNAL BUF_8B   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	SIGNAL BUF_8C   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	SIGNAL BUF_8D   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	SIGNAL BUF_8E   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0);
	
	BEGIN
		-- MUX LEVEL 1 --
		MUX_2X1_A : MUX2X1
					GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
					PORT    MAP ( 
								   D0  => I_SRLI,
								   D1  => I_SRAI,
								   SEL => MUX_2X1_SEL,
								   O   => BUF_2A
								);
		MUX_2X1_B : MUX2X1
					GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
					PORT    MAP ( 
								  D0   => R_ADD,
								  D1   => R_SUB,
								  SEL  => MUX_2X1_SEL,
								  O    => BUF_2B
								);
		MUX_2X1_C : MUX2X1
					GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
					PORT    MAP (
								  D0   => R_SRL,
								  D1   => R_SRA,
								  SEL  => MUX_2X1_SEL,
								  O    => BUF_2C
								);
		-- MUX LEVEL 2 --
		MUX_8X1_A : MUX8X1 
					GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
					PORT    MAP ( 
								  D0   => L_LB,  -- fucnt3 000
								  D1   => L_LH,  -- funct3 001
								  D2   => L_LW,  -- funct3 010
								  D4   => L_LBU, -- funct3 100 
								  D5   => L_LHU, -- funct3 101
								  SEL  => MUX_8X1_SEL,
								  O    => BUF_8A
								 );
		MUX_8X1_B : MUX8X1		
					GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
					PORT    MAP ( 
								  D0  => I_ADDI, -- funct3 000
								  D1  => I_SLLI, -- funct3 001
								  D2  => I_SLTI, -- funct3 010
								  D3  => I_SLTIU,-- funct3 011
								  D4  => I_XORI, -- funct3 100
								  D5  => BUF_2A, -- funct3 101 
								  D6  => I_ORI,  -- funct3 110
								  D7  => I_ANDI, -- funct3 111
								  SEL => MUX_8X1_SEL,
								  O   => BUF_8B
								 );
		MUX_8X1_C: MUX8X1
				   GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
				   PORT    MAP ( 
								 D0   => S_SB, -- funct3 000
								 D1   => S_SH, -- funct3 001
								 D2   => S_SW, -- funct3 010
								 SEL  => MUX_8X1_SEL,
								 O    => BUF_8C
								);
		MUX_8X1_D: MUX8X1
				   GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
				   PORT    MAP (
								 D0   => BUF_2B, -- funct3 000
								 D1   => R_SLL,  -- funct3 001
								 D2   => R_SLT,  -- funct3 010
								 D3   => R_SLTU, -- funct3 011
								 D4   => R_XOR,  -- funct3 100
								 D5   => BUF_2C, -- funct3 101
								 D6   => R_OR,   -- funct3 110
								 D7   => R_AND,  -- funct3 111
								 SEL  => MUX_8X1_SEL,
								 O    => BUF_8D
								);
		MUX_8X1_E: MUX8X1
				   GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
				   PORT    MAP (
								 D0   => B_BEQ,  -- funct3 000
								 D1   => B_BNE,  -- funct3 001
								 D4   => B_BLT,  -- funct3 100
								 D5   => B_BGE,  -- funct3 101
								 D6   => B_BLTU, -- funct3 110
								 D7   => B_BGEU, -- funct3 111
								 SEL  => MUX_8X1_SEL,
								 O    => BUF_8E
								);
		-- MUX LEVEL 3 --
		MUX_32X1: MUX32X1
				  GENERIC MAP ( INSIZE => CTRL_WORD_SIZE )
				  PORT    MAP ( 
								D0  => BUF_8A,
								D4  => BUF_8B,
								D5  => AUIPC,
								D8  => BUF_8C,
								D12 => BUF_8D,
								D13 => LUI,
								D24 => BUF_8E,
								D25 => JALR,
								D27 => JAL,
								SEL => MUX_32X1_SEL,
								O   => CONTROL_WORD
							  );
						
								  
		
END STRUCTURAL;
								   
                               
									
