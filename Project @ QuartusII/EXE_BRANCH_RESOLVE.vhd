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
-- PART#4: BRANCH RESOLVE MODULE
-- " This module, given the result of the subtraction, which is 
--   XLEN + 1 in size, and two control signals (EQLT,INV) desides
--   if the branch should be taken or not. The outcome depends on
--   the following:
--  +----------------------+ 
--  |EQLT LT | BRANCH TYPE |
--- |--------|-------------|
--  | 1   0  |     BEQ     |
--  | 1   1  |     BNE     |
--  | 0   0  |     BLT     |
--  | 0   1  |     BGE     |
--  +----------------------+ "
----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY EXE_BRANCH_RESOLVE IS 
	
	PORT( 
			RES  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
			EQLT : IN  STD_LOGIC;
			INV  : IN  STD_LOGIC;
			T_NT : OUT STD_LOGIC
		);

END EXE_BRANCH_RESOLVE;

ARCHITECTURE RTL OF EXE_BRANCH_RESOLVE IS 
	
	SIGNAL REDUCED_RES : STD_LOGIC;
	SIGNAL MUX_RES     : STD_LOGIC;
	
	BEGIN
	
		REDUCED_RES <= NOR_REDUCE(RES);
		
		MUX: MUX2X1_BIT
			 PORT MAP(
						D0  => RES(32),
						D1  => REDUCED_RES,
						SEL => EQLT,
						O   => MUX_RES
					 );
					  
		T_NT <= MUX_RES XOR INV;
		
END RTL;
	
	