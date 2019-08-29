-- +===========================================================+
-- |		RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos			       |
-- |supervisor: Aristides Efthymiou			       |
-- |===========================================================|
-- |		UNIVERSITY OF IOANNINA - 2019      	       |
-- |  		     VCAS LABORATORY			       |
-- +===========================================================+


-- *** PIPELINE MODULES DESIGN ***
---------------------------------------------------------------
-- PART #4: MEM -> WB PIPELINE REGISTER
---------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PIPE_MEM_TO_WB_REGISTER IS

	PORT(	
		CLK,RST   : IN  STD_LOGIC;
		I_MEM_RES : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_ALU_RES : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OP_WB     : IN  STD_LOGIC_VECTOR(3  DOWNTO 0);
		I_RD_ADDR : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
			
		O_MEM_RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		O_ALU_RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		O_RD_ADDR : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
		OP_WB_LOG : OUT STD_LOGIC_VECTOR(3  DOWNTO 0)
			
	   );

END PIPE_MEM_TO_WB_REGISTER;

ARCHITECTURE BEHAVIORAL OF PIPE_MEM_TO_WB_REGISTER IS

	SIGNAL BUF_O_MEM_RES : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_O_ALU_RES : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_RD_ADDR   : STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL BUF_OP_WB_LOG : STD_LOGIC_VECTOR(3  DOWNTO 0);

	BEGIN

	PROC: PROCESS(CLK,RST)
	
		BEGIN
		
			IF (RST = '1') THEN
			
				BUF_O_MEM_RES <= (OTHERS => '0'); -- We don't care
				BUF_O_ALU_RES <= (OTHERS => '0'); -- We don't care
				BUF_RD_ADDR   <= "00000"; -- We don't care there is not going to be any WB 	
				BUF_OP_WB_LOG <= "0111";  -- MSB = WB OP : 0 = No WB. | 111 = MEMOP : Mem-free-op.

			ELSIF (CLK'EVENT AND CLK = '1') THEN

				BUF_O_MEM_RES <= I_MEM_RES;
				BUF_O_ALU_RES <= I_ALU_RES;
				BUF_RD_ADDR   <= I_RD_ADDR;
				BUF_OP_WB_LOG <= OP_WB;

			END IF;

	END PROCESS;

	O_MEM_RES <= BUF_O_MEM_RES;
	O_ALU_RES <= BUF_O_ALU_RES;
	O_RD_ADDR <= BUF_RD_ADDR;
	OP_WB_LOG <= BUF_OP_WB_LOG;

END BEHAVIORAL;