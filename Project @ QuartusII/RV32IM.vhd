-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+

-- *** RISC-V 32I WITH 5 PIPELINE STAGES IMPLEMENTATION ***
----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;
USE WORK.PIPELINE.ALL;

ENTITY RV32IM IS 

	PORT ( 
			CLK : IN  STD_LOGIC;
			RST : IN  STD_LOGIC;
		 
			-- TESTING SIGNALS --
			PC  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			I_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			I_D : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			MEM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			
		 );
		 
		 
END RV32IM;

ARCHITECTURE STRUCTURAL OF RV32IM IS 
	
	-- PIPELINE CONTROL --
	SIGNAL PIPE_STALL_SIG: STD_LOGIC;
	SIGNAL PIPE_FLUSH_SIG: STD_LOGIC;
		
		-- PIPE REG A [ IF -> ID ]
		SIGNAL PIPE_IN_IFWORD : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_IN_PC_VAL : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_OUT_IFWORD: STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_OUT_PC_VAL: STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- PIPE REG B [ ID -> EXE ]
		 
	
	-- PC REGISTER I/O -- 
	SIGNAL PC_IN_NEXT_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_OUT_DUMP   : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The Output won't be used due to the nature of the M4K blocks.
														  -- The register will actually be bypassed.
	-- IF I/O --
	SIGNAL IF_OUT_IFWORD : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IF_OUT_PC_VAL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- ID I/O --
	SIGNAL ID_IN_WB_RD_ADR: STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL ID_IN_WB_RD_VAL: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_IN_RD_EXE   : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL ID_IN_RD_MEM   : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL ID_IN_LOAD_EXE : STD_LOGIC;
	SIGNAL ID_OUT_RS1_VAL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_RS2_VAL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_RD_ADR  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_IMM     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_J_TARGET: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_PC_VAL  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_OPCODES : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL ID_OUT_STALL   : STD_LOGIC;
	SIGNAL ID_OUT_FWD_A   : STD_LOGIC_VECTOR(1  DOWNTO 0);
	SIGNAL ID_OUT_FWD_B   : STD_LOGIC_VECTOR(1  DOWNTO 0);
	SIGNAL ID_OUT_FWD_C   : STD_LOGIC;
	
	
	
	BEGIN
	
	-- PC REGISTER --
	PC0: PC_REGISTER
		PORT MAP( CLK => CLK, RST => RST, STALL => PIPE_STALL_SIG, NEXT_PC => PC_IN_NEXT_PC, ADDRESS => PC_OUT_DUMP );
	
	-- INSTRUCTION FETCH --	
	IF1: INSTRUCTION_FETCH                                    
		 PORT MAP(  
					GLB_CLK => CLK, 
					STALL   => PIPE_STALL_SIG, 
					PC      => PC_IN_NEXT_PC, -- Bypassing the PC Register
					MEMWORD => IF_OUT_IFWORD, 
					PC_ADD  => IF_OUT_PC_VAL 
				 );	
				  
	--  			FETCHED WORD [FROM I$]							 PC REGISTER VALUE
	-- +------------------- \/ ------------------------------------------- \/ ---------------------+
	-- |						IF ->	PIPELINE REGISTER A -> ID								   |			   
	-- +------------------- \/ ------------------------------------------- \/ ---------------------+

	PIPE_A: PIPE_IF_TO_ID_REGISTER 
			PORT MAP( 
						CLK    	  => CLK, 
						RST 	  => RST,
						FLUSH 	  => PIPE_FLUSH_SIG,
						STALL 	  => PIPE_STALL_SIG,
						I_IF_WORD => PIPE_IN_IFWORD,
						I_PC_ADDR => PIPE_IN_PC_VAL,
						O_IF_WORD => PIPE_OUT_IFWORD,
						O_PC_ADDR => PIPE_OUT_PC_VAL
					 );
					  
	ID2: INSTRUCTION_DECODE
		 GENERIC MAP( CTRL_WORD_TOTAL => 20, CTRL_WORD_OUT => 18 )
		 PORT    MAP(	
						CLK 	   => CLK,
						RST 	   => RST,
						WB_RD_LOAD => ID_IN_WB_RD_ADR, -- Input from WB
						WB_RD_DATA => ID_IN_WB_RD_VAL, -- Input from S
						PC_VALUE   => PIPE_OUT_PC_VAL, -- 
						IF_WORD    => PIPE_OUT_IFWORD, -- 
						RD_FROM_EXE=> ID_IN_RD_EXE,
						RD_FROM_MEM=> ID_IN_RD_MEM,
						PIPE_LOAD_E=> ID_IN_LOAD_EXE,
						RS1_VALUE  => ID_OUT_RS1_VAL,
						RS2_VALUE  => ID_OUT_RS2_VAL,
						RD_ADDR    => ID_OUT_RD_ADR,
						IMMEDIATE  => ID_OUT_IMM,
						TARGET_AD  => ID_OUT_J_TARGET,
						PC_VALUE_O => ID_OUT_PC_VAL,
						CTRL_WORD  => ID_OUT_OPCODES,
						PIPE_STALL => PIPE_STALL_SIG,
						PIPE_FWDA  => ID_OUT_FWD_A,
						PIPE_FWDB  => ID_OUT_FWD_B,
						PIPE_FWDC  => ID_OUT_FWD_C
					);

	--------------------
	PC <= PC_OUT_DUMP;
		
END STRUCTURAL;
		