-- +===========================================================+
-- |		RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos			       |
-- |supervisor: Aristides Efthymiou			       |
-- |===========================================================|
-- |		UNIVERSITY OF IOANNINA - 2019      	       |
-- |  		     VCAS LABORATORY			       |
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

	PORT( 
		CLK : IN  STD_LOGIC;
		RST : IN  STD_LOGIC;
		 
		-- TESTING SIGNALS --
		PC  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_D : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		ALU : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MEM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		WB  : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
		-- EXTRA --
		--NPC_PLUS_4_MUX : OUT STD_LOGIC;
		--NPC_TEST   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		EXE_TNT	     : OUT STD_LOGIC;
		ALU_VALUE_A  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_VALUE_B  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		--ALU_OPCODE_T : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		ECALL        : OUT STD_LOGIC;
		REGISTER_GP  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		T_FWDA       : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		T_FWDB 	     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		T_FWDC 	     : OUT STD_LOGIC;
		WB_DATA      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		--T4_R 	     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		--T5_R       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		--ID_J_ADDR  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		--PC_IN_ID   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		TEST_STALL   : OUT STD_LOGIC;
		TEST_FLUSH   : OUT STD_LOGIC;
		
		OP_BYPASS    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		OP_LATCH     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			
		TEST_ALU_PIPE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		TEST_ALU_FWD : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		TEST_MEM_WRD : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		TEST_MEM_WRAD: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
			
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
	SIGNAL PC_OUT        : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The Output won't be used due to the nature of the M4K blocks.
	SIGNAL NPC_ON_JALR   : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The register will actually be bypassed.
	
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

	SIGNAL RS1_ADDRESS_IF : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL RS2_ADDRESS_IF : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL RD_EQ_RS1_RS2  : STD_LOGIC_VECTOR(1  DOWNTO 0);
	
	SIGNAL RS1_TO_EXE     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RS2_TO_EXE     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- EXE I/O & PRE-LOGIC --
	SIGNAL A_B_SELECTOR   : STD_LOGIC_VECTOR(3  DOWNTO 0);
	SIGNAL A	      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL B	      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_OPCODE     : STD_LOGIC_VECTOR(8  DOWNTO 0);
	SIGNAL TO_OTHER_PIPE  : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL SHIELD_SELECT  : STD_LOGIC;
	
	SIGNAL FORWARD_FROM_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FORWARD_FROM_EXE : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_FWD_B_A      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_FWD_B_B 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL TO_ALU_A		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL TO_ALU_B 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL ALU_RES 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BRANCH_T_NT 	: STD_LOGIC;
	
	SIGNAL NPC_JALR		: STD_LOGIC;
	SIGNAL NPC_JUMP 	: STD_LOGIC;
	
	SIGNAL BUF_ADR_MUX 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_PLUS_FOUR     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL ALU_RES_OR_PC_PLUS_4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- MEM I/O --
	SIGNAL BUF_FWDC_MUX 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FORWARD_TO_MEM_FROM_MEM 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_OUT_RES		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- WB I/O -- 
	SIGNAL WB_IN_MEM_OR_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- TEST 
	SIGNAL GP_REG_TEST  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIM_END      : STD_LOGIC;
	--SIGNAL T5_REG_TEST  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--SIGNAL T4_REG_TEST  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	
	
	BEGIN
	
	-- PC REGISTER --
	PC0: PC_REGISTER
	     PORT MAP( CLK => CLK, RST => RST, STALL => PIPE_STALL_SIG, NEXT_PC => PC_IN_NEXT_PC, ADDRESS => PC_OUT );
	
	-- INSTRUCTION FETCH --	
	IF1: INSTRUCTION_FETCH                             		
		PORT MAP(  
				GLB_CLK => CLK, 
				STALL   => PIPE_STALL_SIG, 
				PC      => PC_IN_NEXT_PC, -- Bypassing the PC Register
				MEMWORD => IF_OUT_IFWORD, 
				PC_ADD  => IF_OUT_PC_VAL 
			);	
				  
	--  			FETCHED WORD [FROM I$]			 PC REGISTER VALUE
	-- +------------------- \/ ------------------------------------------- \/ ---------------------+
	-- |				IF ->	PIPELINE REGISTER A -> ID	                       |			   
	-- +------------------- \/ ------------------------------------------- \/ ---------------------+

	PIPE_A: PIPE_IF_TO_ID_REGISTER 
			PORT MAP(  -- Control
				        CLK    	  => CLK, 
					RST 	  => RST,
					FLUSH 	  => PIPE_FLUSH_SIG,
					STALL 	  => PIPE_STALL_SIG,
					-- Inputs
					I_IF_WORD => IF_OUT_IFWORD,
					I_PC_ADDR => PC_OUT, 
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
					RD_FROM_EXE=> ID_IN_RD_EXE, 	-- Input from EXE(after Shield)
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
					PIPE_FWDC  => ID_OUT_FWD_C,     -- To Pipeline Register C !!!
					
					SIMULATION_END => SIM_END,
					GP         => GP_REG_TEST
					--T5 		   => T5_REG_TEST,
					--T4 		   => T4_REG_TEST
			    );
	
	-- "FORWARD-BYPASS" OF REGFILE (FWD D) --
	RS1_ADDRESS_IF <= PIPE_A_OUT_IFWORD(19 DOWNTO 15);
	RS2_ADDRESS_IF <= PIPE_A_OUT_IFWORD(24 DOWNTO 20); 
	
	-- IF RS1/RS2 EQUALS RD[WB]  AND RD[WB] != 0
	RD_EQ_RS1_RS2(1) <= AND_REDUCE( RS1_ADDRESS_IF XNOR ID_IN_WB_RD_ADR ) AND OR_REDUCE(ID_IN_WB_RD_ADR); 
	RD_EQ_RS1_RS2(0) <= AND_REDUCE( RS2_ADDRESS_IF XNOR ID_IN_WB_RD_ADR ) AND OR_REDUCE(ID_IN_WB_RD_ADR);
					
	WB_RD_RS1: MUX2X1                                         -- Check for equalities between RS1/RS2 and RD[WB].
			GENERIC MAP(INSIZE => 32)  		  -- If found any, then the WB_Value has to be bypassed
			PORT    MAP(                              -- and written to the Register File because the ALU
					D0    => ID_OUT_RS1_VAL,  -- will have the correct value 1 cc later otherwise.
					D1    => ID_IN_WB_RD_VAL,
					SEL   => RD_EQ_RS1_RS2(1),
					O     => RS1_TO_EXE
				   );
	WB_RD_RS2: MUX2X1
			   GENERIC MAP( INSIZE => 32 )
			   PORT    MAP( 
					D0 	=> ID_OUT_RS2_VAL,
					D1 	=> ID_IN_WB_RD_VAL,
					SEL    => RD_EQ_RS1_RS2(0),
					O      => RS2_TO_EXE
				      );
					
	--     RS1  RS2  IMM   RD [ADR]	   PC	  TARGET ADR     FWD_A       FWD_B      CTRLWORD
    	-- + -- \/ - \/ - \/ - \/ -------- \/ -------- \/ -------- \/ -------- \/ -------- \/ ---------+
	-- |				ID ->	PIPELINE REGISTER B -> EXE	                       |			   
	-- + -- \/ - \/ - \/ - \/ -------- \/ -------- \/ -------- \/ -------- \/ -------- \/ ---------+
	
	PIPE_B: PIPE_ID_TO_EXE_REGISTER
			PORT MAP(	-- Control
					CLK 			=> CLK,
					RST 			=> RST,
					FLUSH 			=> PIPE_FLUSH_SIG,
					STALL 			=> PIPE_STALL_SIG,
					-- Inputs
					I_RS1_VAL 		=> RS1_TO_EXE,
					I_RS2_VAL 		=> RS2_TO_EXE,
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
					  
					  
	-- FORWARD MUXES [ B path < A path ]
	FWDB_A: MUX2X1 -- Forward B for A
		GENERIC MAP( INSIZE => 32 )
		PORT    MAP(
				D0 	=> PIPE_B_OUT_RS1_VAL,
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
                	        D0     => PIPE_B_OUT_RS2_VAL,
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
				O 	=> TO_ALU_B
			   );

	-- Decide which values are going to ALU				  
	ALU_IN: DECODE_TO_EXECUTE
		PORT MAP(
				RS1 	=> TO_ALU_A,
				RS2		=> TO_ALU_B,
				PC_I 	=> PIPE_B_OUT_PC_VAL,
				IMME 	=> PIPE_B_OUT_IMM,
				
				JALR	=> A_B_SELECTOR(3),
				JUMP 	=> A_B_SELECTOR(2),
				PC	=> A_B_SELECTOR(1),
				IMM	=> A_B_SELECTOR(0),
					
				A	=> A,
				B	=> B
			);
						
	-- INSTRUCTION EXECUTE - ALU -- 
	EXE3: EXE
		PORT MAP(
				A   => A,
				B   => B,
				OP  => ALU_OPCODE,
				RES => ALU_RES,
				TNT => BRANCH_T_NT
			);
				
	-- FEEDBACK TO PREVIOUS MODULES 

	SHIELD_SELECT <= '1' WHEN (ALU_OPCODE(2) = '1' OR ( TO_OTHER_PIPE(3) = '1' AND TO_OTHER_PIPE(2 DOWNTO 1) /= "11")) ELSE
			 '0';

	BRANCH_SHIELD: MUX2X1                      -- This is just in case there is a branch in EXE (which has no RD) and by random
			GENERIC MAP ( INSIZE => 5 ) -- the IMMEDIATE [11..7] has the same value as the RD address which is in ID. To avoid 
			PORT    MAP (               -- providing a false FWD_A signal we add this "shield" which gives "00000" as RD in this case (which will be caught by STALL_FWD_PREDICTOR)
					D0 	=> PIPE_B_OUT_RD_ADDR,
					D1     => "00000",
					SEL    => SHIELD_SELECT, -- BRANCH CTRL SIG
					O      => ID_IN_RD_EXE	 	  
				    );
								
	ID_IN_LOAD_EXE	<= NOT TO_OTHER_PIPE(3); 	-- This is the MSB of MEMOP CTRL Signal (0 for loads, 1 for Stores and mem-free-ops)
	
	PIPE_FLUSH_SIG  <= NPC_JUMP OR BRANCH_T_NT;  	-- Flush control signal is generted here.

		-- NEXT PC CALCULATION --
		NPC_ON_JALR <= ALU_RES(31 DOWNTO 1) & "0";
		ADR_MUX: MUX2X1 
			GENERIC MAP( INSIZE => 32 )
			PORT    MAP(
					D0 	 => PIPE_B_OUT_TARGET_J,
					D1 	 => NPC_ON_JALR, -- This path will be taken only if the command is a JALR (LSB = 0).
					SEL 	 => NPC_JALR,
					 O  	 => BUF_ADR_MUX
				   );
							  
		PC_P4: PC_PLUS_4 PORT MAP ( PC => PC_OUT, RES => PC_PLUS_FOUR );

		NPC_MUX: MUX2X1
			GENERIC MAP( INSIZE => 32 )
			PORT  	MAP(			
					D0     	 => PC_PLUS_FOUR,
					D1	 => BUF_ADR_MUX,
					SEL 	 => PIPE_FLUSH_SIG,
					O 	 => PC_IN_NEXT_PC -- Input to PC Register (and I$).
				   );
		-- If there is a JALR then, the value that must be transfered to MEM-WB is the ID_ADDER's result, because we do things the oposite way with JALR
		JALR_OR_ALU: MUX2X1
			GENERIC MAP( INSIZE => 32 )
			PORT    MAP( 
				   	D0 	=> ALU_RES,
					D1 	=> PIPE_B_OUT_TARGET_J,
					SEL     => NPC_JALR,
					O       => ALU_RES_OR_PC_PLUS_4
			           );

	--  	ALU RES 		RD[ADR]             RS2                 OPCODE[MEM&WB]
	-- +-------- \/ ---------------- \/ ---------------- \/ ---------------- \/ -------------------+
	-- |				EXE ->	PIPELINE REGISTER C -> MEM 	  	 	       |			   
	-- +-------- \/ ---------------- \/ ---------------- \/ ---------------- \/ -------------------+
	
	PIPE_C: PIPE_EXE_TO_MEM_REGISTER
			PORT MAP(
					CLK 	  	=> CLK,
					RST 	  	=> RST,
					I_FWD_C   	=> ID_OUT_FWD_C,
					I_ALU_RES 	=> ALU_RES_OR_PC_PLUS_4, --ALU_RES,
					I_RD_ADDR 	=> PIPE_B_OUT_RD_ADDR,
					I_RS2_VAL 	=> TO_ALU_B,
					OP_MEM_WB 	=> TO_OTHER_PIPE,
						
					OP_WB 		=> PIPE_C_OUT_WB_OPCODE,
					OP_MEM 		=> PIPE_C_OUT_MEM_OP_DUMP, -- Will be bypassed.
					O_RD_ADDR 	=> PIPE_C_OUT_RD_ADDR,
					O_RS2_VAL 	=> PIPE_C_RS2_VAL_DUMP,    -- Will be bypassed.
					O_ALU_RES 	=> PIPE_C_OUT_ALU_RES,
					O_FWD_C 	=> PIPE_C_OUT_FWD_C
				);
					
	FWDC_MUC: MUX2X1 
			GENERIC MAP( INSIZE => 32 ) 
			PORT    MAP( 
					D0     => TO_ALU_B, -- Even here, we have to bypass.
					D1     => FORWARD_TO_MEM_FROM_MEM,
					SEL    => PIPE_C_OUT_FWD_C,
					O      => BUF_FWDC_MUX
				   );
	MEM4: MEMORY
		PORT MAP(
				CLK 		  => CLK,
				OPCODE_PIPE   => PIPE_C_OUT_MEM_OP_DUMP	,	       -- Will be used for Loads "Masking"
				OPCODE_BYPSS  => TO_OTHER_PIPE(3 DOWNTO 1), 	   -- Bypassing the C Reg (ONLY MEMOP FOR STORES)
				ALU_RES_PIPE  => PIPE_C_OUT_ALU_RES(1 DOWNTO 0),   -- For loads
				ALU_RES_BYPSS => ALU_RES_OR_PC_PLUS_4(1 DOWNTO 0), -- For stores Bypass the C Reg
				WR_ADR  	  => ALU_RES_OR_PC_PLUS_4(8 DOWNTO 2), -- Bypassing the C Reg
				WR_DAT 	 	  => BUF_FWDC_MUX,					   -- Bypassing the C Reg
				
				MEM_RES => MEM_OUT_RES
			);
	
	-- FEEDBACK TO PREVIOUS MODULES --
	
	ID_IN_RD_MEM 	 <= PIPE_C_OUT_RD_ADDR;
	FORWARD_FROM_EXE <= PIPE_C_OUT_ALU_RES; -- Forward A
	FORWARD_TO_MEM_FROM_MEM <= MEM_OUT_RES; -- Forward C
		
	
	--     OPCODE[WB]	 MEM RES                                 ALU RES          RD [ADR]
	-- +------ \/ ------------ \/ ------------------------------------ \/ ------------ \/ ---------+
	-- |				MEM ->	PIPELINE REGISTER D -> WB                              |			   
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
	FORWARD_FROM_MEM <= WB_IN_MEM_OR_ALU; -- Either ALU's or MEM's Result for Forward B.
	----------------------------------------------------------------------------------------------
	-- Each Stage's Output 
	PC  <= PC_OUT;
	I_F <= IF_OUT_IFWORD;
	I_D <= ID_OUT_OPCODES;
	ALU <= ALU_RES;
	MEM <= MEM_OUT_RES;
	WB  <= ID_IN_WB_RD_ADR;
	
	--NPC_PLUS_4_MUX <= NPC_JUMP OR BRANCH_T_NT;
	--NPC_TEST <= PC_IN_NEXT_PC;
	EXE_TNT <= BRANCH_T_NT;
	
	ALU_VALUE_A <= TO_ALU_A;
	ALU_VALUE_B <= TO_ALU_B;
	--ALU_OPCODE_T<= ALU_OPCODE;
	
	REGISTER_GP <= GP_REG_TEST;
	ECALL       <= SIM_END;
	T_FWDA      <= PIPE_B_OUT_FWD_A;
	T_FWDB      <= PIPE_B_OUT_FWD_B;
	T_FWDC      <= PIPE_C_OUT_FWD_C;
	WB_DATA	    <= ID_IN_WB_RD_VAL;
	
	--T4_R 	<=  T4_REG_TEST;
	--T5_R 	<=  T5_REG_TEST;
	
	--ID_J_ADDR <= ID_OUT_J_TARGET;
	--PC_IN_ID  <= PIPE_A_OUT_PC_VAL;
	
	TEST_FLUSH <= PIPE_FLUSH_SIG;
	TEST_STALL <= PIPE_STALL_SIG;
	
	OP_BYPASS     <= TO_OTHER_PIPE(3 DOWNTO 1);
	OP_LATCH   <= PIPE_C_OUT_MEM_OP_DUMP;
	TEST_ALU_PIPE <= PIPE_C_OUT_ALU_RES(1 DOWNTO 0);
	TEST_ALU_FWD  <= ALU_RES_OR_PC_PLUS_4(1 DOWNTO 0);
	TEST_MEM_WRD  <= BUF_FWDC_MUX; -- RS2
	TEST_MEM_WRAD <= ALU_RES_OR_PC_PLUS_4(6 DOWNTO 0);
	
END STRUCTURAL;
