-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+


-- *** 5/5: WRITE BACK MODULE DESIGN ***
-------------------------------------------------
-- If the operation has a value that has to be 
-- written at some "rd" register then this module
-- provides feed back to the register file 
-- (located at ID module) which is the 
-- value that must be written to the register
-- and the address of the regisger at the 
-- register file (range from 1 to 31).
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE WORK.TOOLBOX.ALL;

ENTITY WRITE_BACK IS

	PORT (
			WB_OP : IN  STD_LOGIC;
			WB_ADR: IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
			WB_DAT: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			RD_ADR: OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
			RD_DAT: OUT STD_LOGIC_vECTOR(31 DOWNTO 0)
		 );

END WRITE_BACK;

ARCHITECTURE STRUCTURAL OF WRITE_BACK IS
	
	SIGNAL GND : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS =>'0');
	
	BEGIN
		
		MUX_DATA: MUX2X1
				  GENERIC MAP( INSIZE => 5 )
				  PORT    MAP(
					    	   D0     => GND,
							   D1     => WB_ADR,
							   SEL    => WB_OP,
							   O      => RD_ADR
							 );
		RD_DAT <= WB_DAT;

END STRUCTURAL;