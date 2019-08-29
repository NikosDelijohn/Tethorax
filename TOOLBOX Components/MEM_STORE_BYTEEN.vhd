-- +===========================================================+
-- |		RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos			       |
-- |supervisor: Aristides Efthymiou			       |
-- |===========================================================|
-- |		UNIVERSITY OF IOANNINA - 2019      	       |
-- |  		     VCAS LABORATORY			       |
-- +===========================================================+

-- *** 4/5: MEMORY MODULE DESIGN ***
-------------------------------------------------
-- PART#1: BYTE ENABLE DECODE
-- " Given the 2 bit control bits generated 
--   previously from the ID module, this component
--   generates the proper byte enable signal to
--   feed in the M4K memory block "
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEM_STORE_BYTEEN IS

	PORT(	
		ALU_LSBS: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		OPCODE  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		DATA_IN : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		DATA_OUT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		BYTEEN  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	    );

END MEM_STORE_BYTEEN;

ARCHITECTURE DATAFLOW OF MEM_STORE_BYTEEN IS

	BEGIN
	          -- WRITE BYTE
	BYTEEN <= "0001" WHEN (OPCODE = "00" AND ALU_LSBS = "00") ELSE
	          "0010" WHEN (OPCODE = "00" AND ALU_LSBS = "01") ELSE
	          "0100" WHEN (OPCODE = "00" AND ALU_LSBS = "10") ELSE
	          "1000" WHEN (OPCODE = "00" AND ALU_LSBS = "11") ELSE
	          -- WRITE HALF
		  "0011" WHEN (OPCODE = "01" AND ALU_LSBS(1) = '0') ELSE
		  "1100" WHEN (OPCODE = "01" AND ALU_LSBS(1) = '1') ELSE
		  -- WRITE WORD
		  "1111" WHEN (OPCODE = "10") ELSE
		  "XXXX";

	DATA_OUT <= 	DATA_IN(7 DOWNTO 0) & DATA_IN(7 DOWNTO 0) & DATA_IN(7 DOWNTO 0) & DATA_IN(7 DOWNTO 0) WHEN (OPCODE = "00") ELSE
 			DATA_IN(15 DOWNTO 0) & DATA_IN(15 DOWNTO 0) WHEN (OPCODE = "01") ELSE
			DATA_IN;
			  
END DATAFLOW;
