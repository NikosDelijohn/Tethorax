-- +===========================================================+
-- |		RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos			       |
-- |supervisor: Aristides Efthymiou			       |
-- |===========================================================|
-- |		UNIVERSITY OF IOANNINA - 2019      	       |
-- |  		     VCAS LABORATORY			       |
-- +===========================================================+


-- *** 2/5: INSTRUCTION DECODE (ID) MODULE DESIGN ***
------------------------------------------------------------
-- PART#2: IMMEDIATE GENERATION
-- " With all the needed information from the DECODER
--   this module can now generate a 32-bit (XLEN) immediate
--   with bits and bytes from the memory fetched word.
--   Note that immediates are of type I/S/J/B/U. The 
--   selection is described in the following matrix:
--
--  	*-------------------------------------------*
--	| CTRL_WORD [3 MSBs]  ||  TYPE OF IMMEDIATE |
--  	|-------------------------------------------| 
--  	|       000           ||        I           |
--  	|       001           ||        S           |
--  	|       010           ||        B           |
--  	|       011           ||        U           |
--  	|       100           ||        J           |
--  	*-------------------------------------------*
--
--   3 Bits are required since we have 5 different types. "
------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ID_IMM_GENERATOR IS

	PORT(
		IMM_TYPE  : IN  STD_LOGIC_VECTOR(2  DOWNTO 0);
		IF_WORD   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		IMMEDIATE : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)	
	    );
		 
END ID_IMM_GENERATOR;

ARCHITECTURE RTL OF ID_IMM_GENERATOR IS
	
	SIGNAL RES : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
	
	INIT: PROCESS(IMM_TYPE,IF_WORD)

	BEGIN 
	
		CASE IMM_TYPE IS
			
			--     I
			WHEN "000" => 	RES(31 DOWNTO 11) <= (OTHERS => IF_WORD(31)); 
				 	RES(10 DOWNTO  5) <= IF_WORD(30 DOWNTO 25);
					RES(4  DOWNTO  1) <= IF_WORD(24 DOWNTO 21);
					RES(0)		  <= IF_WORD(20);
			--     S
			WHEN "001" => 	RES(31 DOWNTO 11) <= (OTHERS => IF_WORD(31));
					RES(10 DOWNTO  5) <= IF_WORD(30 DOWNTO 25);
					RES(4  DOWNTO  1) <= IF_WORD(11 DOWNTO  8);
					RES(0) 		  <= IF_WORD(7);
			--     B			  
			WHEN "010" => 	RES(31 DOWNTO 12) <= (OTHERS => IF_WORD(31));
					RES(11)		  <= IF_WORD(7);
					RES(10 DOWNTO  5) <= IF_WORD(30 DOWNTO 25);
					RES(4  DOWNTO  1) <= IF_WORD(11 DOWNTO  8);
					RES(0)		  <= '0';
			--     U
			WHEN "011" => 	RES(31)		  <= IF_WORD(31);
				        RES(30 DOWNTO 20) <= IF_WORD(30 DOWNTO 20);
					RES(19 DOWNTO 12) <= IF_WORD(19 DOWNTO 12);
					RES(11 DOWNTO  0) <= (OTHERS => '0');
			--     J
			WHEN "100" => 	RES(31 DOWNTO 20) <= (OTHERS => IF_WORD(31));
					RES(19 DOWNTO 12) <= IF_WORD(19 DOWNTO 12);
					RES(11)		  <= IF_WORD(20);
					RES(10 DOWNTO  5) <= IF_WORD(30 DOWNTO 25);
					RES(4  DOWNTO  1) <= IF_WORD(24 DOWNTO 21);
					RES(0)		  <= '0';
			
			WHEN OTHERS => RES <= (OTHERS => 'X');
			
		END CASE;
		
	END PROCESS;
	
	IMMEDIATE <= RES;
	
END RTL;