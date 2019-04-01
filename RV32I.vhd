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
USE WORK.PIPELINE.ALL;
USE WORK.TOOLBOX.ALL;

ENTITY RV32I IS 

	PORT ( 
			CLK : IN  STD_LOGIC;
			RST : IN  STD_LOGIC;
		 
			-- TESTING SIGNALS --
			PC  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			I_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			I_D : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			ALU : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			MEM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB  : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
			-- EXTRA
			NPC_PLUS_4_MUX : OUT STD_LOGIC;
			NPC_TEST : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC_VAL_REG_A : OUT STD_LOGIC_vECTOR(31 DOWNTO 0);
			PC_VAL_REG_B : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			EXE_TNT		 : OUT STD_LOGIC;
			ALU_VALUE_A  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_VALUE_B  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_OPCODE_T : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
			
		 );
		 
		 
END RV32I;

ARCHITECTURE STRUCTURAL OF RV32I IS 
	
	-- PIPELINE CONTROL --
	SIGNAL PIPE_STALL_SIG: STD_LOGIC;
	SIGNAL PIPE_FLUSH_SIG: STD_LOGIC;
		
		-- PIPE REG A [ IF -> ID ]
		SIGNAL PIPE_A_OUT_IFWORD: STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_A_OUT_PC_VAL: STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- PIPE REG B [ ID -> EXE ]
		SIGNAL PIPE_B_OUT_RS1_VAL    : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_B_OUT_RS2_VAL    : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_B_OUT_RD_ADDR    : STD_LOGIC_VECTOR(4  DOWNTO 0);
		SIGNAL PIPE_B_OUT_IMM        : STD_LOGIC_VECTOR(31 DOWNTO 0); 
		SIGNAL PIPE_B_OUT_TARGET_J   : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_B_OUT_PC_VAL     : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_B_OUT_CTRL_WORD  : STD_LOGIC_VECTOR(17 DOWNTO 0);
		SIGNAL PIPE_B_OUT_FWD_A      : STD_LOGIC_VECTOR(1  DOWNTO 0);
		SIGNAL PIPE_B_OUT_FWD_B      : STD_LOGIC_VECTOR(1  DOWNTO 0);
		-- PIPE REG C [ EXE -> MEM ]
		SIGNAL PIPE_C_OUT_WB_OPCODE  : STD_LOGIC_VECTOR(3  DOWNTO 0);
		SIGNAL PIPE_C_OUT_MEM_OP_DUMP: STD_LOGIC_VECTOR(3  DOWNTO 0);
		SIGNAL PIPE_C_OUT_RD_ADDR  	 : STD_LOGIC_VECTOR(4  DOWNTO 0); 
		SIGNAL PIPE_C_RS2_VAL_DUMP   : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_C_OUT_ALU_RES	 : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_C_OUT_FWD_C 	 : STD_LOGIC;
		-- PIPE REG D [ MEM -> WB ]
		SIGNAL PIPE_D_OUT_MEM_RES       : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_D_OUT_ALU_RES       : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL PIPE_D_OUT_RD_ADDR       : STD_LOGIC_VECTOR(4  DOWNTO 0);
		SIGNAL PIPE_D_OUT_WB_LOG_OPCODE : STD_LOGIC_VECTOR(3  DOWNTO 0);
		
	
	-- PC REGISTER I/O -- 
	SIGNAL PC_IN_NEXT_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_OUT_DUMP   : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The Output won't be used due to the nature of the M4K blocks.
														  -- The register will actually be bypassed.
	-- IF I/O --
														  -- In case of RST the address must be 0b00 and not 4
	SIGNAL IF_IN_BUF 	 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The Assembler starts at addr 0b00
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
	SIGNAL ID_OUT_RD_ADR  : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL ID_OUT_IMM     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_J_TARGET: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_PC_VAL  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_OUT_OPCODES : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL ID_OUT_STALL   : STD_LOGIC;
	SIGNAL ID_OUT_FWD_A   : STD_LOGIC_VECTOR(1  DOWNTO 0);
	SIGNAL ID_OUT_FWD_B   : STD_LOGIC_VECTOR(1  DOWNTO 0);
	SIGNAL ID_OUT_FWD_C   : STD_LOGIC;  -- This will bypass the Pipeline Register B 
	                                    -- And go directly to C
	-- EXE I/O & PRE-LOGIC --
	SIGNAL A_B_SELECTOR   : STD_LOGIC_VECTOR(3  DOWNTO 0);
	SIGNAL A			  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL B			  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_OPCODE 	  : STD_LOGIC_VECTOR(8  DOWNTO 0);
	SIGNAL TO_OTHER_PIPE  : STD_LOGIC_VECTOR(4  DOWNTO 0);
	
	SIGNAL FORWARD_FROM_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FORWARD_FROM_EXE : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_FWD_B_A 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_FWD_B_B 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL TO_ALU_A			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL TO_ALU_B 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL ALU_RES 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BRANCH_T_NT 		: STD_LOGIC;
	
	SIGNAL NPC_JALR			: STD_LOGIC;
	SIGNAL NPC_JUMP 		: STD_LOGIC;
	
	SIGNAL BUF_ADR_MUX 	    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_PLUS_FOUR     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- MEM I/O --
	SIGNAL BUF_FWDC_MUX 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FORWARD_TO_MEM_FROM_MEM 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_OUT_RES				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- WB I/O -- 
	SIGNAL WB_IN_MEM_OR_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	
	
	
	BEGIN
	
	-- PC REGISTER --
	PC0: PC_REGISTER
		PORT MAP( CLK => CLK, RST => RST, STALL => PIPE_STALL_SIG, NEXT_PC => PC_IN_NEXT_PC, ADDRESS => PC_OUT_DUMP );
	
	NPC_MUX_RST: MUX2X1 
				 GENERIC MAP ( INSIZE => 32 )
				 PORT    MAP ( 
							   D0     => PC_IN_NEXT_PC,
							   D1 	  => (OTHERS => '0'),
							   SEL 	  => RST,
							   O 	  => IF_IN_BUF
							  );
	
	-- INSTRUCTION FETCH --	
	IF1: INSTRUCTION_FETCH                             
		 PORT MAP(  
					GLB_CLK => CLK, 
					STALL   => PIPE_STALL_SIG, 
					PC      => IF_IN_BUF, -- Bypassing the PC Register
					MEMWORD => IF_OUT_IFWORD, 
					PC_ADD  => IF_OUT_PC_VAL 
				 );	
				  
	--  			FETCHED WORD [FROM I$]							 PC REGISTER VALUE
	-- +------------------- \/ ------------------------------------------- \/ ---------------------+
	-- |						IF ->	PIPELINE REGISTER A -> ID								   |			   
	-- +------------------- \/ ------------------------------------------- \/ ---------------------+

	PIPE_A: PIPE_IF_TO_ID_REGISTER 
			PORT MAP(  -- Control
						CLK    	  => CLK, 
						RST 	  => RST,
						FLUSH 	  => PIPE_FLUSH_SIG,
						STALL 	  => PIPE_STALL_SIG,
						-- Inputs
						I_IF_WORD => IF_OUT_IFWORD,
						I_PC_ADDR => IF_OUT_PC_VAL,
						-- Outputs
						O_IF_WORD => PIPE_A_OUT_IFWORD,
						O_PC_ADDR => PIPE_A_OUT_PC_VAL
					 );
					 
	ID2: INSTRUCTION_DECODE
		 GENERIC MAP( CTRL_WORD_TOTAL => 20, CTRL_WORD_OUT => 18 )
		 PORT    MAP(	
						CLK 	   => CLK,
						RST 	   => RST,
						
						WB_RD_LOAD => ID_IN_WB_RD_ADR, 	-- Input from WB
						WB_RD_DATA => ID_IN_WB_RD_VAL, 	-- Input from WB
						PC_VALUE   => PIPE_A_OUT_PC_VAL,-- Input from IF (Reg A)
						IF_WORD    => PIPE_A_OUT_IFWORD,-- Input from IF (Reg A)
						RD_FROM_EXE=> ID_IN_RD_EXE, 	-- Input from EXE
						RD_FROM_MEM=> ID_IN_RD_MEM, 	-- Input from MEM
						PIPE_LOAD_E=> ID_IN_LOAD_EXE, 	-- Input from EXE 
					
						RS1_VALUE  => ID_OUT_RS1_VAL, 
						RS2_VALUE  => ID_OUT_RS2_VAL,
						RD_ADDR    => ID_OUT_RD_ADR,
						IMMEDIATE  => ID_OUT_IMM,
						TARGET_AD  => ID_OUT_J_TARGET,
						PC_VALUE_O => ID_OUT_PC_VAL,
						CTRL_WORD  => ID_OUT_OPCODES,  -- To RERGROUP Module.
					
						PIPE_STALL => PIPE_STALL_SIG,  -- Stall control signals is generated here.
						PIPE_FWDA  => ID_OUT_FWD_A,    -- To Pipeline Register B
						PIPE_FWDB  => ID_OUT_FWD_B,    -- /
						PIPE_FWDC  => ID_OUT_FWD_C     -- To Pipeline Register C !!!
					);
					
	--     RS1  RS2  IMM   RD [ADR]	   PC		  TARGET ADR  FWD_A       FWD_B      CTRLWORD
    -- + -- \/ - \/ - \/ - \/ -------- \/ -------- \/ -------- \/ -------- \/ -------- \/ ---------+
	-- |						ID ->	PIPELINE REGISTER B -> EXE								   |			   
	-- + -- \/ - \/ - \/ - \/ -------- \/ -------- \/ -------- \/ -------- \/ -------- \/ ---------+
	
	PIPE_B: PIPE_ID_TO_EXE_REGISTER
			PORT MAP(	-- Control
						CLK 			=> CLK,
						RST 			=> RST,
						FLUSH 			=> PIPE_FLUSH_SIG,
						STALL 			=> PIPE_STALL_SIG,
						-- Inputs
						I_RS1_VAL 		=> ID_OUT_RS1_VAL,
						I_RS2_VAL 		=> ID_OUT_RS2_VAL,
						I_IMM_VAL 		=> ID_OUT_IMM,
						I_RD_ADDR 		=> ID_OUT_RD_ADR,
						I_PC_VAL  		=> ID_OUT_PC_VAL,
						I_TARGET_ADDR 	=> ID_OUT_J_TARGET,
						I_CTRL_WORD 	=> ID_OUT_OPCODES,
						I_FWD_A 		=> ID_OUT_FWD_A,
						I_FWD_B 		=> ID_OUT_FWD_B,
						-- Outputs
						O_RS1_VAL 		=> PIPE_B_OUT_RS1_VAL,
						O_RS2_VAL  		=> PIPE_B_OUT_RS2_VAL,
						O_IMM_VAL 		=> PIPE_B_OUT_IMM,
						O_RD_ADDR 		=> PIPE_B_OUT_RD_ADDR,
						O_PC_VAL 		=> PIPE_B_OUT_PC_VAL,
						O_TARGET_ADDR 	=> PIPE_B_OUT_TARGET_J,
						O_CTRL_WORD 	=> PIPE_B_OUT_CTRL_WORD,
						O_FWD_A			=> PIPE_B_OUT_FWD_A,
						O_FWD_B 		=> PIPE_B_OUT_FWD_B
					);
					
	CTRL_FIX: CONTROL_WORD_REGROUP
			  PORT MAP(
						CTRL_WORD 		=> PIPE_B_OUT_CTRL_WORD,
						TO_EXE_SELECTOR => A_B_SELECTOR,
						TO_EXE_ALU		=> ALU_OPCODE,
						TO_OTHERS		=> TO_OTHER_PIPE
					  );
					  
	NPC_JALR <= A_B_SELECTOR(3); -- Will be used later for Next PC 
	NPC_JUMP <= A_B_SELECTOR(2); -- Multiplexers
					  
	-- Decide which values are going to ALU				  
	ALU_IN: DECODE_TO_EXECUTE
			  PORT MAP(
						RS1 	=> PIPE_B_OUT_RS1_VAL,
						RS2		=> PIPE_B_OUT_RS2_VAL,
						PC_I 	=> PIPE_B_OUT_PC_VAL,
						IMME 	=> PIPE_B_OUT_IMM,
						
						JALR	=> A_B_SELECTOR(3),
						JUMP 	=> A_B_SELECTOR(2),
						PC		=> A_B_SELECTOR(1),
						IMM		=> A_B_SELECTOR(0),
						
						A		=> A,
						B		=> B
					  );
					  
	-- FORWARD MUXES [ B path < A path ]
	FWDB_A: MUX2X1 -- Forward B for A
			GENERIC MAP( INSIZE => 32 )
			PORT    MAP(
						 D0 	=> A,
						 D1 	=> FORWARD_FROM_MEM,
						 SEL 	=> PIPE_B_OUT_FWD_B(1), -- #Bit 1 for RS1 , 0 for RS2/IMM etc.
						 O	 	=> BUF_FWD_B_A
						);
	FWDA_A: MUX2X1 -- Forward A for A
			GENERIC MAP( INSIZE => 32 )
			PORT    MAP(
						 D0 	=> BUF_FWD_B_A,
						 D1 	=> FORWARD_FROM_EXE,
						 SEL 	=> PIPE_B_OUT_FWD_A(1), -- #Bit 1 for RS1 , 0 for RS2/IMM etc.
						 O 		=> TO_ALU_A
						);
	FWDB_B: MUX2X1 -- Forward B for B
			GENERIC MAP( INSIZE => 32 )
			PORT    MAP( 
						 D0 	=> B,
						 D1 	=> FORWARD_FROM_MEM,
						 SEL 	=> PIPE_B_OUT_FWD_B(0), -- #Bit 1 for RS1 , 0 for RS2/IMM etc.
						 O 		=> BUF_FWD_B_B
						);
	FWDA_B: MUX2X1 -- Forward A for B
			GENERIC MAP( INSIZE => 32 )
			PORT    MAP(
						 D0 	=> BUF_FWD_B_B,
						 D1 	=> FORWARD_FROM_EXE,
						 SEL 	=> PIPE_B_OUT_FWD_A(0), -- #Bit 1 for RS1 , 0 for RS2/IMM etc.
						 O 		=> TO_ALU_B
						);
						
	-- INSTRUCTION EXECUTE - ALU -- 
	EXE3: EXE
		 PORT MAP(
					A   => TO_ALU_A,
					B   => TO_ALU_B,
					OP  => ALU_OPCODE,
					RES => ALU_RES,
					TNT => BRANCH_T_NT
				 );
				
	-- FEEDBACK TO PREVIOUS MODULES --
	
	ID_IN_RD_EXE  	<= PIPE_B_OUT_RD_ADDR;
	ID_IN_LOAD_EXE	<= NOT TO_OTHER_PIPE(2); -- This is the MSB of MEMOP CTRL Signal (0 for loads, 1 for Stores and mem-free-ops)
	
	PIPE_FLUSH_SIG <= NPC_JUMP OR BRANCH_T_NT;   -- Flush control signal is generted here.

		-- NEXT PC CALCULATION --
		ADR_MUX: MUX2X1 
				 GENERIC MAP( INSIZE => 32 )
				 PORT    MAP(
							  D0 	 => PIPE_B_OUT_TARGET_J,
							  D1 	 => ALU_RES(31 DOWNTO 1) & "0", -- This path will be taken only if the command is a JALR (LSB = 0).
							  SEL 	 => NPC_JALR,
							  O  	 => BUF_ADR_MUX
							 );
							  
		PC_P4: PC_PLUS_4 PORT MAP ( PC => PIPE_A_OUT_PC_VAL, RES => PC_PLUS_FOUR );

		NPC_MUX: MUX2X1
				 GENERIC MAP( INSIZE => 32 )
				 PORT  	 MAP(
							  D0     => BUF_ADR_MUX,
							  D1	 => PC_PLUS_FOUR,
							  SEL 	 => NPC_JUMP NAND BRANCH_T_NT,
							  O 	 => PC_IN_NEXT_PC -- Input to PC Register (and I$).
							 );

	--  		ALU RES 			RD[ADR]             RS2                 OPCODE[MEM&WB]
	-- +-------- \/ ---------------- \/ ---------------- \/ ---------------- \/ -------------------+
	-- |						EXE ->	PIPELINE REGISTER C -> MEM								   |			   
	-- +-------- \/ ---------------- \/ ---------------- \/ ---------------- \/ -------------------+
	
	PIPE_C: PIPE_EXE_TO_MEM_REGISTER
			PORT MAP(
						CLK 	  	=> CLK,
						RST 	  	=> RST,
						I_FWD_C   	=> ID_OUT_FWD_C,
						I_ALU_RES 	=> ALU_RES,
						I_RD_ADDR 	=> PIPE_B_OUT_RD_ADDR,
						I_RS2_VAL 	=> PIPE_B_OUT_RS2_VAL,
						OP_MEM_WB 	=> TO_OTHER_PIPE,
						
						OP_WB 		=> PIPE_C_OUT_WB_OPCODE,
						OP_MEM 		=> PIPE_C_OUT_MEM_OP_DUMP, -- Will be bypassed.
						O_RD_ADDR 	=> PIPE_C_OUT_RD_ADDR,
						O_RS2_VAL 	=> PIPE_C_RS2_VAL_DUMP,    -- Will be bypassed.
						O_ALU_RES 	=> PIPE_C_OUT_ALU_RES,
						O_FWD_C 	=> PIPE_C_OUT_FWD_C
					);
					
	FWDC_MUC: MUX2X1 
			  GENERIC MAP ( INSIZE => 32 ) 
			  PORT    MAP ( 
							D0 	   => PIPE_B_OUT_RS2_VAL, -- Even here, we have to bypass.
							D1     => FORWARD_TO_MEM_FROM_MEM,
							SEL    => PIPE_C_OUT_FWD_C,
							O 	   => BUF_FWDC_MUX
						   );
	MEM4: MEMORY
		 PORT MAP(
					CLK 	=> CLK,
					OP  	=> TO_OTHER_PIPE(4 DOWNTO 1), -- Bypassing the C Reg
					WR_ADR  => ALU_RES(6 DOWNTO 0),       -- Bypassing the C Reg
					WR_DAT  => BUF_FWDC_MUX,
					
					MEM_RES => MEM_OUT_RES
				  );
	
	-- FEEDBACK TO PREVIOUS MODULES --
	
	ID_IN_RD_MEM 	 <= PIPE_C_OUT_RD_ADDR;
	FORWARD_FROM_EXE <= PIPE_C_OUT_ALU_RES; -- Forward A
		
	
	--     OPCODE[WB]		 MEM RES                                 ALU RES          RD [ADR]
	-- +------ \/ ------------ \/ ------------------------------------ \/ ------------ \/ ---------+
	-- |						MEM ->	PIPELINE REGISTER D -> WB							 	   |			   
	-- +------ \/ ------------ \/ ------------------------------------ \/ ------------ \/ ---------+

	PIPE_D: PIPE_MEM_TO_WB_REGISTER 
			PORT MAP(
						CLK 	  => CLK,
						RST 	  => RST,
						I_MEM_RES => MEM_OUT_RES,
						I_ALU_RES => PIPE_C_OUT_ALU_RES,
						OP_WB 	  => PIPE_C_OUT_WB_OPCODE,
						I_RD_ADDR => PIPE_C_OUT_RD_ADDR,
						
						O_MEM_RES => PIPE_D_OUT_MEM_RES,
						O_ALU_RES => PIPE_D_OUT_ALU_RES,
						O_RD_ADDR => PIPE_D_OUT_RD_ADDR,
						OP_WB_LOG => PIPE_D_OUT_WB_LOG_OPCODE
					);
					
	SEL_FEED: MEM_TO_WB
			  PORT MAP(
						MEM_IN 	=> PIPE_D_OUT_MEM_RES,
						ALU_IN  => PIPE_D_OUT_ALU_RES,
						MEMOP   => PIPE_D_OUT_WB_LOG_OPCODE(3 DOWNTO 1),
						WB_IN 	=> WB_IN_MEM_OR_ALU
					   );
					   
	WB5: WRITE_BACK
		 PORT MAP(
					WB_OP  => PIPE_D_OUT_WB_LOG_OPCODE(0),
					WB_ADR => PIPE_D_OUT_RD_ADDR,
					WB_DAT => WB_IN_MEM_OR_ALU,
					RD_ADR => ID_IN_WB_RD_ADR, -- Back to ID's Register file.
					RD_DAT => ID_IN_WB_RD_VAL  -- Back to ID's Register file.
				 );
	-- FEEDBACK TO PREVIOUS MODULES --
	FORWARD_FROM_MEM 		<= PIPE_D_OUT_MEM_RES;
	FORWARD_TO_MEM_FROM_MEM <= PIPE_D_OUT_MEM_RES;
	----------------------------------------------------------------------------------------------
	-- Each Stage's Output 
	PC  <= PC_OUT_DUMP;
	I_F <= IF_OUT_IFWORD;
	I_D <= ID_OUT_OPCODES;
	ALU <= ALU_RES;
	MEM <= MEM_OUT_RES;
	WB  <= ID_IN_WB_RD_ADR;
	
	NPC_PLUS_4_MUX <= NPC_JUMP NAND BRANCH_T_NT;
	PC_VAL_REG_A <= PIPE_A_OUT_PC_VAL;
	PC_VAL_REG_B <= PIPE_B_OUT_PC_VAL;
	NPC_TEST <= PC_IN_NEXT_PC;
	EXE_TNT <= BRANCH_T_NT;
	
	ALU_VALUE_A <= TO_ALU_A;
	ALU_VALUE_B <= TO_ALU_B;
	ALU_OPCODE_T<= ALU_OPCODE;
	
END STRUCTURAL;