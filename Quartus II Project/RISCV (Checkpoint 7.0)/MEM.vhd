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
-- "This module works only if the command is a 
-- Load or a Store command. In case of them both
-- the effective address is obtained as ALU's 
-- 7 LSBs [since its capacitance is 128 memory
-- slots, log2(128) = 7] and works according to
-- the OPCODE given which was generated from ID 
-- module."
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

USE WORK.TOOLBOX.ALL;

ENTITY MEM IS

	PORT (
			CLK    : IN  STD_LOGIC;
			OP     : IN  STD_LOGIC_VECTOR(3  DOWNTO 0);
			WR_ADR : IN  STD_LOGIC_VECTOR(6  DOWNTO 0);
			WR_DAT : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			MEM_RES: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		 );
		 
END MEM;

ARCHITECTURE STRUCTURAL OF MEM IS

	SIGNAL MEM_ENABLE: STD_LOGIC;
	SIGNAL BYTEEN    : STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL MEM_DATA  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	BEGIN
	
	MEM_ENABLE <= NAND_REDUCE(OP(2 DOWNTO 0));
	
	BYTE_ENA: MEM_BYTE_ENABLE
			  PORT MAP (
							OPCODE => OP(1 DOWNTO 0),
							BYTEEN => BYTEEN
					   );
	
	DATA_MEM: MEM_DATAMEM 
			  PORT MAP (
							address => WR_ADR,
							byteena => BYTEEN,
							clken   => MEM_ENABLE,
							clock   => CLK,
							data    => WR_DAT,
                            wren    => OP(2),
							q       => MEM_DATA
					    );
					    
	
	EXTEND: MEM_BYTE_EN_MSBS
			PORT MAP (
							U 	  	  => OP(3),
							MEM_VALUE => MEM_DATA,
							BYTE_ENA  => OP(1 DOWNTO 0),
							RES       => MEM_RES
					 );
	
END STRUCTURAL;