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
-- PART #3: EXE -> MEM PIPELINE REGISTER
---------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PIPE_EXE_TO_MEM_REGISTER IS

	PORT (
			CLK,RST    : IN  STD_LOGIC;
			I_FWD_C    : IN  STD_LOGIC;
			I_ALU_RES  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			I_RD_ADDR  : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
			I_RS2_VAL  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OP_MEM_WB  : IN  STD_LOGIC_VECTOR(4  DOWNTO 0); -- MEMU & MEMOP & WB
			
			OP_WB     : OUT STD_LOGIC_VECTOR(3  DOWNTO 0); -- WB_OPCODE & MEMOP (For WB Logic)
			OP_MEM    : OUT STD_LOGIC_VECTOR(3  DOWNTO 0); -- MEMU & MEMOP (For MEM!)
			O_RD_ADDR : OUT STD_LOGIC_VECTOR(4  DOWNTO 0); -- Those two signals
			O_RS2_VAL : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- will be bypassed (to M4K).
			O_ALU_RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- For WB pipeline register.
			O_FWD_C   : OUT STD_LOGIC
			
		 );
		 
END PIPE_EXE_TO_MEM_REGISTER;

ARCHITECTURE BEHAVIORAL OF PIPE_EXE_TO_MEM_REGISTER IS
	
	SIGNAL BUF_OP_WB  : STD_LOGIC_VECTOR(3  DOWNTO 0);
	SIGNAL BUF_OP_MEM : STD_LOGIC_VECTOR(3  DOWNTO 0);
	SIGNAL BUF_RD_ADDR: STD_LOGIC_VECTOR(4  DOWNTO 0);
	SIGNAL BUF_RS2_VAL: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_ALU_RES: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_FWD_C  : STD_LOGIC;
	
	BEGIN

	PROC: PROCESS(CLK)

		BEGIN

		IF (RST = '1') THEN

			BUF_OP_WB   <= "0111";  -- WB = 0   : No WB    & MEMOP = 111 : Mem-free-op 
			BUF_OP_MEM  <= "1111";  -- MEMU = X : Whatever & MEMOP = 111 : Mem-free-op
			BUF_RD_ADDR <= "00000"; -- RD   = X : Whatever 
			BUF_RS2_VAL <= (OTHERS=>'0'); -- We dont care
			BUF_ALU_RES <= (OTHERS=>'0'); -- We dont care
			BUF_FWD_C   <= '0';  -- NO forwarding.
			
			
		ELSIF (CLK'EVENT AND CLK='1') THEN
	
			BUF_OP_WB   <= OP_MEM_WB(3 DOWNTO 0); -- MEMOP & WB
			BUF_OP_MEM  <= OP_MEM_WB(4 DOWNTO 1); -- MEMU  & MEMOP
			BUF_RD_ADDR <= I_RD_ADDR;
			BUF_RS2_VAL <= I_RS2_VAL;
			BUF_ALU_RES <= I_ALU_RES;
			BUF_FWD_c   <= I_FWD_C;
			
		END IF;
		
	END PROCESS;
	
	OP_WB 	  <= BUF_OP_WB;
	OP_MEM	  <= BUF_OP_MEM;
	O_RD_ADDR <= BUF_RD_ADDR;
	O_RS2_VAL <= BUF_RS2_VAL;
	O_ALU_RES <= BUF_ALU_RES;
	O_FWD_C   <= BUF_FWD_C;
	
END BEHAVIORAL;
	
			