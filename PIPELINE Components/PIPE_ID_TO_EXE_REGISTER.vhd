-- +===========================================================+
-- |		RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos			       |
-- |supervisor: Aristides Efthymiou			       |
-- |===========================================================|
-- |		UNIVERSITY OF IOANNINA - 2019      	       |
-- |  		     VCAS LABORATORY			       |
-- +===========================================================+

-- *** PIPELINE MODULES DESIGN ***
---------------------------------------------------------------
-- PART #2: ID -> EXE PIPELINE REGISTER
---------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PIPE_ID_TO_EXE_REGISTER IS

	PORT( 
		CLK,RST : IN  STD_LOGIC;
		FLUSH   : IN  STD_LOGIC;
		STALL   : IN  STD_LOGIC;
		
		I_RS1_VAL: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_RS2_VAL: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_IMM_VAL: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_RD_ADDR: IN STD_LOGIC_VECTOR(4  DOWNTO 0);
		I_PC_VAL : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			
		I_TARGET_ADDR: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		I_CTRL_WORD: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		
		I_FWD_A  : IN STD_LOGIC_VECTOR(1  DOWNTO 0);
		I_FWD_B  : IN STD_LOGIC_vECTOR(1  DOWNTO 0);
			
		O_RS1_VAL: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		O_RS2_VAL: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		O_IMM_VAL: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		O_RD_ADDR: OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
		O_PC_VAL : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			
		O_TARGET_ADDR: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		O_CTRL_WORD : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			
		O_FWD_A  : OUT STD_LOGIC_VECTOR(1  DOWNTO 0);
		O_FWD_B  : OUT STD_LOGIC_vECTOR(1  DOWNTO 0)
			
	    );
		
END PIPE_ID_TO_EXE_REGISTER;

ARCHITECTURE BEHAVIORAL OF PIPE_ID_TO_EXE_REGISTER IS 
			
	
	SIGNAL BUF_RS1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_RS2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_IMM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_RD  : STD_LOGIC_VECTOR(4  DOWNTO 0);
	
	SIGNAL BUF_PC      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_TARG_AD : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_CTRL_WRD: STD_LOGIC_VECTOR(17 DOWNTO 0);
	
	SIGNAL BUF_FWD_A   : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL BUF_FWD_B   : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	BEGIN
			
		PROC: PROCESS(CLK,RST,FLUSH,STALL)
		
			BEGIN
			
			IF (RST = '1') THEN -- NOP
			
				BUF_RS1 <= (OTHERS =>'0'); -- ZERO 
				BUF_RS2 <= (OTHERS =>'0'); -- We dont care
				BUF_IMM <= (OTHERS =>'0'); -- ZERO
				BUF_RD  <= "00000";        -- ZERO REG
				
				BUF_PC       <= (OTHERS => '0'); -- We dont care
				BUF_TARG_AD  <= (OTHERS => '0'); -- We dont care
				BUF_CTRL_WRD <= "0"&"0"&"111"&"00"&"00"&"0"&"0"&"0"&"0"&"1"&"0"&"0"&"0"&"0"; -- NOP Ctrl signal
				
				BUF_FWD_A <= "00"; -- No forwards
				BUF_FWD_B <= "00";
				
			ELSIF (CLK'EVENT AND CLK = '1') THEN -- NOP
			
				IF (FLUSH = '1') THEN -- FLUSH > STALL
					
					BUF_RS1 <= (OTHERS =>'0'); -- ZERO 
					BUF_RS2 <= (OTHERS =>'0'); -- We dont care
					BUF_IMM <= (OTHERS =>'0'); -- ZERO
					BUF_RD  <= "00000";        -- ZERO REG
					
					BUF_PC       <= (OTHERS => '0'); -- We dont care
					BUF_TARG_AD  <= (OTHERS => '0'); -- We dont care
					BUF_CTRL_WRD <= "0"&"0"&"111"&"00"&"00"&"0"&"0"&"0"&"0"&"1"&"0"&"0"&"0"&"0"; -- NOP Ctrl signal
					
					BUF_FWD_A <= "00"; -- No forwards
					BUF_FWD_B <= "00";
					
				ELSIF(FLUSH = '0' AND STALL = '1') THEN -- NOP
				
					BUF_RS1 <= (OTHERS =>'0'); -- ZERO 
					BUF_RS2 <= (OTHERS =>'0'); -- We dont care
					BUF_IMM <= (OTHERS =>'0'); -- ZERO
					BUF_RD  <= "00000";        -- ZERO REG
					
					BUF_PC       <= (OTHERS => '0'); -- We dont care
					BUF_TARG_AD  <= (OTHERS => '0'); -- We dont care
					BUF_CTRL_WRD <= "0"&"0"&"111"&"00"&"00"&"0"&"0"&"0"&"0"&"1"&"0"&"0"&"0"&"0"; -- NOP Ctrl signal
					
					BUF_FWD_A <= "00"; -- No forwards
					BUF_FWD_B <= "00";
					
				ELSIF(FLUSH = '0' AND STALL = '0') THEN
				
					BUF_RS1 <= I_RS1_VAL;
					BUF_RS2 <= I_RS2_VAL;
					BUF_IMM <= I_IMM_VAL;
					BUF_RD  <= I_RD_ADDR;
					
					BUF_PC       <= I_PC_VAL;
					BUF_TARG_AD  <= I_TARGET_ADDR;
					BUF_CTRL_WRD <= I_CTRL_WORD;
					
					BUF_FWD_A <= I_FWD_A;
					BUF_FWD_B <= I_FWD_B;
					
				END IF;
				
			END IF;
			
		END PROCESS;
		
		O_RS1_VAL <= BUF_RS1;
		O_RS2_VAL <= BUF_RS2;
		O_IMM_VAL <= BUF_IMM;
		O_RD_ADDR <= BUF_RD;
		O_PC_VAL  <= BUF_PC;
		
		O_TARGET_ADDR <= BUF_TARG_AD;
		O_CTRL_WORD   <= BUF_CTRL_WRD;
		
		O_FWD_A <= BUF_FWD_A;
		O_FWD_B <= BUF_FWD_B;
		
END BEHAVIORAL;