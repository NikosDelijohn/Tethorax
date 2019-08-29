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

ENTITY MEMORY IS

	PORT(
		CLK    	      : IN  STD_LOGIC;
		OPCODE_PIPE   : IN  STD_LOGIC_VECTOR(3  DOWNTO 0); -- For Loads U & MEMOP 
		OPCODE_BYPSS  : IN  STD_LOGIC_VECTOR(2  DOWNTO 0); -- Only the MEMOP needed for stores
		ALU_RES_PIPE  : IN  STD_LOGIC_VECTOR(1  DOWNTO 0); -- LSB from ALU_RES taken from Pipeline Register
		ALU_RES_BYPSS : IN  STD_LOGIC_VECTOR(1  DOWNTO 0); -- LSB from ALU_RES taken from ALU (Bypass)
		WR_ADR 	      : IN  STD_LOGIC_VECTOR(6  DOWNTO 0); -- WRITE/READ address (Bypass)
		WR_DAT 	      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- WRITE data (Bypass)
			
		MEM_RES: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	    );
		 
END MEMORY;

ARCHITECTURE STRUCTURAL OF MEMORY IS

	SIGNAL MEM_ENABLE    : STD_LOGIC;
	SIGNAL BYTEEN        : STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL MEM_DATA      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL REFORMED_DATA : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
	
	MEM_ENABLE <= NAND_REDUCE(OPCODE_BYPSS(2 DOWNTO 0)); -- IT DOESN'T GET LATCHED SO WE TAKE IT FROM PIPE REG 
	
	BYTE_ENA: MEM_STORE_BYTEEN
			PORT MAP(
					ALU_LSBS => ALU_RES_BYPSS,
					OPCODE   => OPCODE_BYPSS(1 DOWNTO 0),
					DATA_IN  => WR_DAT,
					DATA_OUT => REFORMED_DATA,
					BYTEEN   => BYTEEN
				);
	
	DATA_MEM: MEM_DATAMEM 
			PORT MAP(
					address => WR_ADR, -- BYPASS
					byteena => BYTEEN, -- BYPASS
					clken   => MEM_ENABLE,
					clock   => CLK,
					data    => REFORMED_DATA, -- BYPASS
                            		wren    => OPCODE_BYPSS(2), -- BYPASS
					q       => MEM_DATA
				);
					    
	
	EXTEND: MEM_LOADS_MASKING
			PORT MAP(		
					ALU_LSBS  => ALU_RES_PIPE,
					U   	  => OPCODE_PIPE(3),
					OPCODE    => OPCODE_PIPE(1 DOWNTO 0),
					MEM_VAL   => MEM_DATA,
					OUTPUT    => MEM_RES
				);
					 

END STRUCTURAL;
