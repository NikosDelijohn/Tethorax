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
-- ================== INSTRUCTION FETCH COMPONENTS ================== --
------------------------------------------------------------------------
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
-- ================== INSTRUCTION DECODE COMPONENTS ================== --
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
	-- Defined @ "MUX8X1.vhd" file.
	COMPONENT MUX8X1 IS 

		GENERIC ( INSIZE : INTEGER := 10 );
		
		PORT (	
				D0  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D1  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D2  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D3  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D4  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D5  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D6  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D7  : IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				
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
				 D1: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				 D2: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				 D3: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				 D4: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D5: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D6: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				 D7: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				 D8: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				 D9: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D10: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D11: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D12: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D13: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D14: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D15: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D16: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D17: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D18: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D19: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D20: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D21: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D22: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D23: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D24: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D25: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D26: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D27: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0);
				D28: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D29: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D30: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				D31: IN  STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0) := NULL;
				
				SEL: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
				
				O  : OUT STD_LOGIC_VECTOR(INSIZE-1 DOWNTO 0)
			);
			
	END COMPONENT MUX32X1;
	
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

		GENERIC ( CTRL_WORD_SIZE : INTEGER := 18 );
	
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
				ADDR_RS2 : IN  STD_LOGIC_VECTOR(4  DOWNTO 0) := NULL;
				DATA_RS1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				DATA_RS2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := NULL
			 );
			 
	END COMPONENT REGISTER_FILE;
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
	-- Defined @ "ID_ADDER.vhd" file
	COMPONENT ID_ADDER IS
	
		 PORT (
				PC_VALUE  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				IMMEDIATE : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
				OUTPUT 	  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			  );
		 
	END COMPONENT ID_ADDER;
-------------------------------------------------------------------------
	-- Defined @ "I_D.vhd" file
	COMPONENT I_D
		GENERIC ( CTRL_WORD_TOTAL : INTEGER := 18 ; CTRL_WORD_OUT : INTEGER := 14);
		PORT 	( 	
					CLK,RST    : IN  STD_LOGIC;						
					WB_RD_LOAD : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
					WB_RD_DATA : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  	
					PC_VALUE   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
					IF_WORD    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 

					RS1_VALUE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
					RS2_VALUE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
					RD_ADDR    : OUT STD_LOGIC_VECTOR(4  DOWNTO 0);
					IMMEDIATE  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
					TARGET_AD  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
					PC_VALUE_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
					CTRL_WORD  : OUT STD_LOGIC_VECTOR(CTRL_WORD_OUT-1  DOWNTO 0);
					JALR_CASE  : OUT STD_LOGIC
				);

	END COMPONENT I_D;	
-------------------------------------------------------------------------

END PACKAGE TOOLBOX;