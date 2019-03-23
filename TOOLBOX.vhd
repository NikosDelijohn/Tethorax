-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+

-- *** MAIN PACKAGE FILE ***
----------------------------------------------------------------
-- Usage: LIBRARY WORK; USE WORK.TOOLBOX.ALL;
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE TOOLBOX IS
-------------------------------------------------------------------------	
-- [0] GENERAL PURPOSE COMPONENTS
-------------------------------------------------------------------------
	-- Defined @ "MUX2X1.vhd" file.
	COMPONENT MUX2X1 IS

		GENERIC ( INSIZE : INTEGER := 10 );
	
		PORT (
				D0  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D1  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
			    SEL : IN  STD_LOGIC;
				O   : OUT STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0)
			 );

	END COMPONENT MUX2X1;
	
-------------------------------------------------------------------------
	-- Defined @ "MUX2X1_BIT.vhd" file.
	COMPONENT MUX2X1_BIT IS

		PORT ( 
				D0  : IN  STD_LOGIC;
				D1  : IN  STD_LOGIC;
				SEL : IN  STD_LOGIC;
				O   : OUT STD_LOGIC
			 );
		 
	END COMPONENT MUX2X1_BIT;
-------------------------------------------------------------------------
	-- Defined @ "MUX4X1.vhd" file.
	COMPONENT MUX4X1 IS 
		
		GENERIC ( INSIZE : INTEGER := 10 );
		
		PORT (	
				D0  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D1  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D2  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D3  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				
				SEL : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			 
				O : OUT STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0)
			 );

	END COMPONENT MUX4X1;
-------------------------------------------------------------------------
	-- Defined @ "MUX8X1.vhd" file.
	COMPONENT MUX8X1 IS 

		GENERIC ( INSIZE : INTEGER := 10 );
		
		PORT (	
				D0  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D1  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D2  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D3  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D4  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D5  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D6  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D7  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				
				SEL : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 
				O : OUT STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0)
			 );

	END COMPONENT MUX8X1;
	
-------------------------------------------------------------------------
	-- Defined @ "MUX32X1.vhd" file.
	COMPONENT MUX32X1 IS

		GENERIC ( INSIZE : INTEGER := 10 );
		
		PORT (
		
				 D0: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D1: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D2: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D3: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D4: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D5: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D6: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D7: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D8: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D9: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D10: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D11: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D12: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D13: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D14: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D15: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D16: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D17: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D18: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D19: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D20: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D21: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D22: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D23: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D24: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D25: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D26: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D27: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D28: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D29: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D30: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D31: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				
				SEL: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
				
				O  : OUT STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0)
			);
			
	END COMPONENT MUX32X1;
	
-------------------------------------------------------------------------
	-- Defined @ "ADDER_2B.vhd" file.
	COMPONENT ADDER_2B IS
			
		PORT ( 
				A  : IN STD_LOGIC;
				B  : IN STD_LOGIC;
				CI : IN STD_LOGIC;
				S  : OUT STD_LOGIC;
				CO : OUT STD_LOGIC 
			 );

	END COMPONENT ADDER_2B;
-------------------------------------------------------------------------
	-- Defined @ "DEC5X32.vhd" file.
	COMPONENT DEC5X32 IS 

		PORT (
				SEL : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
				RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );
			 
	END COMPONENT DEC5X32;	
-------------------------------------------------------------------------
-- [1] INSTRUCTION FETCH COMPONENTS 
----------------------------------+--------------------------------------
	-- Defined @ "I_F_RAM.vhd" file. 
	COMPONENT I_F_RAM IS
	
			PORT
				(
					address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
					clock		: IN STD_LOGIC  := '1';
					data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
					wren		: IN STD_LOGIC ;
					q		    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
				);
				
	END COMPONENT I_F_RAM;
-------------------------------------------------------------------------
-- [2] INSTRUCTION DECODE COMPONENTS
-------------------------------------------------------------------------
	-- Defined @ "REG_FLIPPER.vhd" file.
	COMPONENT REG_FLIPPER IS

		PORT (
				IF_WORD : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				FLIP    : OUT STD_LOGIC
			 );
			 
	END COMPONENT REG_FLIPPER;
	
-------------------------------------------------------------------------
	-- Defined @ "ID_DECODER.vhd" file.
	COMPONENT ID_DECODER IS

		GENERIC ( CTRL_WORD_SIZE : INTEGER := 20 );
	
		PORT(
				MUX_2X1_SEL  : IN  STD_LOGIC;                    
				MUX_8X1_SEL  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				MUX_32X1_SEL : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); 
				CONTROL_WORD : OUT STD_LOGIC_VECTOR(CTRL_WORD_SIZE-1 DOWNTO 0)
			);

	END COMPONENT ID_DECODER;
-------------------------------------------------------------------------
	-- Defined @ "ID_IMM_GENERATOR.vhd" file.
	COMPONENT ID_IMM_GENERATOR IS

		PORT(
				IMM_TYPE  : IN  STD_LOGIC_VECTOR(2  DOWNTO 0);
				IF_WORD   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				IMMEDIATE : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)	
			);
		 
	END COMPONENT ID_IMM_GENERATOR;
-------------------------------------------------------------------------	
	-- Defined @ "REG_32B_ZERO.vhd" file.
	COMPONENT REG_32B_ZERO IS

		PORT(
				CLK   : IN  STD_LOGIC;
				Q_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			);

	END COMPONENT REG_32B_ZERO;
-------------------------------------------------------------------------	
	-- Defined @ "REG_32B_CASUAL.vhd" file.
	COMPONENT REG_32B_CASUAL IS

		PORT(
				LOAD, CLK, RST : IN  STD_LOGIC;
				DATA		   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				Q_OUT 		   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			);

	END COMPONENT REG_32B_CASUAL;
-------------------------------------------------------------------------		
	-- Defined @ "REGISTER_FILE.vhd" file.
	COMPONENT REGISTER_FILE IS 

		PORT ( 
				CLK,RST  : IN  STD_LOGIC;
				LOAD_REG : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				DATA_IN  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				ADDR_RS1 : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
				ADDR_RS2 : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
				DATA_RS1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				DATA_RS2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );
			 
	END COMPONENT REGISTER_FILE;
-------------------------------------------------------------------------
	-- Defined @ "ID_ADDER.vhd" file
	COMPONENT ID_ADDER IS
	
		 PORT (
				PC_VALUE  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				IMMEDIATE : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				OUTPUT 	  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			  );
		 
	END COMPONENT ID_ADDER;

-------------------------------------------------------------------------
	-- Defined @ "STALL_FWD_PREDICT.vhd" file.
	COMPONENT STALL_FWD_PREDICT IS

		PORT( 
				RS1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
				RS2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
				RD_E : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
				RD_M : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
				
				LOAD_IN_EXE : IN  STD_LOGIC; 
				LOAD_IN_MEM : IN  STD_LOGIC; 
				
			
				IMGEN : IN STD_LOGIC_VECTOR(2 DOWNTO  0);
				BRANCH: IN STD_LOGIC;
				
				STALL: OUT STD_LOGIC;
				FWDA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				FWDB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); 
				FWDC : OUT STD_LOGIC                     
			);

	END COMPONENT STALL_FWD_PREDICT;
-------------------------------------------------------------------------

	-- Defined @ "I_D.vhd" file
	COMPONENT I_D
		GENERIC ( CTRL_WORD_TOTAL : INTEGER := 20 ; CTRL_WORD_OUT : INTEGER := 18);
		PORT 	( 	
					CLK,RST    : IN  STD_LOGIC;						
					WB_RD_LOAD : IN  STD_LOGIC_VECTOR(4  DOWNTO 0); 
					WB_RD_DATA : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  	
					PC_VALUE   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
					IF_WORD    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 

					RS1_VALUE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
					RS2_VALUE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
					RD_ADDR    : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
					IMMEDIATE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
					TARGET_AD  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
					PC_VALUE_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
					CTRL_WORD  : OUT STD_LOGIC_VECTOR(CTRL_WORD_OUT-1  DOWNTO 0)
				);

	END COMPONENT I_D;	
-------------------------------------------------------------------------	
-- [3] EXE - ALU COMPONENTS
-------------------------------------------------------------------------
	-- Defined @ "BARREL_CELL.vhd" file.
	COMPONENT BARREL_CELL IS
	
		PORT (
				D0    : IN  STD_LOGIC;
				D1    : IN  STD_LOGIC;
				D2    : IN  STD_LOGIC;
				SEL   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				O     : OUT STD_LOGIC
			 );

	END COMPONENT BARREL_CELL;
-------------------------------------------------------------------------
	-- Defined @ "BARREL_SHIFTER.vhd" file.
	COMPONENT BARREL_SHIFTER IS
	
		PORT (
				VALUE_A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				SHAMT_B : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
				OPCODE  : IN  STD_LOGIC_VECTOR(1  DOWNTO 0); 
				RESULT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );
		 
	END COMPONENT BARREL_SHIFTER;
-------------------------------------------------------------------------
	-- Defined @ "EXE_LOGIC_MODULE.vhd" file.
	COMPONENT EXE_LOGIC_MODULE IS 
	
		PORT (
				A   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				B   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				OP  : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
				RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );
			 
	END COMPONENT EXE_LOGIC_MODULE;
-------------------------------------------------------------------------
	-- Defined @ "EXE_ADDER_SUBBER_CELL.vhd" file.
	COMPONENT EXE_ADDER_SUBBER_CELL IS

		PORT (
		    	A  : IN  STD_LOGIC; 
			    B  : IN  STD_LOGIC;
				CI : IN  STD_LOGIC;
				OP : IN  STD_LOGIC;
				S  : OUT STD_LOGIC;
				CO : OUT STD_LOGIC
			 );
		 
	END COMPONENT EXE_ADDER_SUBBER_CELL;
-------------------------------------------------------------------------
	-- Defined @ "EXE_ADDER_SUBBER.vhd" file.
	COMPONENT EXE_ADDER_SUBBER IS 

		PORT (
				A  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
				B  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
				OP : IN  STD_LOGIC; -- OPCODE [0: ADD / 1: SUB]
				S  : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
			 );
			 
	END COMPONENT EXE_ADDER_SUBBER;
-------------------------------------------------------------------------
	-- Defined @ "EXE_BRANCH_RESOLVE.vhd" file.
	COMPONENT EXE_BRANCH_RESOLVE IS 
		
		PORT( 
				RES  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
				EQLT : IN  STD_LOGIC;
				INV  : IN  STD_LOGIC;
				T_NT : OUT STD_LOGIC
			);

	END COMPONENT EXE_BRANCH_RESOLVE;
-------------------------------------------------------------------------
	-- Defined @ "EXE_SLT_MODULE.vhd" file.
	COMPONENT EXE_SLT_MODULE IS

		PORT ( 
				INPUT : IN  STD_LOGIC;
				OUTPUT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );

	END COMPONENT EXE_SLT_MODULE;
-------------------------------------------------------------------------
-- [4] MEM 
-------------------------------------------------------------------------
	-- Defined @ "MEM_DATAMEM.vhd" file.
	COMPONENT MEM_DATAMEM IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			byteena		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT MEM_DATAMEM;
-------------------------------------------------------------------------
	-- Defined @ "MEM_BYTE_ENABLE.vhd" file.
	COMPONENT MEM_BYTE_ENABLE IS

		PORT(
				OPCODE : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				BYTEEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
			);

	END COMPONENT MEM_BYTE_ENABLE;	
-------------------------------------------------------------------------
	-- Defined @ "MEM_BYTE_EN_MSBS.vhd" file.
	COMPONENT MEM_BYTE_EN_MSBS IS

		PORT ( 
				U        : IN  STD_LOGIC;
				MEM_VALUE: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				BYTE_ENA : IN  STD_LOGIC_VECTOR(1  DOWNTO 0);
				RES      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)			
			 );

	END COMPONENT MEM_BYTE_EN_MSBS;
-------------------------------------------------------------------------
	-- Defined @ "MEM.vhd" file.
	COMPONENT MEM IS

		PORT (
				CLK    : IN  STD_LOGIC;
				OP     : IN  STD_LOGIC_VECTOR(3  DOWNTO 0);
				WR_ADR : IN  STD_LOGIC_VECTOR(6  DOWNTO 0);
				WR_DAT : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				
				MEM_RES: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );
			 
	END COMPONENT MEM;
-------------------------------------------------------------------------
-- [5] WB
-------------------------------------------------------------------------
	-- Defined @ "WB.vhd" file.
	COMPONENT WB IS

		PORT (
				WB_OP : IN  STD_LOGIC;
				WB_ADR: IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
				WB_DAT: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				
				RD_ADR: OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
				RD_DAT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );

	END COMPONENT WB;
-------------------------------------------------------------------------
-- [6] COMPONENT CONTROL (REGS,LOGIC etc,)
-------------------------------------------------------------------------
	-- Defined @ "DECODE_TO_EXECUTE.vhd" file.
	COMPONENT DECODE_TO_EXECUTE IS 

		PORT ( 
				RS1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				RS2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				PC_I : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				IMME : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				
				JALR : IN  STD_LOGIC;
				JUMP : IN  STD_LOGIC;
				BRAN : IN  STD_LOGIC;
				PC   : IN  STD_LOGIC;
				IMM  : IN  STD_LOGIC;
				
				A    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				B    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );
			 
	END COMPONENT DECODE_TO_EXECUTE;
-------------------------------------------------------------------------
	-- Defined @ "PC_PLUS_4.vhd" file.
	COMPONENT PC_PLUS_4 IS

		PORT (
				PC : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				RES: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			 );

	END COMPONENT PC_PLUS_4;
-------------------------------------------------------------------------

END PACKAGE TOOLBOX;