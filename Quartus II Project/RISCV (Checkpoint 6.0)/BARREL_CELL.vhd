-- This is actually a 3 to 1 Multiplexer which will be used
-- as a structural component in ALU's Barrel Shifter. 
-- SELECT(0) is for the first mux
-- SELECT(1) is for the second mux

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY BARREL_CELL IS
				
	PORT (
			D0    : IN  STD_LOGIC;
			D1    : IN  STD_LOGIC;
			D2    : IN  STD_LOGIC;
			SEL   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			O     : OUT STD_LOGIC
		 );

END BARREL_CELL;

ARCHITECTURE STRUCTURAL OF BARREL_CELL IS
			
	SIGNAL BUF_A : STD_LOGIC;
	SIGNAL BUF_B : STD_LOGIC;
	
	BEGIN

		MUX2X1_A : MUX2X1_BIT
				   PORT    MAP ( 
								 D0  => D0,
								 D1  => D1,
								 SEL => SEL(0),
								 O   => BUF_A
								);
								
		MUX2X1_B : MUX2X1_BIT
				   PORT    MAP (
								 D0  => BUF_A,
								 D1  => D2,
								 SEL => SEL(1),
								 O   => BUF_B
								);
		
		O <= BUF_B;
		
END STRUCTURAL;
	
