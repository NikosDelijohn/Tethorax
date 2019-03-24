-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+


-- *** 4/5: MEMORY MODULE DESIGN ***
-------------------------------------------------
-- PART#2: SIGN EXTEND | ZERO FILL
-- " Given 4 Control Bits from other modules 
--   and the U Control Bit (from ID) this module
--   customizes the output of the M4K memory 
--   according to the type of the command. "
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEM_BYTE_EN_MSBS IS

	PORT ( 
			U        : IN  STD_LOGIC;
			MEM_VALUE: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			BYTE_ENA : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
			RES      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)			
		 );

END MEM_BYTE_EN_MSBS;

ARCHITECTURE BEHAVIORAL OF MEM_BYTE_EN_MSBS IS
	
	BEGIN
		
	RES <= (31 DOWNTO 8  => MEM_VALUE(7 )) & MEM_VALUE(7  DOWNTO 0) WHEN (U = '0' AND BYTE_ENA = "00") ELSE -- SIGNED   BYTE ENABLE
	       (31 DOWNTO 16 => MEM_VALUE(15)) & MEM_VALUE(15 DOWNTO 0) WHEN (U = '0' AND BYTE_ENA = "01") ELSE -- SIGNED   HALF ENABLE
	       (31 DOWNTO 8  => '0')           & MEM_VALUE(7  DOWNTO 0) WHEN (U = '1' AND BYTE_ENA = "00") ELSE -- UNSIGNED BYTE ENABLE
	       (31 DOWNTO 16 => '0')           & MEM_VALUE(15 DOWNTO 0) WHEN (U = '1' AND BYTE_ENA = "01") ELSE -- UNSIGNED HALF ENABLE
	       MEM_VALUE;
	
END BEHAVIORAL;