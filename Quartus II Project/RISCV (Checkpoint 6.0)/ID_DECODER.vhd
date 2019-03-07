-- =============================================================
-- |				RISC-V RV32I(M) ISA IMPLEMENTATION  	   |
-- =============================================================
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- =============================================================
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- =============================================================


-- *** 2/5: INSTRUCTION DECODE (ID) MODULE DESIGN ***
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PART#1: DECODER
-- " Given specific bit segments from the instruction
--   fetched word, this Decoder "classifies" the command
--   as R/I/S/U/B/J by providing the necessary control
--   signals to the following units (e.g. ALU). 
--							 				
--   CONTROL WORD TRANSLATION: X|XXX|X|X|XXX|XX|XX|X|X|X|X|X 
--     |              
--     | => BIT[0]     : JUMP   (0  : No  | 1  : Yes)
--     | => BIT[1]     : PC	    (0  : RS1 | 1  : PC) ** ALSO IMM = 4 for ALU for JUMPS **
--     | => BIT[2]     : IMM	(0  : RS2 | 1  : IMM)
--	   | => BIT[3]     : SLT    (0  : No  | 1  : Yes)
--	   | => BIT[4]     : BRANCH (0  : No  | 1  : Yes)
--     | => BIT[6..5]  : ALU OP (00 : Add | 01 : Sub | 10: Logic | 11: Shift)  --\  Since the bits [3..2] determine the ALU's output, there
--     | => BIT[8..7]  : BAS OP (00 : Srl | 01 : Sll | 10: Sra   | 11: Error)     \ is no problem using the same bits [5..4] to represent different
-- 	   | 			     LOG OP (00 : And | 01 : Or  | 10: Xor   | 11: Error)     / operations in different ALU modules. Note for AUIPC command the bit[4]
--	   |                 ADD OP (0X : Sgn | 1X : Unsg)                         --/  will be used to set the ALU result's LSB to zero. XOR = 1.
--     | => BIT[11..9] : MEM OP (000: LB  | 001: LH | 010: LW  --\ 
--	   |				         100: SB  | 101: SH | 110: SW     | The MSB signifies the operation when
--	   |				 	     111: MEM-FREE-OP)             --/  the bits[6..5] define the byte enable. 
--	   | => BIT[12]    : MEM U  (0  : Sgn | 1  : Unsg)
--     | => BIT[13]    : WB  OP (0  : No  | 1  : Yes)
--     | => BIT[16..14]: IMMGEN (000: I   | 001: S  | 010: B
--     |                         011: U   | 100: J)
--     | => BIT[17]    : BGE U  (0  : No  | 1  : Yes)
--
-- " Bits [17..14] will be used for ID controlling while [13..0] are about EXE,MEM and WB stages.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TODO:
-- * REPLACE THE SIGNALS' TEST VALUES WITH THE CORRECT ONES. ==> DONE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY ID_DECODER IS
			
	GENERIC ( CTRL_WORD_SIZE : INTEGER := 18 );
	
	PORT(
			MUX_2X1_SEL  : IN  STD_LOGIC;                    -- funct7 bit
			MUX_8X1_SEL  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- funct3
			MUX_32X1_SEL : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); -- opcode
			CONTROL_WORD : OUT STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0)
		);

END ID_DECODER;

ARCHITECTURE STRUCTURAL OF ID_DECODER IS
	                      
    -- LOAD COMANDS --------------------------------------------    BGE IMGEN WB  MEU  MEM  ALOPS ALU BR  SLT IMM PC  J    
	SIGNAL L_LB    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"000"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:0 | MEM OP:000 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 8196]
	SIGNAL L_LH    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"001"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:0 | MEM OP:001 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 8708]
	SIGNAL L_LW    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"010"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:0 | MEM OP:010 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 9220]
	SIGNAL L_LBU   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"1"&"000"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:1 | MEM OP:000 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 12292]
	SIGNAL L_LHU   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"1"&"001"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:1 | MEM OP:001 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 12804]
	-- I COMMANDS ----------------------------------------------    						
	SIGNAL I_ADDI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 11780] 
	SIGNAL I_SLLI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"01"&"11"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | BAS OP:01 | ALU OP:11 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 12004]
	SIGNAL I_SLTI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"00"&"01"&"0"&"1"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:0 | SLT:1 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 11820]
	SIGNAL I_SLTIU : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"11"&"01"&"0"&"1"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:1X | ALU OP:01 | BRANCH:0 | SLT:1 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 12204]
	SIGNAL I_XORI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"10"&"10"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | LOG OP:10 | ALU OP:10 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 12100]
	SIGNAL I_SRLI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"00"&"11"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | BAS OP:00 | ALU OP:11 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 11876]
	SIGNAL I_SRAI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"10"&"11"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | BAS OP:10 | ALU OP:11 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 12132]
	SIGNAL I_ORI   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"01"&"10"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | LOG OP:01 | ALU OP:10 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 11972]
	SIGNAL I_ANDI  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"1"&"0"&"111"&"00"&"10"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:000 | WB OP:1 | MEM U:X | MEM OP:111 | LOG OP:00 | ALU OP:10 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 11844]
	-- STORE COMMANDS ------------------------------------------
	SIGNAL S_SB    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"001"&"0"&"0"&"100"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:001 | WB OP:0 | MEM U:0 | MEM OP:100 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 18436]
	SIGNAL S_SH    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"001"&"0"&"0"&"101"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:001 | WB OP:0 | MEM U:0 | MEM OP:101 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 18948]
	SIGNAL S_SW    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"001"&"0"&"0"&"110"&"00"&"00"&"0"&"0"&"1"&"0"&"0"; -- BGE U:0 | IMMGEN:001 | WB OP:0 | MEM U:0 | MEM OP:110 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:0 | JUMP:0 -- [DECIMAL: 19460]
	-- R COMMANDS ----------------------------------------------
	SIGNAL R_ADD   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"00"&"00"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126464]
	SIGNAL R_SUB   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"00"&"01"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126496]
	SIGNAL R_SLL   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"01"&"11"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | BAS OP:01 | ALU OP:11 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126688]
	SIGNAL R_SLT   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"00"&"01"&"0"&"1"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126504]
	SIGNAL R_SLTU  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"11"&"01"&"0"&"1"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:1X | ALU OP:01 | BRANCH:0 | SLT:1 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126888]
	SIGNAL R_XOR   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"10"&"10"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | LOG OP:10 | ALU OP:10 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126784]
	SIGNAL R_SRL   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"00"&"11"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | BAS OP:00 | ALU OP:11 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126560]
	SIGNAL R_SRA   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"10"&"11"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | BAS OP:10 | ALU OP:11 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126816] || [OUT: 12128]
	SIGNAL R_OR    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"01"&"10"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | LOG OP:01 | ALU OP:10 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126656]
	SIGNAL R_AND   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"111"&"1"&"0"&"111"&"00"&"10"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:XXX | WB OP:1 | MEM U:X | MEM OP:111 | LOG OP:00 | ALU OP:10 | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 126528]
	-- BRANCH COMMANDS -----------------------------------------
	SIGNAL B_BEQ   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"010"&"0"&"0"&"111"&"00"&"01"&"1"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:010 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:1 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 36400] == problem
	SIGNAL B_BNE   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"010"&"0"&"0"&"111"&"00"&"01"&"1"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:010 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:1 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 36400] == here ??? what is alu doin with branches?
	SIGNAL B_BLT   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"010"&"0"&"0"&"111"&"00"&"01"&"1"&"1"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:010 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:1 | SLT:1 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 36408]
	SIGNAL B_BGE   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "1"&"010"&"0"&"0"&"111"&"00"&"01"&"1"&"1"&"0"&"0"&"0"; -- BGE U:1 | IMMGEN:010 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:01 | BRANCH:1 | SLT:1 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 167480]
	SIGNAL B_BLTU  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"010"&"0"&"0"&"111"&"11"&"01"&"1"&"1"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:010 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:1X | ALU OP:01 | BRANCH:1 | SLT:1 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 36792]
	SIGNAL B_BGEU  : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "1"&"010"&"0"&"0"&"111"&"11"&"01"&"1"&"1"&"0"&"0"&"0"; -- BGE U:1 | IMMGEN:010 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:1X | ALU OP:01 | BRANCH:1 | SLT:1 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 167864] 
	-- OTHERS --------------------------------------------------
	SIGNAL AUIPC   : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"011"&"1"&"0"&"111"&"00"&"00"&"0"&"0"&"1"&"1"&"0"; -- BGE U:0 | IMMGEN:011 | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:1 | JUMP:0 -- [DECIMAL: 60934]
	SIGNAL LUI     : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"011"&"1"&"0"&"111"&"00"&"00"&"0"&"0"&"0"&"0"&"0"; -- BGE U:0 | IMMGEN:011 | WB OP:1 | MEM U:X | MEM OP:111 | ADD OP:XX | ALU OP:XX | BRANCH:0 | SLT:0 | IMM:0 | PC:0 | JUMP:0 -- [DECIMAL: 60928]
	SIGNAL JALR    : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"000"&"0"&"0"&"111"&"01"&"00"&"0"&"0"&"1"&"1"&"1"; -- BGE U:0 | IMMGEN:000 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:01 | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:1 | JUMP:1 -- [DECIMAL: 3719]  <= LSB = 0 [XOR ADDOP TRICK]
	SIGNAL JAL     : STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0) := "0"&"100"&"0"&"0"&"111"&"00"&"00"&"0"&"0"&"1"&"1"&"1"; -- BGE U:0 | IMMGEN:100 | WB OP:0 | MEM U:X | MEM OP:111 | ADD OP:0X | ALU OP:00 | BRANCH:0 | SLT:0 | IMM:1 | PC:1 | JUMP:1 -- [DECIMAL: 69127]
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
								   
                               
									