-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+


-- *** PIPELINE MODULES DESIGN ***
---------------------------------------------------------------
-- PART #1: IF -> ID PIPELINE REGISTER
---------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY PIPE_IF_TO_ID_REGISTER IS

	PORT (	
			CLK,RST   : IN  STD_LOGIC;
			FLUSH     : IN  STD_LOGIC;
			STALL     : IN  STD_LOGIC;
			
			I_IF_WORD : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			I_PC_ADDR : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			O_IF_WORD : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			O_PC_ADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		 );

END PIPE_IF_TO_ID_REGISTER;

ARCHITECTURE BEHAVIORAL OF PIPE_IF_TO_ID_REGISTER IS

	SIGNAL BUF_IF_WORD : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_PC_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	CONSTANT NOP    : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000010011";
	CONSTANT NOP_PC : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";

	BEGIN

	PROC: PROCESS(CLK,RST,FLUSH,STALL)

		BEGIN

		IF (RST = '1') THEN 
		
			BUF_IF_WORD <= NOP;
			BUF_PC_ADDR <= NOP_PC;
		
		ELSIF (CLK'EVENT AND CLK = '1') THEN

			IF ( FLUSH = '1' ) THEN -- FLUSH > STALLS

				BUF_IF_WORD <= NOP;
				BUF_PC_ADDR <= NOP_PC;
				
			ELSIF ( FLUSH = '0' AND STALL = '1' ) THEN

				NULL;
				
			ELSIF ( FLUSH = '0' AND STALL = '0' ) THEN
			
				BUF_IF_WORD <= I_IF_WORD;
				BUF_PC_ADDR <= I_PC_ADDR;
				
			END IF;
			
		END IF;

	END PROCESS;

	O_IF_WORD <= BUF_IF_WORD;
	O_PC_ADDR <= BUF_PC_ADDR;

END BEHAVIORAL;