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
-- PART#2: LOGIC MODULE
-- " This is the Module that deals with Logic operations depending 
--   the input's OPCODE. The functions are the following:
--   OPCODE := 00 ( A AND B )
--   OPCODE := 01 ( A OR  B )
--   OPCODE := 10 ( A XOR B )
--   OPCODE := 11 ( ERROR   ) "
----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EXE_LOGIC_MODULE IS

	PORT (
			A   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			B   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OP  : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
			RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		 );
		 
END EXE_LOGIC_MODULE;

ARCHITECTURE BEHAVIORAL OF EXE_LOGIC_MODULE IS

	BEGIN
	
	RES <= A AND B WHEN OP = "00" ELSE
	       A OR  B WHEN OP = "01" ELSE
	       A XOR B WHEN OP = "10" ELSE
	       ( OTHERS => '0' );
	       
END BEHAVIORAL;