-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+


-- *** 2/5: INSTRUCTION DECODE (ID) MODULE DESIGN ***
------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY I_D IS 
	
	GENERIC ( CTRL_WORD_TOTAL : INTEGER := 20; CTRL_WORD_OUT : INTEGER := 18);
	PORT 	( 	
				CLK,RST    : IN  STD_LOGIC;						--\
				WB_RD_LOAD : IN  STD_LOGIC_VECTOR(4  DOWNTO 0); --| Register File inputs.
				WB_RD_DATA : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); --/ 	
				PC_VALUE   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Feed from
				IF_WORD    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruction Fetch

				RS1_VALUE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
				RS2_VALUE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				RD_ADDR    : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
				IMMEDIATE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				TARGET_AD  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
				PC_VALUE_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				CTRL_WORD  : OUT STD_LOGIC_VECTOR(CTRL_WORD_OUT-1  DOWNTO 0)
			);

END I_D;

ARCHITECTURE STRUCTURAL OF I_D IS
	
	-- DECODER SIGS --
	SIGNAL OPCODE : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL FUNCT3 : STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL FUNCT7 : STD_LOGIC;
	SIGNAL DEC_BUF: STD_LOGIC_VECTOR(CTRL_WORD_TOTAL-1 DOWNTO 0);
	-- IMMEDIATE GENERATOR SIGS --
	SIGNAL IMM_BUF: STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- REGISTER FILE SIGS --
	SIGNAL ONE_HOT: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RS1_BUF: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RS2_BUF: STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- ID ADDER SIGS --
	SIGNAL ADD_BUF: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MUX_BUF: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL JALR   : STD_LOGIC;
	-- APPEND JALR --
	SIGNAL CTRL   : STD_LOGIC_VECTOR(CTRL_WORD_OUT-1 DOWNTO 0);

BEGIN

	-- DECODER -------------------
	OPCODE <= IF_WORD(6  DOWNTO  2);
	FUNCT3 <= IF_WORD(14 DOWNTO 12);
	FUNCT7 <= IF_WORD(30);
	
	DEC: ID_DECODER
		 GENERIC MAP( CTRL_WORD_SIZE => CTRL_WORD_TOTAL )
		 PORT    MAP(
					  MUX_2X1_SEL  => FUNCT7,
					  MUX_8X1_SEL  => FUNCT3,
					  MUX_32X1_SEL => OPCODE,
					  CONTROL_WORD => DEC_BUF
					 );
	-- IMMEDIATE GENERATOR --------
	IMG: ID_IMM_GENERATOR
		 PORT    MAP(
					  IMM_TYPE    => DEC_BUF(CTRL_WORD_TOTAL-1 DOWNTO CTRL_WORD_TOTAL-3),
					  IF_WORD     => IF_WORD,
					  IMMEDIATE   => IMM_BUF
					);
	-- REGISTER FILE --------------
	ADR: DEC5X32
		 PORT    MAP(
					  SEL 		  => WB_RD_LOAD,
					  RES         => ONE_HOT
					);
					
	REG: REGISTER_FILE
		 PORT    MAP(
					  CLK 		  => CLK,
					  RST         => RST,
					  LOAD_REG    => ONE_HOT,
					  DATA_IN     => WB_RD_DATA,
					  ADDR_RS1    => IF_WORD(19 DOWNTO 15),
					  ADDR_RS2    => IF_WORD(24 DOWNTO 20),
					  DATA_RS1    => RS1_BUF,
					  DATA_RS2    => RS2_BUF
					);

	-- ID ADDER -------------------
	JALR <= (DEC_BUF(11) XOR DEC_BUF(10)) AND DEC_BUF(1);
		
	MXC: MUX2X1
		 GENERIC MAP( INSIZE => 32 )
		 PORT    MAP(
					  D0  => IMM_BUF,
					  D1  => "00000000000000000000000000000100",
					  SEL => JALR, 
					  O   => MUX_BUF
					);
	
    ADD: ID_ADDER
		PORT     MAP(
					  PC_VALUE    => PC_VALUE,
					  IMMEDIATE   => MUX_BUF,
					  OUTPUT      => ADD_BUF
					);
					
	-- CTRL WORD APPEND JALR ------
	CTRL(CTRL_WORD_OUT-1 DOWNTO 1) <= DEC_BUF(CTRL_WORD_TOTAL-4 DOWNTO 0);
	CTRL(0) 					   <= JALR;
	
	-- OUTPUTS --------------------
	RS1_VALUE  <= RS1_BUF;
	RS2_VALUE  <= RS2_BUF;
	RD_ADDR    <= IF_WORD(11 DOWNTO 7);
	IMMEDIATE  <= IMM_BUF;
    TARGET_AD  <= ADD_BUF;
	PC_VALUE_O <= PC_VALUE;
	CTRL_WORD  <= CTRL;
	
	
   		  
END STRUCTURAL;
							