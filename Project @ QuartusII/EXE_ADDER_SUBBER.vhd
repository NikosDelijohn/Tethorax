-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+


-- *** 3/5: ARITHMETIC AND LOGIC UNIT (EXE-ALU) MODULE DESIGN ***
----------------------------------------------------------------------
-- PART#1: ADDITION - SUBTRACTION MODULE
-- " This is the Module that deals with Addition and Subtraction
--   depending on control bit (OP). 
--   0 := ADDITION
--   1 := SUBTRACTION "
----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY EXE_ADDER_SUBBER IS 

	PORT (
			A  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
			B  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
			OP : IN  STD_LOGIC; -- OPCODE [0: ADD / 1: SUB]
			S  : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
		 );
		 
END EXE_ADDER_SUBBER;

ARCHITECTURE STRUCTURAL OF EXE_ADDER_SUBBER IS

	SIGNAL RIPPLE_CARRY : STD_LOGIC_VECTOR(0 TO 32) := (OTHERS => '0');
	SIGNAL CO_DUMP 	    : STD_LOGIC;
	
	BEGIN
	
	MAIN: FOR I IN 0 TO 32 GENERATE
	
		LSB: IF I = 0 GENERATE
		
			LSBCELL: EXE_ADDER_SUBBER_CELL 
					 PORT MAP (
								A  => A(I),
								B  => B(I),
								CI => OP,
								OP => OP,
								S  => S(I),
								CO => RIPPLE_CARRY(I+1)
							  );
		END GENERATE LSB;
							  
		MID: IF I > 0 AND I < 32 GENERATE 
		
			MIDCELL: EXE_ADDER_SUBBER_CELL
					 PORT MAP (
								A  => A(I),
								B  => B(I),
								CI => RIPPLE_CARRY(I),
								OP => OP,
								S  => S(I),
								CO => RIPPLE_CARRY(I+1)
							   );
		END GENERATE MID;
		
		MSB: IF I = 32 GENERATE 
		
			MSBCELL: EXE_ADDER_SUBBER_CELL
					 PORT MAP (
								A  => A(I),
								B  => B(I),
								CI => RIPPLE_CARRY(I),
								OP => OP,
								S  => S(I),
								CO => CO_DUMP
							  );
		END GENERATE MSB;
	
	END GENERATE MAIN;
	
END STRUCTURAL;
		
		