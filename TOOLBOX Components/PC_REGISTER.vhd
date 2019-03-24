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
-- PART #0: PC REGISTER
---------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PC_REGISTER IS

	PORT(	
			CLK,RST : IN  STD_LOGIC;
			STALL   : IN  STD_LOGIC;
			--FLUSH   : IN  STD_LOGIC;
			NEXT_PC : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			ADDRESS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
		
END PC_REGISTER;

ARCHITECTURE BEHAVIORAL OF PC_REGISTER IS
	
	SIGNAL BUF : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	BEGIN 
	
	PROC: PROCESS(CLK,RST,STALL)
	
		BEGIN
		
			IF 	  ( RST = '1' ) THEN -- Asynchronous RESET
			
				BUF <= (OTHERS =>'0');
			
			ELSIF ( CLK'EVENT AND CLK = '1' ) THEN 
			 
				IF ( STALL = '1' ) THEN  NULL; 
				
				ELSE BUF <= NEXT_PC;					
				
				END IF;
				
			END IF;
			
		END PROCESS;
		
	ADDRESS <= BUF;
	
END BEHAVIORAL;

					